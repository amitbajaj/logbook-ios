//
//  TransactionListView.swift
//  logbook
//
//  Created by Amit Bajaj on 5/7/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI



struct TransactionListView: View {
    enum WhichSheet{
        case fromDate, toDate, partyPicker
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
    @State private var isError = false
    @State private var isPartyError = false
    
    @State private var showSheet = false
    @State private var whichSheet: WhichSheet = .fromDate
    @State var selectedParties = PartyList()
    
    
    var body: some View {
        ZStack{
            NavigationView{
                VStack{
                    HStack{
                        Button(action: {self.whichSheet = .fromDate; self.showSheet = true}){
                            Text("From Date : \(dateFormatter.string(from: self.fromDate))")
                        }
                        Spacer()
                        Button(action: {self.whichSheet = .toDate; self.showSheet = true}){
                            Text("To Date : \(dateFormatter.string(from: self.toDate))")
                        }
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    Button(action: {
                        self.whichSheet = .partyPicker
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
                    HStack{
                        Button(action: {self.loadTransactions()}){
                            Image(systemName: "arrow.2.circlepath")
                        }
                        if appState.isAdmin {
                            NavigationLink(
                                destination: DirectEntry()){
                                Image(systemName: "plus.circle")
                            }
                            NavigationLink(
                                destination: CurrencyEntry()){
                                Image(systemName: "dollarsign.circle")
                            }
                        }
                        NavigationLink(
                            destination: PartyEntry()){
                            Image(systemName: "arrow.up.arrow.down.circle")
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
            if (self.whichSheet == .partyPicker ){
                PartyPickerView(allParties: self.$partyList, partyList: self.$selectedParties)
            }else if (self.whichSheet == .fromDate){
                LogBookDatePicker(selectedDate: self.$fromDate, minDate: Date(timeIntervalSince1970: 0), maxDate: Date())
            }else{
                LogBookDatePicker(selectedDate: self.$toDate, minDate: self.fromDate, maxDate: Date())
            }
        }
        .onAppear{
            self.loadParties()
        }
    }
    
    private func loadTransactions(){
        if(self.disabled){return}
        self.disabled = true
        self.isError = false
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
                            self.isError = true
                        }
                    }catch{
                        self.isError = true
                    }
                }else{
                    self.isError = true
                }
                self.disabled = false
            }
        }
    }
    
    private func loadParties(){
        if(self.disabled){return}
        self.disabled = true
        self.isPartyError = false
        HTTPHelper.doHTTPPost(url: Constants.PartiesCodeURL, postData: ["mode":"QRY"]){data, error in
            DispatchQueue.main.async{
                if(data != nil){
                    do{
                        let response = try JSONDecoder().decode(QueryParty.self, from: data!)
                        if(response.status == Status.success){
                            self.partyList.removeAll()
                            self.partyList.append(contentsOf: response.partyList!)
                        }else{
                            self.isPartyError = true
                        }
                    }catch{
                        self.isPartyError = true
                    }
                }else{
                    self.isPartyError = true
                }
                self.disabled = false
            }
            
        }
    }
}
