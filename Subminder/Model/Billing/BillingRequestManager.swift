//
//  BillingRequestManager.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/13.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class BillingRequestManager {
    
    static let shared = BillingRequestManager()
    
    lazy var db = Firestore.firestore()
    
    func create(billingRequest: inout BillingRequest, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = db.collection("billingRequests").document()
        billingRequest.id = document.documentID
        document.setData(billingRequest.toDict) { error in
            
            if let error = error {
                
                completion(.failure(error))
            } else {

                completion(.success("Success"))
            }
        }
    }
    
    func fetch(uid: String, groupID: String, completion: @escaping (Result<[BillingRequest], Error>) -> Void) {
        
        db.collection("billingRequests").whereField("hostUID", isEqualTo: uid).whereField("groupID", isEqualTo: groupID).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var results = [BillingRequest]()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        
                        if let result = try document.data(as: BillingRequest.self, decoder: Firestore.Decoder()) {
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
    
    func delete(userUID: String, senderUID: String, groupID: String, completion: @escaping (Result<String, Error>) -> Void) {
        // swiftlint:disable next line_length
        db.collection("billingRequests").whereField("hostUID", isEqualTo: userUID).whereField("userUID", isEqualTo: senderUID).whereField("groupID", isEqualTo: groupID).getDocuments() { (querySnapshot, error) in

            if let error = error {
                
                completion(.failure(error))
            } else {

                for document in querySnapshot!.documents {

                    self.db.collection("billingRequests").document(document.documentID).delete() { error in

                        if let error = error {

                            completion(.failure(error))
                        } else {

                            completion(.success(document.documentID))
                        }
                    }
                }
            }
        }
    }
}
