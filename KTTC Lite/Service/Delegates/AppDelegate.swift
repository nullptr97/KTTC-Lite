//
//  AppDelegate.swift
//  WoT Manager
//
//  Created by Ярослав Стрельников on 11.10.2021.
//

import UIKit

protocol Expectable {
    func getExpectedValues()
}

@main class AppDelegate: UIResponder, UIApplicationDelegate, Expectable {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        getExpectedValues()
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

    internal func getExpectedValues() {
        let api = KTTCApi()
        api.requestXVM(with: Info.self).start { expectedValues in
            guard let expectedValues = expectedValues.data else { return }
            Constants.expectedValues = expectedValues
        } error: { error in
            print("Expected values not updated: \(error)")
        } completed: {
            print("Expected values updated")
        }
    }
}

