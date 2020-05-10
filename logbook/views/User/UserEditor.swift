//
//  UserEditor.swift
//  logbook
//
//  Created by Amit Bajaj on 5/10/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI

struct UserEditor: View {
    enum AlertTypes{
        case LoginId, UserName, Password, SaveError, SaveSuccess, UpdateError, UpdateSuccess
    }
    
    @State var userId: String
    @State var loginId: String
    @State var userName: String
    @State var profileId: String
    @State private var password: String = ""
    @State private var showActionSheet = false
    @State private var showAlert = false
    @State private var alertType = AlertTypes.LoginId
    
    @State private var disabled = false

    var body: some View {
        ZStack{
            VStack(alignment: .leading){
                if self.userId.isEmpty {
                    TextField("User Id", text: self.$loginId)
                        .autocapitalization(.none)
                    Divider()
                    .frame(height: 1)
                    .padding(.horizontal, 30)
                    .background(Color(UIColor.systemGray4))
                }else{
                    Text(self.loginId)
                    .foregroundColor(Color(UIColor.systemGray4))
                }
                TextField("User Name", text: self.$userName)
                Divider()
                .frame(height: 1)
                .padding(.horizontal, 30)
                .background(Color(UIColor.systemGray4))
                SecureField("Password", text: self.$password)
                Divider()
                .frame(height: 1)
                .padding(.horizontal, 30)
                .background(Color(UIColor.systemGray4))
                Button(action: {self.showActionSheet = true}){
                    HStack{
                        Text(Constants.getProfileText(pid: self.profileId))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(UIColor.systemGray4))
                            .font(Font.body.weight(.medium))
                    }
                }
                Divider()
                .frame(height: 1)
                .padding(.horizontal, 30)
                .background(Color(UIColor.systemGray4))
                HStack{
                    Spacer()
                    Button(action:{self.saveUser()}){
                        Text("Save")
                    }
                    Spacer()
                }
                Spacer()
            }
                .padding()
            ActivityIndicator(style: .large, animate: self.$disabled)
                .configure{$0.color = .blue}
        }
        .actionSheet(isPresented: self.$showActionSheet){
            ActionSheet(title: Text(Constants.AppName), message: Text("Select profile"), buttons: [
                .default(Text("Admin"), action: {self.profileId = Constants.UserProfiles.Admin}),
                .default(Text("Staff"), action: {self.profileId = Constants.UserProfiles.Staff})
            ])
        }
        .alert(isPresented: self.$showAlert){
            switch self.alertType{
            case .LoginId:
                return Alert(title: Text(Constants.AppName), message: Text("Enter a userId!"))
            case .Password:
                return Alert(title: Text(Constants.AppName), message: Text("Enter a password!"))
            case .SaveError:
                return Alert(title: Text(Constants.AppName), message: Text("Unable to save user details!"))
            case .SaveSuccess:
                return Alert(title: Text(Constants.AppName), message: Text("User saved successfully!"))
            case .UpdateError:
                return Alert(title: Text(Constants.AppName), message: Text("Unable to update user details!"))
            case .UpdateSuccess:
                return Alert(title: Text(Constants.AppName), message: Text("User updated successfully!"))
            case .UserName:
                return Alert(title: Text(Constants.AppName), message: Text("Enter a user name!"))
            }
        }
        .navigationBarTitle(self.getTitle())
    }
    
    private func getTitle()->String{
        if self.userId.isEmpty {return "Add User"} else {return "Edit User"}
    }
    private func saveUser(){
        if loginId.isEmpty {
            self.alertType = .LoginId
            self.showAlert = true
            return
        }
        if userName.isEmpty {
            self.alertType = .UserName
            self.showAlert = true
            return
        }
        if self.userId.isEmpty && self.password.isEmpty {
            self.alertType = .Password
            self.showAlert = true
            return
        }
        var params: [String: String] = [:]
        if self.userId.isEmpty {
            params = [
                "mode":"ADD",
                "usrid":self.loginId,
                "usrname":self.userName,
                "usrpass":self.password,
                "pid":self.profileId
            ]
        }else{
            params = [
                "mode":"SVEDTAPI",
                "uname":self.userName,
                "upass":self.password,
                "uprof":self.profileId,
                "uid":self.userId
            ]
        }
        HTTPHelper.doHTTPPost(url: Constants.UsersCodeURL, postData: params){data, error in
            DispatchQueue.main.async {
                if data != nil {
                    do{
                        if self.userId.isEmpty {
                            let response = try JSONDecoder().decode(AddUserStatus.self, from: data!)
                            if response.status == .success {
                                self.alertType = .SaveSuccess
                            }else{
                                self.alertType = .SaveError
                            }
                        }else{
                            let response = try JSONDecoder().decode(EditUserStatus.self, from: data!)
                            if response.status == .success {
                                self.alertType = .UpdateSuccess
                            }else{
                                self.alertType = .UpdateError
                            }
                        }

                    }catch{
                        self.alertType = .SaveError
                    }
                }else{
                    self.alertType = .SaveError
                }
                self.showAlert = true
            }
        }
    }
}
