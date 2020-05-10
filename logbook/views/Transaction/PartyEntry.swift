//
//  PartyEntry.swift
//  logbook
//
//  Created by Amit Bajaj on 5/9/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI

struct PartyEntry: View {
    enum ActionSheets{
        case Currencies, ExchangeDirection
    }

    enum AlertTypes{
        case SaveError, SaveSuccess, PartyLoadError, AmountError, ExchangeRateError, SamePartyError
    }

    enum PickerSheets{
        case DateSheet, PartySheet
    }
    
    enum CurrencyTargets{
        case FirstParty, SecondParty
    }
    
    enum PartyTargets{
        case FirstParty, SecondParty
    }
    
    @State private var disabled = false
    @State private var showAlert = false
    @State private var alertType: AlertTypes = .PartyLoadError
    @State private var firstPartyIndex = 0
    @State private var secondPartyIndex = 0
    @State private var partyList = [Party]()
    @State private var mPartyTarget = PartyTargets.FirstParty
    @State private var showPickerSheet = false
    @State private var pickerSheet = PickerSheets.DateSheet
    @State private var showActionSheet = false
    @State private var actionSheet: ActionSheets = .Currencies
    
    @State private var mCurrencyTarget = CurrencyTargets.FirstParty
    @State private var mFirstCurrency = CurrencyHelper.CurrencyStrings.INR
    @State private var mFirstCurrencyDescription = CurrencyHelper.CurrecyDescriptions.INR
    @State private var mSecondCurrency = CurrencyHelper.CurrencyStrings.INR
    @State private var mSecondCurrencyDescription = CurrencyHelper.CurrecyDescriptions.INR
    @State private var mExchangeRateDirection = "1"
    @State private var mExchangeRate = ""
    @State private var mTxnDate = Date()
    @State private var mTxnAmount = ""
    @State private var mTxnComments = ""

