//
//  Transactions.swift
//  logbook
//
//  Created by Amit Bajaj on 5/7/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import Foundation
import SwiftUI

struct Transaction: Codable, Hashable, Identifiable{
    
    let id = UUID()
    let tid: String
    let pid: String
    let pty: String
    let dt: String
    let inr: String
    let usd: String
    let aed: String
    let exh: String
    let edr: String
    let ecy: String
    let cmt: String
    let tty: String
    
    func amount()->(Double, CurrencyHelper.Currencies){
        var amt = 0.0
        var cur = CurrencyHelper.Currencies.INR
        if let inrAmt = Double(inr){
            if inrAmt != 0 { amt = inrAmt; cur = .INR } else {
                if let usdAmt = Double(usd){
                    if usdAmt != 0 { amt = usdAmt; cur = .USD } else {
                        if let aedAmt = Double(aed){
                            if aedAmt != 0 { amt = aedAmt; cur = .AED }
                        }
                    }
                }
            }
        }
        return (abs(amt), cur)
    }
    
    func exchangeRate()->Double{
        return Double(exh) ?? 0.0
    }
    
    func exchangeCurrency()->CurrencyHelper.Currencies{
        return CurrencyHelper.Currencies.init(rawValue: Int(ecy) ?? 1) ?? CurrencyHelper.Currencies.INR
    }
    
    func currency() -> CurrencyHelper.Currencies{
        var cur = CurrencyHelper.Currencies.INR
        if let inrAmt = Double(inr){
            if inrAmt != 0 { cur = .INR } else {
                if let usdAmt = Double(usd){
                    if usdAmt != 0 { cur = .USD } else {
                        if let aedAmt = Double(aed){
                            if aedAmt != 0 { cur = .AED }
                        }
                    }
                }
            }
        }
        return cur
    }
    
    func formattedAmount()->(String, Color){
        var formattedValues = CurrencyHelper.FormattedCurrecncy(amount: "",color: .black)
        if let inrAmt = Double(inr){
            if inrAmt != 0 {
                formattedValues = CurrencyHelper.formatCurrency(amount: inr, currency: CurrencyHelper.Currencies.INR)
            } else {
                if let usdAmt = Double(usd){
                    if usdAmt != 0 {
                        formattedValues = CurrencyHelper.formatCurrency(amount: usd, currency: CurrencyHelper.Currencies.USD)
                    } else {
                        if let aedAmt = Double(aed){
                            if aedAmt != 0 {
                            formattedValues = CurrencyHelper.formatCurrency(amount: aed, currency: CurrencyHelper.Currencies.AED)
                            }
                        }
                    }
                }
            }
        }
        return (formattedValues.amount, formattedValues.color)
    }
}

struct QueryTransaction: Codable, Hashable, Identifiable{
    
    let id = UUID()
    let status: Status
    let list: [Transaction]?
    let code: String?

}

struct TransactionResponse: Codable, Hashable, Identifiable{
    
    let id = UUID()
    let status: Status
    let code: String?
    
}

final class TransactionList: ObservableObject{
    @Published var transactionList = [Transaction]()
    func amount(index: Int) -> Double{
        var amt = 0.0
        if(index >= transactionList.count || index < 0){
            return 0.0
        }else{
            if let inr = Double(transactionList[index].inr){
                if inr != 0 { amt = inr } else {
                    if let usd = Double(transactionList[index].usd){
                        if usd != 0 { amt = usd } else {
                            if let aed = Double(transactionList[index].aed){
                                if aed != 0 { amt = aed }
                            }
                        }
                    }
                }
            }

        }
        return amt
    }
}
