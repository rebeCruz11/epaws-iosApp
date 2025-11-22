//
//  DashboardMiniCard.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//

import SwiftUI

struct DashboardMiniCard: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.headline)
            .foregroundColor(color)
            .frame(width: 145, height: 45)
            .background(Color(.systemGray6))
            .cornerRadius(11)
    }
}
