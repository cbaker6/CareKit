/*
 Copyright (c) 2025, Apple Inc. All rights reserved.
 
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

import HealthKit

public struct OCKDevice: Codable, Hashable, Sendable {

    /**
     The name of the receiver.

     The user-facing name, such as the one displayed in the Bluetooth Settings for a BLE device.
     */
    var name: String?

    /**
     The manufacturer of the receiver.
     */
    var manufacturer: String?

    /**
     The model of the receiver.
     */
    var model: String?

    /**
     The hardware revision of the receiver.
     */
    var hardwareVersion: String?

    /**
     The firmware revision of the receiver.
     */
    var firmwareVersion: String?

    /**
     The software revision of the receiver.
     */
    var softwareVersion: String?

    /**
     A unique identifier for the receiver.

     This property is available to clients for a local identifier.
     For example, Bluetooth peripherals managed by HealthKit use this
     for the CoreBluetooth UUID which is valid only on the local
     device and thus distinguish the same Bluetooth peripheral used
     between multiple devices.
     */
    var localIdentifier: String?

    /**
     Represents the device identifier portion of a device's FDA UDI (Unique Device Identifier).

     The device identifier can be used to reference the FDA's GUDID (Globally Unique Device
     Identifier Database). Note that for user privacy concerns this field should not be used to
     persist the production identifier portion of the device UDI. HealthKit clients should manage
     the production identifier independently, if needed.
     See http://www.fda.gov/MedicalDevices/DeviceRegulationandGuidance/UniqueDeviceIdentification/ for more information.
     */
    var udiDeviceIdentifier: String?
}

extension OCKDevice {

    init(device: HKDevice) {
        self.name = device.name
        self.manufacturer = device.manufacturer
        self.model = device.model
        self.hardwareVersion = device.hardwareVersion
        self.firmwareVersion = device.firmwareVersion
        self.localIdentifier = device.localIdentifier
        self.udiDeviceIdentifier = device.udiDeviceIdentifier
    }
}
