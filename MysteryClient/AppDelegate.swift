//
//  AppDelegate.swift
//  MysteryClient
//
//  Created by mac on 21/06/17.
//  Copyright © 2017 Mebius. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.statusBarStyle = .lightContent
        createWorkingPath()
        MYLang.setup(langListCodes: ["it"], langFileName: "Lang.txt")
        return true
    }
    
    private func createWorkingPath () {
        let fm = FileManager.default
        
        if fm.fileExists(atPath: Config.Path.result) {
            return
        }
        do {
            try fm.createDirectory(atPath: Config.Path.result,
                                   withIntermediateDirectories: true,
                                   attributes: nil)
        } catch let error as NSError {
            print("Directory (result) error: \(error.debugDescription)")
        }

    }
}

