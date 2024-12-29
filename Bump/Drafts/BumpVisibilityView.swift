//
//  AddFriendRow.swift
//  Bump
//
//

//import SwiftUI
//
//
//
//struct bumpVisibilityView: View {
//    @EnvironmentObject var userData: UserData
//    @StateObject private var userDao = UserDao()
//    
//    
//    var body: some View {
//        ScrollView {
//            VStack{
//                HStack {
//                    Text("All Friends")
//                        .font(.body)
//                        .fontWeight(.bold)
//                        .foregroundColor(.black)
//                    
//                    Spacer()
//                    ToggleButton()
//                }
//                .padding(.vertical, 11)
//                .padding(.horizontal)
//                .background(Color(red: 217/255, green: 217/255, blue: 217/255))
//            }
//            .padding()
//            
//            Divider()
//            
//            //Vstack
//            VStack(alignment: .center, spacing: 30) {
//                ForEach(0..<5) { _ in
//                    FriendBumpRow()
//                }
//            }
//            .padding(.top, 30)
//            .frame(maxWidth: 321)
//            
//            //To DO: add navigator
//            //TO DO: add save friend toggle later
//            Button(action: {
//                // Add friend action
//                userData.bumpOn.toggle()
//                userDao.updateStatus(userData: userData)
//            }) {
//                Image("Go")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 43, height: 43)
//            }
//            .accessibilityLabel("GoButton")
//            .padding(.top, 58)
//            .frame(maxWidth: 335, alignment: .trailing)
//             
//            Text(userData.bumpOn ? "Bump On" : "Bump Off")
//            
//        }
//    }
//}

//struct bumpVisibilityView_Previews: PreviewProvider {
//    static var previews: some View {
//        bumpVisibilityView()
//            .environmentObject(UserData())
//    }
//}

