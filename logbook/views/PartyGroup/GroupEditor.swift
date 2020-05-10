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
    @State var groupId: String = "-1"
    @State var groupName: String = ""
    @State private var isDisabled: Bool = false
    @State private var isError: Bool = false
    @State private var isSuccess: Bool = false
    
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
        .alert(isPresented: self.$isError){
            Alert(title: Text(self.groupId == "-1" ? "Add Group": "Edit Group"), message: Text("Unable to save group"), dismissButton: .default(Text("Ok")))
        }
        .alert(isPresented: self.$isSuccess){
            Alert(title: Text(self.groupId == "-1" ? "Add Group": "Edit Group"), message: Text("Group saved!"), dismissButton: .default(Text("Ok")))
        }
    }
    
    private func saveGroup(){
        var params: [String: Any]
        if(self.groupName.isEmpty){
            self.isError = true
            return
        }
        self.isDisabled = true
        self.isError = false
        self.isSuccess = false
        if (self.groupId == "-1"){
            params = ["mode":"ADD","grpname": self.groupName]
        }else{
            params = ["mode":"SVEDT","gname":self.groupName, "gid":self.groupId]
        }
        HTTPHelper.doHTTPPost(url: Constants.GroupsCodeURL, postData: params){ response, error in
            if(response != nil){
                do{
                    if(self.groupId == "-1"){
                        let status = try JSONDecoder().decode(AddGroupStatus.self, from: response!)
                        DispatchQueue.main.async {
                            if(status.status == Status.success){
                                self.isSuccess = true
                                self.groupName=""
                            }else{
                                self.isError = true
                            }
                            self.isDisabled = false
                        }
                    }else{
                        let status = try JSONDecoder().decode(EditGroupStatus.self, from: response!)
                        DispatchQueue.main.async {
                            if(status.status == Status.success){
                                self.isSuccess = true
                            }else{
                                self.isError = true
                            }
                            self.isDisabled = false
                        }
                    }
                }catch{
                    self.isDisabled = false
                    self.isError = true
                }
            }else{
                self.isDisabled = false
                self.isError = true
            }
        }
    }
}
