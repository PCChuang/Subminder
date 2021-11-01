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

    func searchUser(id: String = "", completion: @escaping (Result<[User], Error>) -> Void) {
        
        db.collection("users").whereField("id", isEqualTo: id).getDocuments() { (querySnapshot, error) in

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
}
