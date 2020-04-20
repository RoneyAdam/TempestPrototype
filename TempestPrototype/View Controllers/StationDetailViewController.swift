//
//  StationDetailViewController.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/15/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import UIKit
import MapKit

class StationDetailViewController: UIViewController, UITextFieldDelegate {
	
	//MARK: Outlets
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var stationInfoContainer: UIView!
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var idLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var elevationLabel: UILabel!
	@IBOutlet weak var publicSwitch: UISwitch!
	@IBOutlet weak var publicLabel: UILabel!
	@IBOutlet weak var publicTextField: UITextField!
	
	//MARK: Variables
	var weatherStation: Station?
	var mainViewController: MainViewController?
	var nameEdited = false
	
	
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
		setupMap(weatherStation.latitude, weatherStation.longitude, weatherStation.station_name)
		if let name = UserDefaults.standard.value(forKey: "name") as? String{
			setupName(name, weatherStation.station_id)
		}
		setupAddress(weatherStation.latitude, weatherStation.longitude)
		setupStatus(weatherStation.status.status_message)
		setUpElevation(weatherStation.elevation)
		publicSwitch.isOn = UserDefaults.standard.bool(forKey: "isPublic")
		if let publicName = UserDefaults.standard.value(forKey: "publicName") as? String {
			setupPublicTextField(publicName)
		}
		setupKeyboardManager()
	}
	
	//Setup the map to show a placemarker for the weather station
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
	
	//Passing the name as a backup in case something is wrong with user defaults
	func setupName(_ name: String, _ id: Int) {
		nameTextField.delegate = self
		if let defaultName = UserDefaults.standard.value(forKey: "name") as? String {
			nameTextField.text = defaultName
		} else {
			nameTextField.text = name
		}
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
	
	//Setup the elevation. Convert if needed
	func setUpElevation(_ elevation: Double) {
		let unitConverter = UnitConverter()
		elevationLabel.text = "Elevation: \(unitConverter.getStringForSmallLengthLabel(elevation))"
	}
	
	//Setup public name text field
	func setupPublicTextField(_ name: String) {
		publicTextField.delegate = self
		publicTextField.placeholder = name
	}
	
	func setupKeyboardManager() {
		//Add notifications for textFields when the keyboard is showing/dismissing
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
		
		//Add a tap recognizer to view to dismiss keyboard
		let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
		view.addGestureRecognizer(tap)
	}
	
	//MARK: Actions
	//Can't update on the server, so we'll just use userDefaults for these changes
	
	@IBAction func nameDidEndEditing(_ sender: Any) {
		nameEdited = true
		if let newName = nameTextField.text {
			UserDefaults.standard.set(newName, forKey: "name")
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
		UserDefaults.standard.set(sender.isOn, forKey: "isPublic")
	}
	
	@IBAction func publicNameDoneEditing(_ sender: UITextField) {
		if let name = sender.text {
			UserDefaults.standard.set(name, forKey: "publicName")
		}
	}
	
	override func viewWillLayoutSubviews() {
		if !publicTextField.isEditing {
			super.viewWillLayoutSubviews()
		}
	}
	
	//Hide keyboard
	@objc func viewTapped() {
		view.endEditing(true)
	}
	
	//Change the view's origin when the keyboard appears
	@objc func keyboardWillChange(_ notification: Notification) {
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
			if isKeyboardShowing {
				stationInfoContainer.frame.origin.y -= keyboardSize.height
			} else {
				stationInfoContainer.frame.origin.y += keyboardSize.height
			}
			
			
		}
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		//Run setup so the values can be updated on the main view controller
		if let main = mainViewController, nameEdited {
			main.setup()
		}
	}
	
	//MARK: TextField delegate
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		view.endEditing(true)
	}
	
	//MARK: Deinit
	//Remove observers on deinit
	deinit {
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}
}
