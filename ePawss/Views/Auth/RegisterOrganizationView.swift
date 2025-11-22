//
//  RegisterOrganizationView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 25/10/25.
//

import SwiftUI

struct RegisterOrganizationView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var organizationName = ""
    @State private var description = ""
    @State private var website = ""
    @State private var capacity = ""
    @State private var showSuccess = false
    
    var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        !organizationName.isEmpty
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Registro de Organización")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top, 20)
                
                // Formulario
                VStack(spacing: 16) {
                    // Datos personales
                    Text("Datos del Representante")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField(
                        placeholder: "Nombre del representante",
                        text: $name,
                        icon: "person"
                    )
                    
                    CustomTextField(
                        placeholder: "Email",
                        text: $email,
                        icon: "envelope",
                        keyboardType: .emailAddress
                    )
                    
                    CustomTextField(
                        placeholder: "Teléfono",
                        text: $phone,
                        icon: "phone",
                        keyboardType: .phonePad
                    )
                    
                    CustomTextField(
                        placeholder: "Contraseña",
                        text: $password,
                        icon: "lock",
                        isSecure: true
                    )
                    
                    CustomTextField(
                        placeholder: "Confirmar contraseña",
                        text: $confirmPassword,
                        icon: "lock",
                        isSecure: true
                    )
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Datos de la organización
                    Text("Datos de la Organización")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField(
                        placeholder: "Nombre de la organización",
                        text: $organizationName,
                        icon: "building.2"
                    )
                    
                    CustomTextField(
                        placeholder: "Dirección",
                        text: $address,
                        icon: "house"
                    )
                    
                    CustomTextField(
                        placeholder: "Descripción (opcional)",
                        text: $description,
                        icon: "text.alignleft"
                    )
                    
                    CustomTextField(
                        placeholder: "Sitio web (opcional)",
                        text: $website,
                        icon: "globe",
                        keyboardType: .URL
                    )
                    
                    CustomTextField(
                        placeholder: "Capacidad de animales (opcional)",
                        text: $capacity,
                        icon: "number",
                        keyboardType: .numberPad
                    )
                    
                    if !password.isEmpty && password != confirmPassword {
                        Text("Las contraseñas no coinciden")
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 24)
                
                // Botón registrar
                PrimaryButton(
                    title: "Crear Organización",
                    action: {
                        Task {
                            await registerOrganization()
                        }
                    },
                    isLoading: viewModel.isLoading,
                    isDisabled: !isFormValid,
                    backgroundColor: .green
                )
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
            .padding(.bottom, 40)
        }
        .navigationTitle("Nueva Organización")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("¡Organización registrada!", isPresented: $showSuccess) {
            Button("Continuar") {
                dismiss()
            }
        } message: {
            Text("Tu organización ha sido registrada exitosamente.")
        }
    }
    
    private func registerOrganization() async {
        let success = await viewModel.registerOrganization(
            email: email,
            password: password,
            name: name,
            organizationName: organizationName,
            description: description.isEmpty ? nil : description,
            website: website.isEmpty ? nil : website,
            capacity: Int(capacity),
            phone: phone.isEmpty ? nil : phone,
            address: address.isEmpty ? nil : address
        )
        
        if success {
            showSuccess = true
        }
    }
}

#Preview {
    NavigationView {
        RegisterOrganizationView()
    }
}

