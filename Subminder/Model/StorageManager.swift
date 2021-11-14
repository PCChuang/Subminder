//
//  StorageManager.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/14.
//

import Foundation
import FirebaseStorage

class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            
            guard error == nil else {
                
                //failed
                print("failed to upload picture to firebase")
                
                completion(.failure(StorageErrors.failedToUpload))
                
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                
                guard let url = url else {
                    
                    print("failed to get download url")
                    
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    
                    return
                }
                
                let urlString = url.absoluteString
                
                print("download url returned: \(urlString)")
                
                completion(.success(urlString))
            })
        })
    }
    
    public enum StorageErrors: Error {
        
        case failedToUpload
        case failedToGetDownloadUrl
    }
}
