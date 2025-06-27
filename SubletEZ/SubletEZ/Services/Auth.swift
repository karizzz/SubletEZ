//
//  Auth.swift
//  SubletEZ
//
//  Created by Kartik Saxena on 2025-06-17.
//  Updated by Akshay Krishna on 2025-06-27.
import Foundation
import FirebaseAuth

final class AuthService {

    // Shared instance
    static let shared = AuthService()

    private init() {}

    func signUp(email: String, password: String, name: String, school: String, bio: String = "", age: Int? = nil, phone: String? = nil, sex: String? = nil) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Create user profile in Firestore
            let user = User(
                id: result.user.uid,
                name: name,
                school: school,
                bio: bio,
                email: email,
                age: age,
                phone: phone,
                sex: sex
            )
            
            try await withCheckedThrowingContinuation { continuation in
                FirestoreService.shared.createUserProfile(user: user) { result in
                    switch result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            throw handleAuthError(error)
        }
    }

    func login(email: String, password: String) async throws {
        do {
            let _ = try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            throw handleAuthError(error)
        }
    }
    
    func getCurrentUser() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    func getCurrentUserProfile(completion: @escaping (Result<User, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        FirestoreService.shared.getUserProfile(userId: userId, completion: completion)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }

    // MARK: - Basic Error Handler
    private func handleAuthError(_ error: Error) -> Error {
        let errCode = AuthErrorCode(rawValue: (error as NSError).code)

        switch errCode {
        case .emailAlreadyInUse:
            return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Email already in use."])
        case .invalidEmail:
            return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid email address."])
        case .wrongPassword:
            return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Incorrect password."])
        case .userNotFound:
            return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not found."])
        case .weakPassword:
            return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Weak password. Must be at least 6 characters."])
        default:
            return NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
        }
    }
}

