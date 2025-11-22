//
//  VeterinaryHomeView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//

import SwiftUI

struct VeterinaryHomeView: View {
    let user: User
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        Text("Bienvenido, \(user.name) - Veterinaria")
        // Aquí puedes construir la UI específica para organizaciones
    }
}
     
