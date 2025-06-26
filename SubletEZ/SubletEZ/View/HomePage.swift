    //
    //  HomePage.swift
    //  SubletEZ
    //
    //  Created by Kartik Saxena on 2025-06-13.
    //

import SwiftUI
import FirebaseFirestore

struct Sublet: Identifiable {
    var id: String
    var title: String
    var price: Double
    var location: String
    var description: String?  
    var schoolName: String?
    var postalCode: String?
    
}
struct HomePage: View {
    @State private var searchText: String = ""
    @State private var sublets: [Sublet] = []
    var filteredSublets: [Sublet] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return sublets
        } else {
            return sublets.filter { sublet in
                sublet.location.localizedCaseInsensitiveContains(searchText) ||
                sublet.title.localizedCaseInsensitiveContains(searchText)
                // Add more fields as needed
            }
        }
    }
    var body: some View {
        // Embeds view in a navigation-aware stack
        NavigationStack {
            // ZStack allows layering views on top of each other (image + search bar)
            ZStack(alignment: .top) {
                
                // Background image layer
                VStack(spacing: 0) {
                    Image("CityBackground")
                        .resizable()
                        .scaledToFill() // Ensures full width and good crop
                        .frame(height: 250) // Set the visible height
                        .frame(maxWidth: .infinity) // Stretches full width
                        .clipped() // Avoids overflow outside frame
                        .ignoresSafeArea(edges: .top) // Extends image under the notch
                    
                    Spacer() // Pushes image to top
                }
                
                VStack {
                    Spacer().frame(height: 175)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search your Sublet", text: $searchText)
                            .padding(10)
                            .background(Color.white)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .padding(.horizontal)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(filteredSublets) { sublet in
                                VStack(alignment: .leading) {
                                    Text(sublet.title)
                                        .font(.headline)
                                    Text("\(sublet.location) • $\(Int(sublet.price))/month")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .shadow(radius: 1)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
                    fetchSublets()
                }
    }
    func fetchSublets() {
        let db = Firestore.firestore()
        db.collection("sublets").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching sublets: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No documents in 'sublets' collection")
                return
            }
            sublets = documents.compactMap { doc in
                let data = doc.data()
                return Sublet(
                    id: doc.documentID,
                    title: data["title"] as? String ?? "",
                    price: data["price"] as? Double ?? 0,
                    location: data["location"] as? String ?? "",
                    description: data["description"] as? String,
                    schoolName: data["schoolName"] as? String,
                    postalCode: data["postalCode"] as? String
                )
            }
        }
    }
}


#Preview {
    HomePage()
}
