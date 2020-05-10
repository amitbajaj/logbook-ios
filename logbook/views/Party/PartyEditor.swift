//
//  PartyEditor.swift
//  logbook
//
//  Created by Amit Bajaj on 5/5/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI

struct PartyEditor: View {
    @State var partyId: String = ""
    @State var partyName: String = ""
    @State var groupId: String = ""

    @State private var isDisabled = false
    @State private var isError = false
    @State private var isGroupError = false
    @State private var isPartyNameMissing = false
    @State private var isSuccess = false
    @State private var groupIndex = 0
    @State private var groupList = [PartyGroup]()

    var body: some View {
        ZStack{
            VStack{
                Form{
                    Section{
                        TextField("Party Name", text: $partyName)
                            .padding(EdgeInsets.init(top: 0, leading: 10, bottom: 0, trailing: 10))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textFieldStyle(LogBookFields())
                            .disabled(self.isDisabled)
                        Picker(selection: $groupIndex, label: Text("Group")){
                            ForEach(0 ..< groupList.count, id: \.self){gIndex in
                                Text(self.groupList[gIndex].name)
                            }
                            .disabled(self.isDisabled)
                            .padding(EdgeInsets.init(top: 0, leading: 10, bottom: 0, trailing: 10))
                        }
                        HStack{
                            Spacer()
                            Button(action:{self.saveParty()}){
                                LogBookButton(buttonText: "Save Party", buttonSystemImage: Constants.ButtonImages.Save)
                            }
                            .disabled(self.isDisabled)
                            Spacer()
                        }
                    }
                }
                Spacer()
            }
            ActivityIndicator(style: .large, animate: $isDisabled)
                .configure {$0.color = .blue}
        }
        .navigationBarTitle(partyId.isEmpty ? "Add Party" : "Edit Party")
        .onAppear{
            self.loadGroups()
        }
        .alert(isPresented: $isPartyNameMissing){
            Alert(title: Text(Constants.AppName), message: Text("Enter a party name to save"))
        }
        .alert(isPresented: $isGroupError){
            Alert(title: Text(Constants.AppName), message: Text("Unable to load group list"))
        }
        .alert(isPresented: $isError){
            Alert(title: Text(Constants.AppName), message: Text(partyId.isEmpty ? "Unable to add group" : "Unable to update group"))
        }
        .alert(isPresented: $isSuccess){
            Alert(title: Text(Constants.AppName), message: Text("Party saved successfully"))
        }
    }
    
    private func saveParty(){
        if(self.isDisabled){return}
        if(self.partyName.isEmpty){
            self.isPartyNameMissing = true
            return
        }
        self.isDisabled = true
        var params: [String: Any]
        if(self.partyId.isEmpty){
            params = ["mode": "ADD", "ptyname":self.partyName, "gid":self.groupList[self.groupIndex].gid]
        }else{
            params = ["mode": "SVEDT", "pid": self.partyId, "pname": self.partyName, "gid": self.groupList[self.groupIndex].gid ]
        }
        HTTPHelper.doHTTPPost(url: Constants.PartiesCodeURL, postData: params){data, error in
            DispatchQueue.main.async {
                self.isDisabled = false
                do{
                    if(data != nil){
                        if(self.partyId.isEmpty){
                            let response = try JSONDecoder().decode(AddPartyStatus.self, from: data!)
                            if(response.status == Status.success){
                                self.isSuccess = true
                            }else{
                                self.isError = true
                            }
                        }else{
                            let response = try JSONDecoder().decode(EditPartyStatus.self, from: data!)
                            if(response.status == Status.success){
                                self.isSuccess = true
                            }else{
                                self.isError = true
                            }
                        }
                    }else{
                        self.isError = true
                    }
                }catch{
                    self.isError = true
                }
            }
        }
    }
    
    private func loadGroups(){
        if(self.isDisabled) {return}
        if(self.groupList.count>0){return}
        self.isDisabled = true
        HTTPHelper.doHTTPPost(url: Constants.GroupsCodeURL, postData: ["mode":"QRY"]){response, error in
            DispatchQueue.main.async {
                if(response != nil){
                    do{
                        let gList = try JSONDecoder().decode(QueryGroup.self, from: response!)
                        self.groupList.removeAll()
                        self.groupList.append(PartyGroup(gid:"", name: "No group"))
                        self.groupList.append(contentsOf: gList.groupList!)
                        if (self.groupId.isEmpty){
                            self.groupIndex = 0
                        }else{
                            self.groupIndex = self.groupList.firstIndex { (partyObject) -> Bool in
                                partyObject.gid == self.groupId
                                } ?? 0
                        }
                        self.isDisabled = false
                    }catch{
                        self.isGroupError = true
                        self.isDisabled = false
                    }
                }else{
                    self.isGroupError = true
                }
            }            
        }
    }
}
