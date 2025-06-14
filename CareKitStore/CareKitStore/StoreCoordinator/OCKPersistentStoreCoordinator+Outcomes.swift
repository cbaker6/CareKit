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

    public func anyOutcomes(matching query: OCKOutcomeQuery) -> CareStoreQueryResults<OCKAnyOutcome> {

        let stores = readOnlyEventStores + eventStores

        let relevantStores = stores.filter {
            outcomeStore($0, shouldHandleQuery: query)
        }

        let outcomesStreams = relevantStores.map {
            $0.anyOutcomes(matching: query)
        }

        let sortDescriptor = NSSortDescriptor(
            keyPath: \OCKCDOutcome.id,
            ascending: true
        )

        let outcomes = combineMany(
            sequences: outcomesStreams,
            sortingElementsUsing: [sortDescriptor]
        )

        return outcomes
    }

    public func fetchAnyOutcomes(
        query: OCKOutcomeQuery,
        callbackQueue: DispatchQueue = .main,
        completion: @escaping (Result<[OCKAnyOutcome], OCKStoreError>) -> Void
    ) {
        let readableStores = readOnlyEventStores + eventStores
        let respondingStores = readableStores.filter { outcomeStore($0, shouldHandleQuery: query) }
        let closures = respondingStores.map({ store in { done in
            store.fetchAnyOutcomes(query: query, callbackQueue: callbackQueue, completion: done) }
        })
        aggregateAndFlatten(closures, callbackQueue: callbackQueue, completion: completion)
    }

    public func addAnyOutcomes(
        _ outcomes: [OCKAnyOutcome],
        callbackQueue: DispatchQueue = .main,
        completion: ((Result<[OCKAnyOutcome], OCKStoreError>) -> Void)? = nil
    ) {
        do {
            try findStore(forOutcomes: outcomes).addAnyOutcomes(outcomes, callbackQueue: callbackQueue, completion: completion)
        } catch {
            callbackQueue.async {
                completion?(.failure(.addFailed(
                    reason: "Failed to find store accepting outcomes. Error: \(error.localizedDescription)")))
            }
        }
    }

    public func updateAnyOutcomes(
        _ outcomes: [OCKAnyOutcome],
        callbackQueue: DispatchQueue = .main,
        completion: ((Result<[OCKAnyOutcome], OCKStoreError>) -> Void)? = nil
    ) {
        do {
            try findStore(forOutcomes: outcomes).updateAnyOutcomes(outcomes, callbackQueue: callbackQueue, completion: completion)
        } catch {
            callbackQueue.async {
                completion?(.failure(.updateFailed(
                    reason: "Failed to find store accepting outcomes. Error: \(error.localizedDescription)")))
            }
        }
    }

    public func deleteAnyOutcomes(
        _ outcomes: [OCKAnyOutcome],
        callbackQueue: DispatchQueue = .main,
        completion: ((Result<[OCKAnyOutcome], OCKStoreError>) -> Void)? = nil
    ) {
        do {
            try findStore(forOutcomes: outcomes).deleteAnyOutcomes(outcomes, callbackQueue: callbackQueue, completion: completion)
        } catch {
            callbackQueue.async {
                completion?(.failure(.deleteFailed(
                    reason: "Failed to find store accepting outcomes. Error: \(error.localizedDescription)")))
            }
        }
    }

    private func findStore(forOutcomes outcomes: [OCKAnyOutcome]) throws -> OCKAnyOutcomeStore {
        let matchingStores = outcomes.compactMap { outcome in eventStores.first(where: { outcomeStore($0, shouldHandleWritingOutcome: outcome) }) }
        guard matchingStores.count == outcomes.count else { throw OCKStoreError.invalidValue(reason: "No store could be found for some outcomes.") }
        guard let store = matchingStores.first else { throw OCKStoreError.invalidValue(reason: "No store could be found for any outcomes.") }
        guard matchingStores.allSatisfy({ $0 === store }) else { throw OCKStoreError.invalidValue(reason: "Not all outcomes belong to same store.") }
        return store
    }
}
