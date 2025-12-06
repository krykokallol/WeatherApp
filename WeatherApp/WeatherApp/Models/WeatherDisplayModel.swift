//
//  WeatherDisplayModel.swift
//  WeatherApp
//
//  Created by Najmul Hasan on 12/5/25.
//

import Foundation

struct WeatherDisplayModel: Codable, Equatable {
    
    let city: String
    let country: String?
    let temperatureC: String
    let feelsLikeC: String
    let minTemperatureC: String
    let maxTemperatureC: String
    let description: String
    let humidity: String
    let windSpeed: String
    let sunrise: String
    let sunset: String
    let visibility: String
    let iconURL: URL?
}
