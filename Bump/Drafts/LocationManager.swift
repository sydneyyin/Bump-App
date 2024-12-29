//
//  LocationManager.swift
//  Bump
//
//  Created by Sydney yin on 12/7/24.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var userLocation: CLLocationCoordinate2D? // Stores the user's current location
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined // Tracks the permission status

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        requestPermission()
    }

    func requestPermission() {
        // Ask for location permissions
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        // Start getting location updates
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        // Stop location updates when not needed
        locationManager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate Methods

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Update authorization status
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            startUpdatingLocation()
        } else {
            stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Get the user's latest location
        if let location = locations.last {
            DispatchQueue.main.async {
                let userLocation = location.coordinate
            }
        }
    }
    


    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

