//
//  WeatherSearchViewModelTests.swift
//  WeatherAppTests
//
//  Created by Najmul Hasan on 12/5/25.
//

import XCTest

import XCTest
@testable import WeatherApp
import Combine
import CoreLocation

final class WeatherSearchViewModelTests: XCTestCase {

    // MARK: - Basic search tests
    @MainActor
    func testInitialLoad_UsesLastCityAndFetchesWeather() async {
        let service = MockWeatherService()
        service.stubbedResponse = MockWeatherService.sampleResponse()

        let store = MockLastCityStore(lastCity: "San Francisco")
        let location = MockLocationManager()

        let vm = WeatherSearchViewModel(
            weatherService: service,
            lastCityStore: store,
            locationManager: location
        )

        // Allow async init tasks to run
        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(vm.cityQuery, "San Francisco")
        XCTAssertNotNil(vm.weather)
        XCTAssertEqual(service.fetchWeatherCityCallCount, 1)
        XCTAssertEqual(service.lastCityArgument, "San Francisco")
    }

    @MainActor
    func testSearchEmptyCity_ShowsErrorMessage() async {
        let vm = WeatherSearchViewModel(
            weatherService: MockWeatherService(),
            lastCityStore: MockLastCityStore(),
            locationManager: MockLocationManager()
        )

        vm.cityQuery = "   "     // only spaces
        vm.searchTapped()

        XCTAssertNotNil(vm.errorMessage)
    }

    @MainActor
    func testSearchValidCity_UpdatesWeatherAndSavesLastCity() async {
        let service = MockWeatherService()
        service.stubbedResponse = MockWeatherService.sampleResponse(city: "New York")

        let store = MockLastCityStore()
        let location = MockLocationManager()

        let vm = WeatherSearchViewModel(
            weatherService: service,
            lastCityStore: store,
            locationManager: location
        )

        vm.cityQuery = "New York"
        vm.searchTapped()

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(vm.weather?.city, "New York")
        XCTAssertEqual(store.lastCity, "New York")
    }

    // MARK: - Location tests
    @MainActor
    func testRequestLocationAccess_WhenAuthorized_LoadsLocationWeatherAndClearsCity() async {
        let service = MockWeatherService()
        service.stubbedResponse = MockWeatherService.sampleResponse(city: "Cupertino")

        let store = MockLastCityStore()
        let location = MockLocationManager()
        location.currentStatus = .authorizedWhenInUse
        location.stubbedCoordinate = CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090)

        let vm = WeatherSearchViewModel(
            weatherService: service,
            lastCityStore: store,
            locationManager: location
        )

        vm.cityQuery = "Old City"

        vm.requestLocationAccess()

        try? await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertEqual(vm.weather?.city, "Cupertino")
        XCTAssertTrue(vm.isUsingLocation)
        XCTAssertEqual(vm.cityQuery, "")   // cleared
        XCTAssertEqual(location.requestLocationCallCount, 1)
    }

    @MainActor
    func testDidTapWeatherCard_SetsSelectedWeather() async {
        let service = MockWeatherService()
        let store = MockLastCityStore()
        let location = MockLocationManager()

        let vm = WeatherSearchViewModel(
            weatherService: service,
            lastCityStore: store,
            locationManager: location
        )

        // Inject a sample weather model directly
        let sampleModel = WeatherDisplayModel(
            city: "Test City",
            country: "US",
            temperatureC: "20.0 ℃",
            feelsLikeC: "Feels like 19.0 ℃",
            minTemperatureC: "Min: 18.0 ℃",
            maxTemperatureC: "Max: 22.0 ℃",
            description: "Clear Sky",
            humidity: "Humidity: 50%",
            windSpeed: "Wind: 3.0 m/s",
            sunrise: "7:00 AM",
            sunset: "7:00 PM",
            visibility: "Visibility: 10.0 km",
            iconURL: nil
        )

        vm._injectWeatherForTesting(sampleModel)
        vm.didTapWeatherCard()

        XCTAssertEqual(vm.selectedWeather?.city, "Test City")
    }
}

// MARK: - Mocks

final class MockWeatherService: WeatherServiceProtocol {

    var fetchWeatherCityCallCount = 0
    var lastCityArgument: String?
    var fetchWeatherLatLonCallCount = 0

    var stubbedResponse: WeatherResponse?

    func fetchWeather(city: String) async throws -> WeatherResponse {
        fetchWeatherCityCallCount += 1
        lastCityArgument = city
        if let stubbedResponse {
            return stubbedResponse
        }
        return Self.sampleResponse(city: city)
    }

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        fetchWeatherLatLonCallCount += 1
        if let stubbedResponse {
            return stubbedResponse
        }
        return Self.sampleResponse(city: "Location City")
    }

    func fetchWeatherPublisher(city: String) -> AnyPublisher<WeatherResponse, Error> {
        fatalError("Not used in tests")
    }

    // Helper to build a sample response
    static func sampleResponse(city: String = "Mock City") -> WeatherResponse {
        return WeatherResponse(
            name: city,
            weather: [
                WeatherResponse.Weather(
                    main: "Clouds",
                    description: "scattered clouds",
                    icon: "03d"
                )
            ],
            main: WeatherResponse.Main(
                temp: 20,
                feels_like: 19,
                temp_min: 18,
                temp_max: 22,
                humidity: 60
            ),
            wind: WeatherResponse.Wind(speed: 3.4),
            sys: WeatherResponse.Sys(
                country: "US",
                sunrise: 1_700_000_000,
                sunset: 1_700_036_000
            ),
            visibility: 10_000,
            timezone: 0
        )
    }
}

final class MockLastCityStore: LastCityStoreProtocol {
    var lastCity: String?

    init(lastCity: String? = nil) {
        self.lastCity = lastCity
    }
}

final class MockLocationManager: LocationManagerProtocol {

    var currentStatus: CLAuthorizationStatus = .notDetermined
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        authorizationSubject.eraseToAnyPublisher()
    }

    private let authorizationSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(.notDetermined)

    var stubbedCoordinate: CLLocationCoordinate2D?
    var requestLocationCallCount = 0
    var requestPermissionCallCount = 0

    func requestLocationPermission() {
        requestPermissionCallCount += 1
        // Simulate immediate change if needed
        authorizationSubject.send(currentStatus)
    }

    func requestCurrentLocation() async throws -> CLLocationCoordinate2D {
        requestLocationCallCount += 1
        if let c = stubbedCoordinate {
            return c
        }
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
}
