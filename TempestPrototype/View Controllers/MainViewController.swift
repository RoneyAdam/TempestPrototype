//
//  MainViewController.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/14/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import UIKit
class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		fetchData()
    }
	
	//Fetch weather data
	func fetchData() {
		
		let urlString = "https://swd.weatherflow.com/swd/rest/observations/station/15056?token=75df7f48-d250-4d8d-90de-b28d63205ffe"
		guard let url = URL(string: urlString) else
		{ print("Error with URL"); return }
		
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			if let status = response as? HTTPURLResponse, let data = data, status.statusCode == 200 && error == nil {
				do {
					let decoder = JSONDecoder()
					decoder.keyDecodingStrategy = .convertFromSnakeCase
					decoder.dateDecodingStrategy = .secondsSince1970
					let test = try decoder.decode(Station.self, from: data)
					print(test.name)
					catch {
						print("JSON Error")
					}
				} else {
					print ("Session Error: \nStatus code: \(String(describing: response))\nError: \(String(describing: error))")
				}
			}
			
		}.resume()
		
	}
}
