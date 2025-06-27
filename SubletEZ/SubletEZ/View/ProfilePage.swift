//
//  ProfilePage.swift
//  SubletEZ
//
//  Created by Kartik Saxena on 2025-06-13.
//  Updated by Akshay Krishna on 2025-06-27.

import SwiftUI
import FirebaseAuth

struct ProfilePage: View {
    @State private var user: User?
    @State private var isLoading = true
    @State private var showEditProfile = false
    @State private var showSignIn = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isAuthenticated = false
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading...")
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                } else if isAuthenticated, let user = user {
                    // User is signed in and profile loaded
                    ScrollView {
                        VStack(spacing: 24) {
                            // Profile Header
                            VStack(spacing: 16) {
                                // Profile Image Placeholder
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                    )
                                
                                VStack(spacing: 8) {
                                    Text(user.name)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text(user.school)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.top)
                            
                            // Bio Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("About")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text(user.bio.isEmpty ? "No bio added yet." : user.bio)
                                    .font(.body)
                                    .foregroundColor(user.bio.isEmpty ? .secondary : .primary)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            
                            // Contact Information
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Contact Information")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                VStack(spacing: 8) {
                                    HStack {
                                        Image(systemName: "envelope")
                                            .foregroundColor(.blue)
                                            .frame(width: 20)
                                        Text(user.email)
                                            .font(.body)
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.green)
                                            .frame(width: 20)
                                        Text("Member since \(formatDate(user.createdAt))")
                                            .font(.body)
                                        Spacer()
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            
                            // Edit Profile Button
                            Button(action: {
                                showEditProfile = true
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit Profile")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            
                            Spacer(minLength: 50)
                        }
                    }
                } else {
                    // User is not signed in
                    VStack(spacing: 30) {
                        Spacer()
                        
                        // Welcome Section
                        VStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 80))
                                .foregroundColor(.blue)
                            
                            Text("Welcome to SubletEZ")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("Sign in to access your profile, manage your listings, and connect with other students.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Action Buttons
                        VStack(spacing: 16) {
                            Button(action: {
                                showSignIn = true
                            }) {
                                HStack {
                                    Image(systemName: "person.fill")
                                    Text("Sign In")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                showSignIn = true
                            }) {
                                HStack {
                                    Image(systemName: "person.badge.plus")
                                    Text("Create Account")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if isAuthenticated {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Sign Out") {
                            signOut()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                if let user = user {
                    ProfileUpdateView(user: user)
                        .onDisappear {
                            loadUserProfile()
                        }
                }
            }
            .sheet(isPresented: $showSignIn) {
                SignInView()
                    .onDisappear {
                        checkAuthenticationStatus()
                    }
            }
            .alert("Profile", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        .onAppear {
            checkAuthenticationStatus()
        }
    }
    
    private func checkAuthenticationStatus() {
        isLoading = true
        
        if let currentUser = Auth.auth().currentUser {
            // User is signed in, load their profile
            isAuthenticated = true
            loadUserProfile()
        } else {
            // User is not signed in
            isAuthenticated = false
            user = nil
            isLoading = false
        }
    }
    
    private func loadUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else {
            isAuthenticated = false
            user = nil
            isLoading = false
            return
        }
        
        FirestoreService.shared.getUserProfile(userId: userId) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let userProfile):
                    self.user = userProfile
                case .failure(let error):
                    self.user = nil
                    alertMessage = "Failed to load profile: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            user = nil
        } catch {
            alertMessage = "Failed to sign out: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    ProfilePage()
}
