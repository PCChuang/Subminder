//
//  RequestManager.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/29.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class RequestManager {

    static let shared = RequestManager()

    lazy var db = Firestore.firestore()

    func sendRequest(request: inout Request, completion: @escaping (Result<String, Error>) -> Void) {

        let document = db.collection("requests").document()

        document.setData(request.toDict) { error in

            if let error = error {

                completion(.failure(error))
            } else {

                completion(.success("Success"))
            }
        }
    }
}
