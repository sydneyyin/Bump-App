//
//  MainTabView.swift
//  Bump
//
//  Created by Sydney yin on 11/5/24.
//


import SwiftUI

struct MainTabView: View {
    @State private var notificationCount: Int = 0 // Example dynamic count
    @State private var doubleBumpedIds: Set<String> = []
    
    var body: some View {
        TabView {
            ContentView(doubleBumpedIds: $doubleBumpedIds)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            MapView()
                .tabItem {
                    Label( "Map", systemImage: "map")
                }

            NotificationsView(notificationCount: $notificationCount, doubleBumpedIds: $doubleBumpedIds)
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
                .badge(notificationCount > 0 ? notificationCount : 0)
            
            
        }
    }
}


struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(UserData())
            .environmentObject(FriendsDao())
    }
}
