//
//  ClearLayerApp.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/05/20.
//

import SwiftUI
import GoogleMobileAds

@main
struct ClearLayerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
            MobileAds.shared.start(completionHandler: nil)
        return true
    }
}
