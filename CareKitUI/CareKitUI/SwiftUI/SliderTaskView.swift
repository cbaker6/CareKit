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
    private let slider: Slider<EmptyView,EmptyView>
    private let maximumImage: Image?
    private let minimumImage: Image?
    private let vertical: Bool
    
    //    var maximumValue: Double { sliderTask?.maximumValue ?? 10.0 }
        
     //   var minimumValue: Double { sliderTask?.minimumValue ?? 0.0 }
        
    //    @State var value: Double
        
    //    var step: Double { sliderTask?.step ?? 1.0 }
        
     //   var defaultValue: Double { sliderTask?.defaultValue ?? 0.0 }
        
    //    var slider: Slider<Text, Text> {
    //        Slider(value: defaultValue, in minimumValue...maximumValue, step: step, max) ?? Slider(value: 5, in 0...10, step: 1)
    //    }
        
    //    var maximumValueLabel: String? { sliderTask?.maximumValueLabel }
        
    //    var minimumValueLabel: String? { sliderTask?.minimumValueLabel }
        
    //    var maximumImage: Image? { sliderTask?.maximumImage }
    //
    //    var minimumImage: Image? { sliderTask?.minimumImage }
    //
    //    var vertical: Bool { sliderTask?.vertical ?? false }

    public var body: some View {
        CardView {
            VStack {
                header
            }
            Divider()
            instructions?
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(nil)
            
            if vertical {
                VStack {
                    maximumImage
                    GeometryReader { geo in
                        self.slider
                            .rotationEffect(.degrees(-90.0), anchor: .topLeading)
                            .frame(width: geo.size.height)
                            .offset(y: geo.size.height)
                    }
                    maximumImage
                }
            } else {
                HStack {
                    minimumImage
                    slider
                    maximumImage
                }
            }
            
            VStack {
                footer
            }
        }
    }

    // MARK: - Init

    public init(instructions: Text?, slider: Slider<EmptyView,EmptyView>, vertical: Bool, @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer) {
        self.instructions = instructions
        self.slider = slider
        self.maximumImage = nil
        self.minimumImage = nil
        self.vertical = vertical
        self.header = header()
        self.footer = footer()
    }
    
    /// Create an instance.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter header: Header to inject at the top of the card. Specified content will be stacked vertically.
    /// - Parameter footer: View to inject under the instructions. Specified content will be stacked vertically.
    public init(instructions: Text?, maximumImage: Image?, minimumImage: Image?, slider: Slider<EmptyView,EmptyView>, vertical: Bool, @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer) {
        self.instructions = instructions
        self.maximumImage = maximumImage
        self.minimumImage = minimumImage
        self.slider = slider
        self.vertical = vertical
        self.header = header()
        self.footer = footer()
    }
}

public extension SliderTaskView where Header == HeaderView {

    /// Create an instance.
    /// - Parameter title: Title text to display in the header.
    /// - Parameter detail: Detail text to display in the header.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter footer: View to inject under the instructions. Specified content will be stacked vertically.
    init(title: Text, detail: Text?, instructions: Text?, maximumImage: Image?, minimumImage: Image?, slider: Slider<EmptyView,EmptyView>, vertical: Bool, @ViewBuilder footer: () -> Footer) {
        self.init(instructions: instructions, maximumImage: maximumImage, minimumImage: minimumImage, slider: slider, vertical: vertical, header: {
            Header(title: title, detail: detail)
        }, footer: footer)
    }
}

public extension SliderTaskView where Footer == _SliderTaskViewFooter {

    init(isComplete: Bool, instructions: Text?, slider: Slider<EmptyView,EmptyView>, vertical: Bool, action: (() -> Void)?, @ViewBuilder header: () -> Header) {
        self.init(instructions: instructions, slider: slider, vertical: vertical, header: header, footer: {
            _SliderTaskViewFooter(isComplete: isComplete, action: action)
        })
    }
    
    /// Create an instance.
    /// - Parameter isComplete: True if the button under the instructions is in the completed.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter action: Action to perform when the button is tapped.
    /// - Parameter header: Header to inject at the top of the card. Specified content will be stacked vertically.
    init(isComplete: Bool, instructions: Text?, maximumImage: Image?, minimumImage: Image?, slider: Slider<EmptyView,EmptyView>, vertical: Bool, action: (() -> Void)?, @ViewBuilder header: () -> Header) {
        self.init(instructions: instructions, maximumImage: maximumImage, minimumImage: minimumImage, slider: slider, vertical: vertical, header: header, footer: {
            _SliderTaskViewFooter(isComplete: isComplete, action: action)
        })
    }
}

public extension SliderTaskView where Header == HeaderView, Footer == _SliderTaskViewFooter {

    init(title: Text, detail: Text?, instructions: Text?, slider: Slider<EmptyView,EmptyView>, vertical: Bool, isComplete: Bool, action: (() -> Void)?) {
        self.init(instructions: instructions, slider: slider, vertical: vertical, header: {
            Header(title: title, detail: detail)
        }, footer: {
            _SliderTaskViewFooter(isComplete: isComplete, action: action)
        })
    }
    /// Create an instance.
    /// - Parameter title: Title text to display in the header.
    /// - Parameter detail: Detail text to display in the header.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter isComplete: True if the button under the instructions is in the completed state.
    /// - Parameter action: Action to perform when the button is tapped.
    init(title: Text, detail: Text?, instructions: Text?, maximumImage: Image?, minimumImage: Image?, slider: Slider<EmptyView,EmptyView>, vertical: Bool, isComplete: Bool, action: (() -> Void)?) {
        self.init(instructions: instructions, maximumImage: maximumImage, minimumImage: minimumImage, slider: slider, vertical: vertical, header: {
            Header(title: title, detail: detail)
        }, footer: {
            _SliderTaskViewFooter(isComplete: isComplete, action: action)
        })
    }
}

/// The default footer used by an `InstructionsTaskView`.
public struct _SliderTaskViewFooter: View {

    @Environment(\.careKitStyle) private var style

    private var text: String {
        isComplete ? loc("COMPLETED") : loc("MARK_COMPLETE")
    }

    fileprivate let isComplete: Bool
    fileprivate let action: (() -> Void)?

    public var body: some View {
        Button(action: action ?? {}) {
            RectangularCompletionView(isComplete: isComplete) {
                HStack {
                    Spacer()
                    Text(text)
                    Spacer()
                }
            }
        }.buttonStyle(NoHighlightStyle())
    }
}

