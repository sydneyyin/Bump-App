//
//  UserData.swift
//  Bump
//
//  Created by Sydney yin on 10/21/24.
//

import Foundation
import SwiftUI

class UserData: ObservableObject {
    @Published var id: UUID
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var bumpOn: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var friends: [[String: String]] = []

    struct FriendData: Identifiable {
        var id: String
        var firstName: String
        var lastName: String
        var isFriend: Bool
        var bumpOn: Bool
        var bumped: Bool
        var lastBumped: Date?
        var latitude: Double? // New property
        var longitude: Double? // New property
    }
    
    @Published var friendsData: [FriendData] = [] // Use the struct here
    
    
    init() {
            self.id = UUID() // Generate a new UUID
            self.firstName = ""
            self.lastName = ""
            self.email = ""
            self.password = ""
            self.bumpOn = false
            self.isLoggedIn = false
            self.friendsData = [] // Initialize empty array
        }
        
        // Existing isEmpty() method remains unchanged
        func isEmpty() -> Bool {
            return firstName.isEmpty && lastName.isEmpty && email.isEmpty && !bumpOn
        }
    
    func clearData() {
        id = UUID() // Generate a new UUID for the user
        firstName = ""
        lastName = ""
        email = ""
        password = ""
        bumpOn = false
        isLoggedIn = false
        friends.removeAll() // Clear the friends array
        friendsData.removeAll() // Clear the friendsData array
    }
    
    // Function to check if user ID exists in friends
//    func isFriend(userId: String) -> Bool {
//        return self.friends.contains { friend in
//            friend["id"] == userId
//        }
//    }
}
