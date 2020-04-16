//
//  MainViewController.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/14/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
	
	//MARK: Outlets
	@IBOutlet weak var stationContainer: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var tempLabel: UILabel!
	@IBOutlet weak var tempUnitSegControl: UISegmentedControl!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var loadingContainer: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	//MARK: Class Variables
	var weatherStation: Station?
	
	
	//MARK: Setup Functions
    override func viewDidLoad() {
        super.viewDidLoad()
		setupLoading()
		fetchData { weatherStation in
			self.weatherStation = weatherStation
			DispatchQueue.main.async {
				self.setup()
			}
		}
    }
	
	//Setup the loading view while fetching the data
	func setupLoading() {
		stationContainer.layer.cornerRadius = 20
		loadingContainer.layer.cornerRadius = 20
		activityIndicator.startAnimating()
	}
	
	//Setup up view: assign values to labels, controls, etc.
	func setup() {
		//Make sure weather station isn't nil
		guard let weatherStation = self.weatherStation else {
			print("Station is nil!"); return
		}

		//Setup title, temperature, and location
		setupTitle(weatherStation.station_name)
		setupTemp(weatherStation.obs[0].air_temperature)
		setupLocation(weatherStation.latitude, weatherStation.longitude)
	}
	
	func setupTitle(_ stationName: String) {
		//I'm doing this so the actual weather station name font is different
		let titleString = NSMutableAttributedString(string: "Your Tempest: ")
		let stationName = NSMutableAttributedString(string: stationName, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 28, weight: .regular)])
		titleString.append(stationName)
		titleLabel.attributedText = titleString
	}
	
	func setupTemp (_ temp: Double) {
		//Convert if needed and round (And remove trailing zero)
		let temp = tempUnitSegControl.selectedSegmentIndex == 1 ? temp.rounded() : ((temp * 9.0/5.0) + 32).rounded()
		
		tempLabel.text = String(describing: temp).components(separatedBy: ".")[0] + "°"
	}
		
	func setupLocation (_ lat: Double, _ long: Double) {
		//Use reverseGeocode to get city and state
		let geo = CLGeocoder()
		let location = CLLocation(latitude: lat, longitude: long)
		geo.reverseGeocodeLocation(location, completionHandler: { placemarks, error -> Void in
			if let placemark = placemarks?.first, let city = placemark.locality, let state = placemark.administrativeArea {
				self.locationLabel.text = city + ", " + state
				self.hideLoading()
			}
		})
	}
	
	func hideLoading() {
		//Hide loading view when setup is complete
		UIView.animate(withDuration: 0.3, animations: {
			self.loadingContainer.isHidden = true
		})
	}
	
	//MARK: Actions
	@IBAction func tempUnitChanged(_ sender: UISegmentedControl) {
		print("seg")
		//Unwrap weather station and change temperature label value
		if let weatherStation = weatherStation {
			setupTemp(weatherStation.obs[0].air_temperature)
		} else {
			print("Weather station is nil!")
		}
	}
	
	//MARK: Data Fetching
	//Fetch weather data
	func fetchData(completion: @escaping (Station) -> ()) {
		
		let urlString = "https://swd.weatherflow.com/swd/rest/observations/station/15056?token=75df7f48-d250-4d8d-90de-b28d63205ffe"
		guard let url = URL(string: urlString) else
		{ print("Error with URL"); return }
		
		DispatchQueue.main.async {
			URLSession.shared.dataTask(with: url) { (data, response, error) in
				if let status = response as? HTTPURLResponse, let data = data, status.statusCode == 200 && error == nil {
					do {
						let decoder = JSONDecoder()
						let weatherStation = try decoder.decode(Station.self, from: data)
						completion(weatherStation)
					} catch {
						print("JSON Decode Error")
					}
				} else {
					print("Session Error: \nStatus code: \(String(describing: response))\nError: \(String(describing: error))")
				}
			}.resume()
		}
	}
	
	//MARK: Segues
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "stationDetail", let weatherStation = weatherStation, let destination = segue.destination as? StationDetailViewController {
			destination.weatherStation = weatherStation
			destination.title = weatherStation.station_name
		}
	}
}
