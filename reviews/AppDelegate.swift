//
//  AppDelegate.swift
//  reviews
//
//  Created by Kateryna Gridina on 08.03.19.
//  Copyright © 2019 kate. All rights reserved.
//

import UIKit
import Swinject

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ReviewsAssembly().assemble()
        let reviewsWireframe = ReviewsWireframe()
        window?.rootViewController = reviewsWireframe.initiateReviewsViewController()
        return true
    }

}
