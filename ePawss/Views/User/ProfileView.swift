//
//  Profile.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//

import SwiftUI

struct ProileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Tu contenido del perfil
                if let currentUser = viewModel.currentUser {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.blue)
                        .padding(.top, 50)

                    Text(currentUser.name)
                        .font(.title)
                        .bold()

                    Text(currentUser.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Spacer()

                    Button(action: {
                        viewModel.logout()
                        
                    }) {
                        Text("Cerrar sesión")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                    }
                } else {
                    Text("No hay usuario activo")
                        .foregroundColor(.gray)
                }

                Spacer()

                // Solo usar la barra de menú ya declarada
                MainMenuBar(selectedTab: $selectedTab)
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
}
