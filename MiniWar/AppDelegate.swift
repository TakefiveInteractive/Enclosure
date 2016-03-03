//
//  AppDelegate.swift
//  MiniWar
//
//  Created by Kedan Li on 2/20/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let socket = Socket()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
//        let game = EnclosureGame()

        
        var set1 = ["1" : [1,2,4,7,3,5,4,7,2,7,53,56,43,76,87,43,56,234,45,56,76,78,345,76,345,12,4567,26,35,47,46345,1334,609,890,920,857,384,659,187,3461,23,478,1029,348,701,934,8,56] , "2456": [12,234,2344], "3542": [12,234,2344],"24536": [12,234,2344],"245": [12,234,2344],"2353": [12,234,2344], "32": [12,234,2344],"363452": [12,234,2344],"24566": [12,234,2344],"22345": [12,234,2344]]
        
//        let set2 = Set([384,659,187,1,2,40])
//        print(Tool.profile { () -> () in
//            set1 = set1.union(set2)
//        })6
//        print(Tool.profile { () -> () in
//            for s in set2{
//                if set1.contains(s){
//                    
//                }
//            }
//            })
//
//        print(Tool.profile { () -> () in
//            let arr = set1["1"]
//            for x in arr!{
//                let e = 1+1
//            }
//        })
//        
//        print(Tool.profile { () -> () in
//            for x in set1["1"]!{
//                let e = 1+1
//            }
//        })

//
//        print(Tool.profile { () -> () in
//            for index in 1...5000 {
//                set1.insert(49)
//            }
//            })
        
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

