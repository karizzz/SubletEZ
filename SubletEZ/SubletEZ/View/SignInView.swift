//
//  SignInView.swift
//  SubletEZ
//
//  Created by Akshay Krishna on 2025-01-27.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Welcome Back")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Sign in to access your profile")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 50)
                
                // Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.password)
                    }
                }
                .padding(.horizontal, 30)
                
                // Sign In Button
                Button(action: signIn) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        }
                        Text(isLoading ? "Signing In..." : "Sign In")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!isFormValid || isLoading)
                .padding(.horizontal, 30)
                
                // Sign Up Link
                VStack(spacing: 8) {
                    Text("Don't have an account?")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button("Create Account") {
                        showSignUp = true
                    }
                    .font(.body)
                    .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Sign In", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView()
                    .onDisappear {
                        // Refresh authentication state when sign up sheet is dismissed
                        // This will be handled by the parent view
                    }
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    private func signIn() {
        isLoading = true
        
        Task {
            do {
                try await AuthService.shared.login(email: email, password: password)
                
                DispatchQueue.main.async {
                    isLoading = false
                    alertMessage = "Signed in successfully!"
                    showAlert = true
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    alertMessage = "Failed to sign in: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    SignInView()
} 
