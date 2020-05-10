//
//  MutiSelectPicker.swift
//  logbook
//
//  Created by Amit Bajaj on 5/7/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import SwiftUI

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark").foregroundColor(.blue)
                }
            }
        }.foregroundColor(Color.black)
    }
}

struct PartyPickerView: View {
    @State private var selections = [Party]()
    @Binding var allParties : [Party]
    @Binding var partyList : PartyList

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Choose parties")) {
                    ForEach(allParties) { item in
                        MultipleSelectionRow(title: item.pname, isSelected: self.selections.contains(item)) {
                            if self.selections.contains(item) {
                                self.selections.removeAll(where: { $0 == item })
                            }
                            else {
                                self.selections.append(item)
                            }
                        }
                    }

                }
            }
            .onAppear(perform: { self.selections = self.partyList.partyList })
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Parties", displayMode: .inline)
            .navigationBarItems(
                leading:
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                },
                trailing:
                Button(action: {
                    self.partyList.partyList = self.selections
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("OK")
                }
            )
        }
    }
}
