//
//  UserManager.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/29.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class UserManager {

    static let shared = UserManager()

    lazy var db = Firestore.firestore()

    func checkUserRegistration(uid: String = "", completion: @escaping (Result<[User], Error>) -> Void) {
        
        db.collection("users").whereField("uid", isEqualTo: uid).getDocuments() { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))
            } else {

                var results = [User]()

                for document in querySnapshot!.documents {

                    do {
                        if let result = try document.data(as: User.self, decoder: Firestore.Decoder()) {
                            results.append(result)
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }

                completion(.success(results))
            }
        }
    }

    func addUser(user: inout User, completion: @escaping (Result<String, Error>) -> Void) {

        let document = db.collection("users").document()

        user.id = document.documentID

        document.setData(user.toDict) { error in

            if let error = error {

                completion(.failure(error))
            } else {

                completion(.success("Success"))
            }
        }
    }

    func searchUser(uid: String = "", completion: @escaping (Result<[User], Error>) -> Void) {
        
        db.collection("users").whereField("uid", isEqualTo: uid).getDocuments() { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))
            } else {

                var results = [User]()

                for document in querySnapshot!.documents {

                    do {
                        if let result = try document.data(as: User.self, decoder: Firestore.Decoder()) {
                            results.append(result)
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }

                completion(.success(results))
            }
        }
    }

    func addFriend(userID: String, newFreind: String, completion: @escaping (Result<String, Error>) -> Void) {

        let document = db.collection("users").document(userID)

        document.updateData(["friendList": FieldValue.arrayUnion([newFreind])]) { error in

            if let error = error {

                completion(.failure(error))
            } else {

                completion(.success("Success"))
            }
        }
    }
    
    func joinGroup(userUIDs: [String], hostUID: String, newGroup: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        // update users groupList
        for userUID in userUIDs {
            
            let document = db.collection("users").document(userUID)
            
            document.updateData(["groupList": FieldValue.arrayUnion([newGroup])]) { error in
                
                if let error = error {
                    
                    completion(.failure(error))
                } else {
                    
                    completion(.success("Success"))
                }
            }
        }
        
        // update host groupList
        let document = db.collection("users").document(hostUID)
        
        document.updateData(["groupList": FieldValue.arrayUnion([newGroup])]) { error in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                completion(.success("Success"))
            }
        }
    }
}
