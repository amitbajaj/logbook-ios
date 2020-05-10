//
//  ReportTransactionView.swift
//  logbook
//
//  Created by Amit Bajaj on 5/10/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI

struct ReportTransactionView: View {
    @State var reportTxn: ReportTransaction
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Text(reportTxn.tty)
                Spacer()
                Text(reportTxn.tdt)
            }
            
            if(reportTxn.tty != Constants.TransactionTypes.Direct){
                HStack{
                    Text(CurrencyHelper.formatCurrency(amount: reportTxn.exh, currency: reportTxn.exchangeCurrency()).amount)
                        .foregroundColor(CurrencyHelper.formatCurrency(amount: reportTxn.exh, currency: reportTxn.exchangeCurrency()).color)
                    Spacer()
                    Text(Constants.ExchangeTypes[reportTxn.edr]!)
                }
            }
            HStack{
                Spacer()
                Text(reportTxn.formattedAmount())
                    .foregroundColor(reportTxn.amountColor())
            }
            Text(reportTxn.cmt)
        }
    }
}

