//
//  Environment.swift
//  logbook
//
//  Created by Amit Bajaj on 5/3/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import Foundation

class ApplicationState: ObservableObject{
    @Published var sessionId = ""
    @Published var isLoggedIn = false
    @Published var isAdmin = false
    @Published var reloadGroups = false
}
