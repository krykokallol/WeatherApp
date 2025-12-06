//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Najmul Hasan on 12/4/25.
//

import Foundation
import Combine

protocol WeatherServiceProtocol {
    func fetchWeather(city: String) async throws -> WeatherResponse
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse
    func fetchWeatherPublisher(city: String) -> AnyPublisher<WeatherResponse, Error>
}

final class WeatherService: WeatherServiceProtocol {

    // TODO: Move base URL and API key into separate configuration struct.
    private let apiKey: String
    private let baseURL = URL(string: "https://api.openweathermap.org/data/2.5/weather")!

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func fetchWeather(city: String) async throws -> WeatherResponse {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        let url = components.url!
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response)
        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(latitude)"),
            URLQueryItem(name: "lon", value: "\(longitude)"),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        let url = components.url!
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response: response)
        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }

    func fetchWeatherPublisher(city: String) -> AnyPublisher<WeatherResponse, Error> {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        let url = components.url!

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                try self.validate(response: response)
                return data
            }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    // MARK: - Helpers

    private func validate(response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard 200..<300 ~= http.statusCode else {
            throw WeatherServiceError.serverError(code: http.statusCode)
        }
    }
}

enum WeatherServiceError: LocalizedError {
    case serverError(code: Int)
    case invalidCity
    case locationUnavailable

    var errorDescription: String? {
        switch self {
        case .serverError(let code):
            return String(format: NSLocalizedString("error_server", comment: ""), code)
        case .invalidCity:
            return NSLocalizedString("error_invalid_city", comment: "")
        case .locationUnavailable:
            return NSLocalizedString("error_location_unavailable", comment: "")
        }
    }
}

