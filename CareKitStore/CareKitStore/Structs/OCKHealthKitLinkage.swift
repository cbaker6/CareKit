/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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
import HealthKit

/// Describes how a task outcome values should be retrieved from HealthKit.
public struct OCKHealthKitLinkage: Equatable, Codable {

    public enum QuantityType: String, Codable {
        /// Quantities that are defined over a period of time, such as step count or calories burned.
        case cumulative

        /// Quantities that are defined at a single point in time, such as heart rate or blood oxygen level.
        case discrete
    }

    var sampleIdentifier: String

    /// A HealthKitQuantityIdentifier that describes the outcome's data type.
    public var quantityIdentifier: HKQuantityTypeIdentifier? {
        get { HKQuantityTypeIdentifier(rawValue: sampleIdentifier) }
        set { sampleIdentifier = newValue?.rawValue ?? "" }
    }

    /// A HKCategoryTypeIdentifier that describes the outcome's data type.
    public var categoryIdentifier: HKCategoryTypeIdentifier? {
        get { HKCategoryTypeIdentifier(rawValue: sampleIdentifier) }
        set { sampleIdentifier = newValue?.rawValue ?? "" }
    }

    /// Determines what kind of query will be used to fetch data from HealthKit.
    public var quantityType: QuantityType?

    /// A HealthKit unit that will be associated with outcomes saved to and fetched from HealthKit.
    public var unit: HKUnit? {
        get {
            guard let unitString else { return nil }
            return HKUnit(from: unitString)
        }
        set { unitString = newValue?.unitString }
    }
    private var unitString: String?

    /// Initialize by specifying HealthKit types.
    ///
    /// - Parameter quantityIdentifier: A HealthKitQuantityIdentifier that describes the outcome's data type.
    /// - Parameter quantityType: Determines what kind of query will be used to fetch data from HealthKit.
    /// - Parameter unit: A HealthKit unit that will be associated with outcomes saved to and fetched from HealthKit.
    public init(
        quantityIdentifier: HKQuantityTypeIdentifier,
        quantityType: QuantityType,
        unit: HKUnit
    ) {
        self.sampleIdentifier = quantityIdentifier.rawValue
        self.quantityType = quantityType
        self.unitString = unit.unitString
    }

    /// Initialize by specifying HealthKit types.
    ///
    /// - Parameter categoryIdentifier: A HealthKitCategoryIdentifier that describes the outcome's data type.
    /// - Parameter quantityIdentifier: A HealthKitQuantityIdentifier that describes the outcome's data type.
    /// - Parameter quantityType: Determines what kind of query will be used to fetch data from HealthKit.
    /// - Parameter unit: A HealthKit unit that will be associated with outcomes saved to and fetched from HealthKit.
    public init?(
        categoryIdentifier: HKCategoryTypeIdentifier?,
        quantityIdentifier: HKQuantityTypeIdentifier?,
        quantityType: QuantityType?,
        unit: HKUnit?
    ) {
        if let quantityIdentifier = quantityIdentifier,
           let quantityType = quantityType,
           let unit = unit {
            self.sampleIdentifier = quantityIdentifier.rawValue
            self.quantityType = quantityType
            self.unitString = unit.unitString
        } else if let categoryIdentifier = categoryIdentifier {
            self.sampleIdentifier = categoryIdentifier.rawValue
        } else {
            return nil
        }
    }
}
