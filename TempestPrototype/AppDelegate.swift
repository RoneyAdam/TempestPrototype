//
//  AppDelegate.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/14/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import UIKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		 BGTaskScheduler.shared.register(
				   forTaskWithIdentifier: "adamroney.TempestPrototype.weatherFetcher",
				   using: nil
			   ) { task in
				   self.handleWeatherRefresh(task as! BGAppRefreshTask)
			   }
        return true
    }
	
	private func handleWeatherRefresh(_ task: BGAppRefreshTask) {
		task.expirationHandler = {
			task.setTaskCompleted(success: false)
		}
		
		weatherFetcher { () in
			task.setTaskCompleted(success: true)
		}
		
		scheduleWeatherRefresh()
	}

	func scheduleWeatherRefresh() {
		
		let weatherFetchTask = BGAppRefreshTaskRequest(identifier: "adamroney.TempestPrototype.weatherFetcher")
		weatherFetchTask.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
		do {
			try BGTaskScheduler.shared.submit(weatherFetchTask)
		} catch {
			print("Unable to submit task: \(error.localizedDescription)")
		}
	}
	
	func weatherFetcher(completion: @escaping () -> ()) {
		print("In Weather Fetcher")
		let dataFetcher = DataFetcher(nil)
		dataFetcher.fetchData { weatherStation in
			let userDefaults = UserDefaults.standard
			guard var tempDict = userDefaults.value(forKey: "tempDict") as? [String: Double], var pressureDict = userDefaults.value(forKey: "pressureDict") as? [String: Double], var humidityDict = userDefaults.value(forKey: "humidityDict") as? [String: Int] else {
				print("Dictionary Error!")
				return
			}
			let date = weatherStation.obs[0].timestamp
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "h a"
			
			let dateString = dateFormatter.string(from: date)
			print("Date: " + dateString)
			if !tempDict.keys.contains(dateString) {
				if tempDict.count == 5 {
					tempDict.remove(at: tempDict.startIndex)
					tempDict[dateString] = weatherStation.obs[0].air_temperature
				} else {
					tempDict[dateString] = weatherStation.obs[0].air_temperature
				}
			}
			
			if !pressureDict.keys.contains(dateString) {
				if pressureDict.count == 5 {
					pressureDict.remove(at: pressureDict.startIndex)
					pressureDict[dateString] = weatherStation.obs[0].station_pressure
				} else {
					pressureDict[dateString] = weatherStation.obs[0].station_pressure
				}
			}
			
			if !humidityDict.keys.contains(dateString) {
				if humidityDict.count == 5 {
					humidityDict.remove(at: humidityDict.startIndex)
					humidityDict[dateString] = weatherStation.obs[0].relative_humidity
				} else {
					humidityDict[dateString] = weatherStation.obs[0].relative_humidity
				}
			}
			
			userDefaults.set(tempDict, forKey: "tempDict")
			userDefaults.set(pressureDict, forKey: "pressureDict")
			userDefaults.set(humidityDict, forKey: "humidityDict")
			
			print(dateString)
			print(tempDict)
		}
	}

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
