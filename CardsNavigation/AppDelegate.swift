//
//  AppDelegate.swift
//  CardsNavigation
//
//  Created by Alexander Graschenkov on 07.08.2018.
//  Copyright © 2018 Alex Development. All rights reserved.
//

import UIKit
import Liquid

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func printPoints(function: CAMediaTimingFunction) {
        var cps = [Float](repeating: 0, count: 4)
        function.getControlPoint(at: 0, values: &cps[0])
        function.getControlPoint(at: 1, values: &cps[1])
        function.getControlPoint(at: 2, values: &cps[2])
        function.getControlPoint(at: 3, values: &cps[3])
        
        print("p1 Point(\(cps[0]), \(cps[1]))")
        print("p2 Point(\(cps[2]), \(cps[3]))")
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        Liquid.shared.becomeDelegate()
        Liquid.shared.addTransitions([CardTransition(),
                                      PhotoOpenTransition(),
                                      BrokenViewTransition(),
                                      FadeTransition(),
                                      TransitionLibTransition(),
                                      UserCardTransition()])
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

