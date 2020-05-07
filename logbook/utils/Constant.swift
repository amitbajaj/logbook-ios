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
    }
}
