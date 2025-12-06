//
//  AppDelegate.swift
//  WeatherApp
//
//  Created by Najmul Hasan on 12/4/25.
//

import UIKit

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // TODO: Add analytics initialization if needed later.
        // TODO: Add dependency container if app gets bigger.
        true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        let config = UISceneConfiguration(name: "Default Configuration",
                                          sessionRole: connectingSceneSession.role)
        
        // The SceneDelegate class handles window creation.
        config.delegateClass = SceneDelegate.self
        return config
    }
}
