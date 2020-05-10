//
//  UserView.swift
//  logbook
//
//  Created by Amit Bajaj on 5/10/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI

struct UserView: View {
    @EnvironmentObject var appState : ApplicationState
    
    var body: some View {
        Group{
            if appState.isAdmin {
                UserListView()
            }else{
                UserManagementView()
            }
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
