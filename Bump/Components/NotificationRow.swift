//
//  NotificationRow.swift
//  Bump
//
//  Created by Sydney yin on 11/21/24.
//

import Foundation
import SwiftUI


struct NotificationRow: View {
    let userData: UserData
    let friend: (id: String, firstName: String, lastName: String, lastBumped: Date)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(friend.firstName) \(friend.lastName)")
                    .font(.headline)
                    .lineLimit(1)
                Text(" \(formattedDate(friend.lastBumped))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            BumpButton(userData:userData, friendId: friend.id)
            
        }
        .padding()
        .frame(height:70)
        .background(Color(UIColor.systemPurple).opacity(0.1)) // Light purple background))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}


struct DoubleBumpedRow: View {
    let userData: UserData
    let friend: (id: String, firstName: String, lastName: String)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(friend.firstName) \(friend.lastName)")
                    .font(.headline)
                    .lineLimit(1)
            }
            Spacer()
            
        }
        .padding()
        .frame(height:70)
        .background(Color(UIColor.systemGreen).opacity(0.1)) // Light green background))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
