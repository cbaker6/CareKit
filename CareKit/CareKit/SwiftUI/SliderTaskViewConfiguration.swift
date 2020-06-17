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
    
    public let minimumImage: Image?
//
    public var slider: Slider<EmptyView,EmptyView>?=nil
//
    public let maximumImage: Image?
//
    public let minimumValue: Double = 0.0
//
    public let maximumValue: Double = 0.0
//
    public let step: Double = 1.0
//
    public let vertical: Bool = false
//
////    public let minimumValueLabel: String?
////
////    public let maximumValueLabel: String?
//
    @State public var value: Double = 0.0
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
    
    init(controller: OCKTaskControllerProtocol, minimumValue: Double, maximumValue:Double, step: Double){
        //self.init(controller: controller)
        self.title = controller.title
        self.detail = controller.event.map { OCKScheduleUtility.scheduleLabel(for: $0) } ?? ""
        self.instructions = controller.instructions
        self.isComplete = controller.isFirstEventComplete
        self.action = controller.toggleActionForFirstEvent
        self.minimumImage = nil
        self.maximumImage = nil
        
        self.slider = Slider<EmptyView,EmptyView>(value: $value, in: minimumValue...maximumValue, step: step)
        
        
        




        
    }
}
