//
//  OCKSliderButton.swift
//
//
//  Created by Dylan Li on 7/21/20.
//  Copyright © 2020 NetReconLab. All rights reserved.
//

#if !os(watchOS)

import CareKitStore
import CareKitUI
import Foundation
import SwiftUI

@available(iOS 14.0, *)
public struct SynchronizedSliderTaskView<Controller: OCKSliderTaskController, SliderTaskView: View>: View {

    @StateObject private var controller: OCKSliderTaskController
    @State private var value: CGFloat = 5

    private let errorHandler: ((Error) -> Void)?
    private let content: (_ controller: OCKSliderTaskController, _ value: Binding<CGFloat>) -> SliderTaskView
    private let query: OCKSynchronizedTaskQuery?
    
    public var body: some View {
        content(controller, $value)
            .onAppear {
                self.query?.perform(using: self.controller)
            }
            .onReceive(controller.$error.compactMap { $0 }) { error in
                self.errorHandler?(error)
            }
    }

    init(controller: Controller, query: OCKSynchronizedTaskQuery? = nil, errorHandler: ((Error) -> Void)? = nil, initialValue: CGFloat,
         content: @escaping (_ viewModel: OCKSliderTaskController, _ value: Binding<CGFloat>) -> SliderTaskView) {
        self.query = query
        self._controller = .init(wrappedValue: controller)
        self.errorHandler = errorHandler
        self._value = State(initialValue: initialValue)
        self.content = content
    }

    init(copying copy: Self, settingErrorHandler errorHandler: @escaping (Error) -> Void) {
        self.query = copy.query
        self._controller = .init(wrappedValue: copy.controller)
        self.content = copy.content
        self.errorHandler = errorHandler
    }
}

#endif
