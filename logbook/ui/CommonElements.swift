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
