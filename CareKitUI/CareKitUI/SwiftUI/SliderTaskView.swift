//
//  SliderTaskView.swift
//  
//
//  Created by Dylan Li on 6/2/20.
//  Copyright © 2020 NetReconLab. All rights reserved.
//

import Foundation
import SwiftUI

/// A card that displays a header view, multi-line label, and a completion button.
///
/// In CareKit, this view is intended to display a particular event for a task. The state of the button indicates the completion state of the event.
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
    
    // MARK: - Properties
    
    @Environment(\.careKitStyle) private var style
    
    private let header: Header
    private let footer: Footer?
    private let instructions: Text?
    private let maximumImage: Image?
    private let minimumImage: Image?
    private let range: ClosedRange<CGFloat>
    private let step: CGFloat
    private var isComplete: Bool
    private let action: (() -> Void)?
    private let sliderHeight: CGFloat
    private let frameHeightMultiplier: CGFloat
    @State private var value: CGFloat = 0
    
    public var body: some View {
        CardView {
            VStack {
                header
            }
            Divider()
            VStack(alignment: .leading) {
                instructions?
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(nil)
                DefaultSlider(value: self.$value, range: self.range, step: self.step, isComplete: self.isComplete, minimumImage: self.minimumImage, maximumImage: self.maximumImage, sliderHeight: self.sliderHeight, frameHeightMultiplier: self.frameHeightMultiplier)
            }
            VStack {
                footer ?? _SliderTaskViewFooter(value: self.$value, isComplete: self.isComplete, action: self.action) as! Footer
            }
        }
    }
    
    // MARK: - Helper methods
    private func initialValueInRange(initialValue: CGFloat, range: ClosedRange<CGFloat>) -> State<CGFloat> {
        return initialValue > range.upperBound ? State(initialValue: range.upperBound) : (initialValue < range.lowerBound ? State(initialValue: range.lowerBound) : State(initialValue: initialValue))
    }
    
    // MARK: - Init
    
    /// Create an instance.
    /// - Parameter isComplete; True if the button under the instructions is in the completed.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter maximumImage: Image to display to the right of the slider. Default value is nil.
    /// - Parameter minimumImage: Image to display to the left of the slider. Default value is nil.
    /// - Parameter initialValue: Value that the slider begins on. Must be within the range.
    /// - Parameter range: The range that includes all possible values.
    /// - Parameter step: Value of the increment that the slider takes.
    /// - Parameter sliderHeight: Height of the bar of the slider.
    /// - Parameter frameHeightMultiplier: Value to multiply the slider height by to attain the hieght of the frame enclosing the slider. Default value is 1.7
    /// - Parameter action: Action to perform when the button is tapped. Default value is nil
    /// - Parameter header: Header to inject at the top of the card. Specified content will be stacked vertically.
    /// - Parameter footer: View to inject under the instructions. Specified content will be stacked vertically.
    public init(isComplete: Bool, instructions: Text?, maximumImage: Image?=nil, minimumImage: Image?=nil, initialValue: CGFloat, range: ClosedRange<CGFloat>, step: CGFloat, sliderHeight: CGFloat=40, frameHeightMultiplier: CGFloat=1.7, action: (() -> Void)?=nil, @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer?) {
        self.isComplete = isComplete
        self.instructions = instructions
        self.header = header()
        self.footer = footer()
        self.maximumImage = maximumImage
        self.minimumImage = minimumImage
        self.range = range
        self.step = step
        self.sliderHeight = sliderHeight
        self.frameHeightMultiplier = frameHeightMultiplier
        self.action = action
        _value = initialValueInRange(initialValue: initialValue, range: range)
    }
}

public extension SliderTaskView where Header == HeaderView {
    
    /// Create an instance.
    /// - Parameter title: Title text to display in the header.
    /// - Parameter detail: Detail text to display in the header.
    /// - Parameter isComplete; True if the button under the instructions is in the completed.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter maximumImage: Image to display to the right of the slider. Default value is nil.
    /// - Parameter minimumImage: Image to display to the left of the slider. Default value is nil.
    /// - Parameter initialValue: Value that the slider begins on. Must be within the range.
    /// - Parameter range: The range that includes all possible values.
    /// - Parameter step: Value of the increment that the slider takes.
    /// - Parameter sliderHeight: Height of the bar of the slider.
    /// - Parameter frameHeightMultiplier: Value to multiply the slider height by to attain the hieght of the frame enclosing the slider. Default value is 1.7
    /// - Parameter footer: View to inject under the instructions. Specified content will be stacked vertically.
    init(title: Text, detail: Text?, isComplete: Bool, instructions: Text?, maximumImage: Image?=nil, minimumImage: Image?=nil, initialValue: CGFloat, range: ClosedRange<CGFloat>, step: CGFloat, sliderHeight: CGFloat=40, frameHeightMultiplier: CGFloat=1.7, @ViewBuilder footer: () -> Footer) {
        self.init(
            isComplete: isComplete,
            instructions: instructions,
            maximumImage: maximumImage, minimumImage: minimumImage,
            initialValue: initialValue, range: range, step: step,
            sliderHeight: sliderHeight,
            frameHeightMultiplier: frameHeightMultiplier,
            header: { Header(title: title, detail: detail) },
            footer: footer)
    }
}

