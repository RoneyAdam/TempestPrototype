//
//  MainViewController.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/14/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	//MARK: Outlets
	@IBOutlet weak var stationContainer: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var tempLabel: UILabel!
	@IBOutlet weak var tempImage: UIImageView!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var loadingContainer: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var weatherTableView: UITableView!
	@IBOutlet weak var refreshButton: UIBarButtonItem! {
		didSet {
			if let image = UIImage(systemName: "arrow.2.circlepath") {
				let imageSize = CGRect(origin: CGPoint.zero, size: image.size)
				let button = UIButton(frame: imageSize)
				button.setBackgroundImage(image, for: .normal)
				button.addTarget(self, action: "refreshTapped", for: .touchUpInside)
				refreshButton.customView = button
			}
		}
	}
	
	//MARK: Class Variables
	var weatherStation: Station?
	var newWeatherStation: Station?
	var timer: Timer?
	
	
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
		updateStyle()
		hideRefresh()
		stationContainer.layer.cornerRadius = 20
		loadingContainer.layer.cornerRadius = 20
		activityIndicator.startAnimating()
	}
	
	//Setup up view: assign values to labels, controls, etc.
	func setup() {
		//Start your timer to check the api again in 1 minute
		if timer == nil {
			timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(checkAPI), userInfo: nil, repeats: true)
		}
		
		//TableView housekeeping
		weatherTableView.delegate = self
		weatherTableView.dataSource = self
		weatherTableView.tableFooterView = UIView(frame: CGRect.zero)
		weatherTableView.setNeedsLayout()
		
		//Make sure weather station isn't nil
		guard var weatherStation = weatherStation else {
			print("Station is nil!"); return
		}

		//Setup units, title, temperature, and location
		if let newUnitsWeatherStation = updateUnits() {
			weatherStation = newUnitsWeatherStation
		}
		setupTitle(weatherStation.station_name)
		setupLocation(weatherStation.latitude, weatherStation.longitude)
	}
	
	//Setup style
	func updateStyle() {
		//Check user defaults for theme key
		if UserDefaults.standard.object(forKey: "theme") == nil {
			UserDefaults.standard.set(2, forKey: "theme")
		}
		
		//Update theme
		UIApplication.shared.windows.forEach({ window in
			switch UserDefaults.standard.object(forKey: "theme") as? Int {
				case 0:
					window.overrideUserInterfaceStyle = .dark
				case 1:
					window.overrideUserInterfaceStyle = .light
				default:
					window.overrideUserInterfaceStyle = .unspecified
			}
		})
	}
	
	func updateUnits() -> Station? {
		guard var weatherStation = weatherStation else {
			print("Weather Station is nil!"); return nil
		}
		//Check user defaults for units key
		if UserDefaults.standard.object(forKey: "isImperial") == nil {
			UserDefaults.standard.set(true, forKey: "isImperial")
		}
		
		//Update all units based on user defaults
		//This would also be where I would update the weatherStation object on the server/device
		let isImperial = UserDefaults.standard.bool(forKey: "isImperial")
		weatherStation.station_units.units_other = isImperial ? "imperial" : "metric"
		
		//Set up temperature and reload table because unit has changed
		setupTemp(weatherStation.obs[0].air_temperature)
		weatherTableView.reloadData()
		
		//Return the weather station that has new station units
		return weatherStation
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
		let isImperial = UserDefaults.standard.bool(forKey: "isImperial")
		let temp = isImperial ? ((temp * 9.0/5.0) + 32).rounded() : temp.rounded()
		
		tempLabel.text = String(describing: temp).components(separatedBy: ".")[0] + "°" + (isImperial ? " F" : " C")
	}
		
	func setupLocation (_ lat: Double, _ long: Double) {
		//Use reverseGeocode to get city and state
		let geo = CLGeocoder()
		let location = CLLocation(latitude: lat, longitude: long)
		geo.reverseGeocodeLocation(location, completionHandler: { placemarks, error -> Void in
			if let placemark = placemarks?.first, let city = placemark.locality, let state = placemark.administrativeArea {
				self.locationLabel.text = city + ", " + state
				self.hideRefresh()
				self.hideLoading()
			}
		})
	}
	
	//Hide the refresh button until the data needs updating
	func hideRefresh() {
		refreshButton.isEnabled = false
		refreshButton.customView?.tintColor = .clear
	}
	
	func hideLoading() {
		//Hide loading view when setup is complete
		UIView.animate(withDuration: 0.3, animations: {
			self.loadingContainer.isHidden = true
		})
	}
	
	//MARK: Actions
	@IBAction func settingsTapped(_ sender: Any) {
		let alertController = UIAlertController(title: nil, message: "/n", preferredStyle: UIAlertController.Style.actionSheet)
		//Add settings VC as a child, then add the view as a subview
		if let settingsViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController() as? SettingsViewController {
			settingsViewController.mainViewController = self
			alertController.addChild(settingsViewController)
			alertController.view.addSubview(settingsViewController.view)
		}

		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction!) in print("cancel")})

		alertController.addAction(cancelAction)

		DispatchQueue.main.async {
			self.present(alertController, animated: true, completion:{})
		}
	}
	//Assign the new weatherStation and start the setup process gain
	@IBAction func refreshTapped() {
		refreshButton.customView?.tintColor = .link
		
		if let new = newWeatherStation {
			weatherStation = new
			setupLoading()
			weatherTableView.reloadData()
			setup()
		}
	}
	
	//Their's a werid dark/light mode bug with the nav bar. This line fixes it.
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		navigationController?.navigationBar.setNeedsLayout()
	}
	
	//MARK: TableView Functions
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 44
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = tableView.dequeueReusableCell(withIdentifier: "headerCell")
		if let headerView = view as? HeaderTableViewCell {
			switch section {
				case 0:
					headerView.icon.image = UIImage(systemName: "bolt.fill")
					headerView.titleLabel.text = "Lightning"
				case 1:
					headerView.icon.image = UIImage(systemName: "gauge")
					headerView.icon.tintColor = .systemBlue
					headerView.titleLabel.text = "Pressure"
				default:
					headerView.icon.image = UIImage(systemName: "wind")
					headerView.icon.tintColor = .systemGray3
					headerView.titleLabel.text = "Air"
			}
		}
		return view
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		guard let weatherStation = weatherStation else {
			print("Weather Station is nil -- returned unedited lightning cell")
			let cell = tableView.dequeueReusableCell(withIdentifier: "lightningCell")!
			return cell
		}
		let isImperial = UserDefaults.standard.bool(forKey: "isImperial")
		let values = weatherStation.obs[0]
		switch indexPath.section {
			case 0:
				let cell = tableView.dequeueReusableCell(withIdentifier: "lightningCell", for: indexPath) as! LightningTableViewCell
				cell.setupLabels(isImperial, values.lightning_strike_last_distance, values.lightning_strike_last_epoch, values.lightning_strike_count_last_3hr)
				return cell
			case 1:
				let cell = tableView.dequeueReusableCell(withIdentifier: "pressureCell", for: indexPath) as! PressureTableViewCell
				cell.setupLabels(isImperial, values.barometric_pressure, values.station_pressure, values.sea_level_pressure)
				return cell
			default:
				let cell = tableView.dequeueReusableCell(withIdentifier: "airCell", for: indexPath) as! AirTableViewCell
				return cell
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch indexPath.section {
			case 1:
				return 108
			default:
				return 80
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == 0 {
			performSegue(withIdentifier: "lightningDetail", sender: self)
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
						decoder.dateDecodingStrategy = .secondsSince1970
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
	
	//Check the API and
	@objc func checkAPI() {
		fetchData { newWeatherStation in
			if let oldWeatherStation = self.weatherStation {
				if oldWeatherStation.obs[0] != newWeatherStation.obs[0] {
					DispatchQueue.main.async {
						self.newWeatherStation = newWeatherStation
						self.refreshButton.isEnabled = true
						self.refreshButton.customView?.tintColor = .systemRed
					}
				}
			}
		}
	}
	
	//MARK: Segues
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "stationDetail", let weatherStation = weatherStation, let destination = segue.destination as? StationDetailViewController {
			destination.mainViewController = self
			destination.weatherStation = weatherStation
			destination.title = "Your Tempest"
		}
	}
}
