//
//  BumpButton.swift
//  Bump
//
//  Created by Sydney yin on 11/4/24.
//

import SwiftUI

struct BumpButton: View {
    @EnvironmentObject var friendsDao: FriendsDao // Use EnvironmentObject for your DAO
    @ObservedObject var userData: UserData // ObservedObject to get updates from UserData
    var friendId: String // The ID of the friend to bump
    
    @State private var isBumped = false // State variable to track if the button has been pressed
    @State private var canBumpAgain = true // Track if user can bump again
    
    // Function to check if 1 hour has passed from the database
    private func checkIfCanPressAgain() {
        // Find the last bumped date for the specific friend
        if let friend = userData.friendsData.first(where: { $0.id == friendId }),
           let lastBumped = friend.lastBumped {
            let timeElapsed = Date().timeIntervalSince(lastBumped)
            canBumpAgain = timeElapsed >= 900 // 1 hour = 3600 seconds, 15 mins = 900 seconds
        } else {
            canBumpAgain = true // If there's no lastBumped date, allow bumping
        }
        
        // Update the button state based on whether the user can bump again
        isBumped = !canBumpAgain
    }


    var body: some View {
        Button(action: {
            friendsDao.sendBump(userData: userData, friendId: friendId, bumped: true) // Call sendBump
            isBumped = true // Update state to indicate the button has been pressed
        }) {
            Text("Bump")
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 65, height: 45)
                .background(isBumped ? Color.gray : Color(red: 0.027, green: 0.773, blue: 0.349))
                .cornerRadius(50)
                .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.white, lineWidth: 1)
                )
        }
        .accessibilityLabel("Bump friend")
        .disabled(isBumped) // Disable the button after being pressed
    }
}

