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

                
                PartyListView()
                    .environmentObject(appState)
                .tabItem{
                    VStack{
                        Image(systemName: "person.2.fill")
                        Text("Parties")
                    }
                }
                .tag(1)
                
                TransactionListView()
                    .environmentObject(appState)
                .tabItem{
                    VStack{
                        Image(systemName: "arrow.right.arrow.left.square.fill")
                        Text("Transactions")
                    }
                }
                .tag(2)
                
                BalanceReportListView()
                    .environmentObject(appState)
                .tabItem{
                    VStack{
                        Image(systemName: "list.bullet")
                        Text("Reports")
                    }
                }
                .tag(3)
                
                UserListView()
                .tabItem{
                    VStack{
                        Image(systemName: "person.crop.rectangle.fill")
                        Text("User Maintenance")
                    }
                }
                .tag(4)

            }else{
                TransactionListView()
                    .environmentObject(self.appState)
                .tabItem{
                    VStack{
                        Image(systemName: "arrow.right.arrow.left.square.fill")
                        Text("Transactions")
                    }
                }
                .tag(2)
                
                UserManagementView()
                    .environmentObject(self.appState)
                .tabItem{
                    VStack{
                        Image(systemName: "person.crop.rectangle.fill")
                        Text("User Management")
                    }
                }
                .tag(5)
            }
        }
    }
}
