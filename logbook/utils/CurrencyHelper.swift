//
//  CurrencyHelper.swift
//  logbook
//
//  Created by Amit Bajaj on 5/3/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import Foundation
import SwiftUI

class CurrencyHelper{
    enum Currencies: Int{
        case INR = 1, USD, AED
    }
    enum CurrencyStrings: String{
        case INR = "1"
        case USD = "2"
        case AED = "3"
    }
    enum CurrecyDescriptions: String{
        case INR = "INR"
        case USD = "USD"
        case AED = "AED"
    }
    struct FormattedCurrecncy{
        let amount: String
        let color: Color
    }

    static func getCurrencyDescription(mCurrency: String) -> String{
        var retVal = CurrecyDescriptions.INR.rawValue
        switch mCurrency.lowercased() {
        case "inr":
            retVal = CurrecyDescriptions.INR.rawValue
        case "usd":
            retVal = CurrecyDescriptions.USD.rawValue
        case "aed":
            retVal = CurrecyDescriptions.AED.rawValue
        default:
            retVal = CurrecyDescriptions.INR.rawValue
        }
        return retVal
    }
    
    static func getCurrencyDescription(mCurrency: Currencies) -> String{
        var retVal = "INR"
        switch mCurrency {
        case .INR:
            retVal = "INR"
        case .USD:
            retVal = "USD"
        case .AED:
            retVal = "AED"
        }
        return retVal
    }
    
    class func formatCurrency(amount: String, currency: CurrencyStrings) -> FormattedCurrecncy{
        switch currency {
        case .INR:
            return formatCurrency(amount: amount, currency: Currencies.INR)
        case .USD:
            return formatCurrency(amount: amount, currency: Currencies.USD)
        case .AED:
            return formatCurrency(amount: amount, currency: Currencies.AED)
        }
    }
    
    class func formatCurrency(amount: String, currency: CurrecyDescriptions) -> FormattedCurrecncy{
        switch currency {
        case .INR:
            return formatCurrency(amount: amount, currency: Currencies.INR)
        case .USD:
            return formatCurrency(amount: amount, currency: Currencies.USD)
        case .AED:
            return formatCurrency(amount: amount, currency: Currencies.AED)
        }
    }
    
    class func formatCurrency(amount: String, currency: Currencies) -> FormattedCurrecncy{
        let formatter = NumberFormatter()
        switch currency {
        case .INR:
            formatter.locale = Locale.init(identifier: Constants.CurrencyLocales.INR)
        case .USD:
            formatter.locale = Locale.init(identifier: Constants.CurrencyLocales.USD)
        case .AED:
            formatter.locale = Locale.init(identifier: Constants.CurrencyLocales.AED)
        }
        formatter.numberStyle = .currency
        let amt = Double(amount)!
        var col: Color
        if(amt<0){
            col = Color("Red")
        }else{
            col = Color("Green")
        }
        if let formattedAmount = formatter.string(from: amt as NSNumber){
            return FormattedCurrecncy(amount: formattedAmount, color: col)
        }else{
            return FormattedCurrecncy(amount: "", color: col)
        }
    }
}
