//
//  GroupListView.swift
//  logbook
//
//  Created by Amit Bajaj on 5/3/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import Foundation
import SwiftUI

struct GroupListView: View{

    @EnvironmentObject var appState: ApplicationState
    @ObservedObject var groups = GroupPartyList()
    
    @State private var disabled = false
    @State private var isError = false
    
    var body: some View{
        ZStack{
            NavigationView{
                List{
                    ForEach(groups.groupList){group in
                        Section(header:
                            GroupHeader(
                                groupName: group.name,
                                groupId: "")
                        ){
                            ForEach(group.plist){party in
                                VStack(alignment: .leading){
                                    Text(party.pname)
                                    HStack{
                                        Spacer()
                                        Text(CurrencyHelper.formatCurrency(amount: party.inrbal, currency: .INR).amount)
                                            .foregroundColor(CurrencyHelper.formatCurrency(amount: party.inrbal, currency: .INR).color)
                                    }
                                    HStack{
                                        Spacer()
                                        Text(CurrencyHelper.formatCurrency(amount: party.usdbal, currency: .USD).amount)
                                        .foregroundColor(CurrencyHelper.formatCurrency(amount: party.usdbal, currency: .USD).color)
                                    }
                                    HStack{
                                        Spacer()
                                        Text(CurrencyHelper.formatCurrency(amount: party.aedbal, currency: .AED).amount)
                                        .foregroundColor(CurrencyHelper.formatCurrency(amount: party.aedbal, currency: .AED).color)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle("Groups")
                .navigationBarItems(trailing:
                    HStack{
                        Button(action: {self.loadGroups()}){
                            Image(systemName: "arrow.2.circlepath")
                        }
                        NavigationLink(
                        destination: GroupEditor(
                            groupId: "-1",
                            groupName: "")){
                            Image(systemName: "plus")
                        }
                    }
                )
                .disabled(self.disabled)
            }
            
            ActivityIndicator(style: .large, animate: $disabled)
                .configure {
                    $0.color = .blue
            }
        }
        .onAppear{
            self.loadGroups()
        }
        .alert(isPresented: self.$isError){
            Alert(title: Text("Logbook"), message: Text("Unable to load groups"))
        }
    }
    
    private func loadGroups(){
        if(self.disabled) {return}
        let loginParams = ["mode":"QRYPTY"]
        self.disabled=true
        HTTPHelper.doHTTPPost(url: Constants.GroupsCodeURL, postData: loginParams){response, error in
            if(response != nil){
                do {
//                    print("Got the response")
//                    print(String(decoding: response!, as: UTF8.self))
                    let groupList = try JSONDecoder().decode(QueryGroupWithParty.self, from: response!)
                    DispatchQueue.main.async {
//                        print("JSON Decoded")
                        if(groupList.status=="success"){
//                            print("Response is a success")
                            self.groups.groupList.removeAll()
                            self.groups.groupList.append(contentsOf: groupList.list)
//                            print(self.groups.groupList.count)
                            self.isError = false
//                            print("Groups loaded")
                        }else{
//                            print("Response is a failure")
                            self.isError = true
                        }
                    }
                }catch{
//                    print("JSON Decode Error \(error)")
                    self.isError = true
                }
            }else{
//                print("Could not get a respinse \(error ?? "NO ERROR MESSAGE")")
                self.isError=true
            }
            self.disabled=false
        }
    }
}


struct GroupHeader: View{
    var groupName: String
    var groupId: String
    
    var body: some View{
        HStack{
            NavigationLink(destination: GroupEditor(groupId: groupId, groupName: groupName)){
//                Text("\(groupId) : \(groupName)")
                Text(groupName)
                    .font(.system(size:20))
            }
        }
    }
}
