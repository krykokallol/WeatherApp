//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Najmul Hasan on 12/4/25.
//

import CoreLocation
import Combine

protocol LocationManagerProtocol {
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
    var currentStatus: CLAuthorizationStatus { get }

    func requestLocationPermission()
    func requestCurrentLocation() async throws -> CLLocationCoordinate2D
}

final class AppLocationManager: NSObject, LocationManagerProtocol {
    
    private let manager = CLLocationManager()
    private let authorizationSubject = CurrentValueSubject<CLAuthorizationStatus, Never>(.notDetermined)
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    
    override init() {
        super.init()
        manager.delegate = self
        // Seed with current status
        authorizationSubject.send(manager.authorizationStatus)
    }
    
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        authorizationSubject.eraseToAnyPublisher()
    }
    
    var currentStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }
    
    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func requestCurrentLocation() async throws -> CLLocationCoordinate2D {
        guard CLLocationManager.locationServicesEnabled() else {
            throw WeatherServiceError.locationUnavailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            manager.requestLocation()
        }
    }
}

extension AppLocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationSubject.send(manager.authorizationStatus)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = locations.first?.coordinate {
            locationContinuation?.resume(returning: coord)
            locationContinuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}

