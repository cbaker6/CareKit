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
#if !os(watchOS)

import CareKitStore
import CareKitUI
import UIKit

/// A protocol that describes a type-erased view synchronizer for contacts.
@available(*, deprecated, renamed: "ViewSynchronizing")
public protocol OCKAnyContactViewSynchronizerProtocol {

    /// Initialize a view to be synchronized.
    func makeAnyView() -> UIView & OCKContactDisplayable

    /// Update a view using the given context
    /// - Parameters:
    ///   - view: The view to be updated
    ///   - context: Information about the update that is occurring.
    func updateAnyView(_ view: UIView & OCKContactDisplayable, context: OCKSynchronizationContext<OCKAnyContact?>)
}

/// A protocol that describes a view synchronizer for contacts.
@available(*, deprecated, renamed: "ViewSynchronizing")
public protocol OCKContactViewSynchronizerProtocol: OCKAnyContactViewSynchronizerProtocol {

    /// The type of the view that will be synchronized
    associatedtype View: UIView, OCKContactDisplayable

    /// Initialize a view to be synchronized.
    func makeView() -> View

    /// Update a view using the given context.
    /// - Parameters:
    ///   - view: The view to be updated.
    ///   - context: Information about the update that is occurring.
    func updateView(_ view: View, context: OCKSynchronizationContext<OCKAnyContact?>)
}

@available(*, deprecated, renamed: "ViewSynchronizing")
public extension OCKContactViewSynchronizerProtocol {
    func makeAnyView() -> UIView & OCKContactDisplayable {
        return makeView()
    }

    func updateAnyView(_ view: UIView & OCKContactDisplayable, context: OCKSynchronizationContext<OCKAnyContact?>) {
        guard let typedView = view as? View else { fatalError("Type mismatch") }
        updateView(typedView, context: context)
    }
}
#endif
