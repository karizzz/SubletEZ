//
//  MainTabView.swift
//  SubletEZ
//
//  Created by Kartik Saxena on 2025-06-13.
//


import SwiftUI

enum Tab {
    case home, add, chat, profile
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomePage()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)

            AddListing(selectedTab: $selectedTab)
                .tabItem {
                    Label("New Listing", systemImage: "plus")
                }
                .tag(Tab.add)

            ChatMessagaing()
                .tabItem {
                    Label("Inbox", systemImage: "bubble.left")
                }
                .tag(Tab.chat)

            ProfilePage()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(Tab.profile)
        }
    }
}

#Preview() {
    MainTabView()
}
