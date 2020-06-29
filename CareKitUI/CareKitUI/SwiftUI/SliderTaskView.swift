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
    private let footer: Footer
    private let instructions: Text?
    private let maximumImage: Image?
    private let minimumImage: Image?
    private let range: ClosedRange<CGFloat>
    private let step: CGFloat
    private var isComplete: Bool
    @Binding private var value: CGFloat
    
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
                footer
            }
        }
    }
    // MARK: - Init
    
    public init(isComplete: Bool, instructions: Text?, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, step: CGFloat, @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer) {
        self.isComplete = isComplete
        self.instructions = instructions
        self.header = header()
        self.footer = footer()
        self.maximumImage = nil
        self.minimumImage = nil
        self.range = range
        self.step = step
        _value = value
    }
    
    /// Create an instance.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter header: Header to inject at the top of the card. Specified content will be stacked vertically.
    /// - Parameter footer: View to inject under the instructions. Specified content will be stacked vertically.
    public init(isComplete: Bool, instructions: Text?, maximumImage: Image?, minimumImage: Image?, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, step: CGFloat, @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer) {
        self.isComplete = isComplete
        self.instructions = instructions
        self.header = header()
        self.footer = footer()
        self.maximumImage = maximumImage
        self.minimumImage = minimumImage
        self.range = range
        self.step = step
        _value = value
    }
    //
    //    public init(instructions: Text?, maximumImage: Image?, minimumImage: Image?, @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer){
    //        self.instructions = instructions
    //        self.header = header()
    //        self.footer = footer()
    //        self.maximumImage = maximumImage
    //        self.minimumImage = minimumImage
    //    }
    //
    //    public init(instructions: Text?, @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer){
    //        self.instructions = instructions
    //        self.header = header()
    //        self.footer = footer()
    //        self.maximumImage = nil
    //        self.minimumImage = nil
    //    }
}

public extension SliderTaskView where Header == HeaderView {
    
    /// Create an instance.
    /// - Parameter title: Title text to display in the header.
    /// - Parameter detail: Detail text to display in the header.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter footer: View to inject under the instructions. Specified content will be stacked vertically.
    init(title: Text, detail: Text?, isComplete: Bool, instructions: Text?, maximumImage: Image?, minimumImage: Image?, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, step: CGFloat, @ViewBuilder footer: () -> Footer) {
        self.init(
            isComplete: isComplete,
            instructions: instructions,
            maximumImage: maximumImage, minimumImage: minimumImage,
            value: value, range: range, step: step,
            header: { Header(title: title, detail: detail) },
            footer: footer)
    }
    
    init(title: Text, detail: Text?, isComplete: Bool, instructions: Text?, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, step: CGFloat, @ViewBuilder footer: () -> Footer) {
        self.init(
            isComplete: isComplete,
            instructions: instructions,
            value: value, range: range, step: step,
            header: { Header(title: title, detail: detail) },
            footer: footer)
    }
}

public extension SliderTaskView where Footer == _SliderTaskViewFooter {
    
    init(isComplete: Bool, instructions: Text?, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, step: CGFloat, action: (() -> Void)?, @ViewBuilder header: () -> Header) {
        self.init(
            isComplete: isComplete,
            instructions: instructions,
            value: value, range: range, step: step,
            header: header,
            footer: { _SliderTaskViewFooter(isComplete: isComplete, action: action, value: value) })
    }
    
    /// Create an instance.
    /// - Parameter isComplete: True if the button under the instructions is in the completed.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter action: Action to perform when the button is tapped.
    /// - Parameter header: Header to inject at the top of the card. Specified content will be stacked vertically.
    init(isComplete: Bool, instructions: Text?, maximumImage: Image?, minimumImage: Image?, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, step: CGFloat, action: (() -> Void)?, @ViewBuilder header: () -> Header) {
        self.init(
            isComplete: isComplete,
            instructions: instructions,
            maximumImage: maximumImage, minimumImage: minimumImage,
            value: value, range: range, step: step,
            header: header,
            footer: { _SliderTaskViewFooter(isComplete: isComplete, action: action, value: value) })
    }
}

public extension SliderTaskView where Header == HeaderView, Footer == _SliderTaskViewFooter {
    
    init(title: Text, detail: Text?, isComplete: Bool, instructions: Text?, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, step: CGFloat, action: (() -> Void)?) {
        self.init(
            isComplete: isComplete,
            instructions: instructions,
            value: value, range: range, step: step,
            header: { Header(title: title, detail: detail) },
            footer: { _SliderTaskViewFooter(isComplete: isComplete, action: action, value: value) })
    }
    /// Create an instance.
    /// - Parameter title: Title text to display in the header.
    /// - Parameter detail: Detail text to display in the header.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter isComplete: True if the button under the instructions is in the completed state.
    /// - Parameter action: Action to perform when the button is tapped.
    init(title: Text, detail: Text?, isComplete: Bool, instructions: Text?, maximumImage: Image?, minimumImage: Image?, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, step: CGFloat, action: (() -> Void)?) {
        self.init(
            isComplete: isComplete,
            instructions: instructions,
            maximumImage: maximumImage, minimumImage: minimumImage,
            value: value, range: range, step: step,
            header: { Header(title: title, detail: detail) },
            footer: { _SliderTaskViewFooter(isComplete: isComplete, action: action, value: value) })
    }
}

/// The default footer used by an `SliderTaskView`.
public struct _SliderTaskViewFooter: View {
    
    @Environment(\.careKitStyle) private var style
    
    fileprivate let isComplete: Bool
    fileprivate let action: (() -> Void)?
    @Binding var value: CGFloat
    
    public var body: some View {
        Button(action: self.action ?? {}) {
            DefaultSliderCompletionView(value: self.$value, isComplete: self.isComplete, action: self.action)
        }
        
    }
}

//struct SliderCompletionButton: View {
//
//    @Binding var value: CGFloat
//    let geometry: GeometryProxy
//    let themeColor: Color = Color(red: 0.8, green: 0.8, blue: 1)
//    let action: (() -> Void)?
//    let isComplete: Bool
//
//    private var diameter: CGFloat {
//        geometry.size.width * 0.18
//    }
//
//    private var foregroundColor: Color {
//        isComplete ? Color.white : themeColor
//
//    }
//
//    private var backgroundColor: Color {
//        isComplete ? themeColor : Color.white
//    }
//
//    private var text: String {
//        isComplete ? "Done" : ""
//    }
//
//    var body: some View {
//        Button(action: action ?? {}) {
//            ZStack {
//                Circle()
//                    .overlay(Circle().stroke(self.themeColor, lineWidth: self.geometry.size.width * 0.006))
//                    .foregroundColor(backgroundColor)
//                    .frame(width: diameter, height: diameter, alignment: .center)
//                Group {
//                    Text(String(format: "%g", self.value))
//                        .font(.system(size: self.geometry.size.width * 0.07))
//                        .fontWeight(.semibold)
//                    Text(text)
//                        .font(.system(size: self.geometry.size.width * 0.03))
//                        .fontWeight(.semibold)
//                        .offset(y: diameter * 0.3)
//                }
//                .foregroundColor(foregroundColor)
//                .frame(width: diameter, height: diameter)
//            }
//        }
//        .padding(.all)
//        //.buttonStyle(SliderCompletionButtonStyle(color: themeColor))
//    }
//}
//
//struct SliderCompletionButtonStyle: ButtonStyle {
//
//    let color: Color
//
//    init(color: Color) {
//        self.color = color
//    }
//
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .background(configuration.isPressed ? color : Color.white)
//            .clipShape(Circle())
//    }
//}

