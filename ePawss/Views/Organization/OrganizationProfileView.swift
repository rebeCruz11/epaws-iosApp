//
//  OrganizationProfileView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 8/11/25.
//

import SwiftUI

struct OrganizationProfileView: View {
    let user: User
    @State private var showLogin = false

    var body: some View {
        VStack(spacing: 24) {
            if let logoUrl = user.organizationDetails?.logoUrl, let url = URL(string: logoUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Circle().fill(Color(.systemGray5))
                }
                .frame(width: 96, height: 96)
                .clipShape(Circle())
            }
            Text(user.organizationDetails?.organizationName ?? user.name)
                .font(.title)
                .bold()
            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.gray)

            if let desc = user.organizationDetails?.description {
                Text(desc)
                    .font(.body)
                    .padding(.top, 10)
            }

            Spacer()

            Button(action: {
                // Limpia token, datos de usuario o session aquí
                showLogin = true
            }) {
                Text("Cerrar sesión")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.bottom, 30)
            .sheet(isPresented: $showLogin) {
                LoginView() // Tu vista de login
            }
        }
        .padding()
    }
}
