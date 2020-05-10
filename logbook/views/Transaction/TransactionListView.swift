//
//  TransactionListView.swift
//  logbook
//
//  Created by Amit Bajaj on 5/7/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI



struct TransactionListView: View {
    enum ActionSheets{
        case FromDate, ToDate, PartyPicker
    }
    
    enum AlertTypes{
        case TransactionLoadError, PartyLoadError
    }
    
    @EnvironmentObject var appState: ApplicationState
    @ObservedObject var transactions = TransactionList()
    @State private var partyIndex = 0
    @State private var partyList = [Party]()
    @State private var fromDate: Date = {
        let df = DateFormatter()
        df.dateFormat = "yyyy"
        var year = df.string(from: Date())
        df.dateFormat = "yyyy-MM-dd"
        return df.date(from: "\(year)-01-01")!
    }()
    @State private var toDate = Date()
    @State private var disabled = false
    @State private var showAlert = false
    @State private var alertType = AlertTypes.PartyLoadError
    
    @State private var showSheet = false
    @State private var whichSheet: ActionSheets = .FromDate
    @State var selectedParties = PartyList()
    
    
    var body: some View {
        ZStack{
            NavigationView{
                VStack{
                    HStack{
                        Button(action: {self.whichSheet = .FromDate; self.showSheet = true}){
                            Text("From Date : \(dateFormatter.string(from: self.fromDate))")
                        }
                        Spacer()
                        Button(action: {self.whichSheet = .ToDate; self.showSheet = true}){
                            Text("To Date : \(dateFormatter.string(from: self.toDate))")
                        }
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    Button(action: {
                        self.whichSheet = .PartyPicker
                        self.showSheet = true
                    }) {
                        HStack {
                            Text("Select Parties").foregroundColor(Color.black)
                            Spacer()
                            Text("\(selectedParties.partyList.count)")
                                .foregroundColor(Color(UIColor.systemGray))
                                .font(.body)
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(UIColor.systemGray4))
                                .font(Font.body.weight(.medium))
                        }
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    List{
                        ForEach(transactions.transactionList){txn in
                            NavigationLink(destination: TransactionEditor(
                                mTxnId: txn.tid,
                                mTxnType: txn.tty,
                                mTxnPartyId: txn.pid,
                                mTxnDate: dateFormatter.date(from: txn.dt)!,
                                mTxnAmount: amountFormatter(txn.amount().1).string(for: txn.amount().0)!,
                                mTxnCurrency: txn.amount().1,
                                mTxnExch: amountFormatter(txn.exchangeCurrency()).string(for: txn.exchangeRate())!,
                                mTxnExchDir: txn.edr,
                                mTxnExchCurrency: txn.exchangeCurrency(),
                                mTxnComments: txn.cmt
                            )){
                                TransactionView(transaction: txn)
                            }
                            
                        }
                    }
                }
                .navigationBarTitle("Transactions")
                .navigationBarItems(trailing:
                    HStack(spacing: Constants.IconSpacing){
                        Button(action: {self.loadTransactions()}){
                            Image(systemName: Constants.ButtonImages.Reload)
                                .resizable()
                                .frame(width: Constants.IconSize, height: Constants.IconSize-5)
                        }
                        if appState.isAdmin {
                            NavigationLink(
                                destination: DirectEntry()){
                                    Image(systemName: Constants.ButtonImages.DirectTransaction)
                                    .resizable()
                                    .frame(width: Constants.IconSize, height: Constants.IconSize)
                            }
                            NavigationLink(
                                destination: CurrencyEntry()){
                                    Image(systemName: Constants.ButtonImages.CurrencyTransaction)
                                    .resizable()
                                    .frame(width: Constants.IconSize, height: Constants.IconSize)
                            }
                        }
                        NavigationLink(
                            destination: PartyEntry()){
                                Image(systemName: Constants.ButtonImages.PartyTransaction)
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
        .sheet(isPresented: $showSheet) {
            if (self.whichSheet == .PartyPicker ){
                PartyPickerView(allParties: self.$partyList, partyList: self.$selectedParties)
            }else if (self.whichSheet == .FromDate){
                LogBookDatePicker(selectedDate: self.$fromDate, minDate: Date(timeIntervalSince1970: 0), maxDate: Date())
            }else{
                LogBookDatePicker(selectedDate: self.$toDate, minDate: self.fromDate, maxDate: Date())
            }
        }
        .onAppear{
            self.loadParties()
        }
        .alert(isPresented: self.$showAlert){
            switch self.alertType{
            case .PartyLoadError:
                return Alert(title: Text(Constants.AppName), message: Text("Unable to load list of parties!"))
            case .TransactionLoadError:
                return Alert(title: Text(Constants.AppName), message: Text("Unable to load list of transactions!"))
            }
        }
    }
    
    private func loadTransactions(){
        if(self.disabled){return}
        self.disabled = true
        self.showAlert = false
        var pty = "-1"
        if(selectedParties.partyList.count>0){
            pty = selectedParties.partyList.map{$0.pid}.joined(separator: ",")
        }
        HTTPHelper.doHTTPPost(
            url: Constants.TransactionsCodeURL,
            postData: [
                "mode":"QRY",
                "ptyid":pty,
                "fdt":dateFormatter.string(from: self.fromDate),
                "tdt":dateFormatter.string(from: self.toDate)
            ]
        ){data, error in
            DispatchQueue.main.async{
                if(data != nil){
                    do{
                        let response = try JSONDecoder().decode(QueryTransaction.self, from: data!)
                        if(response.status == Status.success){
                            self.transactions.transactionList.removeAll()
                            self.transactions.transactionList.append(contentsOf: response.list!)
                        }else{
                            self.alertType = .TransactionLoadError
                            self.showAlert = true
                        }
                    }catch{
                        self.alertType = .TransactionLoadError
                        self.showAlert = true
                    }
                }else{
                    self.alertType = .TransactionLoadError
                    self.showAlert = true
                }
                self.disabled = false
            }
        }
    }
    
    private func loadParties(){
        if(self.disabled){return}
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
}
