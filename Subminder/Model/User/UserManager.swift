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

        // update user friendList by locating document.id
        let document = db.collection("users").document(userID)

        document.updateData(["friendList": FieldValue.arrayUnion([newFreind])]) { error in

            if let error = error {

                completion(.failure(error))
            } else {

                completion(.success("Success"))
            }
        }
    }
    
    func joinGroup(userIDs: [String], hostID: String, newGroup: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        // update users groupList
        for userID in userIDs {
            
            let document = db.collection("users").document(userID)
            
            document.updateData(["groupList": FieldValue.arrayUnion([newGroup])]) { error in
                
                if let error = error {
                    
                    completion(.failure(error))
                } else {
                    
                    completion(.success("Success"))
                }
            }
        }
        
        // update host groupList
        let document = db.collection("users").document(hostID)
        
        document.updateData(["groupList": FieldValue.arrayUnion([newGroup])]) { error in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                completion(.success("Success"))
            }
        }
    }
    
    func updateProfile(userID: String, name: String, image: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = db.collection("users").document(userID)
        
        document.updateData(["name": name,
                             "image": image
                            ]) { error in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                completion(.success("Success"))
            }
        }
    }
}
