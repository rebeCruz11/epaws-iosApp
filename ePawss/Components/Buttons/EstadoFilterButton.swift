//
//  EstadoFilterButton.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//

import SwiftUI

struct EstadoFilterButton: View {
    let title: String
    let selected: Bool

    var body: some View {
        Text(title)
            .padding(.horizontal, 18)
            .padding(.vertical, 7)
            .background(selected ? Color(.systemGray4) : Color(.systemGray6))
            .cornerRadius(14)
    }
}
