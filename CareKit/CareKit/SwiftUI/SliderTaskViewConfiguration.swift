//
//  SliderTaskViewConfiguration.swift
//  
//
//  Created by Dylan Li on 5/26/20.
//

import Foundation
import SwiftUI

/// Default data used to map data from an `OCKSliderTaskController` to a `CareKitUI.InstructionsTaskView`.
public struct SliderTaskViewConfiguration {

    /// The title text to display in the header.
    public let title: String

    /// The detail text to display in the header.
    public let detail: String?

    /// The instructions text to display under the header.
    public let instructions: String?

    /// The action to perform when the button is tapped.
    public let action: (() -> Void)?

    /// True if the labeled button is complete.
    public let isComplete: Bool
    
    public let minimumImage: Image? = nil

    public let maximumImage: Image? = nil
    
    public let initialValue: CGFloat = 5

    public let range: ClosedRange<CGFloat> = 0...10

    public let step: CGFloat = 1

    @State public var value: CGFloat = 5
    /*
    init(controller: OCKTaskControllerProtocol) {
        self.title = controller.title
        self.detail = controller.event.map { OCKScheduleUtility.scheduleLabel(for: $0) } ?? ""
        self.instructions = controller.instructions
        self.isComplete = controller.isFirstEventComplete
        self.action = controller.toggleActionForFirstEvent
        self.minimumImage = controller.minimumImage
        self.maximumImage = controller.maximumImage
        self.maximumValue = controller.maximumValue
        self.minimumValue = controller.minimumValue
        self.step = controller.step
        self.vertical = controller.vertical
        self.value = controller.defaultValue
        self.minimumValueLabel = controller.minimumValueLabel
        self.maximumValueLabel = controller.maximumValueLabel
    }*/
    
    init(controller: OCKTaskControllerProtocol){
        self.title = controller.title
        self.detail = controller.event.map { OCKScheduleUtility.scheduleLabel(for: $0) } ?? ""
        self.instructions = controller.instructions
        self.isComplete = controller.isFirstEventComplete
        self.action = controller.toggleActionForFirstEvent
    }
    /*
    init(controller: OCKTaskControllerProtocol, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, step: CGFloat){
        self.title = controller.title
        self.detail = controller.event.map { OCKScheduleUtility.scheduleLabel(for: $0) } ?? ""
        self.instructions = controller.instructions
        self.isComplete = controller.isFirstEventComplete
        self.action = controller.toggleActionForFirstEvent
        self.minimumImage = nil
        self.maximumImage = nil
        self.range = range
        self.step = step
        _value = value
    }*/

}
