//
//  otherUsers.swift
//  Bump
//
//  Created by Sydney yin on 10/31/24.
//

import Foundation
import SwiftUI
    

struct OtherUsers: Identifiable {

    let id: String
    let firstName: String
    let lastName: String
    
    init(id: String, firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
    
} //end of class



