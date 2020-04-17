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
	
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var idLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var elevationLabel: UILabel!
	@IBOutlet weak var publicSegmentedControl: UISwitch!
	@IBOutlet weak var publicLabel: UILabel!
	@IBOutlet weak var publicTextField: UITextField!
	
	//MARK: Variables
	var weatherStation: Station?
	var mainViewController: MainViewController?
	var id = 0
	
	
	//MARK: Setup Functions
    override func viewDidLoad() {
        super.viewDidLoad()
		setup()
    }
	
	func setup() {
		guard let weatherStation = weatherStation else {
			print("Weather stati!n is nil!"); return
		}
		id = weatherStation.station_id
		stationInfoContainer.layer.cornerRadius = 32
		setupMap(weatherStation.latitude, weatherStation.longitude, weatherStation.station_name)
		setupName(weatherStation.station_name, id)
		setupAddress(weatherStation.latitude, weatherStation.longitude)
		setupStatus(weatherStation.status.status_message)
		setUpElevation(weatherStation.elevation)
		publicSegmentedControl.isOn = weatherStation.is_public
		publicTextField.placeholder = weatherStation.public_name
		
		//Add notifications for textFields when the keyboard is showing/dismissing
//		NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandler(notification:)), name: NSNotification.Name.UIResponder.keyboardWillShowNotification, object: nil)
	}
	
	func setupMap(_ lat: Double, _ long: Double, _ title: String) {
		let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
		let annotation = MKPointAnnotation()
		annotation.coordinate = location
		annotation.title = "Home"
		annotation.subtitle = "Tempest Weather Station"
		let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
		let region = MKCoordinateRegion(center: location, span: span)
		mapView.setRegion(region, animated: true)
		mapView.addAnnotation(annotation)
	}
	
	func setupName(_ name: String, _ id: Int) {
		nameTextField.text = name
		idLabel.text = "ID: \(id)"
	}
	
	func setupAddress(_ lat: Double, _ long: Double) {
		//Use geocoder to get address
		let geo = CLGeocoder()
		let location = CLLocation(latitude: lat, longitude: long)
		geo.reverseGeocodeLocation(location, completionHandler: { placemarks, error -> Void in
			if let placemark = placemarks?.first {
				let address = "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.postalCode ?? "")"
				self.addressLabel.text = address
			}
		})
	}
	
	func setupStatus(_ status: String) {
		//Doing this to add a different text/text color based on status
		//But, maybe I wouldn't even be able to load data if the status wasn't available ¯\_(ツ)_/¯
		let statusString = NSMutableAttributedString(string: "Status: ")
		let statusBool = status == "SUCCESS"
		let status = NSMutableAttributedString(string: statusBool ? "Online" : "Offline" , attributes: [NSAttributedString.Key.foregroundColor : statusBool ? UIColor.systemGreen.cgColor : UIColor.systemRed.cgColor])
		statusString.append(status)
		statusLabel.attributedText = statusString
	}
	
	func setUpElevation(_ elevation: Double) {
		var elevation = Measurement(value: elevation, unit: UnitLength.feet)
		let numberFormatter = NumberFormatter()
		numberFormatter.maximumFractionDigits = 2
		numberFormatter.string(from: NSNumber(value: elevation.value))
		var valueString = " ft"
		if !UserDefaults.standard.bool(forKey: "isImperial") {
			elevation.convert(to: UnitLength.meters)
			valueString = " m"
		}
		
		if let value = numberFormatter.string(from: NSNumber(value: elevation.value)) {
			elevationLabel.text = "Elevation: \(value)" + valueString
		}
	}
	
	//MARK: Actions
	@IBAction func nameDidEndEditing(_ sender: Any) {
		if let newName = nameTextField.text {
			weatherStation?.station_name = newName
		}
	}
	
	@IBAction func editButtonTapped(_ sender: Any) {
		if nameTextField.isFirstResponder {
			nameTextField.resignFirstResponder()
		} else {
			nameTextField.becomeFirstResponder()
		}
	}
	
	@IBAction func publicSwitchChanged(_ sender: UISwitch) {
		//This would be the spot to update the weather's public boolean value on the server
		weatherStation?.is_public = sender.isOn
	}
	
	@IBAction func publicNameDoneEditing(_ sender: UITextField) {
		//This would be the spot to update the weather's public name value on the server
		if let name = sender.text {
			weatherStation?.public_name = name
		}
	}
	
//	@objc func keyboardHandler(notification: NSNotification) {
//		if let userInfo = notification.userInfo, let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//			let frame = keyboardSize.cgRectValue
//			view.frame.origin.y = view.frame.origin.y == 0 ? (view.frame.origin.y - frame.height) : 0
//		}
//	}
	
	override func viewDidDisappear(_ animated: Bool) {
		//Pass the updated weather station object back to the main view controller
		if let main = mainViewController {
			main.weatherStation = weatherStation
			main.setupLoading()
		}
	}
	
}