public extension SliderTaskView where Footer == _SliderTaskViewFooter {
    
    /// Create an instance.
    /// - Parameter isComplete; True if the button under the instructions is in the completed.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter maximumImage: Image to display to the right of the slider. Default value is nil.
    /// - Parameter minimumImage: Image to display to the left of the slider. Default value is nil.
    /// - Parameter initialValue: Value that the slider begins on. Must be within the range.
    /// - Parameter range: The range that includes all possible values.
    /// - Parameter step: Value of the increment that the slider takes.
    /// - Parameter sliderHeight: Height of the bar of the slider.
    /// - Parameter frameHeightMultiplier: Value to multiply the slider height by to attain the hieght of the frame enclosing the slider. Default value is 1.7
    /// - Parameter action: Action to perform when the button is tapped. Default value is nil
    /// - Parameter header: Header to inject at the top of the card. Specified content will be stacked vertically.
    init(isComplete: Bool, instructions: Text?, maximumImage: Image?=nil, minimumImage: Image?=nil, initialValue: CGFloat, range: ClosedRange<CGFloat>, step: CGFloat, sliderHeight: CGFloat=40, frameHeightMultiplier: CGFloat=1.7, action: (() -> Void)?, @ViewBuilder header: () -> Header) {
        self.init(
            isComplete: isComplete,
            instructions: instructions,
            maximumImage: maximumImage, minimumImage: minimumImage,
            initialValue: initialValue, range: range, step: step,
            sliderHeight: sliderHeight,
            frameHeightMultiplier: frameHeightMultiplier,
            action: action,
            header: header,
            footer: { nil } )
    }
}

public extension SliderTaskView where Header == HeaderView, Footer == _SliderTaskViewFooter {
    
    /// Create an instance.
    /// - Parameter title: Title text to display in the header.
    /// - Parameter detail: Detail text to display in the header.
    /// - Parameter isComplete; True if the button under the instructions is in the completed.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter maximumImage: Image to display to the right of the slider. Default value is nil.
    /// - Parameter minimumImage: Image to display to the left of the slider. Default value is nil.
    /// - Parameter initialValue: Value that the slider begins on. Must be within the range.
    /// - Parameter range: The range that includes all possible values.
    /// - Parameter step: Value of the increment that the slider takes.
    /// - Parameter sliderHeight: Height of the bar of the slider.
    /// - Parameter frameHeightMultiplier: Value to multiply the slider height by to attain the hieght of the frame enclosing the slider. Default value is 1.7
    /// - Parameter action: Action to perform when the button is tapped. Default value is nil
    init(title: Text, detail: Text?, isComplete: Bool, instructions: Text?, maximumImage: Image?=nil, minimumImage: Image?=nil, initialValue: CGFloat, range: ClosedRange<CGFloat>, step: CGFloat, sliderHeight: CGFloat=40, frameHeightMultiplier: CGFloat=1.7, action: (() -> Void)?) {
        self.init(
            isComplete: isComplete,
            instructions: instructions,
            maximumImage: maximumImage, minimumImage: minimumImage,
            initialValue: initialValue, range: range, step: step,
            sliderHeight: sliderHeight,
            frameHeightMultiplier: frameHeightMultiplier,
            action: action,
            header: { Header(title: title, detail: detail) })
    }
}

/// The default footer used by an `SliderTaskView`.
public struct _SliderTaskViewFooter: View {
    
    @Environment(\.careKitStyle) private var style
    
    fileprivate let isComplete: Bool
    fileprivate let action: (() -> Void)?
    @Binding var value: CGFloat
    
    init(value: Binding<CGFloat>, isComplete: Bool, action: (() -> Void)?){
        self.isComplete = isComplete
        self.action = action
        _value = value
    }
    
    public var body: some View {
        DefaultSliderCompletionView(value: self.$value, isComplete: self.isComplete, action: self.action)
    }
}
