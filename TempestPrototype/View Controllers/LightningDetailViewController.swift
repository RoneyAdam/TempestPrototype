//
//  LightningDetailViewController.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/17/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import UIKit
import Charts

class LightningDetailViewController: UIViewController {
	
	//MARK: Class Variables
	@IBOutlet var chartView: UIView!
	
	//MARK: Class Variables
	var weatherStation: Station? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
		
		/*
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.allowedUnits = [.month, .day, .hour, .minute]
		formatter.maximumUnitCount = 2

		if var value = formatter.string(from: values.lightning_strike_last_epoch , to: Date()) {
			value = value.replacingOccurrences(of: "hours", with: "hrs")
			value = value.replacingOccurrences(of: "minutes", with: "mins")
			timeSinceLabel.text = "\(value) ago"
		}
		*/
		for i in 0...5 {
			let date = Date()
			let calendar = Calendar.current
			let hours = calendar.component(.hour, from: date)
			print(hours)
		}

    }

}
