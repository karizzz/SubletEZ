//
//  ProfileUpdateView.swift
//  SubletEZ
//
//  Created by Akshay Krishna on 2025-01-27.
//

import SwiftUI
import FirebaseAuth

struct ProfileUpdateView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var school: String = ""
    @State private var bio: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let user: User
    
    init(user: User) {
        self.user = user
        _name = State(initialValue: user.name)
        _school = State(initialValue: user.school)
        _bio = State(initialValue: user.bio)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Enter your name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("School")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Enter your school", text: $school)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                Section(header: Text("About You")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bio")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $bio)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                
                Section {
                    Button(action: saveProfile) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text(isLoading ? "Saving..." : "Save Changes")
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
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Profile Update", isPresented: $showAlert) {
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
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !school.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveProfile() {
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "User not authenticated"
            showAlert = true
            return
        }
        
        isLoading = true
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSchool = school.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        
        FirestoreService.shared.updateUserProfileFields(
            userId: userId,
            name: trimmedName,
            school: trimmedSchool,
            bio: trimmedBio
        ) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    alertMessage = "Profile updated successfully!"
                    showAlert = true
                case .failure(let error):
                    alertMessage = "Failed to update profile: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}
