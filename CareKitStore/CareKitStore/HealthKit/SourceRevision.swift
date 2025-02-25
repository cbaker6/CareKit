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

import HealthKit

struct SourceRevision: Codable, Hashable {
    /**
     The HKSource of the receiver.
     */
    var source: Source

    /**
     The version of the source property.

     This value is taken from the CFBundleVersion of the source. May be nil for older data.
     */
    var version: String?

    /**
     Represents the product type of the device running HealthKit when the object was created.

     This value may be nil for older data, which indicates an unknown product type.
     */
    var productType: String?

    /**
     Represents the operating system version of the device running HealthKit when the object was created.

     iOS versions after 8.0 but prior to 8.2 are saved as 8.0, and iOS version after 8.2 but prior to 9.0
     are saved as 8.2.
     */
    var operatingSystemVersion: OSVersion
}

extension SourceRevision {
    init(sourceRevision: HKSourceRevision) {
        self.source = Source(source: sourceRevision.source)
        self.version = sourceRevision.version
        self.productType = sourceRevision.productType
        self.operatingSystemVersion = OSVersion(operatingSystemVersion: sourceRevision.operatingSystemVersion)
    }
}
