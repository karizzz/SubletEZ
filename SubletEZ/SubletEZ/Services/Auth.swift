//
//  Auth.swift
//  SubletEZ
//
//  Created by Kartik Saxena on 2025-06-17.
//
import Foundation
import FirebaseAuth

final class AuthService {

    // Shared instance
    static let shared = AuthService()

    private init() {}

    func signUp(email: String, password: String) async throws {
        do {
            let _ = try await Auth.auth().createUser(withEmail: email, password: password)
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

