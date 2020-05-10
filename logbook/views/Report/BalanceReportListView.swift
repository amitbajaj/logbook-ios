//
//  BalanceReportListView.swift
//  logbook
//
//  Created by Amit Bajaj on 5/9/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI


struct BalanceReportListView: View {
    
    enum PickerSheets{
        case FromDate, ToDate, Party
    }
    
    enum AlertTypes{
        case MultiPartyError, PartyLoadError, ReportError
    }

    @EnvironmentObject var appState: ApplicationState
    @ObservedObject var reportEntries = BalanceReportList()
    
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
    @State private var alertSheet = AlertTypes.PartyLoadError
    
    @State private var showSheet = false
    @State private var pickerSheet: PickerSheets = .FromDate
    @State var selectedParties = PartyList()
    
    
    var body: some View {
        ZStack{
            NavigationView{
                VStack{
                    HStack{
                        Button(action: {self.pickerSheet = .FromDate; self.showSheet = true}){
                            Text("From Date : \(dateFormatter.string(from: self.fromDate))")
                        }
                        Spacer()
                        Button(action: {self.pickerSheet = .ToDate; self.showSheet = true}){
                            Text("To Date : \(dateFormatter.string(from: self.toDate))")
                        }
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    Button(action: {
                        self.pickerSheet = .Party
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
                        ForEach(reportEntries.balanceReportList){pty in
                            ReportHeaderView(party: pty, partyName: self.getPartyName(partyId: pty.cid))
                        }
                    }
                }
                .navigationBarTitle("Balance Report")
                .navigationBarItems(trailing:
                    HStack{
                        Button(action: {self.loadTransactions()}){
                            Image(systemName: "arrow.2.circlepath")
                        }
                    .disabled(disabled)
                    }
                )
            }

            ActivityIndicator(style: .large, animate: $disabled)
                .configure {
                    $0.color = .blue
            }
        }
        .sheet(isPresented: $showSheet) {
            if (self.pickerSheet == .Party ){
                PartyPickerView(allParties: self.$partyList, partyList: self.$selectedParties)
            }else if (self.pickerSheet == .FromDate){
                LogBookDatePicker(selectedDate: self.$fromDate, minDate: Date(timeIntervalSince1970: 0), maxDate: Date())
            }else{
                LogBookDatePicker(selectedDate: self.$toDate, minDate: self.fromDate, maxDate: Date())
            }
        }
        .alert(isPresented: self.$showAlert){
            switch self.alertSheet{
            case .MultiPartyError:
                return Alert(title: Text("LogBook"), message: Text("Select parties to show report for!"))
            case .PartyLoadError:
                return Alert(title: Text("LogBook"), message: Text("Unable to load party list!"))
            case .ReportError:
                return Alert(title: Text("LogBook"), message: Text("Unable to generate report"))
            }
        }
        .onAppear{
            self.loadParties()
        }
    }
    
    private func loadTransactions(){
        if(self.disabled){return}
        self.showAlert = false
        var pty = ""
        if(selectedParties.partyList.count>0){
            pty = selectedParties.partyList.map{$0.pid}.joined(separator: ",")
        }else{
            self.alertSheet = .MultiPartyError
            self.showAlert = true
            return
        }
        self.disabled = true
        let params = [
            "mode":"BALRPTAPI",
            "pty":pty,
            "fdt":dateFormatter.string(from: self.fromDate),
            "tdt":dateFormatter.string(from: self.toDate)
        ]
        HTTPHelper.doHTTPPost(
            url: Constants.ReportsCodeURL,
            postData: params
        ){data, error in
            DispatchQueue.main.async{
                self.alertSheet = .ReportError
                if(data != nil){
                    do{
                        let response = try JSONDecoder().decode(QueryBalanceReport.self, from: data!)
                        if(response.status == Status.success){
                            self.reportEntries.balanceReportList.removeAll()
                            self.reportEntries.balanceReportList.append(contentsOf: response.data!)
                        }else{
                            self.showAlert = true
                        }
                    }catch{
                        self.showAlert = true
                    }
                }else{
                    self.showAlert = true
                }
                self.disabled = false
            }
        }
    }
    
    private func getPartyName(partyId: String) -> String{
        if let party = self.partyList.first(where: { (mParty) -> Bool in
            mParty.pid == partyId
        }) {
            return party.pname
        }else{
            return "Name not found"
        }
    }
    
    private func loadParties(){
        if(self.disabled){return}
        self.disabled = true
        self.showAlert = false
        HTTPHelper.doHTTPPost(url: Constants.PartiesCodeURL, postData: ["mode":"QRY"]){data, error in
            DispatchQueue.main.async{
                self.alertSheet = .PartyLoadError
                if(data != nil){
                    do{
                        let response = try JSONDecoder().decode(QueryParty.self, from: data!)
                        if(response.status == Status.success){
                            self.partyList.removeAll()
                            self.partyList.append(contentsOf: response.partyList!)
                        }else{
                            self.showAlert = true
                        }
                    }catch{
                        self.showAlert = true
                    }
                }else{
                    self.showAlert = true
                }
                self.disabled = false
            }
            
        }
    }
}
