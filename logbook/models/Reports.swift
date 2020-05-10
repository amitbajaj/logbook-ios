//
//  Report.swift
//  logbook
//
//  Created by Amit Bajaj on 5/9/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import Foundation
import SwiftUI

struct ReportTransaction: Codable, Hashable, Identifiable{
    
    let id = UUID()
    let tdt: String
    let cmt: String
    let exh: String
    let edr: String
    let tty: String
    let inrbal: String
    let usdbal: String
    let aedbal: String
    let ecy: String
    
    func amount()->Double{
        var amt = 0.0
        let inr = Double(inrbal) ?? 0.0
        if inr != 0.0 {amt = inr} else{
            let usd = Double(usdbal) ?? 0.0
            if usd != 0.0 {amt = usd} else {
                let aed = Double(aedbal) ?? 0.0
                if aed != 0.0 {amt = aed}
            }
        }
        return amt
    }
    
    func currency()->CurrencyHelper.Currencies{
        var cur = CurrencyHelper.Currencies.INR
        let inr = Double(inrbal) ?? 0.0
        if inr != 0.0 {cur = .INR} else{
            let usd = Double(usdbal) ?? 0.0
            if usd != 0.0 {cur = .USD} else {
                let aed = Double(aedbal) ?? 0.0
                if aed != 0.0 {cur = .AED}
            }
        }
        return cur
    }
    
    func exchangeRate()->Double{
        return Double(exh) ?? 0.0
    }
    
    func exchangeCurrency()->CurrencyHelper.Currencies{
        return CurrencyHelper.Currencies.init(rawValue: Int(ecy) ?? 1) ?? CurrencyHelper.Currencies.INR
    }
    
    func formattedAmount()->String{
        var formattedVal = "0.0"
        let inr = Double(inrbal) ?? 0.0
        if inr != 0.0 {formattedVal = CurrencyHelper.formatCurrency(amount: inrbal, currency: CurrencyHelper.Currencies.INR).amount} else{
            let usd = Double(usdbal) ?? 0.0
            if usd != 0.0 {formattedVal = CurrencyHelper.formatCurrency(amount: usdbal, currency: CurrencyHelper.Currencies.USD).amount} else {
                let aed = Double(aedbal) ?? 0.0
                if aed != 0.0 {formattedVal = CurrencyHelper.formatCurrency(amount: aedbal, currency: CurrencyHelper.Currencies.AED).amount}
            }
        }
        return formattedVal
    }
    
    func amountColor()->Color{
        var col = Color.black
        let inr = Double(inrbal) ?? 0.0
        if inr != 0.0 {col = CurrencyHelper.formatCurrency(amount: inrbal, currency: CurrencyHelper.Currencies.INR).color} else{
            let usd = Double(usdbal) ?? 0.0
            if usd != 0.0 {col = CurrencyHelper.formatCurrency(amount: usdbal, currency: CurrencyHelper.Currencies.USD).color} else {
                let aed = Double(aedbal) ?? 0.0
                if aed != 0.0 {col = CurrencyHelper.formatCurrency(amount: aedbal, currency: CurrencyHelper.Currencies.AED).color}
            }
        }
        return col
    }
}

struct ReportPartyBalance: Codable, Hashable, Identifiable{
    let id = UUID()
    let cid: String
    let oinr: String
    let ousd: String
    let oaed: String
    let cinr: String
    let cusd: String
    let caed: String
    let list: [ReportTransaction]
    
    func formattedAmount(balanceType: Constants.BalanceTypes, currency: CurrencyHelper.Currencies)->String{
        switch balanceType{
        case .Opening:
            switch currency {
            case .INR:
                return CurrencyHelper.formatCurrency(amount: oinr, currency: CurrencyHelper.Currencies.INR).amount
            case .USD:
                return CurrencyHelper.formatCurrency(amount: ousd, currency: CurrencyHelper.Currencies.USD).amount
            case .AED:
                return CurrencyHelper.formatCurrency(amount: oaed, currency: CurrencyHelper.Currencies.AED).amount
            }
            
        case .Closing:
            switch currency {
            case .INR:
                return CurrencyHelper.formatCurrency(amount: cinr, currency: CurrencyHelper.Currencies.INR).amount
            case .USD:
                return CurrencyHelper.formatCurrency(amount: cusd, currency: CurrencyHelper.Currencies.USD).amount
            case .AED:
                return CurrencyHelper.formatCurrency(amount: caed, currency: CurrencyHelper.Currencies.AED).amount
            }
        }
    }
    
    func amountColor(balanceType: Constants.BalanceTypes, currency: CurrencyHelper.Currencies)->Color{
        switch balanceType{
        case .Opening:
            switch currency {
            case .INR:
                return CurrencyHelper.formatCurrency(amount: oinr, currency: CurrencyHelper.Currencies.INR).color
            case .USD:
                return CurrencyHelper.formatCurrency(amount: ousd, currency: CurrencyHelper.Currencies.USD).color
            case .AED:
                return CurrencyHelper.formatCurrency(amount: oaed, currency: CurrencyHelper.Currencies.AED).color
            }
            
        case .Closing:
            switch currency {
            case .INR:
                return CurrencyHelper.formatCurrency(amount: cinr, currency: CurrencyHelper.Currencies.INR).color
            case .USD:
                return CurrencyHelper.formatCurrency(amount: cusd, currency: CurrencyHelper.Currencies.USD).color
            case .AED:
                return CurrencyHelper.formatCurrency(amount: caed, currency: CurrencyHelper.Currencies.AED).color
            }
        }
    }
}

struct QueryBalanceReport: Codable, Hashable, Identifiable{
    
    let id = UUID()
    let status: Status
    let data: [ReportPartyBalance]?
    let code: String?

}

final class BalanceReportList: ObservableObject{
    @Published var balanceReportList = [ReportPartyBalance]()
    func amount(pIndex: Int, tIndex: Int) -> Double{
        if(pIndex >= balanceReportList.count || pIndex < 0){
            return 0.0
        }else{
            if(tIndex >= balanceReportList[pIndex].list.count || tIndex < 0){
                return 0.0
            }else{
                return balanceReportList[pIndex].list[tIndex].amount()
            }
        }
    }
}
