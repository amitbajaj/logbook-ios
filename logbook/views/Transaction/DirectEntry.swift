//
//  DirectEntry.swift
//  logbook
//
//  Created by Amit Bajaj on 5/8/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI

struct DirectEntry: View {
    enum ActionSheets{
        case PostingType, Currencies
    }

    enum AlertTypes{
        case SaveError, SaveSuccess, PartyLoadError, AmountError
    }

    enum PickerSheets{
        case DateSheet, PartySheet
    }
    
    @State private var disabled = false
    @State private var showAlert = false
    @State private var alertType: AlertTypes = .PartyLoadError
    @State private var partyIndex = 0
    @State private var partyList = [Party]()
    @State private var showPickerSheet = false
    @State private var pickerSheet = PickerSheets.DateSheet
    @State private var showActionSheet = false
    @State private var actionSheet: ActionSheets = .PostingType
    
    @State private var mPostingType = Constants.PostingTypes.Credit
    @State private var mPostingTypeDescription = Constants.PostingTypes.Credit_Text
    @State private var mCurrency = CurrencyHelper.CurrencyStrings.INR
    @State private var mCurrencyDescription = CurrencyHelper.CurrecyDescriptions.INR
    @State private var mTxnDate = Date()
    @State private var mTxnAmount = ""
    @State private var mTxnComments = ""

    var body: some View {
        ZStack{
            VStack(alignment: .leading){
                VStack{
                Button(action:{self.pickerSheet = .PartySheet; self.showPickerSheet=true}){
                    if(self.partyIndex < self.partyList.count){
                        HStack{
                            Text(self.partyList[self.partyIndex].pname)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(UIColor.systemGray4))
                                .font(Font.body.weight(.medium))
                        }
                    }else{
                        Text("No parties in the system")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                }
                .disabled(self.disabled)
                Divider()
                .frame(height: 1)
                .padding(.horizontal, 30)
                .background(Color(UIColor.systemGray4))
                Button(action: {self.actionSheet = .Currencies ; self.showActionSheet = true}){
                    HStack{
                        Text(self.mCurrencyDescription.rawValue)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(UIColor.systemGray4))
                            .font(Font.body.weight(.medium))
                    }

                }
                .disabled(self.disabled)
                Divider()
                 .frame(height: 1)
                 .padding(.horizontal, 30)
                 .background(Color(UIColor.systemGray4))
                Button(action: {self.actionSheet = .PostingType ; self.showActionSheet = true}){
                    HStack{
                        Text(self.mPostingTypeDescription)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(UIColor.systemGray4))
                            .font(Font.body.weight(.medium))
                    }
                }
                .disabled(self.disabled)
                Divider()
                 .frame(height: 1)
                 .padding(.horizontal, 30)
                 .background(Color(UIColor.systemGray4))
                Button(action: {self.pickerSheet = .DateSheet; self.showPickerSheet = true}){
                    HStack{
                        Text(dateFormatter.string(from: self.mTxnDate))
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
                .background(Color(UIColor.systemGray4))
                .foregroundColor(Color.primary)
                

                VStack{
                TextField("Amount", text: self.$mTxnAmount)
                    .keyboardType(.decimalPad)
                    .disabled(self.disabled)
                Divider()
                .frame(height: 1)
                .padding(.horizontal, 30)
                .background(Color(UIColor.systemGray4))
                
                TextField("Comments", text: self.$mTxnComments)
                .disabled(self.disabled)
                    
                Divider()
                .frame(height: 1)
                .padding(.horizontal, 30)
                .background(Color(UIColor.systemGray4))
                }
                }
                HStack{
                    Spacer()
                    Button(action: {self.saveTransaction()}){
                        Text("Save")
                    }
                    .disabled(self.disabled)
                    Spacer()
                }
                Spacer()
            }
            .padding()
            ActivityIndicator(style: .large, animate: $disabled)
                .configure{$0.color = .blue}
        }
        .navigationBarTitle("Direct Entry")
        .onAppear(){
            self.loadParties()
        }
        .alert(isPresented: self.$showAlert){
            switch self.alertType{
            case .SaveError:
                return Alert(title: Text("LogBook"), message: Text("Unable to save transaction"))
            case .SaveSuccess:
                return Alert(title: Text("LogBook"), message: Text("Transaction saved!"))
            case .PartyLoadError:
               return Alert(title: Text("LogBook"), message: Text("Unable to load party list"))
            case .AmountError:
                return Alert(title: Text("LogBook"), message: Text("Invalid amount"))
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
            case .PostingType:
                return ActionSheet(title: Text("LogBook"), message: Text("Select posting"), buttons: [
                    .default(Text(Constants.PostingTypes.Credit_Text), action: {
                        self.mPostingType = Constants.PostingTypes.Credit
                        self.mPostingTypeDescription = Constants.PostingTypes.Credit_Text
                    }),
                    .default(Text(Constants.PostingTypes.Debit_Text), action: {
                        self.mPostingType = Constants.PostingTypes.Debit
                        self.mPostingTypeDescription = Constants.PostingTypes.Debit_Text
                    })
                ])
            case .Currencies:
                return ActionSheet(title: Text("LogBook"), message: Text("Select Currency"), buttons: [
                    .default(
                        Text(CurrencyHelper.CurrecyDescriptions.INR.rawValue),
                             action: {
                                self.mCurrency = CurrencyHelper.CurrencyStrings.INR
                                self.mCurrencyDescription = CurrencyHelper.CurrecyDescriptions.INR
                            }
                        ),
                    .default(
                        Text(CurrencyHelper.CurrecyDescriptions.USD.rawValue),
                            action: {
                                self.mCurrency = CurrencyHelper.CurrencyStrings.USD
                                self.mCurrencyDescription = CurrencyHelper.CurrecyDescriptions.USD

                            }
                        ),
                    .default(
                        Text(CurrencyHelper.CurrecyDescriptions.AED.rawValue),
                            action: {
                                self.mCurrency = CurrencyHelper.CurrencyStrings.AED
                                self.mCurrencyDescription = CurrencyHelper.CurrecyDescriptions.AED
                            }
                        )
                    ]
                )
            }
        }
    }
    
    private func loadParties(){
        if(self.disabled){return}
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
        if let _ = Double(self.mTxnAmount){
            let params = [
                "mode":"SVDRT",
                "ptyid":self.partyList[self.partyIndex].pid,
                "ccyid":self.mCurrency.rawValue,
                "txntype": String(self.mPostingType),
                "txndt": dateFormatter.string(from: self.mTxnDate),
                "txnamt": self.mTxnAmount,
                "txncmts": self.mTxnComments
                ]
            HTTPHelper.doHTTPPost(url: Constants.TransactionsCodeURL, postData: params){data, error in
                DispatchQueue.main.async{
                    if(data != nil){
                        do{
                            let response = try JSONDecoder().decode(TransactionResponse.self, from: data!)
                            if(response.status == Status.success){
                                self.alertType = .SaveSuccess
                            }else{
                                self.alertType = .SaveError
                            }
                        }catch{
                            self.alertType = .SaveError
                        }
                    }else{
                        self.alertType = .SaveError
                    }
                    self.showAlert = true
                }
            }
        }else{
            self.alertType = .AmountError
            self.showAlert = true
        }
    }
}

struct DirectEntry_Previews: PreviewProvider {
    static var previews: some View {
        DirectEntry()
    }
}
