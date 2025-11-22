//
//  EditProfileView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 14/11/25.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var address: String = ""
    
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información Personal") {
                    TextField("Nombre", text: $name)
                        .textContentType(.name)
                    
                    TextField("Teléfono", text: $phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                    
                    TextField("Dirección", text: $address)
                        .textContentType(.fullStreetAddress)
                }
                
                Section {
                    Button {
                        Task {
                            await saveProfile()
                        }
                    } label: {
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Spacer()
                            }
                        } else {
                            Text("Guardar Cambios")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(Color.blue)
                    .disabled(isLoading)
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCurrentData()
            }
            .alert("Perfil Actualizado", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Tu perfil se actualizó correctamente")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func loadCurrentData() {
        if let user = authViewModel.currentUser {
            name = user.name
            phone = user.phone ?? ""
            address = user.address ?? ""
        }
    }
    
    private func saveProfile() async {
        isLoading = true
        
        do {
            let updatedUser = try await AuthService().updateProfile(
                name: name.isEmpty ? nil : name,
                phone: phone.isEmpty ? nil : phone,
                address: address.isEmpty ? nil : address
            )
            
            authViewModel.currentUser = updatedUser
            isLoading = false
            showSuccess = true
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            showError = true
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthViewModel())
}
