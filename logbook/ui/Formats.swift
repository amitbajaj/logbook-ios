//
//  Formats.swift
//  logbook
//
//  Created by Amit Bajaj on 5/2/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import Foundation
import SwiftUI

struct LogBookFields: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding()
            .border(Color.accentColor)
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

func amountFormatter(_ currency: CurrencyHelper.Currencies) -> NumberFormatter {
    let formatter = NumberFormatter()
    formatter.allowsFloats = true
    formatter.minimum = 0
    switch currency {
    case .INR:
        formatter.locale = Locale.init(identifier: Constants.CurrencyLocales.INR)
        formatter.maximumFractionDigits = 2
    case .USD:
        formatter.locale = Locale.init(identifier: Constants.CurrencyLocales.USD)
        formatter.maximumFractionDigits = 2
    case .AED:
        formatter.locale = Locale.init(identifier: Constants.CurrencyLocales.AED)
        formatter.maximumFractionDigits = 2
    }
    return formatter
}
