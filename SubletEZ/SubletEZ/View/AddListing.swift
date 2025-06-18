//
//  AddListing.swift
//  SubletEZ
//
//  Created by Kartik Saxena on 2025-06-13.
//

import SwiftUI
import FirebaseFirestore

struct AddListing: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTab: Tab


    // MARK: - Form States
    @State private var title: String = ""
    @State private var price: String = ""
    @State private var selectedCondition: String = "New"
    @State private var description: String = ""
    @State private var location: String = ""
    @State private var hideFromFriends: Bool = false
    @State private var showCancelDialog: Bool = false
    @State private var City: String = ""
    @State private var State: String = ""
    @State private var selectedProvince = "Province"

    let conditions = ["New", "Used - Like New", "Used - Good", "Used - Fair"]
    let provinces = ["Province","AB", "BC", "MB", "NB", "NL", "NS", "NT", "NU", "ON", "PE", "QC", "SK", "YT"]
    
    func resetForm() { // to reset once user post or dicard the listing and goes to the home page.
            title = ""
           price = ""
           selectedCondition = "New"
           description = ""
           location = ""
           City = ""
           selectedProvince = "Province"    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Video & Photo Upload
                    HStack(spacing: 16) {
                        VStack {
                            Image(systemName: "video.badge.plus")
                                .font(.system(size: 30))
                            Text("Create a video\n(1 minute max)")
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))

                        VStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 30))
                            Text("Add photos / video")
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
                    }

                    Text("Photos: 0/10  •  Videos: 0/1")
                        .font(.caption)
                        .foregroundColor(.gray)

                    
                    TextField("Title", text: $location)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    
                    TextField("Price",text: $City)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Condition")
                            .font(.headline)

                        // Horizontally scrollable condition picker
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(conditions, id: \.self) { condition in
                                    Button(action: {
                                        selectedCondition = condition
                                    }) {
                                        Text(condition)
                                            .font(.subheadline)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .background(selectedCondition == condition ? Color.blue.opacity(0.2) : Color(.systemGray6))
                                            .foregroundColor(.primary)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    
                    TextField("Description (recommended)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    
                    TextField("Location", text: $location)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    
                    TextField("City",text: $City)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                                        
                    Menu {
                        ForEach(provinces, id: \.self) { province in
                            Button(action: {
                                selectedProvince = province
                            }) {
                                Text(province)
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedProvince.isEmpty ? "Select Province" : selectedProvince)
                                .foregroundColor(selectedProvince.isEmpty ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }


                    Toggle("Hide Property Address", isOn: $hideFromFriends)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .padding(.top)

                }
                .padding()
            }


            .navigationTitle("Listing details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showCancelDialog = true
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Cancel")
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Publish") {
                        let listingData: [String: Any] = [
                            "title": title,
                            "price": price,
                            "selectedCondition": selectedCondition,
                            "description": description,
                            "City": City,
                            "Province": selectedProvince,
                            "timestamp": Timestamp(date: Date())
                        ]

                        FirestoreService.shared.addListing(data: listingData) { result in
                            switch result {
                            case .success:
                                print("Successfully added listing")
                                selectedTab = .home
                                resetForm()
                            case .failure(let error):
                                print("Failed to add listing:", error.localizedDescription)
                            }
                        }
                    }
                }
            }

            .confirmationDialog("Discard Listing?", isPresented: $showCancelDialog, titleVisibility: .visible) {
                Button("Discard", role: .destructive) {
                    selectedTab = .home
                    
                }
                Button("Cancel", role: .cancel) {
                    // Do nothing
                }
            } message: {
                Text("You are about to discard this listing.")
            }
        }
    }
}

#Preview {
    AddListing(selectedTab: .constant(.add))
}
