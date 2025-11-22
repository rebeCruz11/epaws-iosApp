//
//  AnimalCardView.swift
//  ePaw
//

import SwiftUI

struct AnimalCardView: View {
    let animal: Animal
    let onAdopted: () -> Void
    private let imageStorage = ImageStorageService.shared  // ✅ AGREGADO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ✅ Imagen local
            if let primeraFoto = animal.photoUrls.first,
               let image = imageStorage.loadImage(filename: primeraFoto) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 140)
                    .clipped()
                    .cornerRadius(12, corners: [.topLeft, .topRight])
            } else {
                // Placeholder si no hay imagen
                ZStack {
                    Color.gray.opacity(0.2)
                    VStack(spacing: 8) {
                        Text(animal.species.icon)
                            .font(.system(size: 40))
                        Text("Sin foto")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: 140)
                .cornerRadius(12, corners: [.topLeft, .topRight])
            }
            
            // Contenido
            VStack(alignment: .leading, spacing: 6) {
                Text(animal.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text(animal.species.icon)
                        .font(.system(size: 14))
                    Text(animal.species.displayName)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                if let edad = animal.ageEstimate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        Text(edad)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                // Badge de estado
                HStack {
                    Spacer()
                    Text(animal.status.displayName)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor(animal.status))
                        .cornerRadius(6)
                }
            }
            .padding(12)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
    
    private func statusColor(_ status: Animal.Status) -> Color {
        switch status {
        case .available: return .green
        case .pendingAdoption: return .orange
        case .adopted: return .blue
        case .deceased: return .gray
        }
    }
}

// MARK: - Helper para redondear esquinas específicas
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
