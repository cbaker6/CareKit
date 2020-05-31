/*
 Copyright (c) 2020, Apple Inc. All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.

 3. Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import CareKitStore
import Foundation
import SwiftUI

extension OCKTaskControllerProtocol {
    
    var event: OCKAnyEvent? { objectWillChange.value?.firstEvent }
    
    var sliderTask: OCKSliderTask? { event?.task as? OCKSliderTask }

    var title: String { sliderTask?.title ?? "" }

    var instructions: String { sliderTask?.instructions ?? "" }
    
    var maximumValue: Int { sliderTask?.maximumValue ?? 10 }
    
    var minimumValue: Int { sliderTask?.minimumValue ?? 0 }
    
    var defaultValue: Int { sliderTask?.defaultValue ?? Int(((minimumValue+maximumValue)*.5).round()) }
    
    var step: Int { sliderTask?.step ?? 1 }
    
    var slider: Slider { Slider(value: defaultValue, in minimumValue...maximumValue, step: step) ?? Slider(value: 5, in 0...10, step: 1) }
    
    var maximumValueLabel: String? { sliderTask?.maximumValueLabel }
    
    var minimumValueLabel: String? { sliderTask?.minimumValueLabel }
    
    var maximumImage: Image? { sliderTask?.maximumImage }
    
    var minimumImage: Image? { sliderTask?.minimumImage }
    
    var vertical: Bool { sliderTask?.vertical ?? false }
    
    var isFirstEventComplete: Bool { event?.outcome != nil }

    var toggleActionForFirstEvent: () -> Void { { self.toggleFirstEvent() } }

    func isEventComplete(atIndexPath indexPath: IndexPath) -> Bool {
        return eventFor(indexPath: indexPath)?.outcome != nil
    }

    func toggleActionForEvent(atIndexPath indexPath: IndexPath) -> () -> Void {
        return { self.toggleEvent(atIndexPath: indexPath) }
    }

    private func toggleEvent(atIndexPath indexPath: IndexPath) {
        let isComplete = isEventComplete(atIndexPath: indexPath)
        setEvent(atIndexPath: indexPath, isComplete: !isComplete, completion: nil)
    }

    private func toggleFirstEvent() {
        setEvent(atIndexPath: .init(row: 0, section: 0), isComplete: !isFirstEventComplete, completion: nil)
    }
}

class OCKSliderTask: OCKAnyTask {
    
    var id: String { get { self.id  } }

    /// A title that will be used to represent this care plan to the patient.
    var title: String? { get{ self.title } }

    /// Instructions about how this task should be performed.
    var instructions: String? { get { self.instructions} }

    /// If true, completion of this task will be factored into the patient's overall adherence. True by default.
    var impactsAdherence: Bool { get { self.impactsAdherence } }

    /// A schedule that specifies how often this task occurs.
    var schedule: OCKSchedule { get { self.schedule } }

    /// A user-defined group identifer that can be used both for querying and sorting results.
    /// Examples may include: "medications", "exercises", "family", "males", "diabetics", etc.
    var groupIdentifier: String? { get{ self.groupIdentifier } }

    /// An identifier for this patient in a remote store.
    var remoteID: String? { get{ self.remoteID } }

    /// Any array of notes associated with this object.
    var notes: [OCKNote]? { get{ self.notes } }
    
    func belongs(to plan: OCKAnyCarePlan) -> Bool {
       
    }

    var maximumValue: Int { get { self.maximumValue } }
    
    var minimumValue: Int { get { self.minimumValue } }
    
    var defaultValue: Int? { get { self.defaultValue } }
    
    var step: Int { get { self.step } }
    
    var maximumValueLabel: String? { get { self.maximumValueLabel } }
    
    var minimumValueLabel: String? { get { self.minimumValueLabel} }
    
    var maximumImage: Image? { get { self.maximumImage } }
    
    var minimumImage: Image? { get { self.minimumImage } }
    
    var vertical: Bool { get { self.vertical } }

}

internal protocol OCKAnyMutableTask {
    var title: String? { get set }
    var instructions: String? { get set }
    var impactsAdherence: Bool { get set }
    var schedule: OCKSchedule { get set }
    var maximumValue: Int { get set }
    var minimumValue: Int { get set }
    var defaultValue: Int? { get set }
    var step: Int { get set }
    var maximumValueLabel: String? { get set }
    var minimumValueLabel: String? { get set }
    var maximumImage: Image? { get set }
    var minimumImage: Image? { get set }
    var vertical: Bool { get set }
}
