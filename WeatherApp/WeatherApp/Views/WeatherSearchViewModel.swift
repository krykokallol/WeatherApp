//
//  WeatherSearchViewModel.swift
//  WeatherApp
//
//  Created by Najmul Hasan on 12/4/25.
//

import Foundation
import Combine
import CoreLocation

@MainActor
final class WeatherSearchViewModel: ObservableObject {
    
    // Input
    @Published var cityQuery: String = ""
    
    // Output
    @Published private(set) var isLoading = false
    @Published private(set) var weather: WeatherDisplayModel?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isUsingLocation = false
    @Published private(set) var selectedWeather: WeatherDisplayModel?
    
    
    private let weatherService: WeatherServiceProtocol
    private var lastCityStore: LastCityStoreProtocol
    private let locationManager: LocationManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        weatherService: WeatherServiceProtocol,
        lastCityStore: LastCityStoreProtocol,
        locationManager: LocationManagerProtocol
    ) {
        self.weatherService = weatherService
        self.lastCityStore = lastCityStore
        self.locationManager = locationManager
        
        bindAuthorization()
        loadInitialState()
    }

    // We need this for testing for injecting a sample weather model directly
#if DEBUG
    @MainActor
    func _injectWeatherForTesting(_ model: WeatherDisplayModel?) {
        self.weather = model
    }
#endif
    
    private func bindAuthorization() {
        locationManager.authorizationStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    Task { await self.loadWeatherFromLocation() }
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialState() {
        if let last = lastCityStore.lastCity {
            cityQuery = last
            Task { await searchWeather(by: last) }
        }
    }
    
    func onAppear() {
        // TODO: can be used for analytics, etc.
    }
    
    func searchTapped() {
        let trimmed = cityQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = NSLocalizedString("error_empty_city", comment: "")
            return
        }
        Task { await searchWeather(by: trimmed) }
    }
    
    func didTapWeatherCard() {
        guard let weather else { return }
        selectedWeather = weather
    }
    
    func requestLocationAccess() {
        Task {
            // Clear the old city text immediately when user taps the button
            self.cityQuery = ""
            await handleLocationAccess()
        }
    }
    
    private func handleLocationAccess() async {
        let status = locationManager.currentStatus
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            // Already allowed → just load weather now
            await loadWeatherFromLocation()
            
        case .notDetermined:
            // Ask for permission, actual loading happens in bindAuthorization()
            locationManager.requestLocationPermission()
            
        case .denied, .restricted:
            // Show friendly message
            errorMessage = NSLocalizedString("error_location_permission_denied", comment: "")
            
        @unknown default:
            break
        }
    }
    
    // MARK: - Async methods
    
    private func searchWeather(by city: String) async {
        isUsingLocation = false
        await loadWeather {
            try await self.weatherService.fetchWeather(city: city)
        }
        lastCityStore.lastCity = city
    }
    
    private func loadWeatherFromLocation() async {
        do {
            // Clear the text before loading
            self.cityQuery = ""
            let coord = try await locationManager.requestCurrentLocation()
            isUsingLocation = true
            
            await loadWeather {
                try await self.weatherService.fetchWeather(
                    latitude: coord.latitude,
                    longitude: coord.longitude
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func loadWeather(
        loader: @escaping () async throws -> WeatherResponse
    ) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let response = try await loader()
            weather = Self.map(response)
        } catch {
            if let wsError = error as? WeatherServiceError {
                errorMessage = wsError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Mapping
    
    private static func map(_ response: WeatherResponse) -> WeatherDisplayModel {
        let weather = response.weather.first
        let iconURL = weather.flatMap {
            URL(string: "https://openweathermap.org/img/wn/\($0.icon)@2x.png")
        }
        
        func formatTemp(_ value: Double) -> String {
            String(format: "%.1f ℃", value)
        }
        
        let timezoneOffset = response.timezone ?? 0
        let sunriseString = formatTime(
            unix: response.sys?.sunrise,
            timezoneOffset: timezoneOffset,
            fallbackKey: "sunrise_unknown"
        )
        let sunsetString = formatTime(
            unix: response.sys?.sunset,
            timezoneOffset: timezoneOffset,
            fallbackKey: "sunset_unknown"
        )
        
        let visibilityMeters = response.visibility ?? 0
        let visibilityKm = Double(visibilityMeters) / 1000.0
        let visibilityString = String(
            format: NSLocalizedString("visibility_format", comment: ""),
            visibilityKm
        )
        
        return WeatherDisplayModel(
            city: response.name,
            country: response.sys?.country,
            temperatureC: formatTemp(response.main.temp),
            feelsLikeC: String(
                format: NSLocalizedString("feels_like_format", comment: ""),
                formatTemp(response.main.feels_like)
            ),
            minTemperatureC: String(
                format: NSLocalizedString("min_temp_format", comment: ""),
                formatTemp(response.main.temp_min)
            ),
            maxTemperatureC: String(
                format: NSLocalizedString("max_temp_format", comment: ""),
                formatTemp(response.main.temp_max)
            ),
            description: weather?.description.capitalized ?? "",
            humidity: String(
                format: NSLocalizedString("humidity_format", comment: ""),
                response.main.humidity
            ),
            windSpeed: String(
                format: NSLocalizedString("wind_format", comment: ""),
                response.wind?.speed ?? 0
            ),
            sunrise: sunriseString,
            sunset: sunsetString,
            visibility: visibilityString,
            iconURL: iconURL
        )
    }
}

// MARK: - Time formatting helper

private func formatTime(unix: Int?, timezoneOffset: Int, fallbackKey: String) -> String {
    
    guard let unix else {
        return NSLocalizedString(fallbackKey, comment: "")
    }
    let date = Date(timeIntervalSince1970: TimeInterval(unix))
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .none
    formatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
    return formatter.string(from: date)
}
