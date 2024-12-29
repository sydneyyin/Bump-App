//
//  AddFriendButton.swift
//  Bump
//
//  Created by Sydney yin on 10/21/24.
//

import SwiftUI

struct ToggleButton: View {
    @State private var isOn = true
    
    var body: some View {
        Button(action: {
            isOn.toggle()
        }) {
            ZStack {
                Capsule()
                    .fill(isOn ? Color(red: 52/255, green: 199/255, blue: 89/255) : Color.gray)
                    .frame(width: 51, height: 31)
                
                Circle()
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 0)
                    .frame(width: 27, height: 27)
                    .offset(x: isOn ? 10 : -10)
            }
        }
        .accessibilityLabel("Toggle Friend Status")
        .accessibilityValue(isOn ? "On" : "Off")
    }
}


struct AddFriendButton_Previews: PreviewProvider {
    static var previews: some View {
        ToggleButton()
    }
}
