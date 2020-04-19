//
//  UnitConverter.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/19/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import Foundation

class UnitConverter {
	
	//In this case, I'm returning a dictionary because I need to use the temperature converted value in the main view controller
	func getStringForTemperatureLabel(_ value: Double) -> [String: Any] {
		var returnValue = "n/a"
		let value = value
		
		let isImperial = UserDefaults.standard.bool(forKey: "isImperial")
		
		var measurement = Measurement(value: value, unit: UnitTemperature.celsius)
		measurement = isImperial ? measurement.converted(to: UnitTemperature.fahrenheit) : measurement
		
		
		let numberFormatter = NumberFormatter()
		numberFormatter.maximumFractionDigits = 1
		
		if let value = numberFormatter.string(from: NSNumber(value: measurement.value)) {
			returnValue = value + (isImperial ? "° F" : "° C")
		}
		
		return ["Text": returnValue, "Value": measurement.value]
	}
	
	func getStringForPressureLabel(_ value: Double) -> String {
		var returnValue = "n/a"
		let value = value
		
		let isImperial = UserDefaults.standard.bool(forKey: "isImperial")
		
		var measurement = Measurement(value: value, unit: UnitPressure.hectopascals)
		measurement = isImperial ? measurement.converted(to: UnitPressure.inchesOfMercury) : measurement
		
		
		let numberFormatter = NumberFormatter()
		numberFormatter.maximumFractionDigits = 1
		
		if let value = numberFormatter.string(from: NSNumber(value: measurement.value)) {
			returnValue = value + (isImperial ? " inHg" : " hPA")
		}
		
		return returnValue
	}
	
	func getStringForLargeLengthLabel(_ value: Double) -> String {
		var returnValue = "n/a"
		let value = value
		
		let isImperial = UserDefaults.standard.bool(forKey: "isImperial")
		
		var measurement = Measurement(value: value, unit: UnitLength.kilometers)
		measurement = isImperial ? measurement.converted(to: UnitLength.miles) : measurement
		
		
		let numberFormatter = NumberFormatter()
		numberFormatter.maximumFractionDigits = 1
		
		if let value = numberFormatter.string(from: NSNumber(value: measurement.value)) {
			returnValue = value + (isImperial ? " mi" : " km")
		}
		
		return returnValue
	}
	
	func getStringForSmallLengthLabel(_ value: Double) -> String {
		var returnValue = "n/a"
		let value = value
		
		let isImperial = UserDefaults.standard.bool(forKey: "isImperial")
		
		var measurement = Measurement(value: value, unit: UnitLength.meters)
		measurement = isImperial ? measurement.converted(to: UnitLength.feet) : measurement
		
		
		let numberFormatter = NumberFormatter()
		numberFormatter.maximumFractionDigits = 1
		
		if let value = numberFormatter.string(from: NSNumber(value: measurement.value)) {
			returnValue = value + (isImperial ? " ft" : " m")
		}
		
		return returnValue
	}

}
