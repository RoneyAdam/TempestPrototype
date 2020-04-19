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
		
		let unitConverter: UnitConverter = UnitConverter()
		if let wetBulb = unitConverter.getStringForTemperatureLabel(values.wet_bulb_temperature)["Text"] as? String {
			wetBulbLabel.text = "Wet Bulb Temperature: \(wetBulb)"
		}
		
		if let heatIndex = unitConverter.getStringForTemperatureLabel(values.heat_index)["Text"] as? String {
			heatIndexLabel.text = "Feels like: \(heatIndex)"
		}
		
		if let dewPoint = unitConverter.getStringForTemperatureLabel(values.dew_point)["Text"] as? String {
			dewPointLabel.text = "Dew Point: \(dewPoint)"
		}
		
		//From what I've read online, you have to convert Delta T differently than the rest of the temperatures
		var deltaT = values.delta_t
		var unit = "° C"
		if isImperial {
			deltaT = deltaT * (9/5)
			unit = "° F"
		}
		
		let numberFormatter = NumberFormatter()
		numberFormatter.maximumFractionDigits = 1
		
		if let value = numberFormatter.string(from: NSNumber(value: deltaT)) {
			deltaTLabel.text = "Delta T: \(value)"  + unit
		}
		
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
