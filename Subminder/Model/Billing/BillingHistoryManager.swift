//
//  BillingHistoryManager.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/13.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class BillingHistoryManager {
    
    static let shared = BillingHistoryManager()
    
    lazy var db = Firestore.firestore()
    
    func create(billingHistory: inout BillingHistory, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = db.collection("billingHistory").document()
        billingHistory.id = document.documentID
        document.setData(billingHistory.toDict) { error in
            
            if let error = error {
                
                completion(.failure(error))
            } else {

                completion(.success("Success"))
            }
        }
    }
}
