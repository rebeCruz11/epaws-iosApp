//
//  ButtonAction.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//

import SwiftUI

struct ActionButton: View {
    var icon: String
    var text: String
    var color: Color = Color.orange

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
            Text(text)
                .font(.headline)
                .foregroundColor(Color(red: 45/255, green: 66/255, blue: 84/255))
        }
        .frame(width: 156, height: 70)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

