//
//  MapView.swift
//  Bump
//
//  Created by Sydney yin on 12/7/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var userData: UserData // Friends' locations
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default region
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        VStack {
            if let userLocation = locationManager.userLocation {
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: userData.friendsData) { friend in
                    MapMarker(
                        coordinate: CLLocationCoordinate2D(
                            latitude: friend.latitude ?? 0,
                            longitude: friend.longitude ?? 0
                        ),
                        tint: .blue
                    )
                }
                .onAppear {
                    region.center = userLocation
                }
            } else {
                Text("Fetching location...")
            }
        }
        .onAppear {
            locationManager.requestPermission()
        }
    }
}

//import SwiftUI
//
//struct MapView: View {
//    @StateObject private var locationManager = LocationManager()
//    @EnvironmentObject var userData: UserData // Friends' locations
//    @State private var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default region
//        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//    )
//
//    var body: some View {
//        VStack {
//            if let userLocation = locationManager.userLocation {
//                MapViewRepresentable(region: $region, friends: userData.friendsData)
//                    .onAppear {
//                        region.center = userLocation
//                    }
//            } else {
//                Text("Fetching location...")
//            }
//        }
//        .onAppear {
//            locationManager.requestPermission()
//        }
//    }
//}




#Preview {
    MapView()
}
