//
//  AppDelegate.swift
//  MGEventSearch
//
//  Created by Gupta, Mrigank on 10/04/19.
//  Copyright © 2019 Gupta, Mrigank. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else {
            return false
        }
        let navigationController = UINavigationController(rootViewController: EventSearchView())
        applyGlobalAppearanceOnSearchBar()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        return true
    }

    func applyGlobalAppearanceOnSearchBar() {
        let barButtonItem = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        barButtonItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
}
