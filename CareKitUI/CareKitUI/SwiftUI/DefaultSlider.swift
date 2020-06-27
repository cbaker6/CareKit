//
//  DefaultSlider.swift
//  
//
//  Created by Dylan Li on 6/22/20.
//

import SwiftUI

struct DefaultSlider: View {
    
    @Environment(\.careKitStyle) private var style
    @Binding var value: CGFloat
    var range: (CGFloat, CGFloat)
    let step: CGFloat
    let leftBarColor = Color(red: 0.8, green: 0.8, blue: 1)
    let rightBarColor = Color.white
    let geometry: GeometryProxy
    let isComplete: Bool
    
    init(value: Binding<CGFloat>, range: ClosedRange<CGFloat>, step: CGFloat, geometry: GeometryProxy, isComplete: Bool) {
        _value = value
        self.range = (range.lowerBound, range.upperBound)
        self.step = step
        self.geometry = geometry
        self.isComplete = isComplete
    }
    
    var body: some View {
        view(geometry: geometry)
    }
    
    private func view(geometry: GeometryProxy) -> some View {
        GeometryReader { geometry in
            self.addTicks(geometry: geometry, range: self.range, step: self.step)
            self.sliderView(geometry: geometry)
        }.frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.1)
    }
    
    private func sliderView(geometry: GeometryProxy) -> some View {
        let knobWidth = geometry.size.width / 8
        let frame = geometry.frame(in: .global)
        let drag = isComplete ? nil : DragGesture(minimumDistance: 0)
        
        let offsetX = self.getOffsetX(frame: frame)
        let barLeftSize = CGSize(width: CGFloat(offsetX + knobWidth / 2), height:  frame.height)
        let barRightSize = CGSize(width: frame.width - barLeftSize.width, height: frame.height)
        
        let components = DefaultSliderComponents(
            barLeft: DefaultSliderModifier(name: .barLeft, size: barLeftSize, offset: 0),
            barRight: DefaultSliderModifier(name: .barRight, size: barRightSize, offset: barLeftSize.width)
        )
        
        return ZStack {
            self.rightBarColor
                .modifier(components.barRight)
                .cornerRadius(knobWidth)
            self.leftBarColor
                .modifier(components.barLeft)
                .cornerRadius(knobWidth)
            RoundedRectangle(cornerRadius: knobWidth)
                .stroke(Color.black, lineWidth: geometry.size.width / 400)
        }.gesture(
            drag.onChanged( { drag in
                self.onDragChange(drag, in: frame)
                }
            )
        )
    }
    
    private func addTicks(geometry: GeometryProxy, range: (CGFloat, CGFloat), step: CGFloat) -> some View {
        let knobWidth = geometry.size.width / 8
        var values = [CGFloat]()
        var possibleValue = range.0
        while possibleValue <= range.1 {
            values.append(possibleValue)
            possibleValue += step
        }
        let tickLocations = values.map {
            CGFloat(values.firstIndex(of: $0)!) * (geometry.size.width - knobWidth) / CGFloat(values.count - 1)
        }
        
        return Group {
            ForEach(tickLocations, id: \.self) { location in
                DefaultSliderTickMark(possibleLocations: tickLocations, location: location, geometry: geometry, values: values)
            }
        }.offset(x: knobWidth / 2)
    }
    
    private func onDragChange(_ drag: DragGesture.Value, in frame: CGRect) {
        let knobWidth = frame.size.width / 8
        let width = (knob: CGFloat(knobWidth), view: CGFloat(frame.size.width))
        let xrange = (min: CGFloat(0), max: CGFloat(width.view - width.knob))
        var value = CGFloat(drag.startLocation.x + drag.translation.width)
        value -= 0.5 * width.knob
        value = value > xrange.max ? xrange.max : value
        value = value < xrange.min ? xrange.min : value
        value = value.convert(fromRange: (xrange.min, xrange.max), toRange: (CGFloat(range.0), CGFloat(range.1)))
        value = round(value / CGFloat(self.step)) * CGFloat(self.step)
        self.value = value
    }
    
    private func getOffsetX(frame: CGRect) -> CGFloat {
        let knobWidth = frame.size.width / 8
        let width = (knob: knobWidth, view: frame.size.width)
        let xrange: (CGFloat, CGFloat) = (0, CGFloat(width.view - width.knob))
        let result = CGFloat(self.value).convert(fromRange: (CGFloat(range.0), CGFloat(range.1)), toRange: xrange)
        return result
    }
}

struct DefaultSliderTickMark: View {
    let color: Color = Color.black
    let geometry: GeometryProxy
    let location: CGFloat
    let value: CGFloat
    enum PositionalHeight: CGFloat {
        case middle = 1.5
        case end = 1.7
    }
    let position: PositionalHeight
    
    init(geometry: GeometryProxy, location: CGFloat, position: PositionalHeight, value: CGFloat) {
        self.geometry = geometry
        self.location = location
        self.value = value
        self.position = position
    }
    
    init(possibleLocations: [CGFloat], location: CGFloat, geometry: GeometryProxy, values: [CGFloat]) {
        let value = values[possibleLocations.firstIndex(of: location)!]
        if possibleLocations.firstIndex(of: location) != 0, possibleLocations.firstIndex(of: location) != possibleLocations.count - 1 {
            self.init(geometry: geometry, location: location, position: .middle, value: value)
        } else {
            self.init(geometry: geometry, location: location, position: .end, value: value)
        }
    }
    
    var body: some View {
        let tickMark = Rectangle()
            .fill(color)
            .frame(width: geometry.size.width / 400, height: geometry.size.height * position.rawValue)
            .position(x: location, y: geometry.size.height / 2)
        let label = Text(position == .end ? String(format: "%g", value) : "")
            .font(.footnote)
            .position(x: location, y: -geometry.size.height / 5 - (geometry.size.height * position.rawValue - geometry.size.height) / 2)
        
        return ZStack {
            label
            tickMark
        }
    }
}

struct DefaultSliderComponents {
    let barLeft: DefaultSliderModifier
    let barRight: DefaultSliderModifier
}

struct DefaultSliderModifier: ViewModifier {
    enum Name {
        case barLeft
        case barRight
    }
    let name: Name
    let size: CGSize
    let offset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(width: size.width)
            .position(x: size.width * 0.5, y: size.height * 0.5)
            .offset(x: offset)
    }
}

extension CGFloat {
    func convert(fromRange: (CGFloat, CGFloat), toRange: (CGFloat, CGFloat)) -> CGFloat {
        var value = self
        value -= fromRange.0
        value /= CGFloat(fromRange.1 - fromRange.0)
        value *= toRange.1 - toRange.0
        value += toRange.0
        return value
    }
}
