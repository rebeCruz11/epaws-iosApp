//
//  RegisterUserView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 25/10/25.
//

import SwiftUI

struct RegisterUserView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var showSuccess = false
    
    var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Registro de Usuario")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top, 20)
                
                // Formulario
                VStack(spacing: 16) {
                    CustomTextField(
                        placeholder: "Nombre completo",
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
                        placeholder: "Teléfono (opcional)",
                        text: $phone,
                        icon: "phone",
                        keyboardType: .phonePad
                    )
                    
                    CustomTextField(
                        placeholder: "Dirección (opcional)",
                        text: $address,
                        icon: "house"
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
                    
                    if !password.isEmpty && password != confirmPassword {
                        Text("Las contraseñas no coinciden")
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if !password.isEmpty && password.count < 6 {
                        Text("La contraseña debe tener al menos 6 caracteres")
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 24)
                
                // Botón registrar
                PrimaryButton(
                    title: "Crear Cuenta",
                    action: {
                        Task {
                            await registerUser()
                        }
                    },
                    isLoading: viewModel.isLoading,
                    isDisabled: !isFormValid,
                    backgroundColor: .blue
                )
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
            .padding(.bottom, 40)
        }
        .navigationTitle("Nuevo Usuario")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("¡Cuenta creada!", isPresented: $showSuccess) {
            Button("Continuar") {
                dismiss()
            }
        } message: {
            Text("Tu cuenta ha sido creada exitosamente. Ya puedes iniciar sesión.")
        }
    }
    
    private func registerUser() async {
        let success = await viewModel.registerUser(
            email: email,
            password: password,
            name: name,
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
        RegisterUserView()
    }
}

