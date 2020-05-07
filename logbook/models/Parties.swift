//
//  Parties.swift
//  logbook
//
//  Created by Amit Bajaj on 5/5/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import Foundation

struct Party: Codable, Hashable, Identifiable{
    
    enum CodingKeys: String, CodingKey{
        case status
        case pname = "name"
        case pid = "id"
        
    }
    
    let id = UUID()
    let pid: String
    let pname: String
    let status: Status
}

struct QueryParty: Codable, Hashable, Identifiable{
    enum CodingKeys: String, CodingKey{
        case status, code
        case partyList = "list"
    }
    let id = UUID()
    let status: Status
    let code: String?
    let partyList: [Party]?
}

struct PartyWithBalance: Codable, Hashable, Identifiable{
    
    enum CodingKeys: String, CodingKey{
        case gid, gname, inrbal, usdbal, aedbal
        case pid = "id"
        case pname = "name"
    }
    
    let id = UUID()
    let pid: String
    let pname: String
    let gid: String
    let gname: String
    let inrbal: String
    let usdbal: String
    let aedbal: String
}

struct QueryPartyWithBalance: Codable, Hashable, Identifiable{
    enum CodingKeys: String, CodingKey{
        case status, code
        case partyList = "list"
    }
    
    let id = UUID()
    let status: Status
    let code: String?
    let partyList: [PartyWithBalance]?
}

final class PartyList: ObservableObject{
    @Published var partyList = [PartyWithBalance]()
}

struct AddPartyStatus: Codable{
    let status: Status
    let id: String?
    let code: String?
}


struct EditPartyStatus: Codable{
    let status: Status
    let code: String?
}
