//
//  LoginView.swift
//  logbook
//
//  Created by Amit Bajaj on 5/3/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: ApplicationState
    @State private var userId: String = ""
    @State private var password: String = ""
//    @State private var userId: String = "amitbajaj"
//    @State private var password: String = "password"
    @State private var disabled: Bool = false
    @State private var loginSuccess: Bool = false
    @State private var isError = false
    
    var body: some View {
        ZStack{
            VStack{

                Text("Welcome to Logbook!")
                    .font(.system(size: 24))
                TextField("User Id", text: $userId)
                    .padding(EdgeInsets.init(top: 0, leading: 10, bottom: 0, trailing: 10))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .disabled(disabled)
                    .textFieldStyle(LogBookFields())
                SecureField(
                    "Password",
                    text: $password,
                    onCommit: {self.doLogin()}
                )
                    .padding(EdgeInsets.init(top: 0, leading: 10, bottom: 0, trailing: 10))
                    .disabled(disabled)
                    .textFieldStyle(LogBookFields())
                Button(action: { self.doLogin() } ) {
                    LogBookButton(buttonText: "Login", buttonSystemImage: Constants.ButtonImages.Login)
                }
                    .disabled(disabled)
                Spacer()
            }
            ActivityIndicator(style: .large, animate: $disabled)
                .configure {
                    $0.color = .blue
            }
        }
        .actionSheet(isPresented: self.$isError) { () -> ActionSheet in
            ActionSheet(title: Text("Logbook"), message: Text("Login failed"), buttons: [.default(Text("Ok"))])
        }
        .padding()
    }
    private func doLogin(){
        let loginParams = ["mode":"LGN", "uid":self.userId, "pwd":self.password]
        self.disabled=true
        HTTPHelper.doHTTPPost(url: Constants.LoginURL, postData: loginParams){response, error in
            if(response != nil){
                do {
                    let login = try JSONDecoder().decode(Login.self, from: response!)
                    DispatchQueue.main.async {
                        if(login.status=="success"){
                            self.loginSuccess = true
                            self.appState.isLoggedIn = true
                            self.appState.isAdmin = login.code=="1"
                            self.isError = false
                        }else{
                            self.loginSuccess = false
                            self.appState.isLoggedIn = false
                            self.isError = true
                        }
                    }
                }catch{
                    self.loginSuccess = false
                    self.appState.isLoggedIn = false
                    self.isError = true
                }
            }
            self.disabled=false
            
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
