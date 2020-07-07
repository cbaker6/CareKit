//
//  SliderTaskView.swift
//  
//
//  Created by Dylan Li on 5/26/20.
//  Copyright © 2020 NetReconLab. All rights reserved.
//

import CareKitUI
import Foundation
import SwiftUI

/// A card that updates when a controller changes. The view displays a header view, multi-line label, and a completion button.
///
/// In CareKit, this view is intended to display a particular event for a task. The state of the button indicates the completion state of the event.
///
/// # View Updates
/// The view updates with the observed controller. By default, data from the controller is mapped to the view. The mapping can be customized by
/// providing a closure that returns a view. The closure is called whenever the controller changes.
///
/// # Style
/// The card supports styling using `careKitStyle(_:)`.
///
/// ```
///     +-------------------------------------------------------+
///     |                                                       |
///     |  <Title>                                              |
///     |  <Detail>                                             |
///     |                                                       |
///     |  --------------------------------------------------   |
///     |                                                       |
///     |  <Instructions>                                       |
///     |                                                       |
///     |  +-------------------------------------------------+  |
///     |  |               <Completion Button>               |  |
///     |  +-------------------------------------------------+  |
///     |                                                       |
///     +-------------------------------------------------------+
/// ```

public struct SliderTaskView<Header: View, Footer: View>: View {

    private let content: (_ configuration: SliderTaskViewConfiguration) -> CareKitUI.SliderTaskView<Header, Footer>

    /// Owns the view model that drives the view.
    @ObservedObject public var controller: OCKSliderTaskController

    public var body: some View {
        content(.init(controller: controller))
    }

    /// Create an instance that updates the content view when the observed controller changes.
    /// - Parameter controller: Owns the view model that drives the view.
    /// - Parameter content: Return a view to display whenever the controller changes.
    public init(controller: OCKSliderTaskController,
                content: @escaping (_ configuration: SliderTaskViewConfiguration) ->
        CareKitUI.SliderTaskView<Header,Footer>) {
        self.controller = controller
        self.content = content
    }
}

public extension SliderTaskView where Header == HeaderView, Footer == _SliderTaskViewFooter {

    /// Create an instance that updates the content view when the observed controller changes. The default view will be displayed whenever the
    /// controller changes.
    /// - Parameter controller: Owns the view model that drives the view.
    init(controller: OCKSliderTaskController) {
        self.init(controller: controller, content: { .init(configuration: $0) })
    }
}

private extension CareKitUI.SliderTaskView where Header == HeaderView, Footer == _SliderTaskViewFooter {
    init(configuration: SliderTaskViewConfiguration) {
        self.init(title: Text(configuration.title),
                  detail: configuration.detail.map { Text($0) },
                  isComplete: configuration.isComplete,
                  instructions: configuration.instructions.map { Text($0) },
                  maximumImage: configuration.maximumImage,
                  minimumImage: configuration.minimumImage,
                  initialValue: configuration.initialValue,
                  range: configuration.range,
                  step: configuration.step,
                  action: configuration.action)
    }
}
