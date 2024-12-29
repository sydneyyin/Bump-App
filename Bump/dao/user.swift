//
//


import Foundation
import PostgresClientKit
import SwiftUI
    
@MainActor
class UserDao: ObservableObject {
    private var userData = UserData()
    @Published var otherUsers: [OtherUsers] = []
    
    private var connection: Connection?
    @Published var savedSuccessfully = false
    @Published var error: String?
    @Published var connectionStatus: ConnectionStatus = .notConnected
    
    init(){
        do {
            print("in userDao")
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
            print("connection didn't works")
            print(error)
            connectionStatus = .notConnected
        }
    }
    
    func insertUserData(userData: UserData) {
        do {
            print("in insertuserData")
            let text = """
                    INSERT INTO public.usertest2 (id, first_name, last_name, email, password, onhang) VALUES (
                        '\(userData.id)', '\(userData.firstName)', '\(userData.lastName)', '\(userData.email)','\(userData.password)', '\(userData.bumpOn ? "true" : "false")'
                    );
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


        } catch {
            print("didn't work insert data")
            print(error)
            connectionStatus = .disconnected
        }
    }
    
    
    // Function to validate user login
        func validateLogin(email: String, password: String) async -> (UUID?, String, String) {
            do {
                let text = """
                    SELECT id, first_name, last_name
                    FROM usertest2
                    WHERE email = $1 AND password = $2;
                """
                
                print(text)
                
                guard let connection = connection else {
                    throw PostgresError.connectionClosed
                }
                
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [email, password])
                defer { cursor.close() }
                
                for row in cursor {
                    // Get the value as a string and attempt to convert it to a UUID
                    let idString = try row.get().columns[0].string()
                    let firstName = try row.get().columns[1].string()
                    let lastName = try row.get().columns[2].string()
                    
                    if let userId = UUID(uuidString: idString) {
                        print (userId, firstName, lastName)
                        return (userId, firstName, lastName)
                    }
                    
                } //end of row in cursor
                
            } catch {
                
                print ("validatelogin did not work: \(error)")
            }
            
            return (nil,"","")
        }
    
    func updateStatus(userData: UserData) {
        do {
            print("in updateStatus")
            let text = """
                    UPDATE public.usertest2
                    SET onhang = '\(userData.bumpOn ? "true" : "false")'
                    WHERE id = '\(userData.id)';
                    """

            guard let connection = connection else {
                print("Postgres Error")
                throw PostgresError.connectionClosed
            }

            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }

            let cursor = try statement.execute()
            defer { cursor.close() }

            savedSuccessfully = true
            connectionStatus = .connected


        } catch {
            print("didn't work update status")
            print(error)
            connectionStatus = .disconnected
        }
    }
    
    func updateUserData(userData: UserData) {
        do {
            print("in updateStatus")
            let text = """
                    UPDATE public.usertest2
                    SET first_name = '\(userData.firstName)',last_name ='\(userData.lastName)'
                    WHERE id = '\(userData.id)';
                    """

            guard let connection = connection else {
                print("Postgres Error")
                throw PostgresError.connectionClosed
            }

            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }

            let cursor = try statement.execute()
            defer { cursor.close() }

            savedSuccessfully = true
            connectionStatus = .connected


        } catch {
            print("didn't work update userData")
            print(error)
            connectionStatus = .disconnected
        }
    }
    
    func addFriend (userId: String, userData: UserData) {
        do {
            print("in addFriend")
            let text = """
                    UPDATE public.usertest2 SET
                        friend_ids = array_append(friend_ids,
                        '\(userId)'
                    ::uuid)
                    WHERE
                    id = '\(userData.id)';
                    """
            print(text)

            guard let connection = connection else {
                print("Postgres Error")
                throw PostgresError.connectionClosed
            }

            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }

            let cursor = try statement.execute()
            defer { cursor.close() }

            savedSuccessfully = true
            connectionStatus = .connected


        } catch {
            print("didn't work add friend")
            print(error)
            connectionStatus = .disconnected
        }
    }
    
    func fetchUserStatus(userData: UserData) {
            do {
                print("in fetchUserStatus")
                let text = """
                        SELECT onhang
                        FROM usertest2
                        WHERE id = '\(userData.id)';
                        """
                
                print (text)

                guard let connection = connection else {
                    print("Postgres Error")
                    throw PostgresError.connectionClosed
                }

                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }

                let cursor = try statement.execute()
                defer { cursor.close() }
                
                // Process the query result
                for row in cursor {
                    // Get the value of onhang, assuming it's returned as a Bool-like type (String or Int)
                    let onhangValue = try row.get().columns[0].bool() // assuming it's a bool, otherwise adapt it
                    
                    // Assign the boolean value to userData.bumpOn
                    DispatchQueue.main.async {
                        userData.bumpOn = onhangValue // Default to false if nil
                    }
                }
                
                print(userData.bumpOn)
                
            } catch {
                print("error: \(error)")
                connectionStatus = .disconnected
            }
        }
    
    @MainActor
    func fetchUserDetails() {
            do {
                print("in showUsers")
                let text = """
                        SELECT id, first_name, last_name
                        FROM usertest2
                        """

                guard let connection = connection else {
                    print("Postgres Error")
                    throw PostgresError.connectionClosed
                }

                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }

                let cursor = try statement.execute()
                defer { cursor.close() }

                // Process the results
                var users: [OtherUsers] = []
                
                for row in cursor {
                    let id = try row.get().columns[0].string()
                    let firstName = try row.get().columns[1].string()
                    let lastName = try row.get().columns[2].string()
                    let newUser = OtherUsers(id: id , firstName: firstName , lastName: lastName )
                    users.append(newUser)
                }
                
                // Update the published property to trigger view updates
                DispatchQueue.main.async {
                    self.otherUsers = users
                }

            } catch {
                print("error: \(error)")
                connectionStatus = .disconnected
            }
        }

    @MainActor
    func fetchFriends(userData: UserData) {
            do {
                print("in fetchfriends")
                
                //Step 1: get friends ID
                let friendIdQuery = """
                        SELECT friend_ids
                        FROM usertest2
                        WHERE
                        id = '\(userData.id)';
                                            
                        """
                print(friendIdQuery)

                guard let connection = connection else {
                    print("Postgres Error")
                    throw PostgresError.connectionClosed
                }

                let statement = try connection.prepareStatement(text: friendIdQuery)
                defer { statement.close() }

                let cursor = try statement.execute()
                defer { cursor.close() }
                
                // Process the results
                var friendIds: [String] = []
                
                for row in cursor {
                    let idString = try row.get().columns[0].string()
                    friendIds = idString.trimmingCharacters(in: CharacterSet(charactersIn: "{}")).split(separator: ",").map { String($0) }
                    
                }
                
                // Step 2: Query for each friend's details using their id
                var friendsData: [(id: String, firstName: String, lastName: String, bumpOn: Bool)] = []
                for friendId in friendIds {
                    let friendQuery = """
                                SELECT id, first_name, last_name, onHang
                                FROM usertest2
                                WHERE id = '\(friendId)';
                            """
                    
                    let friendStatement = try connection.prepareStatement(text: friendQuery)
                    defer { friendStatement.close() }
                    
                    let friendCursor = try friendStatement.execute()
                    defer { friendCursor.close() }
                    
                    for row in friendCursor {
                        let id = try row.get().columns[0].string()
                        let firstName = try row.get().columns[1].string() 
                        let lastName = try row.get().columns[2].string() 
                        let bumpOn = try row.get().columns[3].bool() 
                        
                        friendsData.append((id: id, firstName: firstName, lastName: lastName, bumpOn: bumpOn))
                    }
                }
                
                // Step 3: Update userData with detailed friend info
                DispatchQueue.main.async {
                    userData.friends = friendsData.map {
                        ["id": $0.id, "first_name": $0.firstName, "last_name": $0.lastName, "bumpOn": String($0.bumpOn)]
                    }
                }
                
                print("\(userData.friends)")

            } catch {
                print("error: \(error)")
                connectionStatus = .disconnected
            }
        }

    
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
    
    
} //end of class
