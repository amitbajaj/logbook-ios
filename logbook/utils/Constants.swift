//
//  Constant.swift
//  logbook
//
//  Created by Amit Bajaj on 5/2/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import Foundation

enum Constants {
    private static let BaseDomain = "dev.bajajtech.in"
    private static let BaseURL = "https://\(BaseDomain)/logbook"
    static let LoginURL = "\(BaseURL)/code/login.php"
    static let LogoutURL = "\(BaseURL)/code/logout.php"
    static let GroupsCodeURL = "\(BaseURL)/code/actions/groups.php"
    static let PartiesCodeURL = "\(BaseURL)/code/actions/parties.php"
    static let TransactionsCodeURL = "\(BaseURL)/code/actions/txns.php"
    static let ReportsCodeURL = "\(BaseURL)/code/actions/reports.php"
    static let UsersCodeURL = "\(BaseURL)/code/actions/users.php"
    static let SessionCookieName = "PHPSESSID"
    
    enum ButtonImages{
        static let Login = "lock.open.fill"
        static let Add = "plus"
        static let Save = "tray.and.arrow.down.fill"
        static let Delete = "trash"
        static let Reload = "arrow.2.circlepath"
        static let Password = "keyboard"
        static let Logout = "lock.fill"
    }
    
    enum TransactionTypes{
        static let Direct = "Direct"
        static let Currency = "Currency Transfer"
        static let Party = "Party Transfer"
    }
    
    enum PostingTypes{
        static let Credit = 1
        static let Credit_Text = "Credit"
        static let Debit = 2
        static let Debit_Text = "Debit"
    }
    
    enum CurrencyPostingTypes{
        static let Buy = "1"
        static let Buy_Text = "Buy"
        static let Sell = "1"
        static let Sell_Text = "Sell"
    }
    
    enum CurrencyLocales{
        static let INR = "en_IN"
        static let USD = "en_US"
        static let AED = "en_AE"
    }
    
    enum BalanceTypes{
        case Opening, Closing
    }
    
    static let ExchangeTypes = ["1":"Forward", "2":"Reverse"]
    
    enum UserProfiles{
        static let Admin = "1"
        static let Admin_Text = "Admin"
        static let Staff = "2"
        static let Staff_Text = "Staff"
    }
    
    static func getProfileText(pid: String)->String{
        switch pid {
        case UserProfiles.Admin:
            return UserProfiles.Admin_Text
        default:
            return UserProfiles.Staff_Text
        }
    }
}
