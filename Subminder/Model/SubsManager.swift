//
//  SubsManager.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class SubsManager {

    static let shared = SubsManager()

    lazy var db = Firestore.firestore()

    func fetchSubs(uid: String, completion: @escaping (Result<[Subscription], Error>) -> Void) {

        db.collection("subscriptions").whereField("userUID", isEqualTo: uid).getDocuments() { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))
            } else {

                var subscriptions = [Subscription]()

                for document in querySnapshot!.documents {

                    do {
                        if let subscription = try document.data(as: Subscription.self, decoder: Firestore.Decoder()) {
                            subscriptions.append(subscription)
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }

                completion(.success(subscriptions))
            }
        }
    }
    
    func fetchSubsForPayable(uid: String, groupID: String, completion: @escaping (Result<[Subscription], Error>) -> Void) {
        
        db.collection("subscriptions").whereField("userUID", isEqualTo: uid).whereField("groupID", isEqualTo: groupID).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var subscriptions = [Subscription]()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        
                        if let subscription = try document.data(as: Subscription.self, decoder: Firestore.Decoder()) {
                            subscriptions.append(subscription)
                        }
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                completion(.success(subscriptions))
            }
        }
    }

    func fetchSubsToEdit(subscriptionID: String, completion: @escaping (Result<[Subscription], Error>) -> Void) {
        
        db.collection("subscriptions").whereField("id", isEqualTo: subscriptionID).getDocuments() { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))
            } else {

                var subscriptions = [Subscription]()

                for document in querySnapshot!.documents {

                    do {
                        if let subscription = try document.data(as: Subscription.self, decoder: Firestore.Decoder()) {
                            subscriptions.append(subscription)
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }

                completion(.success(subscriptions))
            }
        }
    }
    
//    func fetchGroupSubs(completion: @escaping (Result<[Subscription], Error>) -> Void) {
//        
//        db.collection("subscriptions").whereField("", isEqualTo: subscriptionID).getDocuments() { (querySnapshot, error) in
//
//            if let error = error {
//
//                completion(.failure(error))
//            } else {
//
//                var subscriptions = [Subscription]()
//
//                for document in querySnapshot!.documents {
//
//                    do {
//                        if let subscription = try document.data(as: Subscription.self, decoder: Firestore.Decoder()) {
//                            subscriptions.append(subscription)
//                        }
//
//                    } catch {
//
//                        completion(.failure(error))
//                    }
//                }
//
//                completion(.success(subscriptions))
//            }
//        }
//    }

    func publishSub(subscription: inout Subscription, completion: @escaping (Result<String, Error>) -> Void) {

        let document = db.collection("subscriptions").document()
        subscription.id = document.documentID
        document.setData(subscription.toDict) { error in

            if let error = error {

                completion(.failure(error))
            } else {

                completion(.success("Success"))
            }
        }
    }
    
    func publishInBatch(userUIDs: [String], hostUID: String, subscription: inout Subscription, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = db.collection("subscriptions").document()
        subscription.id = document.documentID
        subscription.userUID = hostUID
        document.setData(subscription.toDict)
        
        for userUID in userUIDs {
            
            let document = db.collection("subscriptions").document()
            subscription.id = document.documentID
            subscription.userUID = userUID
            document.setData(subscription.toDict) { error in

                if let error = error {

                    completion(.failure(error))
                } else {

                    completion(.success("Success"))
                }
            }
        }
    }

    func saveEditedSub(subscription: inout Subscription,subscriptionID: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = db.collection("subscriptions").document(subscriptionID)
        document.setData(subscription.toDict) { error in

            if let error = error {

                completion(.failure(error))
            } else {

                completion(.success("Success"))
            }
        }
    }

    func deleteSub(subscription: Subscription, completion: @escaping (Result<String, Error>) -> Void) {

        // user conditions to be added
        db.collection("subscriptions").document(subscription.id).delete() { error in

            if let error = error {

                completion(.failure(error))
            } else {

                completion(.success(subscription.id))
            }
        }
    }
}
