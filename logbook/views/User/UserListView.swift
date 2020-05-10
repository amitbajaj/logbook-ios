//
//  UserListView.swift
//  logbook
//
//  Created by Amit Bajaj on 5/10/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI


struct UserListView: View {
    @EnvironmentObject var appState: ApplicationState
    @ObservedObject var users = UserList()
    @State private var disabled = false
    @State private var isError = false
    
    var body: some View {
        ZStack{
            NavigationView{
                List{
                    ForEach(users.userList){user in
                        NavigationLink(destination: UserEditor(userId: user.uid, loginId: user.login, userName: user.name, profileId: user.pid)){
                            VStack(alignment: .leading){
                                Text(user.name)
                                    .font(.headline)
                                HStack{
                                    Text(user.login)
                                        .font(.footnote)
                                    Spacer()
                                    Text(Constants.getProfileText(pid: user.pid))
                                        .font(.footnote)
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle("Users")
                    .disabled(self.disabled)
                .navigationBarItems(leading:
                    HStack{
                        Button(action: {self.appState.isLoggedIn=false}){
                            Image(systemName: Constants.ButtonImages.Logout)
                        }
                        NavigationLink(destination: UserManagementView()){
                            Image(systemName: Constants.ButtonImages.Password)
                        }
                    }, trailing:
                    HStack{
                        Button(action: {self.loadUsers()}){
                            Image(systemName: Constants.ButtonImages.Reload)
                        }
                        NavigationLink(
                        destination: UserEditor(userId: "", loginId: "", userName: "", profileId: Constants.UserProfiles.Staff)){
                            Image(systemName: Constants.ButtonImages.Add)
                        }
                    }
                )
                    .disabled(self.disabled)
            }
            ActivityIndicator(style: .large, animate: $disabled)
                .configure {
                    $0.color = .blue
            }
        }
        .onAppear{
            self.loadUsers()
        }
        .alert(isPresented: self.$isError){
            Alert(title: Text("Logbook"), message: Text("Unable to load users"))
        }
    }
    
    private func loadUsers(){
        if(self.disabled) {return}
        let params = ["mode":"QRY"]
        self.disabled=true
        HTTPHelper.doHTTPPost(url: Constants.UsersCodeURL, postData: params){data, error in
            if(data != nil){
                do {
                    let response = try JSONDecoder().decode(QueryUser.self, from: data!)
                    DispatchQueue.main.async {
                        if(response.status==Status.success){
                            self.users.userList.removeAll()
                            self.users.userList.append(contentsOf: response.userList!)
                            self.isError = false
                        }else{
                            self.isError = true
                        }
                    }
                }catch{
                    self.isError = true
                }
            }else{
                self.isError=true
            }
            self.disabled=false
        }
    }
}


