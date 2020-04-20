//
//  ChartTableViewCell.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/19/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import UIKit
import SwiftChart

class ChartTableViewCell: UITableViewCell {

	@IBOutlet weak var chartView: Chart!

	func updateChart(_ dict: [String: Double]) {
		if !dict.isEmpty {
			let unitConverter = UnitConverter()
			var times = Array(dict.keys)
			var data = [Double]()
			times.sort()
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "h a"
			
			for i in 0...times.count - 1 {
				if let tempForTime = dict[times[i]], let value = unitConverter.getStringForTemperatureLabel(tempForTime)["Value"] as? Double {
					data.append(value)
				}
			}
			
			chartView.labelColor = UIColor.label
			let chartSeries = ChartSeries(data)
			chartView.add(chartSeries)
			let unit = UserDefaults.standard.bool(forKey: "isImperial") ? "°F" : "°C"
			chartView.maxX = 5
			chartView.minX = 0
			chartView.yLabelsFormatter = { String(Int($1)) +  unit }
			chartView.xLabelsFormatter = { times[Int($1)] }
		} else {
			print("Dicitonary is empty!")
		}
	}

}
