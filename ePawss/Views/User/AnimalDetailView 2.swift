//
//  AnimalDetailView 2.swift
//  ePaw
//
//  Created by ESTUDIANTE on 14/11/25.
//


//
//  AnimalDetailView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//

import SwiftUI

struct AnimalDetailView: View {
    let animal: Animal
    @State private var showAdoptionForm = false  // ✅ Cambio aquí
    @State private var showMedicalRecord = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Nombre arriba
                Text(animal.name)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.blue)
                    .padding(.top, 16)
                    .padding(.horizontal)

                // Imagen
                AsyncImage(url: URL(string: animal.photoUrls.first ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.25)
                }
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(18)
                .padding(.horizontal)

                // Datos
                HStack {
                    Text(animal.species.rawValue.capitalized)
                    Text("•")
                    Text(animal.ageEstimate ?? "")
                }
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)

                Text(animal.story ?? "Sin historia")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                
                // Botones
                HStack(spacing: 16) {
                    Button {
                        showAdoptionForm = true  // ✅ Abre el formulario
                    } label: {
                        Text("Quiero Adoptar")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button {
                        showMedicalRecord = true
                    } label: {
                        Text("Ver Expediente")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .sheet(isPresented: $showAdoptionForm) {  // ✅ Muestra el formulario
            AdoptionFormView(animal: animal)
        }
        .sheet(isPresented: $showMedicalRecord) {
            Text("Expediente médico de \(animal.name)")
                .font(.title)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
