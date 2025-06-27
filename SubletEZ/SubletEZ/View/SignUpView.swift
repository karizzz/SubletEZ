//
//  SignUpView.swift
//  SubletEZ
//
//  Created by Akshay Krishna on 2025-01-27.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var school = ""
    @State private var bio = ""
    @State private var age = ""
    @State private var phone = ""
    @State private var sex = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Information")) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                }
                
                Section(header: Text("Profile Information")) {
                    TextField("Full Name", text: $name)
                        .textContentType(.name)
                    
                    TextField("School/University", text: $school)
                        .textContentType(.organizationName)
                    
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    
                    Picker("Sex", selection: $sex) {
                        Text("").tag("")
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bio (Optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $bio)
                            .frame(minHeight: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                
                Section {
                    Button(action: signUp) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text(isLoading ? "Creating Account..." : "Sign Up")
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .cornerRadius(10)
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Sign Up", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !school.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !age.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Int(age) != nil &&
        !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !sex.isEmpty
    }
    
    private func signUp() {
        isLoading = true
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSchool = school.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSex = sex
        let intAge = Int(age)
        
        Task {
            do {
                try await AuthService.shared.signUp(
                    email: email,
                    password: password,
                    name: trimmedName,
                    school: trimmedSchool,
                    bio: trimmedBio,
                    age: intAge,
                    phone: trimmedPhone,
                    sex: trimmedSex
                )
                
                DispatchQueue.main.async {
                    isLoading = false
                    alertMessage = "Account created successfully!"
                    showAlert = true
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    alertMessage = "Failed to create account: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    SignUpView()
} 
