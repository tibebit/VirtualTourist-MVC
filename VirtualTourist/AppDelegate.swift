//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Fabio Tiberio on 14/05/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        isFirstLaunch()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func isFirstLaunch() {
        // if app has not launched before set the values for the initial map location
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            UserDefaults.standard.setValue(true, forKey: "hasLaunchedBefore")
            UserDefaults.standard.setValue(37.334599999999995, forKey: "latitude")
            UserDefaults.standard.setValue(-122.00919999999999, forKey: "longitude")
            UserDefaults.standard.setValue(3, forKey: "latitudeDelta")
            UserDefaults.standard.setValue(3, forKey: "longitudeDelta")
        }
    }
}

