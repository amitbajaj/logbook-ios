//
//  PartyListView.swift
//  logbook
//
//  Created by Amit Bajaj on 5/5/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI

struct PartyListView: View {
    @EnvironmentObject var appState: ApplicationState
    @ObservedObject var parties = PartyList()
    @Binding var editMode: Bool
    @State private var disabled = false
    @State private var isError = false
    
    
    
    var body: some View {
        ZStack{
            NavigationView{
                List{
                    ForEach(parties.partyList){party in
                        NavigationLink(destination: PartyEditor(editMode: self.$editMode, partyId: party.pid, partyName: party.pname, groupId: party.gid)){
                            VStack(alignment: .leading){
                                HStack{
                                    Text(party.pname)
                                    Spacer()
                                    Text(party.gname)
                                }
                                
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
                .navigationBarTitle("Parties")
                .navigationBarItems(trailing:
                    HStack{
                        Button(action: {self.loadParties()}){
                            Image(systemName: "arrow.2.circlepath")
                        }
                        NavigationLink(
                            destination: PartyEditor(editMode: self.$editMode, partyId: "", partyName: "", groupId: "")){
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
            self.loadParties()
        }
        .alert(isPresented: self.$isError){
            Alert(title: Text("Logbook"), message: Text("Unable to load parties"))
        }
    }
    
    private func loadParties(){
        if(self.disabled) {return}
        let loginParams = ["mode":"QRYBAL"]
        self.disabled=true
        HTTPHelper.doHTTPPost(url: Constants.PartiesCodeURL, postData: loginParams){response, error in
            if(response != nil){
                do {
//                    print("Got the response")
//                    print(String(decoding: response!, as: UTF8.self))
                    let partyList = try JSONDecoder().decode(QueryPartyWithBalance.self, from: response!)
                    DispatchQueue.main.async {
//                        print("JSON Decoded")
                        if(partyList.status==Status.success){
//                            print("Response is a success")
                            self.parties.partyList.removeAll()
                            self.parties.partyList.append(contentsOf: partyList.partyList!)
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


