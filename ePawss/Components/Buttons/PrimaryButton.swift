//
//  PrimaryButton.swift
//  ePaw
//
//  Created by ESTUDIANTE on 25/10/25.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var backgroundColor: Color = .blue
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isDisabled ? Color.gray : backgroundColor)
            .cornerRadius(12)
        }
        .disabled(isDisabled || isLoading)
    }
}

