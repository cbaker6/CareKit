//
//  SliderTaskViewConfiguration.swift
//  
//
//  Created by Dylan Li on 5/26/20.
//

import Foundation

/// Default data used to map data from an `OCKInstructionsTaskController` to a `CareKitUI.InstructionsTaskView`.
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

    init(controller: OCKTaskControllerProtocol) {
        self.title = controller.title
        self.detail = controller.event.map { OCKScheduleUtility.scheduleLabel(for: $0) } ?? ""
        self.instructions = controller.instructions
        self.isComplete = controller.isFirstEventComplete
        self.action = controller.toggleActionForFirstEvent
    }
}
