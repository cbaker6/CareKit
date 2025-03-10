/*
 Copyright (c) 2021, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3. Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import CoreData
import Foundation


class OCKStoreMigration2_1To3_0Policy: NSEntityMigrationPolicy {

    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager) throws {

        let dInstance = NSEntityDescription.insertNewObject(
            forEntityName: sInstance.entity.name!,
            into: manager.destinationContext
        )

        // This allows us to look up the destination instance using
        // the source instance during the relationship establishment
        // phase later on.
        manager.associate(
            sourceInstance: sInstance,
            withDestinationInstance: dInstance,
            for: mapping
        )

        // Copy all the primitive attributes from the source to the destination.
        // Almost all of the attributes have the same names. Note that this does
        // not capture any relationships - we have to tackle that separately.
        for key in sInstance.entity.attributesByName.keys {

            // Update the schema version to 3.0.0
            if key == "schemaVersion" {
                dInstance.setValue("3.0.0", forKey: key)
                continue
            }

            // OCKCDHealthKitLinkage's `quantityIdentifier` was renamed to `sampleIdentifier`.
            if sInstance.entity.name == "OCKCDHealthKitLinkage" && key == "quantityIdentifier" {

                let quantityIdentifier = sInstance.value(forKey: key) as! String
                dInstance.setValue(quantityIdentifier, forKey: "sampleIdentifier")

            } else {

                let value = sInstance.value(forKey: key)
                dInstance.setValue(value, forKey: key)
            }
        }
    }

    override func createRelationships(
        forDestination dInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager) throws {

        // Now we can deal with all of the relationships. Note that we can't
        // copy relationships over the same way that we did primitives. We need
        // to look up the corresponding related objects in the destination and
        // link them.
        let sInstance = manager.sourceInstances(
            forEntityMappingName: mapping.name,
            destinationInstances: [dInstance]
        ).first!

        // Add a set of knowledge elements to each entity
        let clock: NSManagedObject
        let request = NSFetchRequest<NSManagedObject>(entityName: "OCKCDClock")
        if let fetched = try manager.destinationContext.fetch(request).first {
            clock = fetched
        } else {
            let uuid = UUID()
            clock = NSEntityDescription.insertNewObject(
                forEntityName: "OCKCDClock",
                into: manager.destinationContext)
            clock.setValue([uuid: 1], forKey: "vectorClock")
            clock.setValue(uuid, forKey: "uuid")
        }
        let uuid = clock.value(forKey: "uuid") as! UUID
        let element = NSEntityDescription.insertNewObject(
            forEntityName: "OCKCDKnowledgeElement",
            into: manager.destinationContext)
        element.setValue(1, forKey: "time")
        element.setValue(uuid, forKey: "uuid")

        dInstance.setValue(Set([element]), forKey: "knowledge")

        for (key, relationship) in sInstance.entity.relationshipsByName {

            guard let sValue = sInstance.value(forKey: key) else {
                continue
            }

            let relationEntity = "\(relationship.destinationEntity!.name!)"
            let relationMapping = "\(relationEntity)To\(relationEntity)"

            if relationship.isToMany {
                let sRelations = sValue as! Set<NSManagedObject>
                let dRelations = manager.destinationInstances(
                    forEntityMappingName: relationMapping,
                    sourceInstances: Array(sRelations)
                )
                dInstance.setValue(Set(dRelations), forKey: key)
            } else {
                let sRelation = sValue as! NSManagedObject
                let dRelation = manager.destinationInstances(
                    forEntityMappingName: relationMapping,
                    sourceInstances: [sRelation]
                ).first!
                dInstance.setValue(dRelation, forKey: key)
            }
        }
    }
}

