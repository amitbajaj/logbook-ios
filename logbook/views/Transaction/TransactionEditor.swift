//
//  TransactionEditor.swift
//  logbook
//
//  Created by Amit Bajaj on 5/8/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI



struct TransactionEditor: View {
    
    enum ActionSheets{
        case Direction, DeleteConfirmation
    }

    enum AlertTypes{
        case SaveError, SaveSuccess, PartyLoadError, DeleteError, DeleteSuccess
    }

    enum PickerSheets{
        case DateSheet, PartySheet
    }
    
    @State var mTxnId: String
    @State var mTxnType: String
    @State var mTxnPartyId: String
    @State var mTxnDate: Date
    @State var mTxnAmount: String
    @State var mTxnCurrency: CurrencyHelper.Currencies
    @State var mTxnExch: String
    @State var mTxnExchDir: String
    @State var mTxnExchCurrency: CurrencyHelper.Currencies
    @State var mTxnComments: String
    
    @State private var disabled = false
    @State private var showAlert = false
    @State private var alertType: AlertTypes = .PartyLoadError
    @State private var partyIndex = 0
    @State private var partyList = [Party]()
    @State private var showPickerSheet = false
    @State private var pickerSheet = PickerSheets.DateSheet
    @State private var showActionSheet = false
    @State private var actionSheet: ActionSheets = .DeleteConfirmation
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Button(action:{self.pickerSheet = .PartySheet; self.showPickerSheet=true}){
                        if(self.partyIndex < self.partyList.count){
                            Text(self.partyList[self.partyIndex].pname)
                            .multilineTextAlignment(.leading)
                        }else{
                            Text(self.mTxnPartyId)
                            .multilineTextAlignment(.leading)
                        }
                        
                    }
                    .disabled(self.disabled)
                    Spacer()
                }
                HStack{
                    Button(action: {self.pickerSheet = .DateSheet; self.showPickerSheet = true}){
                        Text(dateFormatter.string(from: self.mTxnDate))
                    }
                    .disabled(self.disabled)
                    Spacer()
                    TextField("Amount", text: self.$mTxnAmount)
                    .multilineTextAlignment(.trailing)
                    .disabled(self.disabled)
                    Text(CurrencyHelper.getCurrencyDescription(mCurrency: mTxnExchCurrency))
                    .disabled(self.disabled)
                }
                if(self.mTxnType != Constants.TransactionTypes.Direct){
                    HStack{
                        TextField("Exchange", text: self.$mTxnExch)
                            .disabled(self.disabled)
                        Button(action: {self.actionSheet = .Direction ; self.showActionSheet = true}){
                            Text(Constants.ExchangeTypes[self.mTxnExchDir]!)
                        }
                        .disabled(self.disabled)
                        
                    }
                }
                TextField("Comments", text: self.$mTxnComments)
                .disabled(self.disabled)
            
                HStack{
                    Button(action:{self.actionSheet = .DeleteConfirmation; self.showActionSheet = true}){
                        Text("Delete")
                    }
                    .disabled(self.disabled)
                    Spacer()
                    Button(action:{self.saveTransaction()}){
                        Text("Save")
                    }
                    .disabled(self.disabled)
                }
                Spacer()
            }
            .padding()
            ActivityIndicator(style: .large, animate: self.$disabled)
                .configure{
                    $0.color = .blue
            }
        }
        .navigationBarTitle("Edit Transaction")
        .onAppear{
            self.loadParties()
        }
        
        
        .alert(isPresented: self.$showAlert){
            switch self.alertType{
            case .SaveError:
                return Alert(title: Text("LogBook"), message: Text("Unable to save transaction"))
            case .DeleteError:
                return Alert(title: Text("LogBook"), message: Text("Unable to delete transaction"))
            case .SaveSuccess:
                return Alert(title: Text("LogBook"), message: Text("Transaction saved!"))
            case .DeleteSuccess:
                return Alert(title: Text("LogBook"), message: Text("Transaction deleted!"))
            case .PartyLoadError:
               return Alert(title: Text("LogBook"), message: Text("Unable to load party list"))
            }
        }
            
        .sheet(isPresented: self.$showPickerSheet) {
            if self.pickerSheet == PickerSheets.DateSheet{
                LogBookDatePicker(selectedDate: self.$mTxnDate, minDate: Date(timeIntervalSince1970: 0), maxDate: Date())
            }else{
                LogBookListPicker(selectedItem: self.$partyIndex, label: "Select Party", listOfValues: self.partyList.map{$0.pname})
            }
        }
            
        .actionSheet(isPresented: self.$showActionSheet){
            switch self.actionSheet{
            case .Direction:
                return ActionSheet(title: Text("LogBook"), message: Text("Select direction"), buttons: [
                    .default(Text(Constants.ExchangeTypes["1"]!), action: {self.mTxnExchDir = "1"}),
                    .default(Text(Constants.ExchangeTypes["2"]!), action: {self.mTxnExchDir = "2"})
                ])
            case .DeleteConfirmation:
                return ActionSheet(title: Text("LogBook"), message: Text("Are you sure you want to delete this transaction?"), buttons: [
                    .default(Text("Yes"), action: {self.deleteTransaction()}),
                    .default(Text("No"))
                ])
            }
        }
        
        
        
        
    }
    
    private func loadParties(){
        if(self.disabled){return}
//        if(self.dataLoaded){return}
        if(self.partyList.count>0){return}
        self.disabled = true
        self.showAlert = false
        HTTPHelper.doHTTPPost(url: Constants.PartiesCodeURL, postData: ["mode":"QRY"]){data, error in
            DispatchQueue.main.async{
                if(data != nil){
                    do{
                        let response = try JSONDecoder().decode(QueryParty.self, from: data!)
                        if(response.status == Status.success){
                            self.partyList.removeAll()
                            self.partyList.append(contentsOf: response.partyList!)
                            self.partyIndex = self.partyList.firstIndex
                                { (partyObject) -> Bool in
                                    partyObject.pid == self.mTxnPartyId
                                } ?? 0
                        }else{
                            self.alertType = .PartyLoadError
                            self.showAlert = true
                        }
                    }catch{
                        self.alertType = .PartyLoadError
                        self.showAlert = true
                    }
                }else{
                    self.alertType = .PartyLoadError
                    self.showAlert = true
                }
                self.disabled = false
            }
        }

    }
    
    private func saveTransaction(){
        if(self.disabled){return}
        self.disabled = true
        self.showAlert = false
        let params = [
            "mode":"SVEDT",
            "tid":self.mTxnId,
            "pid":self.partyList[self.partyIndex].pid,
            "dt":dateFormatter.string(from: self.mTxnDate),
            "amt":String(self.mTxnAmount),
            "exch":String(self.mTxnExch),
            "edir": self.mTxnExchDir,
            "cmt":self.mTxnComments
        ]
        HTTPHelper.doHTTPPost(url: Constants.TransactionsCodeURL, postData: params){data, error in
            DispatchQueue.main.async {
                if(data != nil){
                    do{
                        let response = try JSONDecoder().decode(TransactionResponse.self, from: data!)
                        if response.status == Status.success {
                            self.alertType = .SaveSuccess
                            self.showAlert = true
                        }else{
                            self.alertType = .SaveError
                            self.showAlert = true
                        }
                    }catch{
                        self.alertType = .SaveError
                        self.showAlert = true
                    }
                }else{
                    self.alertType = .SaveError
                    self.showAlert = true
                }
                self.disabled=false
            }
        }
    }
    
    private func deleteTransaction(){
        if(self.disabled){return}
        self.disabled = true
        self.showAlert = false
        let params = ["mode":"TDEL", "tid":self.mTxnId]
        HTTPHelper.doHTTPPost(url: Constants.TransactionsCodeURL, postData: params){data, error in
            DispatchQueue.main.async {
                if(data != nil){
                    do{
                        let response = try JSONDecoder().decode(TransactionResponse.self, from: data!)
                        if response.status == Status.success {
                            self.alertType = .DeleteSuccess
                            self.showAlert = true
                        }else{
                            self.alertType = .DeleteError
                            self.showAlert = true
                        }
                    }catch{
                        self.alertType = .DeleteError
                        self.showAlert = true
                    }
                }else{
                    self.alertType = .DeleteError
                    self.showAlert = true
                }
                self.disabled=false
            }
        }
    }
}
