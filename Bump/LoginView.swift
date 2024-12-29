//
//  LoginView.swift
//  Bump
//
//  Created by Sydney yin on 11/7/24.
// make sure it takes to new tab if it works

import SwiftUI

struct LoginPage: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var userDao: UserDao
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loginError: String?
    @Binding var showLogin: Bool
    @FocusState private var focusedField: FocusedField? // Track which field is focused
    
    private enum FocusedField {
            case email, password
        }
    
    var body: some View {
        VStack {
            Spacer()
            Text("Welcome Back!")
                .font(.largeTitle)
            
            TextField("Email", text: $email)
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
            
            TextField("Password", text: $password)
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
            
            //login button
            Button(action: {
                Task {
                    await attemptLogin()
                }
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity) // Expands button width if neede
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.purple)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    
            }
            .padding()
            
            if let error = loginError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .multilineTextAlignment(.center) // Ensures wrapped alignment
            }
            
            
            //create profile
            Button(action: {
                showLogin = false
            }) {
                Text("Don't have account? Create profile")
                
            }
            .padding()
            Spacer()
            
        }
        //.padding()
    }
    
    // Function to attempt login
    func attemptLogin() async {
        
        let (userId, firstName, lastName) = await userDao.validateLogin(email: email, password: password)
        
        if let userId = userId {
            userData.id = userId
            userData.firstName = firstName
            userData.lastName = lastName
            userData.email = email
            userData.isLoggedIn = true
            showLogin = false
        } else {
            loginError = "Invalid email or password"
        }
        
    }
}


//struct LoginPage_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginPage(showLogin: $showLogin)
//            .environmentObject(UserDao())
//            .environmentObject(UserData())
//    }
//}
