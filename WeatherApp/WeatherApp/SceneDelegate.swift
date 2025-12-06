//
//  SceneDelegate.swift
//  WeatherApp
//
//  Created by Najmul Hasan on 12/4/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // Creates UIWindow for UIKit
        let window = UIWindow(windowScene: windowScene)
        
        // Root navigation controller
        let navController = UINavigationController()
        navController.navigationBar.prefersLargeTitles = true
        
        // Dependency Injection (services)
        // TODO: Later move this into a Dependency Container.
        let weatherService = WeatherService(
            apiKey: "9ef6073acf3edfee5eb6eb6747ac80d3"
        )
        let lastCityStore = LastCityStore()
        let locationManager = AppLocationManager()
        
        // Coordinator
        let appCoordinator = AppCoordinator(
            navigationController: navController,
            weatherService: weatherService,
            lastCityStore: lastCityStore,
            locationManager: locationManager
        )
        
        // Keep reference to avoid Combine subscriptions being cancelled
        self.appCoordinator = appCoordinator
        appCoordinator.start()
        
        window.rootViewController = navController
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
