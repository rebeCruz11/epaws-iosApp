//
//  HomeView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 31/10/25.
//

import SwiftUI

struct HomeView: View {
    let user: User
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            switch user.role {
               case .user:
                   UserHomeView(user: user)
               default:
                   Text("Rol no soportado")
            }
        }
        .environmentObject(viewModel)
    }
}

