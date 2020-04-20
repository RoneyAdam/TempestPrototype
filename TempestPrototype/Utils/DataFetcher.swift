//
//  DataFetcher.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/19/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import Foundation

class DataFetcher {
	//MARK: Class Variables
	var main: MainViewController?
	
	
	//MARK: Init
	init(_ main: MainViewController?) {
		if let main = main {
			self.main = main
		}
	}
	
	
	//MARK: Data Fetch
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
					DispatchQueue.main.async {
						if let main = self.main {
							main.handleError()
						}
					}
				}
			}.resume()
		}
	}
}
