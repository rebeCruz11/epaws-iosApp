//
//  OrganizationComponents.swift
//  ePaw
//
//  Created by ESTUDIANTE on 15/11/25.
//

import SwiftUI

// MARK: - Organization Dashboard Card
struct OrgDashboardCard: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(value)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Organization Action Button
struct OrgActionButton: View {
    let icon: String
    let text: String
    var color: Color = Color(red: 0.2, green: 0.3, blue: 0.5)
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(14)
    }
}

// MARK: - Organization Urgency Badge
struct OrgUrgencyBadge: View {
    let urgency: String
    
    var body: some View {
        let color: Color = urgency == "high" ? .red : (urgency == "medium" ? .orange : .gray)
        let text = urgency == "high" ? "Urgente" : urgency == "medium" ? "Media" : "Baja"
        
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(6)
    }
}

// MARK: - Organization Status Badge
struct OrgStatusBadge: View {
    let status: String
    
    var statusInfo: (text: String, color: Color) {
        switch status {
        case "pending": return ("Pendiente", .orange)
        case "assigned": return ("Asignado", .blue)
        case "rescued": return ("Rescatado", .green)
        case "in_veterinary": return ("En tratamiento", .purple)
        case "ready_for_adoption": return ("Listo", .teal)
        default: return (status.capitalized, .gray)
        }
    }
    
    var body: some View {
        let info = statusInfo
        Text(info.text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(info.color)
            .cornerRadius(6)
    }
}

// MARK: - Organization Reporte Card (Para Home - con RecentReport)
struct OrgReporteCard: View {
    
    var body: some View {
        HStack(spacing: 12) {
            // Imagen del reporte
            if let photoUrl = reporte.photoUrls?.first, let url = URL(string: photoUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Reporte #\(String(reporte.id.prefix(4)))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                    
                    Spacer()
                    
                    OrgUrgencyBadge(urgency: reporte.urgencyLevel)
                }
                
                Text(reporte.description)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Text(reporte.locationAddress)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Organization Report List Card (Para lista completa - con OrganizationReport)
struct OrgReportListCard: View {
    let reporte: OrganizationReport
    
    var body: some View {
        HStack(spacing: 14) {
            // Imagen
            if let photoUrl = reporte.photoUrls.first, let url = URL(string: photoUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Reporte #\(String(reporte.id.prefix(6)))")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    OrgStatusBadge(status: reporte.status)
                }
                
                Text(reporte.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 11))
                        Text(reporte.locationAddress)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.gray)
                    
                    OrgUrgencyBadge(urgency: reporte.urgencyLevel)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Organization Solicitud Card
struct OrgSolicitudCard: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.orange.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "pawprint.fill")
                        .foregroundColor(.orange)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(animal.name)
                    .font(.system(size: 14, weight: .semibold))
                Text(animal.species.capitalized)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Organization Estado Filter Button
struct OrgEstadoFilterButton: View {
    let title: String
    let selected: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: selected ? .semibold : .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(selected ? Color.orange : Color.white)
            .foregroundColor(selected ? .white : .gray)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(selected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}
