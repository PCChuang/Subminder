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
}
