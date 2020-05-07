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
    struct FormattedCurrecncy{
        let amount: String
        let color: Color
    }
    class func formatCurrency(amount: String, currency: Currencies) -> FormattedCurrecncy{
        let formatter = NumberFormatter()
        switch currency {
        case .INR:
            formatter.locale = Locale.init(identifier: "en_IN")
        case .USD:
            formatter.locale = Locale.init(identifier: "en_US")
        case .AED:
            formatter.locale = Locale.init(identifier: "en_AE")
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
