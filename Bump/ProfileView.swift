//
//  ProfileView.swift
//  Bump
//
//  Created by Sydney yin on 10/20/24.
//

import SwiftUI


struct EditProfileView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var userDao: UserDao
    @State private var firstName: String
    @State private var lastName: String
    @State private var isEditing = false
    @Binding var showEditProfileView: Bool  // Binding to control the visibility of the EditProfileView
    @Environment(\.presentationMode) var presentationMode // For navigation control
    
    init(showEditProfileView: Binding<Bool>) {
        _firstName = State(initialValue: "")
        _lastName = State(initialValue: "")
        _showEditProfileView = showEditProfileView
    }
    
    var body: some View {
        NavigationView{
            VStack {
                // Initials Box
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.5)) // Circle background
                        .frame(width: 120, height: 120)

                    Text("\(userData.firstName.prefix(1).uppercased())\(userData.lastName.prefix(1).uppercased())")
                        .font(.system(size: 50, weight: .bold)) // Style the initials
                        .foregroundColor(.white) // Text color
                }
                .padding()

                
                HStack {
                    Text("First Name:")
                        .font(.headline)
                    TextField("Enter First Name", text: $firstName)
                        .font(.system(size: 18))
                        .textFieldStyle(PlainTextFieldStyle()) // No box
                    
                }
                .padding()
                
                HStack {
                    Text("Last Name:")
                        .font(.headline)
                    TextField("Enter Last Name", text: $lastName)
                        .font(.system(size: 18))
                        .textFieldStyle(PlainTextFieldStyle()) // No box
                }
                .padding()
                
                Spacer()
                
                // Logout Button
                Button("Log Out") {
                    userData.isLoggedIn = false
                    userData.clearData()
                    self.presentationMode.wrappedValue.dismiss()
                }
                .font(.system(size: 18))
                .padding()
                .foregroundColor(.white)
                .background(Color.gray)
                .cornerRadius(16)
                
                Spacer()
                
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Save Button on the Top Right
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        userData.firstName = firstName
                        userData.lastName = lastName
                        userDao.updateUserData(userData: userData)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 18))
                }
            } // end of toolbar
            .onAppear {
                firstName = userData.firstName
                lastName = userData.lastName
            }
        }
        
    }
}


//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//            .environmentObject(UserData())
//    }
//}

