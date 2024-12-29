//
//  otherUser.swift
//  Bump
//
//  Created by Sydney yin on 11/1/24.
//

import Foundation
import SwiftUI

struct AddFriendView: View {
    @EnvironmentObject var userDao: UserDao
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var friendsDao: FriendsDao
    
    var isFriend = false
    var isRequested = false
        
    var body: some View {
        
        VStack {
                List(userDao.otherUsers) { user in
                    HStack {
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.headline)
                        Spacer()
                
                        //check relationship before button to add new
                        HStack{
                            if userData.id.uuidString == user.id.uppercased() {
                                Text("Me")
                                    .foregroundColor(.gray)
                            } else if friendsDao.checkIsRequested(userData: userData, friendId: user.id){
                                Text("Requested")
                                    .foregroundColor(.gray)
                            } else if friendsDao.checkIsFriend(userData: userData, friendId: user.id) {
                                Text("Friends")
                                    .foregroundColor(.gray)
                            } else {
                                Button(action: {
                                    userDao.addFriend(userId: user.id, userData: userData)
                                    // addfriend to the friendDao
                                    friendsDao.addFriend(userData: userData, friendId: user.id)
                                }) {
                                    Image("AddFriendButton")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 43, height: 43)
                                }
                            }
                        } //end of hstack
                        .frame(maxWidth: 90, alignment:.center)
                    }
                    //.padding(.vertical, 5) // Add some padding around each row
                    .frame(height:53)
                    
                } // end of list
                .onAppear {
                    userDao.fetchUserDetails()
                    print("we've fetched")
                }
            
        } // end of vstack
    } //end of body view
    
    private func checkIsRequested (friendId: String) -> Bool {
        return friendsDao.checkIsRequested(userData:userData, friendId: friendId)
        }
    
    private func checkIsFriend(friendId: String) -> (Bool) {
        return friendsDao.checkIsFriend(userData:userData, friendId: friendId)
    }
    
    private func isMe(userId: String) -> Bool {
        return userData.id.uuidString == userId
        }
    
    
    
} //end of struct

struct AddFriendView_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendView()
            .environmentObject(UserData())
            .environmentObject(UserDao())
            .environmentObject(FriendsDao())
    }
}


