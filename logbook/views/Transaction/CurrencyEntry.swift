//
//  CurrencyEntry.swift
//  logbook
//
//  Created by Amit Bajaj on 5/9/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI

struct CurrencyEntry: View {
    enum ActionSheets{
        case PostingType, Currencies, ExchangeDirection
    }

    enum AlertTypes{
        case SaveError, SaveSuccess, PartyLoadError, AmountError, ExchangeRateError, SameCurrencyError
    }

    enum PickerSheets{
        case DateSheet, PartySheet
    }
    
    enum CurrencyTargets{
        case Source, Target
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
    
    @State private var mPostingType = Constants.CurrencyPostingTypes.Buy
    @State private var mPostingTypeDescription = Constants.CurrencyPostingTypes.Buy_Text
    @State private var mCurrencyTarget = CurrencyTargets.Source
    @State private var mSourceCurrency = CurrencyHelper.CurrencyStrings.INR
    @State private var mSourceCurrencyDescription = CurrencyHelper.CurrecyDescriptions.INR
    @State private var mTargetCurrency = CurrencyHelper.CurrencyStrings.INR
    @State private var mTargetCurrencyDescription = CurrencyHelper.CurrecyDescriptions.INR
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
                        Spacer()
                        Button(action:{self.actionSheet = .PostingType; self.showActionSheet = true}){
                            HStack{
                                Text(self.mPostingTypeDescription)
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
                        Button(action: {self.actionSheet = .Currencies; self.mCurrencyTarget = .Source; self.showActionSheet = true}){
                            HStack{
                                Text(self.mSourceCurrencyDescription.rawValue)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(UIColor.systemGray4))
                                    .font(Font.body.weight(.medium))
                            }
                        }
                            .disabled(self.disabled)
                        Spacer()
                        Button(action: {self.actionSheet = .Currencies; self.mCurrencyTarget = .Target; self.showActionSheet = true}){
                            HStack{
                                Text(self.mTargetCurrencyDescription.rawValue)
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
            .navigationBarTitle("Currency Transfer")
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
                case .SameCurrencyError:
                    return Alert(title: Text("LogBook"), message: Text("Select different currencies!"))
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
                        .default(Text(Constants.CurrencyPostingTypes.Buy_Text), action: {
                            self.mPostingType = Constants.CurrencyPostingTypes.Buy
                            self.mPostingTypeDescription = Constants.CurrencyPostingTypes.Buy_Text
                        }),
                        .default(Text(Constants.CurrencyPostingTypes.Sell_Text), action: {
                            self.mPostingType = Constants.CurrencyPostingTypes.Sell
                            self.mPostingTypeDescription = Constants.CurrencyPostingTypes.Sell_Text
                        })
                    ])
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
        case .Source:
            switch selectedCurrency {
            case .INR:
                self.mSourceCurrency = .INR
                self.mSourceCurrencyDescription = .INR
            case .USD:
                self.mSourceCurrency = .USD
                self.mSourceCurrencyDescription = .USD
            case .AED:
                self.mSourceCurrency = .AED
                self.mSourceCurrencyDescription = .AED
            }
        case .Target:
            switch selectedCurrency {
            case .INR:
                self.mTargetCurrency = .INR
                self.mTargetCurrencyDescription = .INR
            case .USD:
                self.mTargetCurrency = .USD
                self.mTargetCurrencyDescription = .USD
            case .AED:
                self.mTargetCurrency = .AED
                self.mTargetCurrencyDescription = .AED
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
                if self.mSourceCurrency == self.mTargetCurrency {
                    self.alertType = .SameCurrencyError
                    self.showAlert = true
                }else{
                    let params = [
                    "mode":"SVCCY",
                    "ptyid":self.partyList[self.partyIndex].pid,
                    "txntyp": self.mPostingType,
                    "ccy1id":self.mSourceCurrency.rawValue,
                    "ccy2id":self.mTargetCurrency.rawValue,
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
