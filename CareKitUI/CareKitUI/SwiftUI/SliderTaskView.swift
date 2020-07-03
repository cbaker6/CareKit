//
//  SliderTaskView.swift
//  
//
//  Created by Dylan Li on 6/2/20.
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
    //@Binding private var value: CGFloat
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
                DefaultSlider(value: self.$value, range: self.range, step: self.step, isComplete: self.isComplete, minimumImage: self.minimumImage, maximumImage: self.maximumImage)
            }
            VStack {
                footer ?? _SliderTaskViewFooter(value: self.$value, isComplete: self.isComplete, action: self.action) as! Footer
            }
        }
//        .padding(.leading)
//        .padding(.trailing)
    }
    // MARK: - Init
    
    public init(isComplete: Bool, instructions: Text?, initialValue: CGFloat, range: ClosedRange<CGFloat>, step: CGFloat, @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer) {
        self.isComplete = isComplete
        self.instructions = instructions
        self.header = header()
        self.footer = footer()
        self.maximumImage = nil
        self.minimumImage = nil
        self.range = range
        self.step = step
        self.action = nil
        _value = State(initialValue: initialValue)
    }
    
//    public init(isComplete: Bool, instructions: Text?, value: CGFloat, range: ClosedRange<CGFloat>, step: CGFloat, @ViewBuilder header: () -> Header, action: (() -> Void)?) {
//        self.isComplete = isComplete
//        self.instructions = instructions
//        self.header = header()
//        self.footer = nil
//        self.maximumImage = nil
//        self.minimumImage = nil
//        self.range = range
//        self.step = step
//        self.action = action
//        self.value = value
//    }
    
    /// Create an instance.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter header: Header to inject at the top of the card. Specified content will be stacked vertically.
    /// - Parameter footer: View to inject under the instructions. Specified content will be stacked vertically.
    public init(isComplete: Bool, instructions: Text?, maximumImage: Image?, minimumImage: Image?, initialValue: CGFloat, range: ClosedRange<CGFloat>, step: CGFloat, @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer) {
        self.isComplete = isComplete
        self.instructions = instructions
        self.header = header()
        self.footer = footer()
        self.maximumImage = maximumImage
        self.minimumImage = minimumImage
        self.range = range
        self.step = step
        self.action = nil
        _value = State(initialValue: initialValue)
    }
    
//    public init(isComplete: Bool, instructions: Text?, maximumImage: Image?, minimumImage: Image?, value: CGFloat, range: ClosedRange<CGFloat>, step: CGFloat, @ViewBuilder header: () -> Header, action: (() -> Void)?) {
//        self.isComplete = isComplete
//        self.instructions = instructions
//        self.header = header()
//        self.footer = nil
//        self.maximumImage = maximumImage
//        self.minimumImage = minimumImage
//        self.range = range
//        self.step = step
//        self.action = action
//        self.value = value
//    }
    
}

public extension SliderTaskView where Header == HeaderView {
    
    /// Create an instance.
    /// - Parameter title: Title text to display in the header.
    /// - Parameter detail: Detail text to display in the header.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter footer: View to inject under the instructions. Specified content will be stacked vertically.
    init(title: Text, detail: Text?, isComplete: Bool, instructions: Text?, maximumImage: Image?, minimumImage: Image?, initialValue: CGFloat, range: ClosedRange<CGFloat>, step: CGFloat, @ViewBuilder footer: () -> Footer) {
        self.init(
            isComplete: isComplete,
            instructions: instructions,
            maximumImage: maximumImage, minimumImage: minimumImage,
            initialValue: initialValue, range: range, step: step,
            header: { Header(title: title, detail: detail) },
            footer: footer)
    }
    
    init(title: Text, detail: Text?, isComplete: Bool, instructions: Text?, initialValue: CGFloat, range: ClosedRange<CGFloat>, step: CGFloat, @ViewBuilder footer: () -> Footer) {
        self.init(
            isComplete: isComplete,
            instructions: instructions,
            initialValue: initialValue, range: range, step: step,
            header: { Header(title: title, detail: detail) },
            footer: footer)
    }
}

public extension SliderTaskView where Footer == _SliderTaskViewFooter {
    
    init(isComplete: Bool, instructions: Text?, initialValue: CGFloat, range: ClosedRange<CGFloat>, step: CGFloat, @ViewBuilder header: () -> Header, action: (() -> Void)?) {
//        self.init(
//            isComplete: isComplete,
//            instructions: instructions,
//            value: value, range: range, step: step,
//            header: header,
//            action: action)
        self.isComplete = isComplete
        self.instructions = instructions
        self.header = header()
        self.footer = nil
        self.maximumImage = nil
        self.minimumImage = nil
        self.range = range
        self.step = step
        self.action = action
        _value = State(initialValue: initialValue)
    }
    
    /// Create an instance.
    /// - Parameter isComplete: True if the button under the instructions is in the completed.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter action: Action to perform when the button is tapped.
    /// - Parameter header: Header to inject at the top of the card. Specified content will be stacked vertically.
    init(isComplete: Bool, instructions: Text?, maximumImage: Image?, minimumImage: Image?, initialValue: CGFloat, range: ClosedRange<CGFloat>, step: CGFloat, @ViewBuilder header: () -> Header, action: (() -> Void)?) {
//        self.init(
//            isComplete: isComplete,
//            instructions: instructions,
//            maximumImage: maximumImage, minimumImage: minimumImage,
//            value: value, range: range, step: step,
//            header: header,
//            action: action)
        self.isComplete = isComplete
        self.instructions = instructions
        self.header = header()
        self.footer = nil
        self.maximumImage = maximumImage
        self.minimumImage = minimumImage
        self.range = range
        self.step = step
        self.action = action
        _value = State(initialValue: initialValue)
    }
}

public extension SliderTaskView where Header == HeaderView, Footer == _SliderTaskViewFooter {
    
    init(title: Text, detail: Text?, isComplete: Bool, instructions: Text?, initialValue: CGFloat, range: ClosedRange<CGFloat>, step: CGFloat, action: (() -> Void)?) {
        self.init(
            isComplete: isComplete,
            instructions: instructions,
            initialValue: initialValue, range: range, step: step,
            header: { Header(title: title, detail: detail) },
            action: action)
    }
    /// Create an instance.
    /// - Parameter title: Title text to display in the header.
    /// - Parameter detail: Detail text to display in the header.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter isComplete: True if the button under the instructions is in the completed state.
    /// - Parameter action: Action to perform when the button is tapped.
    init(title: Text, detail: Text?, isComplete: Bool, instructions: Text?, maximumImage: Image?, minimumImage: Image?, initialValue: CGFloat, range: ClosedRange<CGFloat>, step: CGFloat, action: (() -> Void)?) {
        self.init(
            isComplete: isComplete,
            instructions: instructions,
            maximumImage: maximumImage, minimumImage: minimumImage,
            initialValue: initialValue, range: range, step: step,
            header: { Header(title: title, detail: detail) },
            action: action)
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
