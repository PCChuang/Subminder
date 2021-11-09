//
//  GroupManager.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/5.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class GroupManager {
    
    static let shared = GroupManager()
    
    lazy var db = Firestore.firestore()
    
    func createGroup(group: inout Group, completion: @escaping (Result<String, Error>) -> Void) {

        let document = db.collection("groups").document()

        group.id = document.documentID
        
        document.setData(group.toDict) { error in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                completion(.success("Success"))
            }
        }
    }
    
    func searchGroup(id: String, completion: @escaping (Result<[Group], Error>) -> Void) {
        
        db.collection("groups").whereField("id", isEqualTo: id).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var results = [Group]()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let result = try document.data(as: Group.self, decoder: Firestore.Decoder()) {
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
}
