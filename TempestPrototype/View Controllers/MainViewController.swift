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
	@IBOutlet weak var tempLabelTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var tempImage: UIImageView!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var locationImage: UIImageView!
	@IBOutlet weak var loadingContainer: UIView!
	@IBOutlet weak var errorImageView: UIImageView!
	@IBOutlet weak var errorLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var weatherTableView: UITableView!
	//Custom refresh button
	@IBOutlet weak var refreshButton: UIBarButtonItem! {
		didSet {
			if let image = UIImage(systemName: "arrow.2.circlepath") {
				let imageSize = CGRect(origin: CGPoint.zero, size: image.size)
				let button = UIButton(frame: imageSize)
				button.setBackgroundImage(image, for: .normal)
				button.addTarget(self, action: #selector(self.refreshTapped), for: .touchUpInside)
				refreshButton.customView = button
			}
		}
	}
	
	//MARK: Class Variables
	var dataFetcher: DataFetcher?
	var weatherStation: Station?
	var newWeatherStation: Station?
	var timer: Timer?
	var unitConverter: UnitConverter?
	
	
	//MARK: Setup Functions
    override func viewDidLoad() {
        super.viewDidLoad()
		setupLoading()
		startProcess()
    }
	
	//Fetch the data
	func startProcess() {
		dataFetcher = DataFetcher(self)
		dataFetcher?.fetchData { weatherStation in
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
		errorImageView.isHidden = true
		errorLabel.isHidden = true
		stationContainer.layer.cornerRadius = 20
		loadingContainer.layer.cornerRadius = 20
		activityIndicator.startAnimating()
		locationLabel.isHidden = true
		locationImage.isHidden = true
		tempImage.isHidden = true
		tempLabel.isHidden = true
	}
	
	//Setup up view: assign values to labels, controls, etc.
	func setup() {
		//Start your timer to check the api again in 1 minute
		if timer == nil {
			timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(checkAPI), userInfo: nil, repeats: true)
		}
		
		//TableView housekeeping
		weatherTableView.delegate = self
		weatherTableView.dataSource = self
		weatherTableView.tableFooterView = UIView(frame: CGRect.zero)
		weatherTableView.setNeedsLayout()
		
		//Make sure weather station isn't nil
		guard let weatherStation = weatherStation else {
			print("Station is nil!"); return
		}
		
		//Get unit converter
		unitConverter = UnitConverter()
		
		//Run 1 time only
		if !UserDefaults.standard.bool(forKey: "isSetup") {
			setupUserDefaults(2, false, weatherStation.is_public, weatherStation.station_name, weatherStation.public_name)
			UserDefaults.standard.set(true, forKey: "isSetup")
		}

		//Setup units, title, temperature, and location
		if let name = UserDefaults.standard.value(forKey: "name") as? String {
			setupTitle(name)
		}
		setupTemp(weatherStation.obs[0].air_temperature)
		setupLocation(weatherStation.latitude, weatherStation.longitude)
	}
	
	//Since I can't update values on the server, we'll use user defaults for these cases
	func setupUserDefaults(_ theme: Int, _ isImperial: Bool, _ isPublic: Bool, _ name: String, _ publicName: String) {
		let userDefaults = UserDefaults.standard
		userDefaults.set(theme, forKey: "theme")
		userDefaults.set(isImperial, forKey: "isImperial")
		userDefaults.set(isPublic, forKey: "isPublic")
		userDefaults.set(name, forKey: "name")
		userDefaults.set(publicName, forKey: "publicName")
		userDefaults.set([String: Double](), forKey: "tempDict")
		userDefaults.set([String: Double](), forKey: "pressureDict")
		userDefaults.set([String: Int](), forKey: "humidityDict")
	}
	
	//Setup style
	func updateStyle() {
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
	
	func setupTitle(_ stationName: String) {
		//I'm doing this so the actual weather station name font is different
		let titleString = NSMutableAttributedString(string: "Your Tempest: ")
		let stationName = NSMutableAttributedString(string: stationName, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 28, weight: .regular)])
		titleString.append(stationName)
		titleLabel.attributedText = titleString
	}
	
	func setupTemp (_ temp: Double) {
		let isImperial = UserDefaults.standard.bool(forKey: "isImperial")
		let tempValue = unitConverter?.getStringForTemperatureLabel(temp)
		tempLabel.text = tempValue?["Text"] as? String
		
		//Changed termperature image based on temperature hot/cold
		//I gues what is hot/cold is subjective but this is my personal opinion, haha
		if let value = tempValue?["Value"] as? Double {
			if isImperial && value >= 80  || !isImperial && value >= 26.6 {
				tempImage.image = UIImage(systemName: "thermometer.sun")
				tempImage.tintColor = .systemOrange
			} else if isImperial && value <= 40 || !isImperial && value <= 4.4 {
				tempImage.image = UIImage(systemName: "thermometer.snowflake")
				tempImage.tintColor = .systemBlue
			} else {
				tempImage.image = UIImage(systemName: "thermometer")
				tempImage.tintColor = .label
			}
		}
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
			self.locationLabel.isHidden = false
			self.locationImage.isHidden = false
			self.tempImage.isHidden = false
			self.tempLabel.isHidden = false
		})
	}
	
	//Show/hide elementes to handle internet connection being lost
	func handleError() {
		UIView.animate(withDuration: 0.3, animations: {
			self.activityIndicator.stopAnimating()
			self.activityIndicator.isHidden = true
			self.errorImageView.isHidden = false
			self.errorLabel.isHidden = false
			self.refreshButton.isEnabled = true
			self.refreshButton.customView?.tintColor = .link
		})
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		//Update the other elements based on the label height
		if titleLabel.frame.height > 44 {
			tempLabelTopConstraint.constant = 8
		} else {
			tempLabelTopConstraint.constant = 24
		}
	}
	
	//MARK: Actions
	@IBAction func settingsTapped(_ sender: Any) {
		let alertController = UIAlertController(title: nil, message: " ", preferredStyle: UIAlertController.Style.actionSheet)
		//Add settings VC as a child, then add the view as a subview
		if let settingsViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController() as? SettingsViewController {
			settingsViewController.mainViewController = self
			alertController.addChild(settingsViewController)
			let settingsView = settingsViewController.view
			settingsView?.layer.cornerRadius = 12
			if let view = settingsView {
				alertController.view.addSubview(view)
			}
			
		}

		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction!) in print("cancel")})

		alertController.addAction(cancelAction)

		DispatchQueue.main.async {
			self.present(alertController, animated: true, completion:{})
		}
	}
	
	//First check if you're refreshing from an error, if not assign the new weather station and reload the data
	@objc func refreshTapped() {
		refreshButton.customView?.tintColor = .link
		
		if !errorImageView.isHidden {
			startProcess()
		} else if let new = newWeatherStation {
			weatherStation = new
			setup()
			weatherTableView.reloadData()
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

		//Check if weather station is nil
		if let weatherStation = weatherStation {
			let isImperial = UserDefaults.standard.bool(forKey: "isImperial")
			let values = weatherStation.obs[0]
			switch indexPath.section {
				case 0:
					if let cell = tableView.dequeueReusableCell(withIdentifier: "lightningCell", for: indexPath) as? LightningTableViewCell {
						cell.setupLabels(isImperial, values)
						return cell
					}
				case 1:
					if let cell = tableView.dequeueReusableCell(withIdentifier: "pressureCell", for: indexPath) as? PressureTableViewCell {
						cell.setupLabels(isImperial, values)
						return cell
					}
				default:
					if let cell = tableView.dequeueReusableCell(withIdentifier: "airCell", for: indexPath) as? AirTableViewCell {
						cell.setupLabels(isImperial, values)
						return cell
					}
			}
			
			//This cell would only be returned in some kind of weird error scenario
			let errorCell = UITableViewCell(style: .default, reuseIdentifier: "error")
			errorCell.textLabel?.text = "Error loading weather data"
			return errorCell
		} else {
			print("Weather Station is nil")
			let errorCell = tableView.dequeueReusableCell(withIdentifier: "errorCell", for: indexPath)
			return errorCell
		}
		
	}
	
	//Set the heights for the cells
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
			performSegue(withIdentifier: "charts", sender: self)
		}
	}
	
	//Check the API and update the UI (There will always be new data -- timestamp and lightingStrike epoch)
	@objc func checkAPI() {
		dataFetcher?.fetchData { newWeatherStation in
			DispatchQueue.main.async {
				self.newWeatherStation = newWeatherStation
				self.refreshButton.isEnabled = true
				self.refreshButton.customView?.tintColor = .systemRed
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
