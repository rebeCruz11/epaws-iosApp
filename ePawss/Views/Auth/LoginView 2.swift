//
//  LoginView 2.swift
//  ePaw
//
//  Created by ESTUDIANTE on 14/11/25.
//


import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Logo
            VStack(spacing: 8) {
                Image("Icono")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .aspectRatio(contentMode: .fit)

                Text("ePaw")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
            }

            // Formulario
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)

                SecureField("Contraseña", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)

            // Botón Login
            Button {
                Task {
                    await viewModel.login(email: email, password: password)
                }
            } label: {
                ZStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Iniciar Sesión")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    email.isEmpty || password.isEmpty || viewModel.isLoading
                    ? Color.gray
                    : Color.blue
                )
                .cornerRadius(12)
            }
            .disabled(email.isEmpty || password.isEmpty || viewModel.isLoading)
            .padding(.horizontal, 24)

            Spacer()

            NavigationLink("¿No tienes cuenta? Regístrate") {
                RegisterView()
            }
            .font(.subheadline)
            .foregroundColor(.blue)
            .padding(.top, 16)
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "Error desconocido")
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
