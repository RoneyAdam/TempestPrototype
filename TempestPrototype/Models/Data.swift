//
//  Data.swift
//  TempestPrototype
//
//  Created by Adam Roney on 4/14/20.
//  Copyright © 2020 Adam Roney. All rights reserved.
//

import Foundation

struct Station: Decodable {
    let stationId: Int
    let name: String
    let publicName: String
    let lat: Float
    let long: Float
    let timeZone: String
    let elevation: Float
    let isPublic: Bool
    let status: [Int: String]
}

struct StationUnits: Decodable {
	let temp: String
	let wind: String
	let precip: String
	let pressure: String
	let distance: String
	let direction: String
	let other: String
}

struct Weather: Decodable {
	let timeStamp: Date
	let airTemperature: Float
	let barometricPressure: Float
	let stationPressure: Float
	let seaLevelPressure: Float
	let relHumidity: Float
	let lightningStrikeLastEpoch: Int
	let lightningStrikeLastDistance: Int
	let lightningStrikeCount: Int
	let lightningStrikeCountLast3hr: Int
	let heatIndex: Float
	let dewPoint: Float
	let wetBulbTemperature: Float
	let deltaT: Float
	let airDensity: Float
}
