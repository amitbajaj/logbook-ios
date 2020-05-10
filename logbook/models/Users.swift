//
//  Users.swift
//  logbook
//
//  Created by Amit Bajaj on 5/10/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import Foundation

struct User: Codable, Hashable, Identifiable{
    
    enum CodingKeys: String, CodingKey{
        case login = "uid"
        case uid = "id"
        case name = "uname"
        case pid
    }
    
    let id = UUID()
    let uid: String
    let login: String
    let name: String
    let pid: String
}

struct QueryUser: Codable, Hashable, Identifiable{
    enum CodingKeys: String, CodingKey{
        case status, code
        case userList = "list"
    }
    let id = UUID()
    let status: Status
    let code: String?
    let userList: [User]?
}

final class UserList: ObservableObject{
    @Published var userList = [User]()
}

struct AddUserStatus: Codable, Hashable, Identifiable{
    enum CodingKeys: String, CodingKey{
        case status, code
        case uid = "id"
    }
    
    let id = UUID()
    let status: Status
    let uid: String?
    let code: String?
}


struct EditUserStatus: Codable, Hashable, Identifiable{
    let id = UUID()
    let status: Status
    let code: String?
}
