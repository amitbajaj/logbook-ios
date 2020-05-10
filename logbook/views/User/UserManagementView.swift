//
//  UserManagementView.swift
//  logbook
//
//  Created by Amit Bajaj on 5/10/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI

struct UserManagementView: View {
    enum AlertTypes{
        case PasswordChanged, PasswordMismatch, CurrentPasswordMissing, NewPasswordMissing, PasswordNotUpdated
    }
    
    @State private var disabled = false
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertType = AlertTypes.CurrentPasswordMissing
    
    
    var body: some View {
        ZStack{
            VStack{
                Text("Change Password")
                VStack(alignment: .leading){
                    SecureField("Current Password", text: self.$currentPassword)
                    Divider()
                        .frame(height: 1)
                        .padding(.horizontal, 30)
                        .background(Color(UIColor.systemGray4))
                    SecureField("New Password", text: self.$newPassword)
                    Divider()
                        .frame(height: 1)
                        .padding(.horizontal, 30)
                        .background(Color(UIColor.systemGray4))
                    SecureField("Confirm Password", text: self.$confirmPassword)
                    Divider()
                        .frame(height: 1)
                        .padding(.horizontal, 30)
                        .background(Color(UIColor.systemGray4))
                }
                VStack(alignment: .center){
                    Button(action:{self.changePassword()}){
                        Text("Save")
                    }
                }
                Spacer()
            }
            .padding()
            ActivityIndicator(style: .large, animate: self.$disabled)
                .configure{$0.color = .blue}
            .navigationBarTitle("User Management")
            .alert(isPresented: self.$showAlert){
                switch self.alertType{
                case .CurrentPasswordMissing:
                    return Alert(title: Text("LogBook"), message: Text("Enter the current password"))
                case .NewPasswordMissing:
                    return Alert(title: Text("LogBook"), message: Text("Enter the new password"))
                case .PasswordChanged:
                    return Alert(title: Text("LogBook"), message: Text("Password updated!"))
                case .PasswordMismatch:
                    return Alert(title: Text("LogBook"), message: Text("New and Confirm password should be same"))
                case .PasswordNotUpdated:
                    return Alert(title: Text("LogBook"), message: Text("Password could not be updated!"))
                }
            }
        }
    }
    
    private func changePassword(){
        if disabled {return}
        if self.currentPassword.isEmpty {
            self.alertType = .CurrentPasswordMissing
            self.showAlert = true
            return
        }
        if self.newPassword.isEmpty {
            self.alertType = .NewPasswordMissing
            self.showAlert = true
            return
        }
        if self.newPassword != self.confirmPassword {
            self.alertType = .PasswordMismatch
            self.showAlert = true
            return
        }
        let params = [
            "mode":"UPPWD",
            "upwd":self.newPassword,
            "opwd":self.currentPassword
        ]
        self.disabled = true
        HTTPHelper.doHTTPPost(url: Constants.UsersCodeURL, postData: params){data, error in
            DispatchQueue.main.async {
                if data != nil {
                    do{
                        let response = try JSONDecoder().decode(EditUserStatus.self, from: data!)
                        if response.status == Status.success {
                            self.alertType = .PasswordChanged
                        }else{
                            self.alertType = .PasswordNotUpdated
                        }
                    }catch{
                        self.alertType = .PasswordNotUpdated
                    }
                    
                }else{
                    self.alertType = .PasswordNotUpdated
                }
                self.disabled = false
                self.showAlert = true
            }
        }
    }
}

