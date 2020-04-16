//
//  SettingsViewController.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/16/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
	
	//MARK: Outlets
	@IBOutlet weak var themeSegmentedControl: UISegmentedControl!
	@IBOutlet weak var unitsSegmentedControl: UISegmentedControl!
	
	//MARK: Variables
	var mainViewController: MainViewController?
	
	
	//MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
		setup()
    }
	
	func setup() {
		setupThemeControl()
		setupUnitsSegmentedControl()
	}
	
	func setupThemeControl() {
		if let index = UserDefaults.standard.value(forKey: "theme") as? Int {
			themeSegmentedControl.selectedSegmentIndex = index
		}
	}
	
	func setupUnitsSegmentedControl() {
		let isImperial = UserDefaults.standard.bool(forKey: "isImperial")
		unitsSegmentedControl.selectedSegmentIndex = isImperial ? 0 : 1
	}
	
	//MARK: Actions
	@IBAction func themeValueChanged(_ sender: UISegmentedControl) {
		//Update user defualts and app style
		UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "theme")
		if let main = mainViewController {
			main.updateStyle()
		}
	}
	
	@IBAction func unitsValueChanged(_ sender: UISegmentedControl) {
		let newValue = sender.selectedSegmentIndex == 0
		UserDefaults.standard.set(newValue, forKey: "isImperial")
		if let main = mainViewController {
			let _ = main.updateUnits()
		}
	}
	
}
