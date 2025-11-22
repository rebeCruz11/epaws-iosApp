//
//  ChangePasswordView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 14/11/25.
//

import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Contraseña Actual") {
                    SecureField("Contraseña actual", text: $currentPassword)
                        .textContentType(.password)
                }
                
                Section("Nueva Contraseña") {
                    SecureField("Nueva contraseña", text: $newPassword)
                        .textContentType(.newPassword)
                    
                    SecureField("Confirmar contraseña", text: $confirmPassword)
                        .textContentType(.newPassword)
                }
                
                if !newPassword.isEmpty && newPassword != confirmPassword {
                    Section {
                        Text("Las contraseñas no coinciden")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button {
                        Task {
                            await changePassword()
                        }
                    } label: {
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Cambiar Contraseña")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(Color.blue)
                    .disabled(isLoading || !isValid)
                }
            }
            .navigationTitle("Cambiar Contraseña")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .alert("Contraseña Actualizada", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Tu contraseña se cambió correctamente")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isValid: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        newPassword == confirmPassword &&
        newPassword.count >= 6
    }
    
    private func changePassword() async {
        isLoading = true
        
        let success = await authViewModel.changePassword(
            current: currentPassword,
            new: newPassword
        )
        
        isLoading = false
        
        if success {
            showSuccess = true
        } else {
            errorMessage = authViewModel.errorMessage ?? "Error al cambiar contraseña"
            showError = true
        }
    }
}

#Preview {
    ChangePasswordView()
        .environmentObject(AuthViewModel())
}
