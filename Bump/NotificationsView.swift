//
//  Notifications.swift
//  Bump
//
// Once button created 
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var userDao: UserDao
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var friendsDao: FriendsDao
    
    @Binding var notificationCount: Int // Binding to parent notification count
    
    @State private var recentBumps: [(id: String, firstName: String, lastName: String, lastBumped: Date)] = []
    @State private var olderBumps: [(id: String, firstName: String, lastName: String, lastBumped: Date)] = []
    @State private var friendedMe: [(id: String, firstName: String, lastName: String)] = []
    @State private var doubleBumped: [(id: String, firstName: String, lastName: String)] = []
    
    @Binding var doubleBumpedIds: Set<String> // Binding to pass doubleBumpedIds


    var body: some View {
        //NavigationView{
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title for the screen
                    Text("Notifications")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Friend Requests")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(friendedMe, id: \.id) { friend in // Use friend's ID as the unique identifier
                            HStack {
                                Text("\(friend.firstName) \(friend.lastName)")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button(action:{
                                    friendsDao.confirmFriend(userData: userData, friendId: friend.id)
                                    loadData()
                                }){
                                    Text("Confirm Friend")
                                }
                                
                            } // end of hstack
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                    }
                    
                    Divider()
                    
                    // Section for accepted (two bumps)
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Let's Link Up!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if doubleBumped.isEmpty {
                            Text("No Linkups")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            ForEach(doubleBumped, id: \.id) { friend in
                                DoubleBumpedRow(userData: userData, friend: friend)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    Divider()
                    
                    // Section for recent bumps
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Recent Bumps")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if recentBumps.isEmpty {
                            Text("No recent bumps")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            ForEach(recentBumps, id: \.id) { friend in
                                NotificationRow(userData: userData, friend: friend)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    
                    Divider() // Add a divider between sections
                    
                    // Section for older bumps
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Older")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if olderBumps.isEmpty {
                            Text("No older bumps")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            ForEach(olderBumps, id: \.id) { friend in
                                NotificationRow(userData:userData, friend: friend)
                                    .padding(.horizontal)
                                
                            }
                        }
                    } //end of older bumps
                } //end of bigger vstack
                .padding(.top, 20) // Adjust top padding as needed
            } // end of scroll view
            .onAppear {loadData()} // end of on appear
    //} end of navigation view
    } //end of some view
    
    private func loadData() {
        print("in loadData")
        
        // Fetch bumpedMe updates
        let previousBumpedMeIds = Set(recentBumps.map { $0.id })
        let updatedBumpedMe = friendsDao.fetchBumpedMe(userData: userData)
        
        // Fetch double bumps
        let previousDoubleBumpedIds = Set(doubleBumped.map { $0.id })
        let updatedDoubleBumped = friendsDao.fetchDoubleBumped(userData: userData)
        doubleBumped = updatedDoubleBumped
        
        // Get the IDs of double bumped friends
        doubleBumpedIds = Set(doubleBumped.map { $0.id })
        
        // Filter recent and older bumps, excluding double bumped friends
        let oneHourAgo = Date().addingTimeInterval(-3600)
        recentBumps = updatedBumpedMe.filter {
            $0.lastBumped >= oneHourAgo && !doubleBumpedIds.contains($0.id)
        }
        olderBumps = updatedBumpedMe.filter {
            $0.lastBumped < oneHourAgo && !doubleBumpedIds.contains($0.id)
        }
        
        // Identify new recent bumps
        let newRecentBumps = recentBumps.filter { !previousBumpedMeIds.contains($0.id) }
        let newBumpsCount = newRecentBumps.count
        if newBumpsCount > 0 {
            notificationCount += newBumpsCount
        }
        
        // Identify new Double Bumped
        let newDoubleBumped = doubleBumped.filter { !previousDoubleBumpedIds.contains($0.id) }
        let newDoubleBumpedCount = newDoubleBumped.count
        if newDoubleBumpedCount > 0 {
            notificationCount += newDoubleBumpedCount
        }
        
        // Fetch friendedMe updates
        let previousFriendedMeIds = Set(friendedMe.map { $0.id })
        let updatedFriendedMe = friendsDao.fetchFriendedMe(userData: userData)
        
        // Track removed friend requests (accepted friends)
        let removedFriendRequests = friendedMe.filter { !updatedFriendedMe.map { $0.id }.contains($0.id) }
        let removedFriendRequestsCount = removedFriendRequests.count
        if removedFriendRequestsCount > 0 {
            notificationCount -= removedFriendRequestsCount
        }
        
        friendedMe = updatedFriendedMe
    
        // Identify new friend requests
        let newFriendRequests = friendedMe.filter { !previousFriendedMeIds.contains($0.id) }
        let newRequestsCount = newFriendRequests.count
        if newRequestsCount > 0 {
            notificationCount += newRequestsCount
        }
    
        // Debugging logs
        print("friendedMe: \(friendedMe)")
        print("notificationview doubleBumped: \(doubleBumped)")
        print("recentBumps: \(recentBumps)")
        print("olderBumps: \(olderBumps)")
        print("end of loadData")
    }
}



//struct NotificationsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationsView(notificationCount: $notificationCount)
//            .environmentObject(FriendsDao())
//            .environmentObject(UserData())
//    }
//}



