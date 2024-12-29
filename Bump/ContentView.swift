//
//
//

import SwiftUI

struct ContentView: View {
    
    @State private var addFriend = false
    @State private var showAddFriendView = false
    @State private var showEditProfileView = false
    
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var userDao: UserDao
    @StateObject private var friendsDao = FriendsDao()
    
    @Binding var doubleBumpedIds: Set<String> // Binding from parent


    var body: some View {
        NavigationView(){
        VStack() {
            HStack {
                Button (action:{ showEditProfileView = true }){
                    HStack{
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 60, height: 60)
                            .padding()
                        Text("\(userData.firstName) \(userData.lastName)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black) // Set text color to black or any other color
                    }
                }
                .buttonStyle(PlainButtonStyle()) // Remove default button styles (like blue)
                .sheet(isPresented: $showEditProfileView) {
                    // Present the EditProfileView as a sheet
                    EditProfileView(showEditProfileView: $showEditProfileView)
                }
                
                
                Spacer()
                Button(action: { showAddFriendView = true }) {
                    Image("AddFriendButton")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 43, height: 43)
                }
                NavigationLink("", destination:  AddFriendView(), isActive: $showAddFriendView)
            } //end of hstack
            //.padding()
        
            if showEditProfileView {
                EditProfileView(showEditProfileView: $showEditProfileView)
                    .environmentObject(userData)
                    .environmentObject(userDao)
            }
            
        //Start of bump on button
        Button(action:{
            userData.bumpOn.toggle()
            userDao.updateStatus(userData: userData)

        }){
            Text(userData.bumpOn ? "Bump ON!": "Off")
                .padding()
                .frame(width: 167, height: 167)
                .background(userData.bumpOn ? Color.green: Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .clipShape(Circle()) // Make the button round
                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 4) // Add shadow
                .animation(.easeInOut,value:userData.bumpOn)
        }
        .padding()
        
            Spacer()
            VStack (alignment: .leading){
                // Header
                    HStack {
                        Text("Friends")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                
                // Show my friends
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Assuming `friendsData` is an array of friend objects with their details
                        ForEach(userData.friendsData.filter {$0.isFriend}, id: \.id) { friend in // Use friend's ID as the unique identifier
                            HStack {
                                Text("\(friend.firstName) \(friend.lastName)")
                                    .font(.headline)
                                
                                Spacer()
                                
                                if friend.bumpOn && !doubleBumpedIds.contains(friend.id){
                                    BumpButton(userData:userData, friendId: friend.id) // Pass user data and friend's ID
                                }
                                
                            } // end of hstack
                            .padding()
                            .frame(maxWidth: .infinity)
                            .frame(height:70)
                            .background(
                                doubleBumpedIds.contains(friend.id) ? Color(.systemGreen).opacity(0.1) : Color(.systemGray6)
                            )
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                    } //end of vstack
                }
            } //end of vstack Friends
            
        } //end of Vstack
        .onAppear {
            userDao.fetchUserStatus(userData: userData)
            friendsDao.fetchFriends(userData: userData)
            updateDoubleBumpedIds()
            print("contentview doublebumped: \(doubleBumpedIds)")
        }
        .navigationBarHidden(true)
        }
    } //end of some view
    
    private func updateDoubleBumpedIds() {
        // Fetch and update `doubleBumpedIds` when `ContentView` appears
        let doubleBumped = friendsDao.fetchDoubleBumped(userData: userData)
        doubleBumpedIds = Set(doubleBumped.map { $0.id })
    }
    
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .environmentObject(UserData())
//    }
//}

