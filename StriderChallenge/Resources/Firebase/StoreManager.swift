//
//  StoreManager.swift
//  StriderChallenge
//
//  Created by Renato Mateus on 29/08/22.
//

import FirebaseStorage

final class StoreManager {
    static let shared = StoreManager()
    
    public func downloadImage(with reference: String, completion: @escaping (Result<URL, Error>) -> Void){
        STORAGE_REF.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(IGStorageManagerError.failedToDownload))
                return
            }
            completion(.success(url))
        })
    }
    
    public func uploadImage(with reference: String, data: Data, completion: @escaping(Result<String, Error>) -> Void) {
        let storageRef = STORAGE_PROFILE_IMAGES.child(reference)
        storageRef.putData(data, metadata: nil) { (meta, error) in
            if let error = error {
                print("Error occoured: \(error.localizedDescription)")
            }
            storageRef.downloadURL { (url, error) in
                guard let profileImageUrl = url?.absoluteString else {
                    completion(.failure(IGStorageManagerError.failedToDownload))
                    return
                }
                completion(.success(profileImageUrl))
            }
           
        }
    }
    
    
}

public enum IGStorageManagerError: Error {
    case failedToDownload
}
