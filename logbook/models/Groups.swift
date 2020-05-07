//
//  Groups.swift
//  logbook
//
//  Created by Amit Bajaj on 5/3/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import Foundation
import SwiftUI

struct PartyGroup: Codable, Hashable, Identifiable{
    let id = UUID()
    let gid: String
    let name: String
}

struct QueryGroup: Codable, Hashable, Identifiable{
    enum CodingKeys: String, CodingKey{
        case status, code
        case groupList = "list"
    }
    let id = UUID()
    let status: Status
    let code: String?
    let groupList: [PartyGroup]?
}

struct GroupWithParty: Codable, Hashable, Identifiable{
    let id = UUID()
    let gid: String
    let name: String
    let plist: [GroupParty]
}

struct GroupParty: Codable, Hashable, Identifiable{
    let id = UUID()
    let pid: String
    let pname: String
    let inrbal: String
    let usdbal: String
    let aedbal: String
}

struct QueryGroupWithParty: Codable{
    let id = UUID()
    let status: String
    let code: String?
    let list: [GroupWithParty]
}

struct AddGroupStatus: Codable{
    let status: Status
    let id: String?
    let code: String?
}

struct EditGroupStatus: Codable{
    let status: Status
    let code: String?
}

final class GroupList: ObservableObject {
    @Published var groupList = [PartyGroup]()
}

final class GroupPartyList: ObservableObject {
    @Published var groupList = [GroupWithParty]()
}
