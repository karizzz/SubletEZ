//
//  User.swift
//  SubletEZ
//
//  Created by Akshay Krishna on 2025-01-27.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    let id: String
    var name: String
    var school: String
    var bio: String
    var email: String
    var age: Int?
    var phone: String?
    var sex: String?
    var profileImageURL: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String, name: String, school: String, bio: String, email: String, age: Int? = nil, phone: String? = nil, sex: String? = nil, profileImageURL: String? = nil) {
        self.id = id
        self.name = name
        self.school = school
        self.bio = bio
        self.email = email
        self.age = age
        self.phone = phone
        self.sex = sex
        self.profileImageURL = profileImageURL
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        self.id = document.documentID
        self.name = data["name"] as? String ?? ""
        self.school = data["school"] as? String ?? ""
        self.bio = data["bio"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.age = data["Age"] as? Int
        self.phone = data["Phone"] as? String
        self.sex = data["Sex"] as? String
        self.profileImageURL = data["profileImageURL"] as? String
        
        if let createdAtTimestamp = data["createdAt"] as? Timestamp {
            self.createdAt = createdAtTimestamp.dateValue()
        } else {
            self.createdAt = Date()
        }
        
        if let updatedAtTimestamp = data["updatedAt"] as? Timestamp {
            self.updatedAt = updatedAtTimestamp.dateValue()
        } else {
            self.updatedAt = Date()
        }
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "school": school,
            "bio": bio,
            "email": email,
            "profileImageURL": profileImageURL as Any,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
        if let age = age { dict["Age"] = age }
        if let phone = phone { dict["Phone"] = phone }
        if let sex = sex { dict["Sex"] = sex }
        return dict
    }
} 