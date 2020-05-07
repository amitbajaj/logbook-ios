//
//  PartyManagement.swift
//  logbook
//
//  Created by Amit Bajaj on 5/6/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI

struct PartyManagement: View {
    @State private var editMode = false
    
    var body: some View {
        Group{
            if(editMode){
                PartyEditor(editMode: $editMode, partyId: "", partyName: "", groupId: "")
            }else{
                PartyListView(editMode: $editMode)
            }
        }
    }
}

struct PartyManagement_Previews: PreviewProvider {
    static var previews: some View {
        PartyManagement()
    }
}
