


import SwiftUI

@main
struct BumpApp: App {
    
    @StateObject private var userData = UserData()
    @StateObject private var userDao = UserDao()
    @StateObject private var friendsDao = FriendsDao()
    

    // Actual code starting
    var body: some Scene {
        WindowGroup {
            if userData.isLoggedIn{
                MainTabView()
                    .environmentObject(userData)
                    .environmentObject(userDao)
                    .environmentObject(friendsDao)
            } else {
                LandingPage()
                    .environmentObject(userData)
                    .environmentObject(userDao)
            }
        }
    }
} // end of struc

// To DO:
//add userlogin feature - DONE
//add edit profile feature - DONE
//add "add friend request" and accept friend and things only being friends after
// A) Create difference in add friend and confirm friend - DONE
// B) update swift code for confirm friend feature - DONE
// C) add logic that friends only show if is_friend = true - DONE
// D) adjust the checkifFriends feature accordingly - DONE
// E) log off function - DONE
// UI on landing page - DONE
// time zone for lastbumped - DONE
// when loggedin, defualt bumpOn status fetchfrom whats in database - DONE
// bubble on notifications to show you'vebeen bumped and friend requests -  DONE
// notificationpage, option to bump back and when both parties bump it turns green across all pages - DONE
// B) filter on the other page too - DONE
// wipe notification counter when you accept as friend - DONE
// decide when it wipes (15 minutes to wipe the green) - DONE
// fix bug on log out - DONE
// UI on profile - DONE

// older bumps to expire after 1 hour
// notification flag a bit stale
//Map feature
//add message feature for notifiactions received
// upload photos
//add bump visibility feature

