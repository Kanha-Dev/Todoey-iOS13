//
//  AppDelegate.swift
//  Destini
//
//  Created by Kanha Gupta on 15/07/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //print(Realm.Configuration.defaultConfiguration.fileURL)
        
        //Realm Inititalisation Block
        do{
            _ = try Realm()
        } catch{
            print("Error Initialising new Realm \(error)")
        }
        
        return true
    }
    
}

