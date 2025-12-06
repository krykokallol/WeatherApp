//
//  ViewController.swift
//  WeatherApp
//
//  Created by Najmul Hasan on 12/4/25.
//

import UIKit
import SwiftUI
import Combine

final class WeatherSearchCoordinator {
    
    private let navigationController: UINavigationController
    private let weatherService: WeatherServiceProtocol
    private let lastCityStore: LastCityStoreProtocol
    private let locationManager: LocationManagerProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
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
        let viewModel = WeatherSearchViewModel(
            weatherService: weatherService,
            lastCityStore: lastCityStore,
            locationManager: locationManager
        )
        
        // Listen for selection
        viewModel.$selectedWeather
            .compactMap { $0 }
            .sink { [weak self] model in
                self?.showDetails(for: model)
            }
            .store(in: &cancellables)
        
        let rootView = WeatherSearchView(viewModel: viewModel)
        let hosting = UIHostingController(rootView: rootView)
        hosting.title = NSLocalizedString("weather_search_title", comment: "Weather")
        navigationController.pushViewController(hosting, animated: false)
    }
    
    private func showDetails(for model: WeatherDisplayModel) {
        let detailView = WeatherDetailView(model: model)
        let hosting = UIHostingController(rootView: detailView)
        hosting.title = model.city
        navigationController.pushViewController(hosting, animated: true)
    }
}
