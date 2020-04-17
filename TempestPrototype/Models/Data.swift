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
	var obs: [Obs]
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

struct Obs: Codable, Equatable {
	let timestamp: Date
	var air_temperature: Double
	let barometric_pressure: Double
	let station_pressure: Double
	let sea_level_pressure: Double
	let relative_humidity: Int
	let lightning_strike_last_epoch: Date
	let lightning_strike_last_distance: Int
	let lightning_strike_count: Int
	let lightning_strike_count_last_3hr: Int
	let heat_index: Double
	let dew_point: Double
	let wet_bulb_temperature: Double
	let delta_t: Double
	let air_density: Double
	
	/*
	There's probaly a better way to this, but this check and sees if every value is equal to the new value.
	That way, we're not telling the user to update their weather data if only the timestamp has changed
	*/
	static func != (lhs: Obs, rhs: Obs) -> Bool {
		return !(
			lhs.air_temperature == rhs.air_temperature &&
			lhs.barometric_pressure == rhs.barometric_pressure &&
			lhs.station_pressure == rhs.station_pressure &&
			lhs.sea_level_pressure == rhs.sea_level_pressure &&
			lhs.relative_humidity == rhs.relative_humidity &&
			lhs.lightning_strike_last_epoch == rhs.lightning_strike_last_epoch &&
			lhs.lightning_strike_last_distance == rhs.lightning_strike_last_distance &&
			lhs.lightning_strike_count == rhs.lightning_strike_count &&
			lhs.lightning_strike_count_last_3hr == rhs.lightning_strike_count_last_3hr &&
			lhs.heat_index == rhs.heat_index &&
			lhs.dew_point == rhs.dew_point &&
			lhs.wet_bulb_temperature == rhs.wet_bulb_temperature &&
			lhs.delta_t == rhs.delta_t &&
			lhs.air_density == rhs.air_density
		)
	}
}
