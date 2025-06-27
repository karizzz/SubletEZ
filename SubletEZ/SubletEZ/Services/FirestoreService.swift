//
//  FirestoreService.swift
//  SubletEZ
//
//  Created by Kartik Saxena on 2025-06-17.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class FirestoreService {
    static let shared = FirestoreService()
    private init() {}
    
    private let db = Firestore.firestore()
    
    func addListing(data : [ String : Any], completion: @escaping (Result<Void, Error>)-> Void){
        db.collection("sublets").addDocument(data: data) {error in
            if let error = error {
                completion(.failure(error))
                
            }else{
                completion(.success(()))
            }
        }
    }
    
    // MARK: - User Profile Management
    
    func createUserProfile(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("profile").document(user.id).setData(user.toDictionary()) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func getUserProfile(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection("profile").document(userId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])))
                return
            }
            
            if let user = User(document: document) {
                completion(.success(user))
            } else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to parse user data"])))
            }
        }
    }
    
    func updateUserProfile(userId: String, updates: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        var updateData = updates
        updateData["updatedAt"] = Timestamp(date: Date())
        
        db.collection("profile").document(userId).updateData(updateData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateUserProfileFields(userId: String, name: String? = nil, school: String? = nil, bio: String? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        var updates: [String: Any] = [:]
        
        if let name = name {
            updates["name"] = name
        }
        if let school = school {
            updates["school"] = school
        }
        if let bio = bio {
            updates["bio"] = bio
        }
        
        updateUserProfile(userId: userId, updates: updates, completion: completion)
    }
}