    var body: some View {
        ZStack{
            VStack(alignment: .leading){
                VStack{
                    HStack{
                        Button(action:{self.mPartyTarget = .FirstParty;self.pickerSheet = .PartySheet; self.showPickerSheet=true}){
                            if(self.firstPartyIndex < self.partyList.count){
                                HStack{
                                    Text(self.partyList[self.firstPartyIndex].pname)
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
                        Spacer()
                        Button(action:{self.actionSheet = .Currencies; self.mCurrencyTarget = .FirstParty; self.showActionSheet = true}){
                            HStack{
                                Text(self.mFirstCurrencyDescription.rawValue)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(UIColor.systemGray4))
                                    .font(Font.body.weight(.medium))
                            }
                        }
                        .disabled(self.disabled)

                    }
                    Divider()
                        .frame(height: 1)
                        .padding(.horizontal, 30)
                        .background(Color(UIColor.systemGray4))
                    HStack{
                        Button(action:{self.mPartyTarget = .FirstParty;self.pickerSheet = .PartySheet; self.showPickerSheet=true}){
                            if(self.secondPartyIndex < self.partyList.count){
                                HStack{
                                    Text(self.partyList[self.secondPartyIndex].pname)
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
                        Spacer()
                        Button(action:{self.actionSheet = .Currencies; self.mCurrencyTarget = .SecondParty; self.showActionSheet = true}){
                            HStack{
                                Text(self.mSecondCurrencyDescription.rawValue)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(UIColor.systemGray4))
                                    .font(Font.body.weight(.medium))
                            }
                        }
                        .disabled(self.disabled)
                    }
                    Divider()
                        .frame(height: 1)
                        .padding(.horizontal, 30)
                        .background(Color(UIColor.systemGray4))
                    HStack{
                        TextField("Exchange", text: self.$mExchangeRate)
                            .keyboardType(.decimalPad)
                            .disabled(self.disabled)
                        Spacer()
                        Button(action: {self.actionSheet = .ExchangeDirection ; self.showActionSheet = true}){
                            HStack{
                                Text(Constants.ExchangeTypes[self.mExchangeRateDirection]!)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(UIColor.systemGray4))
                                    .font(Font.body.weight(.medium))
                            }
                        }
                            .disabled(self.disabled)
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
                    }
                    
                }
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
            .navigationBarTitle("Party Transfer")
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
                case .ExchangeRateError:
                    return Alert(title: Text("LogBook"), message: Text("Invalid exchange rate"))
                case .SamePartyError:
                    return Alert(title: Text("LogBook"), message: Text("Select different parties!"))
                }
            }
            .sheet(isPresented: self.$showPickerSheet) {
                if self.pickerSheet == PickerSheets.DateSheet{
                    LogBookDatePicker(selectedDate: self.$mTxnDate, minDate: Date(timeIntervalSince1970: 0), maxDate: Date())
                }else if (self.mPartyTarget == PartyTargets.FirstParty){
                    LogBookListPicker(selectedItem: self.$firstPartyIndex, label: "Select Party", listOfValues: self.partyList.map{$0.pname})
                }else{
                    LogBookListPicker(selectedItem: self.$secondPartyIndex, label: "Select Party", listOfValues: self.partyList.map{$0.pname})
                }
            }
            .actionSheet(isPresented: self.$showActionSheet){
                switch self.actionSheet{
                case .Currencies:
                    return ActionSheet(title: Text("LogBook"), message: Text("Select Currency"), buttons: [
                        .default(
                            Text(CurrencyHelper.CurrecyDescriptions.INR.rawValue),
                            action: {self.setCurrencyValue(selectedCurrency: .INR)}
                            ),
                        .default(
                            Text(CurrencyHelper.CurrecyDescriptions.USD.rawValue),
                                action: {self.setCurrencyValue(selectedCurrency: .USD)}
                            ),
                        .default(
                            Text(CurrencyHelper.CurrecyDescriptions.AED.rawValue),
                                action: {self.setCurrencyValue(selectedCurrency: .AED)}
                            )
                        ]
                    )
                case .ExchangeDirection:
                    return ActionSheet(title: Text("LogBook"), message: Text("Select Exchange Direction"), buttons: [
                        .default(
                            Text(Constants.ExchangeTypes["1"]!),
                            action: {self.mExchangeRateDirection = "1"}
                            ),
                        .default(
                            Text(Constants.ExchangeTypes["2"]!),
                                action: {self.mExchangeRateDirection = "2"}
                            )
                        ]
                    )
                }
            }
    }
    
    private func setCurrencyValue(selectedCurrency: CurrencyHelper.Currencies){
        switch mCurrencyTarget {
        case .FirstParty:
            switch selectedCurrency {
            case .INR:
                self.mFirstCurrency = .INR
                self.mFirstCurrencyDescription = .INR
            case .USD:
                self.mFirstCurrency = .USD
                self.mFirstCurrencyDescription = .USD
            case .AED:
                self.mFirstCurrency = .AED
                self.mFirstCurrencyDescription = .AED
            }
        case .SecondParty:
            switch selectedCurrency {
            case .INR:
                self.mSecondCurrency = .INR
                self.mSecondCurrencyDescription = .INR
            case .USD:
                self.mSecondCurrency = .USD
                self.mSecondCurrencyDescription = .USD
            case .AED:
                self.mSecondCurrency = .AED
                self.mSecondCurrencyDescription = .AED
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
            if let _ = Double(self.mExchangeRate){
                if (self.firstPartyIndex == self.secondPartyIndex){
                    self.alertType = .SamePartyError
                    self.showAlert = true
                }else{
                    let params = [
                        "mode":"SVPTY",
                        "pty1id":self.partyList[self.firstPartyIndex].pid,
                        "ccy1id":self.mFirstCurrency.rawValue,
                        "pty2id":self.partyList[self.secondPartyIndex].pid,
                        "ccy2id":self.mSecondCurrency.rawValue,
                        "txndt": dateFormatter.string(from: self.mTxnDate),
                        "txnamt": self.mTxnAmount,
                        "txnexch":self.mExchangeRate,
                        "txnedir":self.mExchangeRateDirection,
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
                }
            }else{
                self.alertType = .ExchangeRateError
                self.showAlert = true
            }
        }else{
            self.alertType = .AmountError
            self.showAlert = true
        }
    }
}
