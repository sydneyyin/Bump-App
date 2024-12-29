//
//  FriendsDao.swift
//  Bump
//
//  Created by Sydney yin on 11/4/24.
//

import Foundation
import PostgresClientKit
import SwiftUI

@MainActor
class FriendsDao: ObservableObject {
    private var userData = UserData()
    
    
    private var connection: Connection?
    @Published var savedSuccessfully = false
    @Published var error: String?
    @Published var connectionStatus: ConnectionStatus = .notConnected
    
    init(){
        do {
            print("in FriendsDao")
            var configuration = PostgresClientKit.ConnectionConfiguration()
            configuration.host = "localhost"
            configuration.database = "postgres"
            configuration.user = "postgres"
            configuration.ssl = false
            configuration.credential = .scramSHA256(password: "post")
            
            connection = try PostgresClientKit.Connection(configuration: configuration)
            connectionStatus = .connected
            print("connection works")
        } catch {
            print("connection didn't work")
            print(error)
            connectionStatus = .notConnected
        }
    }
    
    func addFriend(userData: UserData, friendId: String) {
        do {
            let text = """
                INSERT INTO Friends (user_id, friend_id, is_friend, bumped)
                VALUES ('\(userData.id)', '\(friendId)', false, false);
                """
            guard let connection = connection else {
                throw PostgresError.connectionClosed
            }
            
            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            
            let cursor = try statement.execute()
            defer { cursor.close() }
            
            savedSuccessfully = true
            connectionStatus = .connected
            print("Friendship inserted successfully")
            
        } catch {
            print("Error inserting friendship")
            print(error)
            connectionStatus = .disconnected
        }
    }
    
    func confirmFriend(userData: UserData, friendId: String) {
        do {
            guard let connection = connection else {
                throw PostgresError.connectionClosed
            }
            
            //confirmfriend
            let text = """
                UPDATE Friends
                SET is_friend = true
                WHERE user_id = '\(friendId)' AND friend_id = '\(userData.id)';
                """
            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            
            let cursor = try statement.execute()
            defer { cursor.close() }
            
            print("Friendship confirmed successfully.")
            
            //create corresponding new row
            let additionalText = """
                INSERT INTO Friends (user_id, friend_id, is_friend, bumped)
                VALUES ('\(userData.id)', '\(friendId)', true, false);
                """
            
            let additionalStatement = try connection.prepareStatement(text: additionalText)
            defer { additionalStatement.close() }
            
            let additionalCursor = try additionalStatement.execute()
            defer { additionalCursor.close() }
            
            print("Corresponding friendship added successfully.")
            
            savedSuccessfully = true
            connectionStatus = .connected
            
        } catch {
            print("Error inserting friendship")
            print(error)
            connectionStatus = .disconnected
        }
    }
    
    func sendBump(userData: UserData, friendId: String, bumped: Bool) {
        do {
            let text = """
                UPDATE Friends
                SET bumped = '\(bumped ? "true" : "false")', last_bumped = CURRENT_TIMESTAMP AT TIME ZONE 'UTC'
                WHERE user_id = '\(userData.id)' AND friend_id = '\(friendId)';
                """
            guard let connection = connection else {
                throw PostgresError.connectionClosed
            }
            
            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            
            let cursor = try statement.execute()
            defer { cursor.close() }
            
            savedSuccessfully = true
            connectionStatus = .connected
            print("Bump status updated successfully.")
            
        } catch {
            print("Error updating bump status")
            print(error)
            connectionStatus = .disconnected
        }
    }
    
    func fetchFriends(userData: UserData) {
        do {
            let text = """
                SELECT f.friend_id, u.first_name, u.last_name, f.is_friend, u.onhang, f.bumped
                FROM Friends f
                JOIN usertest2 u ON f.friend_id = u.id
                WHERE f.user_id = '\(userData.id)';
                """
            
            print("in fetchfriends")
            print(text)
            
            guard let connection = connection else {
                throw PostgresError.connectionClosed
            }
            
            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            
            let cursor = try statement.execute()
            defer { cursor.close() }
            
            var friendsData: [(id: String, firstName: String, lastName: String, isFriend: Bool, bumpOn: Bool, bumped: Bool)] = []
            
            for row in cursor {
                let friendId = try row.get().columns[0].string()
                let firstName = try row.get().columns[1].string()
                let lastName = try row.get().columns[2].string()
                let isFriend = try row.get().columns[3].bool()
                let bumpOn = try row.get().columns[4].bool()
                let bumped = try row.get().columns[5].bool()
            
                friendsData.append((id: friendId, firstName: firstName, lastName: lastName, isFriend: isFriend, bumpOn: bumpOn, bumped: bumped))
            }
            
            DispatchQueue.main.async {
                // Assuming userData is updated to store the array of friends
                userData.friendsData = friendsData.map { friend in
                    UserData.FriendData(id: friend.id, firstName: friend.firstName, lastName: friend.lastName, isFriend: friend.isFriend, bumpOn: friend.bumpOn, bumped: friend.bumped)
                    }
            }
            
            
        } catch {
            print("Error fetching friends")
            print(error)
        }
    }
    
