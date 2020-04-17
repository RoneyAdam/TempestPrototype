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
	
	func setupLabels(_ isImperial: Bool, _ values: [String : Any]) {
		
	}
	
}
