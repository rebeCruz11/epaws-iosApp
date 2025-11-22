//
//  SolicitudCard.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//

import SwiftUI

struct SolicitudCard: View {
    var animal: AnimalResumen

    var body: some View {
        HStack {
            if let urlString = animal.photoUrls?.first, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            }
            VStack(alignment: .leading) {
                Text(animal.name).font(.subheadline)
                Text(animal.species).font(.caption)
                Text(animal.createdAt).font(.caption2)
            }
            Spacer()
            Text(animal.status.capitalized)
                .font(.caption)
                .padding(6)
                .background(Color.orange.opacity(0.15))
                .cornerRadius(8)
        }
        .padding(7)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
