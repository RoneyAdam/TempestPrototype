//
//  ChartsViewController.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/19/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import UIKit
import SwiftChart

class ChartsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	//MARK: Outlets
	@IBOutlet weak var chartTableView: UITableView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		chartTableView.delegate = self
		chartTableView.dataSource = self
    }
	
	
	//MARK: Table View Functions
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "chartCell") as! ChartTableViewCell
		let tempDict = UserDefaults.standard.value(forKey: "tempDict") as! [String: Double]
		cell.updateChart(tempDict)
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 250
	}

}
