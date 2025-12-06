//
//  LastCityStore.swift
//  WeatherApp
//
//  Created by Najmul Hasan on 12/4/25.
//

import Foundation

protocol LastCityStoreProtocol {
    var lastCity: String? { get set }
}

final class LastCityStore: LastCityStoreProtocol {

    private let key = "LastCityKey"

    var lastCity: String? {
        get { UserDefaults.standard.string(forKey: key) }
        set { UserDefaults.standard.setValue(newValue, forKey: key) }
    }
}

