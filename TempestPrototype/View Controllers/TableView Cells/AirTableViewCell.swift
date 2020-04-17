//
//  AirTableViewCell.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/16/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import UIKit

class AirTableViewCell: UITableViewCell {
	@IBOutlet weak var stationPressure: UILabel!
	@IBOutlet weak var barometricPressure: UILabel!
	@IBOutlet weak var sealevelPressure: UILabel!
	@IBOutlet weak var relativeHumidity: UILabel!
	@IBOutlet weak var airDensity: UILabel!
	
}
