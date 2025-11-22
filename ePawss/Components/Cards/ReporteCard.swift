//
//  ReporteCard.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//

import SwiftUI

struct ReporteCard: View {
    var reporte: ReporteResumen

    var urgenciaColor: Color {
        switch reporte.urgencyLevel {
        case "high": return .red
        case "medium": return .yellow
        case "low": return .green
        default: return .gray
        }
    }

    var body: some View {
        HStack {
            Image(systemName: "photo").frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(reporte.description).font(.headline)
                Text(reporte.animalType).font(.caption)
                Text(reporte.createdAt).font(.caption2)
            }
            Spacer()
            Text(reporte.urgencyLevel.capitalized)
                .font(.caption)
                .padding(6)
                .background(urgenciaColor.opacity(0.2))
                .cornerRadius(7)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}
