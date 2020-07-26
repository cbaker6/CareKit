//
//  SliderTaskView.swift
//
//  Created by Dylan Li on 5/26/20.
//  Copyright © 2020 NetReconLab. All rights reserved.
//
#if !os(watchOS)

import CareKitStore
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

@available(iOS 14.0, *)
public struct SliderTaskView<Header: View, SliderView: View>: View {
    
    private typealias TaskView = SynchronizedSliderTaskView<OCKSliderTaskController, CareKitUI.SliderTaskView<Header, SliderView>>

    private let taskView: TaskView
    
    public var body: some View {
        taskView
    }

    private init(taskView: TaskView) {
        self.taskView = taskView
        
    }
    
    /// Create an instance. The first task and event that match the provided queries will be fetched from the the store and displayed in the view.
    /// The view will update when changes occur in the store.
    /// - Parameters:
    ///     - taskID: The ID of the task to fetch.
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - storeManager: Wraps the store that contains the task and event to fetch.
    ///     - content: Create a view to display whenever the body is computed.
    public init(taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager, initialValue: CGFloat,
                content: @escaping (_ controller: OCKSliderTaskController, _ value: Binding<CGFloat>) -> CareKitUI.SliderTaskView<Header, SliderView>) {
        taskView = .init(controller: .init(storeManager: storeManager),
                         query: .taskIDs([taskID], eventQuery),
                         initialValue: initialValue,
                         content: content)
    }
    
    /// Create an instance. The first event that matches the provided query will be fetched from the the store and displayed in the view. The view
    /// will update when changes occur in the store.
    /// - Parameters:
    ///     - task: The task associated with the event to fetch.
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - storeManager: Wraps the store that contains the event to fetch.
    ///     - content: Create a view to display whenever the body is computed.
    public init(task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager, initialValue: CGFloat,
                content: @escaping (_ controller: OCKSliderTaskController, _ value: Binding<CGFloat>) -> CareKitUI.SliderTaskView<Header, SliderView>) {
        taskView = .init(controller: .init(storeManager: storeManager),
                         query: .tasks([task], eventQuery),
                         initialValue: initialValue,
                         content: content)
    }
    
    /// Create an instance.
    /// - Parameters:
    ///     - controller: Controller that holds a reference to data displayed by the view.
    ///     - content: Create a view to display whenever the body is computed.
    public init(controller: OCKSliderTaskController, initialValue: CGFloat,
                content: @escaping (_ controller: OCKSliderTaskController, _ value: Binding<CGFloat>) -> CareKitUI.SliderTaskView<Header, SliderView>) {
        taskView = .init(controller: controller, initialValue: initialValue, content: content)
    }
    
    /// Handle any errors that may occur.
    /// - Parameter handler: Handle the encountered error.
    public func onError(_ perform: @escaping (Error) -> Void) -> Self {
        .init(taskView: .init(copying: taskView, settingErrorHandler: perform))
    }
}

@available(iOS 14.0, *)
public extension SliderTaskView where Header == _SliderTaskViewHeader, SliderView == _SliderTaskViewFooter {

    /// Create an instance that displays the default content. The first task and event that match the provided queries will be fetched from the the
    /// store and displayed in the view. The view will update when changes occur in the store.
    /// - Parameters:
    ///     - taskID: The ID of the task to fetch.
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - storeManager: Wraps the store that contains the task and event to fetch.
    ///     - content: Create a view to display whenever the body is computed.
    init(taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager, initialValue: CGFloat) {
        self.init(taskID: taskID, eventQuery: eventQuery, storeManager: storeManager, initialValue: initialValue) {
            .init(viewModel: $0.viewModel, value: $1)
        }
    }
    
    /// Create an instance that displays the default content. The first event that matches the provided query will be fetched from the the store and
    /// displayed in the view. The view will update when changes occur in the store.
    /// - Parameters:
    ///     - task: The task associated with the event to fetch.
    ///     - eventQuery: A query used to fetch an event in the store.
    ///     - storeManager: Wraps the store that contains the event to fetch.
    ///     - content: Create a view to display whenever the body is computed.
    init(task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager, initialValue: CGFloat) {
        self.init(task: task, eventQuery: eventQuery, storeManager: storeManager, initialValue: initialValue) {
            .init(viewModel: $0.viewModel, value: $1)
        }
    }
    
