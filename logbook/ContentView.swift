//
//  ContentView.swift
//  logbook
//
//  Created by Amit Bajaj on 5/2/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: ApplicationState
    
    var body: some View{
        Group{
            if(appState.isLoggedIn){
                ApplicationView()
            }else{
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
