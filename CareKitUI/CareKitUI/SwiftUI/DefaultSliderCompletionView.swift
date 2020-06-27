//
//  File.swift
//  
//
//  Created by Dylan Li on 6/27/20.
//

import SwiftUI

public struct DefaultSliderCompletionButton: View {
    
    @Binding var value: CGFloat
    let geometry: GeometryProxy
    let themeColor: Color = Color(red: 0.8, green: 0.8, blue: 1)
    let isComplete: Bool

    private var diameter: CGFloat {
        geometry.size.width * 0.18
    }
    
    private var foregroundColor: Color {
        isComplete ? Color.white : themeColor
        
    }
    
    private var backgroundColor: Color {
        isComplete ? themeColor : Color.white
    }
    
//    private var text: String {
//        isComplete ? "Done" : ""
//    }
    
    public var body: some View {
        ZStack {
            Circle()
                .overlay(Circle().stroke(self.themeColor, lineWidth: self.geometry.size.width * 0.006))
                .foregroundColor(backgroundColor)
                .frame(width: diameter, height: diameter, alignment: .center)
            Group {
                Text(String(format: "%g", self.value))
                    .font(.system(size: self.geometry.size.width * 0.07))
                    .fontWeight(.semibold)
//                Text(text)
//                    .font(.system(size: self.geometry.size.width * 0.03))
//                    .fontWeight(.semibold)
//                    .offset(y: diameter * 0.3)
            }
            .foregroundColor(foregroundColor)
            .frame(width: diameter, height: diameter)
        }
    }
}
