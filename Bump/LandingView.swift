//
//  Need to make sheet a page navigation so it jumps
//

import SwiftUI

struct LandingPage: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var userDao: UserDao
    @State private var showLogin = false
    @FocusState private var focusedField: FocusedField? // Track which field is focused
    
    private enum FocusedField {
        case firstname, lastname, email, password
    }
    
    var body: some View {
        NavigationView {
            ZStack{
                VStack{
                    Text("Welcome to")
                        .font(.largeTitle)
                        //.multilineTextAlignment(.leading)
                    
                    Image("Bump")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                        .padding()
                    
                    VStack (spacing: 16) {
                        TextField("First name",text:$userData.firstName)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.systemPurple).opacity(0.1)) // Light purple background
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(focusedField == .firstname ? Color.purple : Color.clear, lineWidth: 2)
                            )
                            .focused($focusedField, equals: .firstname) // Bind focus state
                            .padding(.horizontal)
                        
                        TextField("Last Name", text: $userData.lastName)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.systemPurple).opacity(0.1)) // Light purple background
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(focusedField == .lastname ? Color.purple : Color.clear, lineWidth: 2)
                            )
                            .focused($focusedField, equals: .lastname) // Bind focus state
                            .padding(.horizontal)
                        
                        TextField("Email", text: $userData.email)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.systemPurple).opacity(0.1)) // Light purple background
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(focusedField == .email ? Color.purple : Color.clear, lineWidth: 2)
                            )
                            .focused($focusedField, equals: .email) // Bind focus state
                            .padding(.horizontal)
                        
                        TextField("Password", text: $userData.password)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.systemPurple).opacity(0.1)) // Light purple background
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(focusedField == .password ? Color.purple : Color.clear, lineWidth: 2)
                            )
                            .focused($focusedField, equals: .password) // Bind focus state
                            .padding(.horizontal)
                    } // end of vstack for input
                    
                    //Button to create profile and save data
                    Button(action: {
                        userData.isLoggedIn = true
                        Task {
                            await saveUserDataAsync()
                        }
                    }) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.purple)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                    .padding()
                    
                    // Button to navigate to the Login page
                    Button(action: {
                        showLogin = true
                    }) {
                        Text("Already have account? Login")
                        
                    }
                    .padding()
                } //end of vstack
                
                // Conditionally show the login page
                if showLogin {
                    ZStack {
                        LoginPage(showLogin: $showLogin)
                            .environmentObject(userData)
                            .background(Color.white)
                    }
                    .zIndex(1) // Ensure it stays on top
                } //end of showlogin
                
                
            } //end of zstack
            .navigationBarHidden(true)
            .animation(.easeInOut, value: showLogin) // Smooth transition
        } //end of nav view
        .navigationViewStyle(StackNavigationViewStyle())
    } //end of var view
        
    
    //Function to save data
    func initializeUserDao() {
        // Ensure userDao is initialized before attempting to save data
        _ = userDao.connectionStatus // may be problematic
    }
     
    func saveUserDataAsync() async {
        userDao.insertUserData(userData: userData)
        userDao.savedSuccessfully = true
    }
    
} //end of struct


struct LandingPage_Previews: PreviewProvider {
    static var previews: some View {
        LandingPage()
            .environmentObject(UserData())
    }
}
 
 
