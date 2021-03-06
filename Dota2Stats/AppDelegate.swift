//
//  AppDelegate.swift
//  Dota2Stats
//
//  Created by Peter Chen on 2015-05-16.
//  Copyright (c) 2015 Peter Chen. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let apiSession = DotaApiSession()
        if defaults.objectForKey("HeroList") == nil {
            var heroes: [NSObject:AnyObject] = [:]
            apiSession.getHeroList(){ (result) -> () in
                println(result)
                for eachHero in result {
                    if let hero = eachHero as? NSDictionary {
                        let numId = hero["id"] as! Int
                        let id = "\(numId)"
                        let name = hero["name"] as! String
                        let localName = hero["localized_name"] as! String
                        
                        heroes[id] = ["id":id, "name":name, "localName":localName]
                    }
                }
                println(heroes)
                defaults.setObject(heroes, forKey: "HeroList")
            }
        }
        
        if defaults.objectForKey("ItemList") == nil {
            var items: [NSObject:AnyObject] = [:]
            apiSession.getItemList(){ (result) -> () in
                for eachItem in result {
                    if let item = eachItem as? NSDictionary {
                        let numId = item["id"] as! Int
                        let id = "\(numId)"
                        let name = item["name"] as! String
                        let recipe = item["recipe"] as! Bool
                        let localName = item["localized_name"] as! String
                        
                        items[id] = ["id":id, "name":name, "recipe": recipe, "localName": localName]
                    }
                }
                defaults.setObject(items, forKey: "ItemList")
            }
        }
    
        
        println(NSTemporaryDirectory())
        println(NSDate().timeIntervalSince1970)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

