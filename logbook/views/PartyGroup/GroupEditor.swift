//
//  GroupEditor.swift
//  logbook
//
//  Created by Amit Bajaj on 5/4/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import Foundation
import SwiftUI

struct GroupEditor: View{

    enum AlertTypes{
        case SaveError, SaveSuccess, GroupNameMissing
    }
    
    @State var groupId: String = "-1"
    @State var groupName: String = ""
    @State private var isDisabled = false
    @State private var showAlert = false
    @State private var alertType = AlertTypes.SaveError
    
    var body: some View{
        ZStack{
            VStack{
                TextField("Group Name", text: $groupName)
                    .padding(EdgeInsets.init(top: 0, leading: 10, bottom: 0, trailing: 10))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(LogBookFields())
                    .disabled(self.isDisabled)
                Button(action:{self.saveGroup()}){
                    LogBookButton(buttonText: "Save Group", buttonSystemImage: Constants.ButtonImages.Save)
                }
                .disabled(self.isDisabled)
                Spacer()
            }
            ActivityIndicator(style: .large, animate: $isDisabled)
                .configure { $0.color = .blue }
        }
        .navigationBarTitle(self.groupId == "-1" ? "Add Group": "Edit Group : \(self.groupId)")
        .alert(isPresented: self.$showAlert){
            switch self.alertType{
            case .SaveError:
                return Alert(title: Text(Constants.AppName), message: Text("Unable to save group"))
            case .SaveSuccess:
                return Alert(title: Text(Constants.AppName), message: Text("Group saved!"))
            case .GroupNameMissing:
                return Alert(title: Text(Constants.AppName), message: Text("Enter a group name!"))
            }
        }
    }
    
    private func saveGroup(){
        var params: [String: Any]
        if(self.groupName.isEmpty){
            self.alertType = .GroupNameMissing
            self.showAlert = true
            return
        }
        self.isDisabled = true
        self.showAlert = false
        if (self.groupId == "-1"){
            params = ["mode":"ADD","grpname": self.groupName]
        }else{
            params = ["mode":"SVEDT","gname":self.groupName, "gid":self.groupId]
        }
        print(params)
        HTTPHelper.doHTTPPost(url: Constants.GroupsCodeURL, postData: params){ response, error in
            if(response != nil){
                do{
                    if(self.groupId == "-1"){
                        let status = try JSONDecoder().decode(AddGroupStatus.self, from: response!)
                        DispatchQueue.main.async {
                            if(status.status == Status.success){
                                self.alertType = .SaveSuccess
                                self.groupName=""
                            }else{
                                self.alertType = .SaveError
                            }
                            self.showAlert = true
                            self.isDisabled = false
                        }
                    }else{
                        let status = try JSONDecoder().decode(EditGroupStatus.self, from: response!)
                        DispatchQueue.main.async {
                            if(status.status == Status.success){
                                self.alertType = .SaveSuccess
                            }else{
                                self.alertType = .SaveError
                            }
                            self.showAlert = true
                            self.isDisabled = false
                        }
                    }
                }catch{
                    self.alertType = .SaveError
                    self.isDisabled = false
                    self.showAlert = true
                }
            }else{
                self.alertType = .SaveError
                self.isDisabled = false
                self.showAlert = true
            }
        }
    }
}
