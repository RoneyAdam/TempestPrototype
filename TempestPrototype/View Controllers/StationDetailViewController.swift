//
//  StationDetailViewController.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/15/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import UIKit
import MapKit

class StationDetailViewController: UIViewController {
	
	//MARK: Outlets
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var stationInfoContainer: UIView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var elevationLabel: UILabel!
	@IBOutlet weak var elevationSegmentedControl: UISegmentedControl!
	@IBOutlet weak var publicSegmentedControl: UISwitch!
	@IBOutlet weak var publicLabel: UILabel!
	@IBOutlet weak var publicTextField: UITextField!
	
	//MARK: Variables
	var weatherStation: Station?
	
	//MARK: Setup Functions
    override func viewDidLoad() {
        super.viewDidLoad()
		setup()
    }
	
	func setup() {
		guard let weatherStation = weatherStation else {
			print("Weather stati!n is nil!"); return
		}
		stationInfoContainer.layer.cornerRadius = 32
		setupTitle(weatherStation.station_name)
		setupAddress(weatherStation.latitude, weatherStation.longitude)
		setupStatus(weatherStation.status.status_message)
		setUpElevation(weatherStation.elevation)
	}
	
	func setupTitle(_ title: String) {
		nameLabel.text = title
	}
	
	func setupAddress(_ lat: Double, _ long: Double) {
		//Use geocoder to get address
		let geo = CLGeocoder()
		let location = CLLocation(latitude: lat, longitude: long)
		geo.reverseGeocodeLocation(location, completionHandler: { placemarks, error -> Void in
			if let placemark = placemarks?.first {
				let address = "\(placemark.subThoroughfare ?? ""), \(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.postalCode ?? "")"
				self.addressLabel.text = address
			}
		})
	}
	
	func setupStatus(_ status: String) {
		//Doing this to add a different text/text color based on status
		//But, maybe I wouldn't even be able to load data if the status wasn't available ¯\_(ツ)_/¯
		let statusString = NSMutableAttributedString(string: "Status: ")
		let statusBool = status == "SUCCESS"
		let status = NSMutableAttributedString(string: statusBool ? "Online" : "Offline" , attributes: [NSAttributedString.Key.foregroundColor : statusBool ? UIColor.green.cgColor : UIColor.red.cgColor])
		statusString.append(status)
		statusLabel.attributedText = statusString
	}
	
	func setUpElevation(_ elevation: Double) {
		var elevation = Measurement(value: elevation, unit: UnitLength.feet)
		if elevationSegmentedControl.selectedSegmentIndex == 1 {
			elevation.convert(to: UnitLength.meters)
			let numberFormatter = NumberFormatter()
			numberFormatter.maximumFractionDigits = 2
			let measurementFormatter = MeasurementFormatter()
			measurementFormatter.numberFormatter = numberFormatter
			print(measurementFormatter.string(from: elevation))
		}
		/*var x = Measurement(value:19, unit: UnitMass.kilograms)
		x.convert(to:UnitMass.pounds)
		x.description // 41.8878639834918 lb

		let n = NumberFormatter()
		n.maximumFractionDigits = 2
		let m = MeasurementFormatter()
		m.numberFormatter = n
		m.string(from: x) // 41.89 lb*/
		
	}
	
	//MARK: Actions
	@IBAction func elevationUnitChanged(_ sender: Any) {
		if let elevation = weatherStation?.elevation {
			setUpElevation(elevation)
		}
	}
	

}