    /// Create an instance that displays the default content.
    /// - Parameters:
    ///     - controller: Controller that holds a reference to data displayed by the view.
    init(controller: OCKSliderTaskController, initialValue: CGFloat) {
        taskView = .init(controller: controller, initialValue: initialValue) {
            .init(viewModel: $0.viewModel, value: $1)
        }
    }
}

private extension CareKitUI.SliderTaskView where Header == _SliderTaskViewHeader, SliderView == _SliderTaskViewFooter {
    init(viewModel: SliderTaskViewModel?, value: Binding<CGFloat>,
         minimumImage: Image? = nil, maximumImage: Image? = nil, range: ClosedRange<CGFloat> = 0...10, step: CGFloat = 1, sliderStyle: SliderStyle = .system) {
        self.init(title: Text(viewModel?.title ?? ""),
                  detail: viewModel?.detail.map { Text($0) },
                  instructions: viewModel?.instructions.map{ Text($0) },
                  isComplete: viewModel?.isComplete ?? false,
                  value: value,
                  range: range,
                  step: step,
                  minimumImage: minimumImage,
                  maximumImage: maximumImage,
                  sliderStyle: sliderStyle,
                  action: viewModel?.action ?? { _ in })
    }
}

public struct SliderTaskViewModel {
    
    /// The title text to display in the header.
    public let title: String
    
    /// The detail text to display in the header.
    public let detail: String?
    
    /// Instructions text to display under the header.
    public let instructions: String?
    
    /// True if the button under the slider is in the completed.
    public let isComplete: Bool

    /// Action to perform when the button is tapped.
    public let action: (Double) -> Void
    
    /*
    /// Image to display to the left of the slider. Default value is nil.
    public let minimumImage: Image?
    
    /// Image to display to the right of the slider. Default value is nil.
    public let maximumImage: Image?
    
    /// Source of truth for value of the slider.
    //@State public var value: CGFloat = 0
    
    /// Value that the slider begins on. Must be within the range.
    //public let initialValue: CGFloat
    
    /// The range that includes all possible values.
    public let range: ClosedRange<CGFloat>
    
    /// Value of the increment that the slider takes.
    public let step: CGFloat
    
    /// Height of the bar of the slider. Default value is 40.
    public let sliderHeight: CGFloat
    
    /// Value to multiply the slider height by to attain the hieght of the frame enclosing the slider. Default value is 1.7.
    public let frameHeightMultiplier: CGFloat
    
    public let useDefaultSlider: Bool
    
    private func initialValueInRange(initialValue: CGFloat, range: ClosedRange<CGFloat>) -> State<CGFloat> {
        initialValue > range.upperBound ? State(initialValue: range.upperBound) :
            (initialValue < range.lowerBound ? State(initialValue: range.lowerBound) :
                State(initialValue: initialValue))
    }

    init(title: String, detail: String? = nil, instructions: String? = nil, isComplete: Bool, action: @escaping () -> Void, minimumImage: Image? = nil, maximumImage: Image? = nil, initialValue: CGFloat, range: ClosedRange<CGFloat>, step: CGFloat, sliderHeight: CGFloat = 40, frameHeightMultiplier: CGFloat = 1.7, useDefaultSlider: Bool) {
        self.title = title
        self.detail = detail
        self.instructions = instructions
        self.isComplete = isComplete
        self.action = action
        self.minimumImage = minimumImage
        self.maximumImage = maximumImage
        self.range = range
        self.step = step
        self.sliderHeight = sliderHeight
        self.frameHeightMultiplier = frameHeightMultiplier
        self.useDefaultSlider = useDefaultSlider
        _value = initialValueInRange(initialValue: initialValue, range: range)
    }*/
}

#endif
