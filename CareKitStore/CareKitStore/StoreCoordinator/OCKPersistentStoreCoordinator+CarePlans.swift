/*
 Copyright (c) 2016-2025, Apple Inc. All rights reserved.
 
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

import Foundation

extension OCKStoreCoordinator {

    public func anyCarePlans(matching query: OCKCarePlanQuery) -> CareStoreQueryResults<OCKAnyCarePlan> {

        let stores = readOnlyPlanStores + planStores

        let relevantStores = stores.filter {
            carePlanStore($0, shouldHandleQuery: query)
        }

        let carePlansStreams = relevantStores.map {
            $0.anyCarePlans(matching: query)
        }

        let sortDescriptors = query
            .sortDescriptors
            .map(\.nsSortDescriptor)

        let carePlans = combineMany(
            sequences: carePlansStreams,
            sortingElementsUsing: sortDescriptors
        )

        return carePlans
    }

    public func fetchAnyCarePlans(
        query: OCKCarePlanQuery,
        callbackQueue: DispatchQueue = .main,
        completion: @escaping (Result<[OCKAnyCarePlan], OCKStoreError>) -> Void
    ) {
        let readableStores = readOnlyPlanStores + planStores
        let respondingStores = readableStores.filter { carePlanStore($0, shouldHandleQuery: query) }
        let closures = respondingStores.map({ store in { done in
            store.fetchAnyCarePlans(query: query, callbackQueue: callbackQueue, completion: done) }
        })
        aggregateAndFlatten(closures, callbackQueue: callbackQueue, completion: completion)
    }

    public func addAnyCarePlans(
        _ plans: [OCKAnyCarePlan],
        callbackQueue: DispatchQueue = .main,
        completion: ((Result<[OCKAnyCarePlan], OCKStoreError>) -> Void)? = nil
    ) {
        do {
            try findStore(forCarePlans: plans).addAnyCarePlans(plans, callbackQueue: callbackQueue, completion: completion)
        } catch {
            callbackQueue.async {
                completion?(.failure(.addFailed(
                    reason: "Failed to find store accepting care plans. Error: \(error.localizedDescription)")))
            }
        }
    }

    public func updateAnyCarePlans(
        _ plans: [OCKAnyCarePlan],
        callbackQueue: DispatchQueue = .main,
        completion: ((Result<[OCKAnyCarePlan], OCKStoreError>) -> Void)? = nil
    ) {
        do {
            try findStore(forCarePlans: plans).updateAnyCarePlans(plans, callbackQueue: callbackQueue, completion: completion)
        } catch {
            callbackQueue.async {
                completion?(.failure(.updateFailed(
                    reason: "Failed to find store accepting care plans. Error: \(error.localizedDescription)")))
            }
        }
    }

    public func deleteAnyCarePlans(
        _ plans: [OCKAnyCarePlan],
        callbackQueue: DispatchQueue = .main,
        completion: ((Result<[OCKAnyCarePlan], OCKStoreError>) -> Void)? = nil
    ) {
        do {
            try findStore(forCarePlans: plans).deleteAnyCarePlans(plans, callbackQueue: callbackQueue, completion: completion)
        } catch {
            callbackQueue.async {
                completion?(.failure(.deleteFailed(
                    reason: "Failed to find store accepting care plans. Error: \(error.localizedDescription)")))
            }
        }
    }

    private func findStore(forCarePlans plans: [OCKAnyCarePlan]) throws -> OCKAnyCarePlanStore {
        let matchingStores = plans.compactMap { plan in planStores.first(where: { carePlanStore($0, shouldHandleWritingCarePlan: plan) }) }
        guard matchingStores.count == plans.count else { throw OCKStoreError.invalidValue(reason: "No store could be found for some plans.") }
        guard let store = matchingStores.first else { throw OCKStoreError.invalidValue(reason: "No store could be found for any plans.") }
        guard matchingStores.allSatisfy({ $0 === store }) else { throw OCKStoreError.invalidValue(reason: "Not all plans belong to same store.") }
        return store
    }
}
