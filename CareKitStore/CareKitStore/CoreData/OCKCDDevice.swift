//
/*
 Copyright (c) 2025, Apple Inc. All rights reserved.
 
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

@objc(OCKCDDevice)
class OCKCDDevice: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var manufacturer: String?
    @NSManaged var model: String?
    @NSManaged var hardwareVersion: String?
    @NSManaged var firmwareVersion: String?
    @NSManaged var softwareVersion: String?
    @NSManaged var localIdentifier: String?
    @NSManaged var udiDeviceIdentifier: String?

    convenience init(device: OCKDevice, context: NSManagedObjectContext) {
        self.init(entity: Self.entity(), insertInto: context)
        name = device.name
        manufacturer = device.manufacturer
        model = device.model
        hardwareVersion = device.hardwareVersion
        firmwareVersion = device.firmwareVersion
        softwareVersion = device.softwareVersion
        localIdentifier = device.localIdentifier
        udiDeviceIdentifier = device.udiDeviceIdentifier
    }

    func makeValue() -> OCKDevice {

        var device = OCKDevice()
        self.managedObjectContext!.performAndWait {
            device.name = name
            device.manufacturer = manufacturer
            device.model = model
            device.hardwareVersion = hardwareVersion
            device.firmwareVersion = firmwareVersion
            device.softwareVersion = softwareVersion
            device.localIdentifier = localIdentifier
            device.udiDeviceIdentifier = udiDeviceIdentifier
        }

        return device
    }
}
