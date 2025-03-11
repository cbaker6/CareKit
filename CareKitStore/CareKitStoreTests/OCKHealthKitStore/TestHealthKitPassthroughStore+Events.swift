/*
 Copyright (c) 2022, Apple Inc. All rights reserved.
 
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

@testable import CareKitStore

import AsyncAlgorithms
import HealthKit
import XCTest

// Note, we test the event stream and not the outcome stream because the outcome stream
// calls into the event stream. Testing the outcome stream is unnecessary.

@available(iOS 15, watchOS 8, *)
class TestHealthKitPassthroughStoreEvents: XCTestCase {

    private let cdStore = OCKStore(
        name: "TestEvents.Store",
        type: .inMemory
    )

    private lazy var passthroughStore = OCKHealthKitPassthroughStore(store: cdStore)

    override func setUpWithError() throws {
        try super.setUpWithError()
        try passthroughStore.reset()
    }

    // MARK: - Fetch Tests

    // Note: under the hood, the fetching logic uses the same business logic as the event stream.
    // There are pretty extensive tests for the event stream in this file, so we can lightly test
    // the fetch logic with some minor sanity checks.

    func testFetchEvents() throws {

        // Add tasks to the store

        let stepsTask = OCKHealthKitTask.makeDailyStepTask()
        let stepsQuantityIdentifier = try XCTUnwrap(stepsTask.healthKitLinkage.quantityIdentifier)
        let stepsUnit = try XCTUnwrap(stepsTask.healthKitLinkage.unit)
        let heartRateTask = OCKHealthKitTask.makeDailyHeartRateTask()
        let heartRateQuantityIdentifier = try XCTUnwrap(heartRateTask.healthKitLinkage.quantityIdentifier)
        let heartRateUnit = try XCTUnwrap(heartRateTask.healthKitLinkage.unit)
        let acneTask = try OCKHealthKitTask.makeDailyAcneTask()
        let acneCategoryIdentifier = try XCTUnwrap(acneTask.healthKitLinkage.categoryIdentifier)
        try passthroughStore.addTasksAndWait([stepsTask, heartRateTask, acneTask])

        // Generate samples that match the event date

        let steps: [Double] = [10, 20]

        let stepsSamples = steps.map {
            QuantitySample(
                id: UUID(),
                type: HKObjectType.quantityType(forIdentifier: stepsQuantityIdentifier)!,
                quantity: HKQuantity(unit: stepsUnit, doubleValue: $0),
                dateInterval: DateInterval(start: stepsTask.schedule[0].start, end: stepsTask.schedule[0].end)
            )
        }
        let heartRates: [Double] = [70, 80]
        let heartRateStart = heartRateTask.schedule[0].start
        let heartRateEnd = heartRateTask.schedule[0].end
        let heartRateDateInterval = DateInterval(start: heartRateStart, end: heartRateEnd)
        let heartRateSourceRevision = OCKSourceRevision(
            source: .init(
                name: "name",
                bundleIdentifier: "bundle"
            ),
            version: "version",
            productType: "productType",
            operatingSystemVersion: .init(
                majorVersion: 1,
                minorVersion: 0,
                patchVersion: 2
            )
        )
        let heartRateDevice = OCKDevice(
            name: "deviceName",
            manufacturer: "manufacturer",
            model: "model",
            hardwareVersion: "hardwareVersion",
            firmwareVersion: "firmwareVersion",
            softwareVersion: "softwareVersion",
            localIdentifier: "localIdentifier",
            udiDeviceIdentifier: "udiDeviceIdentifier"
        )
        let heartRateMetadata = ["key": "value"]
        let heartRateSamples = heartRates.map {
            QuantitySample(
                id: UUID(),
                type: HKObjectType.quantityType(forIdentifier: heartRateQuantityIdentifier)!,
                quantity: HKQuantity(unit: heartRateUnit, doubleValue: $0),
                dateInterval: heartRateDateInterval,
                sourceRevision: heartRateSourceRevision,
                device: heartRateDevice,
                metadata: heartRateMetadata
            )
        }
        let acne: [Int] = [3, 5]

        let acneSamples = acne.map {
            CategorySample(
                id: UUID(),
                type: HKObjectType.categoryType(forIdentifier: acneCategoryIdentifier)!,
                value: $0,
                dateInterval: DateInterval(start: acneTask.schedule[0].start, end: acneTask.schedule[0].end)
            )
        }

        let samples: [Sample] = stepsSamples + heartRateSamples + acneSamples

        // Fetch the events from the store

        let didFetchEvents = XCTestExpectation(description: "Fetched events")

        var result: Result<[OCKHealthKitPassthroughStore.Event], Error>!

        passthroughStore.fetchEvents(
            query: OCKTaskQuery(for: Date()),
            callbackQueue: .main,
            fetchSamples: { _, completion in
                completion(.success(samples))
            },
            updateCumulativeSumOfSamples: updateCumulativeSumOfSamples,
            completion: {
                result = $0
                didFetchEvents.fulfill()
            }
        )

        wait(for: [didFetchEvents], timeout: 2)

        let events = try result.get()
        XCTAssertEqual(events.count, 3)

        events.forEach { event in

            let outcomeValues = event.outcome?.values ?? []

            switch event.task.id {

            case stepsTask.id:
                XCTAssertEqual(outcomeValues.count, 1)
                XCTAssertEqual(outcomeValues.first?.doubleValue, -1)

            case heartRateTask.id:
                XCTAssertEqual(outcomeValues.count, 2)
                XCTAssertEqual(outcomeValues.first?.doubleValue, 70)
                XCTAssertEqual(outcomeValues.first?.dateInterval, heartRateDateInterval)
                XCTAssertEqual(outcomeValues.first?.sourceRevision, heartRateSourceRevision)
                XCTAssertEqual(outcomeValues.first?.device, heartRateDevice)
                XCTAssertEqual(outcomeValues.first?.metadata, heartRateMetadata)
                XCTAssertEqual(outcomeValues.last?.doubleValue, 80)
                XCTAssertEqual(outcomeValues.last?.dateInterval, heartRateDateInterval)
                XCTAssertEqual(outcomeValues.last?.sourceRevision, heartRateSourceRevision)
                XCTAssertEqual(outcomeValues.last?.device, heartRateDevice)
                XCTAssertEqual(outcomeValues.last?.metadata, heartRateMetadata)

            case acneTask.id:
                XCTAssertEqual(outcomeValues.count, 2)
                XCTAssertEqual(outcomeValues.first?.integerValue, 3)
                XCTAssertEqual(outcomeValues.last?.integerValue, 5)

            default:
                XCTFail("Unexpected task")
            }
        }
    }

    // MARK: - Stream Tests

    func testInitialResultIsEmpty() async throws {

        let noChanges: AsyncSyncSequence<[SampleChange]> = [SampleChange()].async

        let query = OCKTaskQuery()

        let events = passthroughStore.events(
            matching: query,
            applyingChanges: { _ in noChanges },
            updateCumulativeSumOfSamples: updateCumulativeSumOfSamples
        )

        let accumulatedEvents = try await accumulate(events, expectedCount: 1)

        let observedEvents = accumulatedEvents.map { events in
            events.map { Event($0) }
        }

        let expectedEvents: [[Event]] = [[]]

        XCTAssertEqual(expectedEvents, observedEvents)
    }

    func testCorrectTasksAreChecked() async throws {

        // Add tasks to the store

        let stepsTask = OCKHealthKitTask.makeDailyStepTask()
        let heartRateTask = OCKHealthKitTask.makeDailyHeartRateTask()
        _ = try await passthroughStore.addTasks([stepsTask, heartRateTask])

        // Create a task query that does not include either of the existing tasks
        let query = OCKTaskQuery(id: "irrelevantTask")

        let noChanges: AsyncSyncSequence<[SampleChange]> = [].async

        let events = passthroughStore.events(
            matching: query,
            applyingChanges: { _ in noChanges },
            updateCumulativeSumOfSamples: updateCumulativeSumOfSamples
        )

        let accumulatedEvents = try await accumulate(events, expectedCount: 1)

        let observedEvents = accumulatedEvents.map { events in
            events.map { Event($0) }
        }

        let expectedEvents: [[Event]] = [[]]

        XCTAssertEqual(expectedEvents, observedEvents)
    }

    func testEventsAreSortedByStartDateThenEffectiveDate() async throws {

        // Add tasks to the store.
        // Ensure there are two tasks whose events occur at the same time, to ensure they are then sorted stably.
        // This test will be a bit imperfect, because there is a chance that events just *happen* to turn out
        // sorted randomly, even if we don't explicitly sort them. Hopefully by adding enough tasks to the store,
        // we decrease the chance of that random success case

        let heartRateTask = OCKHealthKitTask.makeDailyHeartRateTask(startHour: 2)

        var weightTask = OCKHealthKitTask.makeDailyWeightTask(startHour: 2)
        weightTask.effectiveDate = heartRateTask.effectiveDate + 1

        let stepsTask = OCKHealthKitTask.makeDailyStepTask(startHour: 3)
        let oxygenSaturationTask = OCKHealthKitTask.makeDailyOxygenSaturationTask(startHour: 4)

        _ = try await passthroughStore.addTasks([heartRateTask, stepsTask, oxygenSaturationTask, weightTask])

        // Accumulate streamed results

        let queryInterval = DateInterval(
            start: weightTask.schedule[0].start,
            end: oxygenSaturationTask.schedule[2].end
        )

        let query = OCKTaskQuery(dateInterval: queryInterval)

        let noChanges: AsyncSyncSequence<[SampleChange]> = [].async

        let events = passthroughStore.events(
            matching: query,
            applyingChanges: { _ in noChanges },
            updateCumulativeSumOfSamples: updateCumulativeSumOfSamples
        )

        let accumulatedEvents = try await accumulate(events, expectedCount: 1)

        // Validate the result

        let observedEvents = accumulatedEvents.map { events in
            events.map { Event($0) }
        }

        let expectedEvents = [
            [
                Event(taskUUID: heartRateTask.uuid, scheduleEvent: heartRateTask.schedule[0]),
                Event(taskUUID: weightTask.uuid, scheduleEvent: weightTask.schedule[0]),
                Event(taskUUID: stepsTask.uuid, scheduleEvent: stepsTask.schedule[0]),
                Event(taskUUID: oxygenSaturationTask.uuid, scheduleEvent: oxygenSaturationTask.schedule[0]),

                Event(taskUUID: heartRateTask.uuid, scheduleEvent: heartRateTask.schedule[1]),
                Event(taskUUID: weightTask.uuid, scheduleEvent: weightTask.schedule[1]),
                Event(taskUUID: stepsTask.uuid, scheduleEvent: stepsTask.schedule[1]),
                Event(taskUUID: oxygenSaturationTask.uuid, scheduleEvent: oxygenSaturationTask.schedule[1]),

                Event(taskUUID: heartRateTask.uuid, scheduleEvent: heartRateTask.schedule[2]),
                Event(taskUUID: weightTask.uuid, scheduleEvent: weightTask.schedule[2]),
                Event(taskUUID: stepsTask.uuid, scheduleEvent: stepsTask.schedule[2]),
                Event(taskUUID: oxygenSaturationTask.uuid, scheduleEvent: oxygenSaturationTask.schedule[2])
            ]
        ]

        XCTAssertEqual(expectedEvents, observedEvents)
    }

    func testSamplesAreAppliedToOutcomesForMultipleTasks() async throws {

        // Add tasks to the store

        let stepsTask = OCKHealthKitTask.makeDailyStepTask(startHour: 0)
        let stepsQuantityIdentifier = try XCTUnwrap(stepsTask.healthKitLinkage.quantityIdentifier)
        let stepsUnit = try XCTUnwrap(stepsTask.healthKitLinkage.unit)
        let heartRateTask = OCKHealthKitTask.makeDailyHeartRateTask(startHour: 1)
        let heartRateQuantityIdentifier = try XCTUnwrap(heartRateTask.healthKitLinkage.quantityIdentifier)
        let heartRateUnit = try XCTUnwrap(heartRateTask.healthKitLinkage.unit)

        _ = try await passthroughStore.addTasks([stepsTask, heartRateTask])

        // Generate samples that match the event date

        let steps: [Double] = [10, 20]

        let stepsSamples = steps.map {
            QuantitySample(
                id: UUID(),
                type: HKObjectType.quantityType(forIdentifier: stepsQuantityIdentifier)!,
                quantity: HKQuantity(unit: stepsUnit, doubleValue: $0),
                dateInterval: DateInterval(start: stepsTask.schedule[0].start, end: stepsTask.schedule[0].end)
            )
        }

        let heartRates: [Double] = [70, 80]

        let heartRateSamples = heartRates.map {
            QuantitySample(
                id: UUID(),
                type: HKObjectType.quantityType(forIdentifier: heartRateQuantityIdentifier)!,
                quantity: HKQuantity(unit: heartRateUnit, doubleValue: $0),
                dateInterval: DateInterval(start: heartRateTask.schedule[0].start, end: heartRateTask.schedule[0].end)
            )
        }

        let samples = stepsSamples + heartRateSamples
        let sampleChange = SampleChange(addedSamples: samples)
        let sampleChanges = [sampleChange].async

        // Accumulate the streamed events

        let query = OCKTaskQuery()

        let events = passthroughStore.events(
            matching: query,
            applyingChanges: { _ in sampleChanges },
            updateCumulativeSumOfSamples: updateCumulativeSumOfSamples
        )

        let accumulatedEvents = try await accumulate(events, expectedCount: 2)

        // Validate the events

        let observedEvents = accumulatedEvents.map { events in
            events.map { Event($0) }
        }

        let expectedEvents = [
            // Initial events before the samples are applied
            [
                Event(
                    taskUUID: stepsTask.uuid,
                    scheduleEvent: stepsTask.schedule[0],
                    outcome: nil
                ),
                Event(
                    taskUUID: heartRateTask.uuid,
                    scheduleEvent: heartRateTask.schedule[0],
                    outcome: nil
                )
            ],
            // Events after the samples are applied
            [
                Event(
                    taskUUID: stepsTask.uuid,
                    scheduleEvent: stepsTask.schedule[0],
                    outcome: OCKHealthKitOutcome(
                        taskUUID: stepsTask.uuid,
                        taskOccurrenceIndex: 0,
                        values: [
                            // -1 indicates a stale cumulative sum. That's expected because we aren't actually going
                            // and fetching a cumulative sum from HK after we detect a change while unit testing
                            OCKOutcomeValue(-1.0, units: "count")
                        ],
                        isOwnedByApp: true,
                        healthKitUUIDs: [stepsSamples.map(\.id)]
                    )
                ),
                Event(
                    taskUUID: heartRateTask.uuid,
                    scheduleEvent: heartRateTask.schedule[0],
                    outcome: OCKHealthKitOutcome(
                        taskUUID: heartRateTask.uuid,
                        taskOccurrenceIndex: 0,
                        values: [
                            OCKOutcomeValue(70.0, units: "count/min"),
                            OCKOutcomeValue(80.0, units: "count/min")
                        ],
                        isOwnedByApp: true,
                        healthKitUUIDs: [
                            [heartRateSamples[0].id],
                            [heartRateSamples[1].id]
                        ]
                    )
                )
            ]
        ]

        XCTAssertEqual(expectedEvents, observedEvents)
    }

    func testSamplesAreAppliedToOutcomesAtBoundaries() async throws {

        // Add task to the store

        let heartRateTask = OCKHealthKitTask.makeDailyHeartRateTask()
        let heartRateQuantityIdentifier = try XCTUnwrap(heartRateTask.healthKitLinkage.quantityIdentifier)
        let heartRateUnit = try XCTUnwrap(heartRateTask.healthKitLinkage.unit)
        _ = try await passthroughStore.addTask(heartRateTask)

        // Generate samples that match the event date
        let samples = [

            // Intersects with the lower bound of the event
            QuantitySample(
                id: UUID(),
                type: HKObjectType.quantityType(forIdentifier: heartRateQuantityIdentifier)!,
                quantity: HKQuantity(unit: heartRateUnit, doubleValue: 1),
                dateInterval: DateInterval(start: heartRateTask.schedule[0].start - 1, end: heartRateTask.schedule[0].start)
            ),

            // Intersects with the upper bound of the event
            QuantitySample(
                id: UUID(),
                type: HKObjectType.quantityType(forIdentifier: heartRateQuantityIdentifier)!,
                quantity: HKQuantity(unit: heartRateUnit, doubleValue: 2),
                dateInterval: DateInterval(start: heartRateTask.schedule[0].end - 1, end: heartRateTask.schedule[0].end)
            ),

            // Misses the lower bound of the event
            QuantitySample(
                id: UUID(),
                type: HKObjectType.quantityType(forIdentifier: heartRateQuantityIdentifier)!,
                quantity: HKQuantity(unit: heartRateUnit, doubleValue: 3),
                dateInterval: DateInterval(start: heartRateTask.schedule[0].start - 2, end: heartRateTask.schedule[0].start - 1)
            ),

            // Misses the upper bound of the event
            QuantitySample(
                id: UUID(),
                type: HKObjectType.quantityType(forIdentifier: heartRateQuantityIdentifier)!,
                quantity: HKQuantity(unit: heartRateUnit, doubleValue: 4),
                dateInterval: DateInterval(start: heartRateTask.schedule[0].end, end: heartRateTask.schedule[0].end + 1)
            )
        ]

        let sampleChange = SampleChange(addedSamples: samples)
        let sampleChanges = [sampleChange].async

        // Accumulate the streamed events

        let query = OCKTaskQuery()

        let events = passthroughStore.events(
            matching: query,
            applyingChanges: { _ in sampleChanges },
            updateCumulativeSumOfSamples: updateCumulativeSumOfSamples
        )

        let accumulatedEvents = try await accumulate(events, expectedCount: 2)

        // Validate the events

        let observedEvents = accumulatedEvents.map { events in
            events.map { Event($0) }
        }

        let expectedEvents = [
            // Initial events before the samples are applied
            [
                Event(
                    taskUUID: heartRateTask.uuid,
                    scheduleEvent: heartRateTask.schedule[0],
                    outcome: nil
                )
            ],
            // Events after the samples are applied
            [
                Event(
                    taskUUID: heartRateTask.uuid,
                    scheduleEvent: heartRateTask.schedule[0],
                    outcome: OCKHealthKitOutcome(
                        taskUUID: heartRateTask.uuid,
                        taskOccurrenceIndex: 0,
                        values: [
                            OCKOutcomeValue(1.0, units: "count/min"),
                            OCKOutcomeValue(2.0, units: "count/min")
                        ],
                        isOwnedByApp: true,
                        healthKitUUIDs: [
                            [samples[0].id],
                            [samples[1].id]
                        ]
                    )
                )
            ]
        ]

        XCTAssertEqual(expectedEvents, observedEvents)
    }

    func testSampleIsAppliedToMultipleOutcomes() async throws {

        // Add tasks to the store

        let stepsTask = OCKHealthKitTask.makeDailyStepTask()
        let stepsQuantityIdentifier = try XCTUnwrap(stepsTask.healthKitLinkage.quantityIdentifier)
        let stepsUnit = try XCTUnwrap(stepsTask.healthKitLinkage.unit)
        _ = try await passthroughStore.addTask(stepsTask)

        // Generate samples that match the dates for two events

        let sample = QuantitySample(
            id: UUID(),
            type: HKObjectType.quantityType(forIdentifier: stepsQuantityIdentifier)!,
            quantity: HKQuantity(unit: stepsUnit, doubleValue: 10),
            dateInterval: DateInterval(start: stepsTask.schedule[0].start, end: stepsTask.schedule[1].end)
        )

        let sampleChange = SampleChange(addedSamples: [sample])
        let sampleChanges = [sampleChange].async

        // Accumulate the streamed events

        let queryInterval = DateInterval(
            start: stepsTask.schedule[0].start,
            end: stepsTask.schedule[1].end
        )

        let query = OCKTaskQuery(dateInterval: queryInterval)

        let events = passthroughStore.events(
            matching: query,
            applyingChanges: { _ in sampleChanges },
            updateCumulativeSumOfSamples: updateCumulativeSumOfSamples
        )

        let accumulatedEvents = try await accumulate(events, expectedCount: 2)

        // Validate the events

        let observedEvents = accumulatedEvents.map { events in
            events.map { Event($0) }
        }

        let expectedEvents = [
            // Initial events before the samples are applied
            [
                Event(
                    taskUUID: stepsTask.uuid,
                    scheduleEvent: stepsTask.schedule[0],
                    outcome: nil
                ),
                Event(
                    taskUUID: stepsTask.uuid,
                    scheduleEvent: stepsTask.schedule[1],
                    outcome: nil
                )
            ],
            // Events after the samples are applied
            [
                Event(
                    taskUUID: stepsTask.uuid,
                    scheduleEvent: stepsTask.schedule[0],
                    outcome: OCKHealthKitOutcome(
                        taskUUID: stepsTask.uuid,
                        taskOccurrenceIndex: 0,
                        values: [
                            OCKOutcomeValue(-1.0, units: "count")
                        ],
                        isOwnedByApp: true,
                        healthKitUUIDs: [[sample.id]]
                    )
                ),
                Event(
                    taskUUID: stepsTask.uuid,
                    scheduleEvent: stepsTask.schedule[1],
                    outcome: OCKHealthKitOutcome(
                        taskUUID: stepsTask.uuid,
                        taskOccurrenceIndex: 1,
                        values: [
                            OCKOutcomeValue(-1.0, units: "count")
                        ],
                        isOwnedByApp: true,
                        healthKitUUIDs: [[sample.id]]
                    )
                )
            ]
        ]

        XCTAssertEqual(expectedEvents, observedEvents)
    }

    // MARK: - Test Changes

    func testSampleChangesAreApplied() async throws {

        // Add tasks to the store

        let stepsTask = OCKHealthKitTask.makeDailyStepTask(startHour: 7)
        let stepsQuantityIdentifier = try XCTUnwrap(stepsTask.healthKitLinkage.quantityIdentifier)
        let stepsUnit = try XCTUnwrap(stepsTask.healthKitLinkage.unit)
        let weightTask = OCKHealthKitTask.makeDailyWeightTask(startHour: 8)
        let weightQuantityIdentifier = try XCTUnwrap(weightTask.healthKitLinkage.quantityIdentifier)
        let weightUnit = try XCTUnwrap(weightTask.healthKitLinkage.unit)
        _ = try await passthroughStore.addTasks([stepsTask, weightTask])

        // Generate samples that match the dates for two events

        let weightSampleUUID = UUID()

        let weightSample = QuantitySample(
            id: weightSampleUUID,
            type: HKObjectType.quantityType(forIdentifier: weightQuantityIdentifier)!,
            quantity: HKQuantity(unit: weightUnit, doubleValue: 70),
            dateInterval: DateInterval(start: weightTask.schedule[0].start, end: weightTask.schedule[1].end)
        )

        let stepsSampleUUID = UUID()

        let stepsSample = QuantitySample(
            id: stepsSampleUUID,
            type: HKObjectType.quantityType(forIdentifier: stepsQuantityIdentifier)!,
            quantity: HKQuantity(unit: stepsUnit, doubleValue: 10),
            dateInterval: DateInterval(start: stepsTask.schedule[0].start, end: stepsTask.schedule[1].end)
        )

        let sampleChanges = [
            SampleChange(addedSamples: [weightSample, stepsSample]),
            SampleChange(deletedIDs: [weightSampleUUID]),
            SampleChange(addedSamples: [weightSample]),
            SampleChange(deletedIDs: [stepsSampleUUID])
        ]
        .async

        // Accumulate the streamed events

        let query = OCKTaskQuery()

        let events = passthroughStore.events(
            matching: query,
            applyingChanges: { _ in sampleChanges },
            updateCumulativeSumOfSamples: updateCumulativeSumOfSamples
        )

        let accumulatedEvents = try await accumulate(events, expectedCount: 5)

        // Validate the events

        let observedEvents = accumulatedEvents.map { events in
            events.map { Event($0) }
        }

        let expectedEvents = [
            // Initial events before the samples are applied
            [
                Event(
                    taskUUID: stepsTask.uuid,
                    scheduleEvent: stepsTask.schedule[0],
                    outcome: nil
                ),
                Event(
                    taskUUID: weightTask.uuid,
                    scheduleEvent: weightTask.schedule[0],
                    outcome: nil
                )
            ],
            // Events after the samples have been applied
            [
                Event(
                    taskUUID: stepsTask.uuid,
                    scheduleEvent: stepsTask.schedule[0],
                    outcome: OCKHealthKitOutcome(
                        taskUUID: stepsTask.uuid,
                        taskOccurrenceIndex: 0,
                        values: [
                            OCKOutcomeValue(-1.0, units: "count")
                        ],
                        isOwnedByApp: true,
                        healthKitUUIDs: [[stepsSample.id]]
                    )
                ),
                Event(
                    taskUUID: weightTask.uuid,
                    scheduleEvent: weightTask.schedule[0],
                    outcome: OCKHealthKitOutcome(
                        taskUUID: weightTask.uuid,
                        taskOccurrenceIndex: 0,
                        values: [
                            OCKOutcomeValue(70.0, units: "count")
                        ],
                        isOwnedByApp: true,
                        healthKitUUIDs: [[weightSample.id]]
                    )
                )
            ],
            [
                Event(
                    taskUUID: stepsTask.uuid,
                    scheduleEvent: stepsTask.schedule[0],
                    outcome: OCKHealthKitOutcome(
                        taskUUID: stepsTask.uuid,
                        taskOccurrenceIndex: 0,
                        values: [
                            OCKOutcomeValue(-1.0, units: "count")
                        ],
                        isOwnedByApp: true,
                        healthKitUUIDs: [[stepsSample.id]]
                    )
                ),
                Event(
                    taskUUID: weightTask.uuid,
                    scheduleEvent: weightTask.schedule[0],
                    outcome: nil
                )
            ],
            [
                Event(
                    taskUUID: stepsTask.uuid,
                    scheduleEvent: stepsTask.schedule[0],
                    outcome: OCKHealthKitOutcome(
                        taskUUID: stepsTask.uuid,
                        taskOccurrenceIndex: 0,
                        values: [
                            OCKOutcomeValue(-1.0, units: "count")
                        ],
                        isOwnedByApp: true,
                        healthKitUUIDs: [[stepsSample.id]]
                    )
                ),
                Event(
                    taskUUID: weightTask.uuid,
                    scheduleEvent: weightTask.schedule[0],
                    outcome: OCKHealthKitOutcome(
                        taskUUID: weightTask.uuid,
                        taskOccurrenceIndex: 0,
                        values: [
                            OCKOutcomeValue(70.0, units: "count")
                        ],
                        isOwnedByApp: true,
                        healthKitUUIDs: [[weightSample.id]]
                    )
                )
            ],
            [
                Event(
                    taskUUID: stepsTask.uuid,
                    scheduleEvent: stepsTask.schedule[0],
                    outcome: nil
                ),
                Event(
                    taskUUID: weightTask.uuid,
                    scheduleEvent: weightTask.schedule[0],
                    outcome: OCKHealthKitOutcome(
                        taskUUID: weightTask.uuid,
                        taskOccurrenceIndex: 0,
                        values: [
                            OCKOutcomeValue(70.0, units: "count")
                        ],
                        isOwnedByApp: true,
                        healthKitUUIDs: [[weightSample.id]]
                    )
                )
            ]
        ]

        XCTAssertEqual(expectedEvents, observedEvents)
    }

    // MARK: - Helpers

    private func updateCumulativeSumOfSamples(
        events: [OCKHealthKitPassthroughStore.Event],
        completion: @escaping (Result<[OCKHealthKitPassthroughStore.Event], Error>) -> Void
    ) {
        let updatedEvents = events.map { event -> OCKHealthKitPassthroughStore.Event in

            guard event.outcome?.values.isEmpty == false else {
                return event
            }

            let outcomeValues = event.outcome?.values ?? []

            let summedOutcomeValue = outcomeValues
                .map { $0.numberValue!.doubleValue }
                .reduce(0, +)

            var updatedEvent = event
            updatedEvent.outcome?.values[0].value = summedOutcomeValue

            return updatedEvent
        }

        completion(.success(updatedEvents))
    }
}

private extension OCKHealthKitTask {

    private static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }

    static func makeDailyStepTask(startHour: Int = 7) -> OCKHealthKitTask {

        let task = OCKHealthKitTask(
            id: "steps",
            title: nil,
            carePlanUUID: nil,
            schedule: .dailyAtTime(hour: startHour, minutes: 0, start: startOfDay, end: nil, text: nil),
            healthKitLinkage: OCKHealthKitLinkage(quantityIdentifier: .stepCount, quantityType: .cumulative, unit: .count())
        )

        return task
    }

    static func makeDailyHeartRateTask(startHour: Int = 7) -> OCKHealthKitTask {

        let unit = HKUnit.count().unitDivided(by: .minute())

        let task = OCKHealthKitTask(
            id: "heartRate",
            title: nil,
            carePlanUUID: nil,
            schedule: .dailyAtTime(hour: startHour, minutes: 0, start: startOfDay, end: nil, text: nil),
            healthKitLinkage: OCKHealthKitLinkage(quantityIdentifier: .heartRate, quantityType: .discrete, unit: unit)
        )

        return task
    }

    static func makeDailyWeightTask(startHour: Int = 7) -> OCKHealthKitTask {

        let task = OCKHealthKitTask(
            id: "weight",
            title: nil,
            carePlanUUID: nil,
            schedule: .dailyAtTime(hour: startHour, minutes: 0, start: startOfDay, end: nil, text: nil),
            healthKitLinkage: OCKHealthKitLinkage(quantityIdentifier: .bodyMass, quantityType: .discrete, unit: .gram())
        )

        return task
    }

    static func makeDailyOxygenSaturationTask(startHour: Int = 7) -> OCKHealthKitTask {

        let task = OCKHealthKitTask(
            id: "oxygenSaturation",
            title: nil,
            carePlanUUID: nil,
            schedule: .dailyAtTime(hour: startHour, minutes: 0, start: startOfDay, end: nil, text: nil),
            healthKitLinkage: OCKHealthKitLinkage(quantityIdentifier: .oxygenSaturation, quantityType: .discrete, unit: .count())
        )

        return task
    }

    static func makeDailyAcneTask(startHour: Int = 7) throws -> OCKHealthKitTask {
        let link = try XCTUnwrap(
            OCKHealthKitLinkage(
                categoryIdentifier: .acne,
                quantityIdentifier: nil,
                quantityType: nil,
                unit: nil
            )
        )
        let task = OCKHealthKitTask(
            id: "acne",
            title: nil,
            carePlanUUID: nil,
            schedule: .dailyAtTime(hour: startHour, minutes: 0, start: startOfDay, end: nil, text: nil),
            healthKitLinkage: link
        )

        return task
    }
}

private struct Event: Equatable {

    var taskUUID: UUID
    var scheduleEvent: OCKScheduleEvent
    var outcome: OCKHealthKitOutcome?
}

@available(iOS 15, watchOS 8, *)
private extension Event {

    init(_ event: OCKHealthKitPassthroughStore.Event) {

        taskUUID = event.task.uuid
        outcome = event.outcome
        scheduleEvent = event.scheduleEvent
    }
}