    func fetchBumpedMe (userData: UserData) -> [(id: String, firstName: String, lastName: String, lastBumped: Date)] {
        var bumpedMe: [(id: String, firstName: String, lastName: String, lastBumped: Date)] = []
        
        do {
            let text = """
                SELECT u.id, u.first_name, u.last_name, f.last_bumped
                FROM Friends f
                JOIN usertest2 u ON f.user_id = u.id
                WHERE f.friend_id = '\(userData.id.uuidString)' AND f.bumped = true;
                """
            
            guard let connection = connection else {
                throw PostgresError.connectionClosed
            }
            
            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            
            let cursor = try statement.execute()
            defer { cursor.close() }
            
            for row in cursor {
                let userId = try row.get().columns[0].string()
                let firstName = try row.get().columns[1].string()
                let lastName = try row.get().columns[2].string()
    
                // Attempt to retrieve `last_bumped` as a PostgresTimestamp
                let lastBumpedPostgresTimestamp = try row.get().columns[3].timestamp()
                
                // Convert `PostgresTimestamp` to Swift `Date` in the device's local time zone
                // Assuming the timestamp is stored as UTC in the database:
                let utcDate = lastBumpedPostgresTimestamp.date(in: TimeZone(identifier: "UTC")!)
                let lastBumped = utcDate // `Date` in the current time zone
                
            
                bumpedMe.append((id: userId, firstName: firstName, lastName: lastName, lastBumped: lastBumped))

                print(bumpedMe)
            }
            
        } catch {
            print("Error fetching bumped friends: \(error)")
        }
        
        return bumpedMe
    }

    func fetchFriendedMe (userData: UserData) -> [(id: String, firstName: String, lastName: String)] {
        var FriendedMe: [(id: String, firstName: String, lastName: String)] = []
        
        do {
            let text = """
                SELECT u.id, u.first_name, u.last_name
                FROM Friends f
                JOIN usertest2 u ON f.user_id = u.id
                WHERE f.friend_id = '\(userData.id.uuidString)' AND f.is_friend = false;
                """
            
            guard let connection = connection else {
                throw PostgresError.connectionClosed
            }
            
            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            
            let cursor = try statement.execute()
            defer { cursor.close() }
            
            for row in cursor {
                let userId = try row.get().columns[0].string()
                let firstName = try row.get().columns[1].string()
                let lastName = try row.get().columns[2].string()
                
                FriendedMe.append((id: userId, firstName: firstName, lastName: lastName))

                print(FriendedMe)
            }
            
        } catch {
            print("Error fetching friended me: \(error)")
        }
        
        return FriendedMe
    }
    
    func fetchDoubleBumped (userData: UserData) -> [(id: String, firstName: String, lastName: String)] {
        var DubleBumped: [(id: String, firstName: String, lastName: String)] = []
        
        do {
            let text = """
                SELECT u.id, u.first_name, u.last_name
                FROM Friends f
                JOIN usertest2 u ON f.user_id = u.id
                WHERE f.friend_id = '\(userData.id.uuidString)' AND f.bumped = true 
                AND EXISTS (
                      SELECT 1 
                      FROM Friends f2
                      WHERE f2.user_id = '\(userData.id.uuidString)' 
                        AND f2.friend_id = u.id 
                        AND f2.bumped = true
                        AND (
                            f.last_bumped >= NOW() - INTERVAL '15 minutes' 
                            OR f2.last_bumped >= NOW() - INTERVAL '15 minutes'
                            )
                  );
                """
            
            guard let connection = connection else {
                throw PostgresError.connectionClosed
            }
            
            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            
            let cursor = try statement.execute()
            defer { cursor.close() }
            
            for row in cursor {
                let userId = try row.get().columns[0].string()
                let firstName = try row.get().columns[1].string()
                let lastName = try row.get().columns[2].string()
                
                DubleBumped.append((id: userId, firstName: firstName, lastName: lastName))

                print(DubleBumped)
            }
            
        } catch {
            print("Error fetching DubleBumped: \(error)")
        }
        
        return DubleBumped
    }
    

    func checkIsFriend(userData: UserData, friendId: String) -> Bool {
        do {
            let text = """
                SELECT COUNT(*)
                FROM Friends
                WHERE (user_id = '\(userData.id.uuidString)' AND friend_id = '\(friendId)' AND is_friend = true)
                OR (user_id = '\(friendId)' AND friend_id = '\(userData.id.uuidString)' AND is_friend = true);
                """
            
            guard let connection = connection else {
                throw PostgresError.connectionClosed
            }
            
            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            
            let cursor = try statement.execute()
            defer { cursor.close() }
            
            if let row = cursor.next() {
                let count = try row.get().columns[0].int() // Assuming it returns the count of friends
                
                // If the count is greater than 0, the user is a friend
                return count > 0
            }
            
        } catch {
            print("Error checking friendship status: \(error)")

        }
        // If any error occurs or no rows are found, return false
        return false
    }
    
    func checkIsRequested(userData: UserData, friendId: String) -> Bool {
        do {
            let text = """
                SELECT COUNT(*)
                FROM Friends
                WHERE (user_id = '\(userData.id.uuidString)' AND friend_id = '\(friendId)' AND is_friend = false);
                """
            
            guard let connection = connection else {
                throw PostgresError.connectionClosed
            }
            
            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            
            let cursor = try statement.execute()
            defer { cursor.close() }
            
            if let row = cursor.next() {
                let count = try row.get().columns[0].int() // Assuming it returns the count of friends
                
                return count > 0
            }
            
        } catch {
            print("Error checking friendship status: \(error)")
        }
        // If any error occurs or no rows are found, return false
        return false
    }

    
    

    // Close the database connection
    func closeConnection() {
        connection?.close()
        connection = nil
        connectionStatus = .notConnected
    }
    
    enum ConnectionStatus: String, CaseIterable {
        case connected
        case disconnected
        case notConnected
    }
}
