//
//  AppCoordinator.swift
//  WeatherApp
//
//  Created by Najmul Hasan on 12/4/25.
//

import UIKit

final class AppCoordinator {

    private let navigationController: UINavigationController
    private let weatherService: WeatherServiceProtocol
    private let lastCityStore: LastCityStoreProtocol
    private let locationManager: LocationManagerProtocol
    
    // Keep a strong reference to child coordinator
    private var weatherSearchCoordinator: WeatherSearchCoordinator?

    init(
        navigationController: UINavigationController,
        weatherService: WeatherServiceProtocol,
        lastCityStore: LastCityStoreProtocol,
        locationManager: LocationManagerProtocol
    ) {
        self.navigationController = navigationController
        self.weatherService = weatherService
        self.lastCityStore = lastCityStore
        self.locationManager = locationManager
    }

    @MainActor func start() {
        let coordinator = WeatherSearchCoordinator(
            navigationController: navigationController,
            weatherService: weatherService,
            lastCityStore: lastCityStore,
            locationManager: locationManager
        )
        self.weatherSearchCoordinator = coordinator  
        coordinator.start()
    }
}
