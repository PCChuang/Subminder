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
    
    // swiftlint:disable function_parameter_count
    func createPayableInBatch(
        
        totalAmount: Decimal,
        amount: Decimal,
        nextPaymentDate: Date,
        userUIDs: [String],
        hostUID: String,
        startDate: Date,
        cycleAmount: Decimal,
        payable: inout Payable,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
        let document = db.collection("payable").document()
        payable.id = document.documentID
        payable.userUID = hostUID
        payable.amount = -totalAmount + amount
        payable.nextPaymentDate = nextPaymentDate
        payable.startDate = startDate
        payable.cycleAmount = cycleAmount
        document.setData(payable.toDict)
        
        for userUID in userUIDs {
            
            let document = db.collection("payable").document()
            payable.id = document.documentID
            payable.userUID = userUID
            payable.amount = amount
            payable.nextPaymentDate = nextPaymentDate
            payable.startDate = startDate
            payable.cycleAmount = cycleAmount
            document.setData(payable.toDict) { error in
                
                if let error = error {
                    
                    completion(.failure(error))
                } else {
                    
                    completion(.success("Success"))
                }
            }
        }
    }
    
    func fetch(uid: String, groupID: String, completion: @escaping (Result<[Payable], Error>) -> Void) {
        
        db.collection("payable").whereField("userUID", isEqualTo: uid).whereField("groupID", isEqualTo: groupID).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var results = [Payable]()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        
                        if let result = try document.data(as: Payable.self, decoder: Firestore.Decoder()) {
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
    
//    func fetchOverduePayable(nextPaymentDate: String, completion: @escaping (Result<[Payable], Error>) -> Void) {
//
//        db.collection("payable").whereField("nextPaymentDate", isLessThanOrEqualTo: nextPaymentDate).getDocuments() { (querySnapshot, error) in
//
//            if let error = error {
//
//                completion(.failure(error))
//            } else {
//
//                var results = [Payable]()
//
//                for document in querySnapshot!.documents {
//
//                    do {
//
//                        if let result = try document.data(as: Payable.self, decoder: Firestore.Decoder()) {
//                            results.append(result)
//                        }
//                    } catch {
//
//                        completion(.failure(error))
//                    }
//                }
//                completion(.success(results))
//            }
//
//
//        }
//    }
    
    func update(
        payableID: String,
        groupID: String,
        userUID: String,
        nextPaymentDate: Date,
        startDate: Date,
        cycleAmount: Decimal,
        amount: Decimal,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let document = db.collection("payable").document(payableID)
        
        document.setData([
            "id": payableID,
            "groupID": groupID,
            "userUID": userUID,
            "nextPaymentDate": nextPaymentDate,
            "startDate": startDate,
            "cycleAmount": cycleAmount,
            "amount": amount
        ]) { error in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                completion(.success("Success"))
            }
        }
    }
}
