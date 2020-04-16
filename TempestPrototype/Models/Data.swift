//
//  Data.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/14/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import Foundation

struct Station: Decodable {
	let station_id: Int
	var station_name: String
	var public_name: String
	let latitude: Double
	let longitude: Double
	let timezone: String
	let elevation: Double
	var is_public: Bool
	let status: Status
	var station_units: Station_units
	let outdoor_keys: [String]
	let obs: [Obs]
}

struct Status: Decodable {
	let status_code: Int
	let status_message: String
}

struct Station_units: Codable {
	let units_temp: String
	let units_wind: String
	let units_precip: String
	let units_pressure: String
	let units_distance: String
	let units_direction: String
	var units_other: String
}

struct Obs: Codable {
	let timestamp: Int
	let air_temperature: Double
	let barometric_pressure: Double
	let station_pressure: Double
	let sea_level_pressure: Double
	let relative_humidity: Int
	let lightning_strike_last_epoch: Int
	let lightning_strike_last_distance: Int
	let lightning_strike_count: Int
	let lightning_strike_count_last_3hr: Int
	let heat_index: Double
	let dew_point: Double
	let wet_bulb_temperature: Double
	let delta_t: Double
	let air_density: Double
}
