//
//  MyReportsView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//

import SwiftUI

struct MyReportsView: View {
    let user: User
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        Text("Bienvenido, \(user.name) - Usuario")
    }
}
