//
//  friends.swift
//  Bump
//
//  Created by Sydney yin on 11/1/24.
//

import Foundation
import PostgresClientKit
import SwiftUI
    

private var userData = UserData()
var otherUsers: [OtherUsers] = []

    func loadUsers() async {
            do {
                guard let connection = connection else {
                    print("Postgres Error")
                    throw PostgresError.connectionClosed
                }

                let query = """
                SELECT id, first_name, last_name FROM usertest2;
                """

                let statement = try connection.prepareStatement(text: query)
                defer { statement.close() }

                let cursor = try await statement.execute()
                defer { cursor.close() }

                // Initialize an empty array to store the fetched user data
                var results: [OtherUsers] = []

                while let rowResult = try? cursor.next() {
                            switch rowResult {
                            case .success(let row):
                                // Safely extract id, firstName, and lastName values
                                if let idValue = row[0],
                                   let firstNameValue = row[1],
                                   let lastNameValue = row[2],
                                   let id = idValue.uuid,   // Assuming `id` is of type UUID
                                   let firstName = firstNameValue.string,
                                   let lastName = lastNameValue.string {

                                    // Create an OtherUsers instance and add it to the results array
                                    let otherUser = OtherUsers(id: id, firstName: firstName, lastName: lastName)
                                    results.append(otherUser)
                                }
                            case .failure(let error):
                                print("Error processing row: \(error)")
                            }
                        }


                    self.otherUsers = results  // Store the fetched users
                    connectionStatus = .connected
            } // end of do
                catch {
                print("Error fetching users: \(error)")
                connectionStatus = .notConnected
            }
        } //end of async function
    
