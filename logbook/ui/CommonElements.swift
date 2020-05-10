//
//  CommonElements.swift
//  logbook
//
//  Created by Amit Bajaj on 5/2/20.
//  Copyright © 2020 Bajaj Tech. All rights reserved.
//

import Foundation
import SwiftUI

struct ActivityIndicator: UIViewRepresentable {

    let style: UIActivityIndicatorView.Style
    @Binding var animate: Bool

    private let spinner: UIActivityIndicatorView = {
        $0.hidesWhenStopped = true
        return $0
    }(UIActivityIndicatorView(style: .medium))

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        spinner.style = style
        return spinner
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        animate ? uiView.startAnimating() : uiView.stopAnimating()
    }

    func configure(_ indicator: (UIActivityIndicatorView) -> Void) -> some View {
        indicator(spinner)
        return self
    }
}

struct LogBookButton: View{
    var buttonText: String
    var buttonSystemImage: String
    
    var body: some View{
        HStack {
            Text(buttonText)
//                .fontWeight(.semibold)
//                .font(.title)
//            Image(systemName: buttonSystemImage)
//                .font(.title)
        }
        .padding()
//        .foregroundColor(.white)
//        .background(Color.green)
//        .cornerRadius(40)
    }
}


struct LogBookDatePicker: View{
    @Binding var selectedDate: Date
    @State var label: String = ""
    @State var minDate: Date
    @State var maxDate: Date
    @State private var currentDate = Date()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View{
        NavigationView{
            VStack{
                DatePicker(selection: self.$currentDate, in: self.minDate...self.maxDate, displayedComponents: .date){
                    Text(self.label)
                }
                .labelsHidden()
                Button(action: {self.currentDate = Date()}){
                    Text("Today")
                }
                Spacer()
            }
            .navigationBarTitle("Select date", displayMode: .inline)
            .navigationBarItems(
                leading:
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                },
                trailing:
                Button(action: {
                    self.selectedDate = self.currentDate
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("OK")
                }
            )
        }
        .onAppear{
            self.currentDate = self.selectedDate
        }
    }
}

struct LogBookListPicker: View{
    @Binding var selectedItem: Int
    @State var label: String
    @State var listOfValues: [String]
    @State private var currentItem = 0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View{
        NavigationView{
            VStack{
                Picker(selection: $currentItem, label: Text(label)){
                    ForEach(0 ..< self.listOfValues.count){pIndex in
                        Text(self.listOfValues[pIndex])
                    }
                }
                .labelsHidden()
                Spacer()
            }
            .navigationBarTitle("\(label)", displayMode: .inline)
            .navigationBarItems(
                leading:
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                },
                trailing:
                Button(action: {
                    self.selectedItem = self.currentItem
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("OK")
                }
            )
        }
        .onAppear{
            self.currentItem = self.selectedItem
        }
    }
}
