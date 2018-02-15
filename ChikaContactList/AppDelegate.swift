//
//  AppDelegate.swift
//  ChikaContactList
//
//  Created by Mounir Ybanez on 2/14/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import UIKit
import ChikaCore
import ChikaFirebase
import FirebaseCommunity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        if let uid = FirebaseCommunity.Auth.auth().currentUser?.uid, !uid.isEmpty {
            makeSceneAsRoot()
            
        } else {
            let action = SignIn()
            let _ = action.signIn(withEmail: "waa@waa.com", password: "mynameiswaa") { result in
                print(result)
                self.makeSceneAsRoot()
            }
        }

        return true
    }
    
    func makeSceneAsRoot() {
        let scene = Factory().onSelectContact({
            print("select", $0)
            
        }).onDeselectContact({
            print("deselect:", $0)
        
        }).isSelectionEnabled({
            true
            
        }).withInitialSelectedContactIDs({
            [
                ID("7OYWnGH1PWfi1cKEq1sAeMVSw0y2"),
//                ID("cicStvHdPWbbiEEFLPdlqXn6rHy2"),
            ]
            
        }).build()
        
        window?.rootViewController = scene
        window?.makeKeyAndVisible()
    }

}

