//
//  FirestoreService.swift
//  SubletEZ
//
//  Created by Kartik Saxena on 2025-06-17.
//

import Foundation
import Firebase
import FirebaseFirestore


class FirestoreService {
    static let shared = FirestoreService()
    private init() {}
    
    private let db =  Firestore.firestore()
    
    func addListing(data : [ String : Any], completion: @escaping (Result<Void, Error>)-> Void){
        db.collection("sublets").addDocument(data: data) {error in
            if let error = error {
                completion(.failure(error))
                
            }else{
                completion(.success(()))
            }
        }
        
    }
}
