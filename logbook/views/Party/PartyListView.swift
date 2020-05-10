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
    @ObservedObject var parties = PartyWithBalanceList()
    @State private var disabled = false
    @State private var isError = false
    
    var body: some View {
        ZStack{
            NavigationView{
                List{
                    ForEach(parties.partyList){party in
                        NavigationLink(destination: PartyEditor(partyId: party.pid, partyName: party.pname, groupId: party.gid)){
                            VStack(alignment: .leading){
                                HStack{
                                    Text(party.pname)
                                    Spacer()
                                    Text(party.gname)
                                }
                                
                                HStack{
                                    Spacer()
                                    Text(CurrencyHelper.formatCurrency(amount: party.inrbal, currency: CurrencyHelper.Currencies.INR).amount)
                                    .foregroundColor(CurrencyHelper.formatCurrency(amount: party.inrbal, currency: CurrencyHelper.Currencies.INR).color)
                                }
                                HStack{
                                    Spacer()
                                    Text(CurrencyHelper.formatCurrency(amount: party.usdbal, currency: CurrencyHelper.Currencies.USD).amount)
                                    .foregroundColor(CurrencyHelper.formatCurrency(amount: party.usdbal, currency: CurrencyHelper.Currencies.USD).color)
                                }
                                HStack{
                                    Spacer()
                                    Text(CurrencyHelper.formatCurrency(amount: party.aedbal, currency: CurrencyHelper.Currencies.AED).amount)
                                    .foregroundColor(CurrencyHelper.formatCurrency(amount: party.aedbal, currency: CurrencyHelper.Currencies.AED).color)
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle("Parties")
                .navigationBarItems(trailing:
                    HStack(spacing: Constants.IconSpacing){
                        Button(action: {self.loadParties()}){
                            Image(systemName: Constants.ButtonImages.Reload)
                                .resizable()
                                .frame(width: Constants.IconSize, height: Constants.IconSize-5)
                        }
                        NavigationLink(
                            destination: PartyEditor(partyId: "", partyName: "", groupId: "")){
                                Image(systemName: Constants.ButtonImages.Add)
                                .resizable()
                                .frame(width: Constants.IconSize, height: Constants.IconSize)
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
            Alert(title: Text(Constants.AppName), message: Text("Unable to load parties"))
        }
    }
    
    private func loadParties(){
        if(self.disabled) {return}
        let loginParams = ["mode":"QRYBAL"]
        self.disabled=true
        HTTPHelper.doHTTPPost(url: Constants.PartiesCodeURL, postData: loginParams){response, error in
            if(response != nil){
                do {
                    let partyList = try JSONDecoder().decode(QueryPartyWithBalance.self, from: response!)
                    DispatchQueue.main.async {
                        if(partyList.status==Status.success){
                            self.parties.partyList.removeAll()
                            self.parties.partyList.append(contentsOf: partyList.partyList!)
                            self.isError = false
                        }else{
                            self.isError = true
                        }
                    }
                }catch{
                    self.isError = true
                }
            }else{
                self.isError=true
            }
            self.disabled=false
        }
    }
}


