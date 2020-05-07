//
//  ApplicationView.swift
//  logbook
//
//  Created by Amit Bajaj on 5/3/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import Foundation
import SwiftUI

struct ApplicationView: View{
    @EnvironmentObject var appState: ApplicationState

    var body: some View{
        TabView{
            if(appState.isAdmin){
                GroupListView()
                    .environmentObject(appState)
                .tabItem{
                    VStack{
                        Image(systemName: "person.3.fill")
                        Text("Groups")
                    }
                }
                .tag(0)

                
                PartyManagement()
                    .environmentObject(appState)
                .tabItem{
                    VStack{
                        Image(systemName: "person.2.fill")
                        Text("Parties")
                    }
                }
                .tag(1)
                
                Text("Transaction Maintenance")
                .tabItem{
                    VStack{
                        Image(systemName: "arrow.right.arrow.left.square.fill")
                        Text("Transactions")
                    }
                }
                .tag(2)
                
                Text("Reports")
                .tabItem{
                    VStack{
                        Image(systemName: "list.bullet")
                        Text("Reports")
                    }
                }
                .tag(3)
                
                Text("User Maintenance")
                .tabItem{
                    VStack{
                        Image(systemName: "person.crop.rectangle.fill")
                        Text("User Maintenance")
                    }
                }
                .tag(4)
                
                Text("Settings")
                .tabItem{
                    VStack{
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                }
                .tag(5)

            }else{
                Text("Transaction Maintenance")
                .tabItem{
                    VStack{
                        Image(systemName: "arrow.right.arrow.left.square.fill")
                        Text("Transactions")
                    }
                }
                .tag(2)
                
                Text("Settings")
                .tabItem{
                    VStack{
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                }
                .tag(5)
            }
        }
    }
}
