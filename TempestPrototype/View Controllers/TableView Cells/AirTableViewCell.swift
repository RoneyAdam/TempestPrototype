//
//  AirTableViewCell.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/16/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import UIKit

class AirTableViewCell: UITableViewCell {
	@IBOutlet weak var wetBulbLabel: UILabel!
	@IBOutlet weak var humidityLabel: UILabel!
	@IBOutlet weak var heatIndexLabel: UILabel!
	@IBOutlet weak var deltaTLabel: UILabel!
	@IBOutlet weak var airDensityLabel: UILabel!
	@IBOutlet weak var dewPointLabel: UILabel!
	
	//Setup air labels
	func setupLabels(_ isImperial: Bool, _ values: Obs) {
		let humidity = values.relative_humidity
		let airDensity = values.air_density
		let measurements = [Measurement(value: values.wet_bulb_temperature, unit: UnitTemperature.celsius), Measurement(value: values.heat_index, unit: UnitTemperature.celsius), Measurement(value: values.dew_point, unit: UnitTemperature.celsius)]
		var convertedMeasurements = [String()]
		
		let numberFormatter = NumberFormatter()
		numberFormatter.maximumFractionDigits = 1
		for item in measurements {
			var measurement = item
			if isImperial {
				measurement.convert(to: .fahrenheit)
			}
			
			if var value = numberFormatter.string(from: NSNumber(value: measurement.value)) {
				value += isImperial ? "° F" : "° C"
				convertedMeasurements.append(value)
			}
		}
		
		
		wetBulbLabel.text = "Wet Bulb Temperature: \(convertedMeasurements[1])"
		heatIndexLabel.text = "Feels like: \(convertedMeasurements[2])"
		dewPointLabel.text = "Dew Point: \(convertedMeasurements[3])"
		
		humidityLabel.text = "Humidity: \(humidity)%"
		
		//I'm not sure how to convert Air Density to imperial, so I'll just leave it alone
		numberFormatter.maximumFractionDigits = 3
		if let densityValue = numberFormatter.string(from: NSNumber(value: airDensity)) {
			//Using attributed string so I can set the exponent
			let units = NSMutableAttributedString(string: "kg/m3", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)])
			units.setAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 6), NSAttributedString.Key.baselineOffset : 6], range: NSRange(location: 4, length: 1))
			let value = NSMutableAttributedString(string: "Air Desnity: \(densityValue) ")
			value.append(units)
			airDensityLabel.attributedText = value
		}
		
	}
	
}
