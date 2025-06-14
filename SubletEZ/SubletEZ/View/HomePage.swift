    //
    //  HomePage.swift
    //  SubletEZ
    //
    //  Created by Kartik Saxena on 2025-06-13.
    //

import SwiftUI

struct HomePage: View {
    @State private var searchText: String = ""
    var body: some View {
        
        let dummyListing = [
            "Cozy basement room near University",
            "Sunny 1BHK in downtown",
            "Shared 2BHK close to metro",
            "Studio apartment - 3 month lease",
            "Furnished sublet with balcony",
            "Pet-friendly house near campus"
        ]
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
                            ForEach(dummyListing, id: \.self) { listing in
                                Text(listing)
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
    }
}


#Preview {
    HomePage()
}
