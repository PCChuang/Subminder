//
//  PayableManager.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/10.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class PayableManager {
    
    static let shared = PayableManager()
    
    lazy var db = Firestore.firestore()
    
    func createPayableInBatch(
        totalAmount: Decimal,
        amount: Decimal,
        nextPaymentDate: Date,
        userUIDs: [String],
        hostUID: String,
        payable: inout Payable,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
        let document = db.collection("payable").document()
        payable.id = document.documentID
        payable.userUID = hostUID
        payable.amount = -totalAmount + amount
        payable.nextPaymentDate = nextPaymentDate
        document.setData(payable.toDict)
        
        for userUID in userUIDs {
            
            let document = db.collection("payable").document()
            payable.id = document.documentID
            payable.userUID = userUID
            payable.amount = amount
            payable.nextPaymentDate = nextPaymentDate
            document.setData(payable.toDict) { error in
                
                if let error = error {
                    
                    completion(.failure(error))
                } else {
                    
                    completion(.success("Success"))
                }
            }
        }
    }
}
