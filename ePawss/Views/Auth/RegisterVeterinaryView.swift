//
//  RegisterVeterinaryView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 25/10/25.
//

import SwiftUI

struct RegisterVeterinaryView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var clinicName = ""
    @State private var licenseNumber = ""
    @State private var specialties = ""
    @State private var businessHours = ""
    @State private var showSuccess = false
    
    var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        !clinicName.isEmpty &&
        !licenseNumber.isEmpty
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                    
                    Text("Registro de Veterinaria")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top, 20)
                
                // Formulario
                VStack(spacing: 16) {
                    // Datos personales
                    Text("Datos del Veterinario")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField(
                        placeholder: "Nombre del veterinario",
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
                    
                    // Datos de la clínica
                    Text("Datos de la Clínica")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField(
                        placeholder: "Nombre de la clínica",
                        text: $clinicName,
                        icon: "cross.case"
                    )
                    
                    CustomTextField(
                        placeholder: "Número de licencia",
                        text: $licenseNumber,
                        icon: "doc.text"
                    )
                    
                    CustomTextField(
                        placeholder: "Dirección",
                        text: $address,
                        icon: "house"
                    )
                    
                    CustomTextField(
                        placeholder: "Especialidades (ej: cirugía, pediatría)",
                        text: $specialties,
                        icon: "star"
                    )
                    
                    CustomTextField(
                        placeholder: "Horario (opcional)",
                        text: $businessHours,
                        icon: "clock"
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
                    title: "Crear Veterinaria",
                    action: {
                        Task {
                            await registerVeterinary()
                        }
                    },
                    isLoading: viewModel.isLoading,
                    isDisabled: !isFormValid,
                    backgroundColor: .purple
                )
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
            .padding(.bottom, 40)
        }
        .navigationTitle("Nueva Veterinaria")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("¡Veterinaria registrada!", isPresented: $showSuccess) {
            Button("Continuar") {
                dismiss()
            }
        } message: {
            Text("Tu clínica veterinaria ha sido registrada exitosamente.")
        }
    }
    
    private func registerVeterinary() async {
        let specialtiesArray = specialties.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        let success = await viewModel.registerVeterinary(
            email: email,
            password: password,
            name: name,
            clinicName: clinicName,
            licenseNumber: licenseNumber,
            specialties: specialtiesArray.isEmpty ? nil : specialtiesArray,
            businessHours: businessHours.isEmpty ? nil : businessHours,
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
        RegisterVeterinaryView()
    }
}

