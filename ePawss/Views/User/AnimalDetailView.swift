//
//  AnimalDetailView.swift
//  ePaw
//

import SwiftUI

struct AnimalDetailView: View {
    let animal: Animal
    @Binding var userActiveAdoptions: [Adoption]
    var onAdoptionSubmitted: (() async -> Void)? = nil

    @State private var showAdoptionForm = false
    @State private var showMedicalRecord = false
    @State private var showAlreadyAppliedAlert = false
    
    private let imageStorage = ImageStorageService.shared  // ✅ AGREGADO

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(animal.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                
                // Card principal
                VStack(spacing: 0) {
                    // ✅ Imágenes locales con TabView
                    if !animal.photoUrls.isEmpty {
                        TabView {
                            ForEach(animal.photoUrls, id: \.self) { photoFilename in
                                if let image = imageStorage.loadImage(filename: photoFilename) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 280)
                                        .clipped()
                                } else {
                                    // Placeholder si no se puede cargar
                                    ZStack {
                                        Color.gray.opacity(0.25)
                                        VStack(spacing: 8) {
                                            Text(animal.species.icon)
                                                .font(.system(size: 60))
                                            Text("Imagen no disponible")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .frame(height: 280)
                                }
                            }
                        }
                        .frame(height: 280)
                        .tabViewStyle(.page)
                    } else {
                        // Placeholder si no hay fotos
                        ZStack {
                            Color.gray.opacity(0.25)
                            VStack(spacing: 8) {
                                Text(animal.species.icon)
                                    .font(.system(size: 60))
                                Text("Sin fotos")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(height: 280)
                    }
                    
                    // Contenido
                    VStack(alignment: .leading, spacing: 12) {
                        // Edad
                        HStack(spacing: 6) {
                            Text(animal.ageEstimate ?? "Edad desconocida")
                                .font(.subheadline)
                            Text("📍")
                        }
                        .foregroundColor(.secondary)
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        // Descripción
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Conoce a \(animal.name):")
                                .font(.system(size: 15, weight: .semibold))
                            
                            Text(animal.story ?? "Un adorable compañero buscando un hogar lleno de amor.")
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // Botones
                        VStack(spacing: 10) {
                            if hasActiveAdoption {
                                adoptionBanner
                            } else {
                                Button {
                                    if hasActiveAdoption {
                                        showAlreadyAppliedAlert = true
                                    } else {
                                        showAdoptionForm = true
                                    }
                                } label: {
                                    Text("¡QUIERO ADOPTAR!")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color(red: 0.3, green: 0.35, blue: 0.45))
                                        .cornerRadius(10)
                                }
                            }
                            
                            Button {
                                showMedicalRecord = true
                            } label: {
                                Text("VER EXPEDIENTE")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(red: 0.3, green: 0.35, blue: 0.45))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.gray.opacity(0.15))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color(UIColor.systemGray6))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAdoptionForm) {
            AdoptionFormView(animal: animal) {
                Task {
                    await onAdoptionSubmitted?()
                }
            }
        }
        .sheet(isPresented: $showMedicalRecord) {
            NavigationStack {
                AnimalMedicalRecordView(animal: animal)
                    .navigationTitle("Expediente")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Cerrar") {
                                showMedicalRecord = false
                            }
                        }
                    }
            }
        }
        .alert("Solicitud Activa", isPresented: $showAlreadyAppliedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Ya tienes una solicitud activa para \(animal.name). Revisa el estado en la sección de Adopciones.")
        }
    }

    private var hasActiveAdoption: Bool {
        userActiveAdoptions.contains {
            ($0.animalId == animal.id || $0.animalDetails?.id == animal.id)
            && [.pending, .underReview, .approved].contains($0.status)
        }
    }

    private var adoptionBanner: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            VStack(spacing: 4) {
                Text("Ya enviaste una solicitud")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.orange)
                
                Text("para este animal")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
            }
            
            if let adoption = userActiveAdoptions
                .first(where: { ($0.animalId == animal.id || $0.animalDetails?.id == animal.id)
                    && [.pending, .underReview, .approved].contains($0.status) }) {
                Text("Estado: \(adoption.status.displayName)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Vista de Expediente Médico
struct AnimalMedicalRecordView: View {
    let animal: Animal
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Expediente Médico")
                        .font(.title2)
                        .bold()
                    
                    Text("de \(animal.name)")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                
                // Información de salud
                if let healthInfo = animal.healthInfo {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Estado de Salud")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            HealthStatusRow(
                                icon: "syringe.fill",
                                title: "Vacunado",
                                status: healthInfo.isVaccinated
                            )
                            
                            HealthStatusRow(
                                icon: "scissors",
                                title: "Esterilizado",
                                status: healthInfo.isSterilized
                            )
                            
                            HealthStatusRow(
                                icon: "pills.fill",
                                title: "Desparasitado",
                                status: healthInfo.isDewormed
                            )
                        }
                        .padding(.horizontal)
                        
                        if let notes = healthInfo.medicalNotes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notas Médicas")
                                    .font(.headline)
                                
                                Text(notes)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                } else {
                    Text("No hay información médica disponible")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Health Status Row
struct HealthStatusRow: View {
    let icon: String
    let title: String
    let status: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(status ? .green : .gray)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Image(systemName: status ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(status ? .green : .red)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
