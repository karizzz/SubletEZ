//
//  MainTabView.swift
//  SubletEZ
//
//  Created by Kartik Saxena on 2025-06-13.
//


import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            
            HomePage()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            
            AddListing()
                .tabItem {
                    Image(systemName: "plus")
                    Text("New Listing")
                }

            
            ChatMessagaing()
                .tabItem {
                    Image(systemName: "bubble.left")
                    Text("Inbox")
                }

            
            ProfilePage()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}




#Preview() {
    MainTabView()
}
