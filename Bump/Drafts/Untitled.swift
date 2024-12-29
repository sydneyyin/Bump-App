//
//  Untitled.swift
//  Bump
//
//  Created by Sydney yin on 11/10/24.
//

//import UIKit
//import UserNotifications
//
//@main
//class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
//
//    var window: UIWindow?
//
//    func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//    ) -> Bool {
//        // Request notification permissions
//        UNUserNotificationCenter.current().delegate = self
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
//            if let error = error {
//                print("Error requesting authorization: \(error)")
//            }
//            if granted {
//                DispatchQueue.main.async {
//                    application.registerForRemoteNotifications()
//                }
//            }
//        }
//        return true
//    }
//
//    // Handle registration success
//    func application(
//        _ application: UIApplication,
//        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
//    ) {
//        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
//        print("Device Token: \(tokenString)")
//        // Send the token to your server here
//    }
//
//    // Handle registration failure
//    func application(
//        _ application: UIApplication,
//        didFailToRegisterForRemoteNotificationsWithError error: Error
//    ) {
//        print("Failed to register: \(error.localizedDescription)")
//    }
//}
