//
//  ReportHeaderView.swift
//  logbook
//
//  Created by Amit Bajaj on 5/10/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI

struct ReportHeaderView: View {
    @State var party: ReportPartyBalance
    @State var partyName: String
    var body: some View {
        VStack(alignment: .leading){
            Text(self.partyName)
            VStack{
                HStack{
                    Text(party.formattedAmount(balanceType: .Opening, currency: .INR))
                        .foregroundColor(party.amountColor(balanceType: .Opening, currency: .INR))
                    Spacer()
                    Text(party.formattedAmount(balanceType: .Closing, currency: .INR))
                        .foregroundColor(party.amountColor(balanceType: .Closing, currency: .INR))
                }
                HStack{
                    Text(party.formattedAmount(balanceType: .Opening, currency: .USD))
                        .foregroundColor(party.amountColor(balanceType: .Opening, currency: .USD))
                    Spacer()
                    Text(party.formattedAmount(balanceType: .Closing, currency: .USD))
                        .foregroundColor(party.amountColor(balanceType: .Closing, currency: .USD))
                }
                HStack{
                    Text(party.formattedAmount(balanceType: .Opening, currency: .AED))
                        .foregroundColor(party.amountColor(balanceType: .Opening, currency: .AED))
                    Spacer()
                    Text(party.formattedAmount(balanceType: .Closing, currency: .AED))
                        .foregroundColor(party.amountColor(balanceType: .Closing, currency: .AED))
                }
            }
            ScrollView(.horizontal, content: {
                HStack(spacing: 10) {
                    ForEach(party.list){txn in
                        ReportTransactionView(reportTxn: txn)
                        Divider()
                        .frame(width: 1)
                        .padding(.vertical, 10)
                        .background(Color(UIColor.systemGray4))
                    }
                }
            })
        }
    }
}
