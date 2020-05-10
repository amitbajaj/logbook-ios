//
//  Transaction.swift
//  logbook
//
//  Created by Amit Bajaj on 5/7/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI

struct TransactionView: View {
    @State var transaction: Transaction
    
    var body: some View {
        VStack(alignment: .leading){
            Text(transaction.pty)
                .font(.headline)
            HStack{
                Text(transaction.tty)
                Spacer()
                Text(transaction.dt)
            }
            if(transaction.tty != Constants.TransactionTypes.Direct){
                HStack{
                    Text(CurrencyHelper.formatCurrency(amount: transaction.exh, currency :CurrencyHelper.CurrencyStrings(rawValue: transaction.ecy)!).amount)
                    Spacer()
                    Text(Constants.ExchangeTypes[transaction.edr]!)
                }
            }
            HStack{
                Spacer()
                Text(transaction.formattedAmount().0)
                    .foregroundColor(transaction.formattedAmount().1)
            }
            if transaction.cmt.count > 0 {
                Text(transaction.cmt)
            }
        }
    }
}
