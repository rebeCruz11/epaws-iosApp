//
//  RegisterView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 25/10/25.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedRole: UserRole? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("🐾")
                            .font(.system(size: 60))
                        
                        Text("Únete a ePaw")
                            .font(.system(size: 32, weight: .bold))
                        
                        Text("Selecciona tu tipo de cuenta")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    
                    // Opciones de rol
                    VStack(spacing: 16) {
                        RoleCard(
                            icon: "person.fill",
                            title: "Usuario",
                            description: "Adopta una mascota o reporta casos",
                            color: .blue,
                            isSelected: selectedRole == .user
                        ) {
                            selectedRole = .user
                        }
                        
                        RoleCard(
                            icon: "building.2.fill",
                            title: "Organización",
                            description: "Administra refugios y rescates",
                            color: .green,
                            isSelected: selectedRole == .organization
                        ) {
                            selectedRole = .organization
                        }
                        
                        RoleCard(
                            icon: "cross.case.fill",
                            title: "Veterinaria",
                            description: "Ofrece servicios veterinarios",
                            color: .purple,
                            isSelected: selectedRole == .veterinary
                        ) {
                            selectedRole = .veterinary
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Botón continuar
                    if let role = selectedRole {
                        NavigationLink(destination: destinationView(for: role)) {
                            Text("Continuar")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for role: UserRole) -> some View {
        switch role {
        case .user:
            RegisterUserView()
        case .organization:
            RegisterOrganizationView()
        case .veterinary:
            RegisterVeterinaryView()
        }
    }
}

// Card para seleccionar rol
struct RoleCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .white : color)
                    .frame(width: 60, height: 60)
                    .background(isSelected ? color : color.opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(color)
                        .font(.title2)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RegisterView()
}

