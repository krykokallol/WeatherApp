//
//  WeatherAPIModels.swift
//  WeatherApp
//
//  Created by Najmul Hasan on 12/4/25.
//

import Foundation

struct WeatherResponse: Decodable {
    let name: String
    let weather: [Weather]
    let main: Main
    let wind: Wind?
    let sys: Sys?
    let visibility: Int?      // in meters
    let timezone: Int?        // seconds from UTC
    
    struct Weather: Decodable {
        let main: String
        let description: String
        let icon: String
    }

    struct Main: Decodable {
        let temp: Double
        let feels_like: Double
        let temp_min: Double
        let temp_max: Double
        let humidity: Int
    }

    struct Wind: Decodable {
        let speed: Double
    }

    struct Sys: Decodable {
        let country: String?
        let sunrise: Int?     // unix timestamp (seconds)
        let sunset: Int?      // unix timestamp (seconds)
    }
}
