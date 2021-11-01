//
//  RequestManager.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/29.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import UIKit

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

    func fetchRequest(id: String = "", completion: @escaping (Result<[Request], Error>) -> Void) {

        db.collection("requests").whereField("to", isEqualTo: id).getDocuments() { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))
            } else {

                var results = [Request]()

                for document in querySnapshot!.documents {

                    do {

                        if let result = try document.data(as: Request.self, decoder: Firestore.Decoder()) {
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

    func closeRequest(userID: String, senderID: String, completion: @escaping (Result<String, Error>) -> Void) {

        db.collection("requests").whereField("to", isEqualTo: userID).whereField("from", isEqualTo: senderID).getDocuments() { (querySnapshot, error) in

            if let error = error {
                
                completion(.failure(error))
            } else {

                for document in querySnapshot!.documents {

                    self.db.collection("requests").document(document.documentID).delete() { error in

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
