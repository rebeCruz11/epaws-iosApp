//
//  CreateAnimalFromReportView.swift
//  ePaw
//

import SwiftUI

struct CreateAnimalFromReportView: View {
    let reporte: Report
    @Environment(\.dismiss) var dismiss
    
    @State private var nombre = ""
    @State private var especieSeleccionada: Animal.Species = .dog
    @State private var raza = ""
    @State private var generoSeleccionado: Animal.Gender = .unknown
    @State private var edadEstimada = ""
    @State private var tamanoSeleccionado: Animal.Size = .medium
    @State private var color = ""
    @State private var historia = ""
    @State private var necesidadesEspeciales = ""
    
    // Salud
    @State private var vacunado = false
    @State private var esterilizado = false
    @State private var desparasitado = false
    @State private var notasMedicas = ""
    
    // UI
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let animalService = AnimalService()
    
    var puedeGuardar: Bool {
        !nombre.isEmpty && !historia.isEmpty && nombre.count >= 2
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Información Básica
                Section("Información Básica") {
                    TextField("Nombre del animal", text: $nombre)
                    
                    Picker("Especie", selection: $especieSeleccionada) {
                        ForEach(Animal.Species.allCases, id: \.self) { especie in
                            Text("\(especie.icon) \(especie.displayName)").tag(especie)
                        }
                    }
                    
                    TextField("Raza (opcional)", text: $raza)
                    
                    Picker("Género", selection: $generoSeleccionado) {
                        Text("Macho").tag(Animal.Gender.male)
                        Text("Hembra").tag(Animal.Gender.female)
                        Text("Desconocido").tag(Animal.Gender.unknown)
                    }
                    
                    TextField("Edad estimada (ej: 2 años)", text: $edadEstimada)
                    
                    Picker("Tamaño", selection: $tamanoSeleccionado) {
                        Text("Pequeño").tag(Animal.Size.small)
                        Text("Mediano").tag(Animal.Size.medium)
                        Text("Grande").tag(Animal.Size.large)
                    }
                    
                    TextField("Color (opcional)", text: $color)
                }
                
                // Historia
                Section("Historia") {
                    TextEditor(text: $historia)
                        .frame(height: 100)
                        .overlay(alignment: .topLeading) {
                            if historia.isEmpty {
                                Text("Cuenta la historia de cómo fue rescatado...")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                }
                
                // Necesidades Especiales
                Section("Necesidades Especiales (opcional)") {
                    TextField("Ej: Requiere ejercicio diario", text: $necesidadesEspeciales)
                }
                
                // Información de Salud
                Section("Información de Salud") {
                    Toggle("Vacunado", isOn: $vacunado)
                    Toggle("Esterilizado", isOn: $esterilizado)
                    Toggle("Desparasitado", isOn: $desparasitado)
                    
                    TextField("Notas médicas (opcional)", text: $notasMedicas, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Info del Reporte
                Section("Reporte Asociado") {
                    HStack {
                        Text("Reporte:")
                        Spacer()
                        Text("#\(String(reporte.id.prefix(6)))")
                            .foregroundColor(.gray)
                    }
                    
                    if let direccion = reporte.locationAddress {
                        HStack {
                            Text("Ubicación:")
                            Spacer()
                            Text(direccion)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.trailing)
                                .lineLimit(2)
                        }
                    }
                }
                
                // Botón Guardar
                Section {
                    Button {
                        Task {
                            await crearAnimal()
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Crear Perfil del Animal")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .bold()
                        }
                    }
                    .listRowBackground(puedeGuardar ? Color.green : Color.gray)
                    .disabled(!puedeGuardar || isLoading)
                }
            }
            .navigationTitle("Crear Perfil de Animal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .alert("¡Perfil Creado!", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("El perfil de \(nombre) ha sido creado exitosamente y está listo para adopción.")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                // Pre-llenar con info del reporte
                historia = reporte.description
                especieSeleccionada = mapAnimalType(reporte.animalType)
            }
        }
    }
    
    private func crearAnimal() async {
        isLoading = true
        
        do {
            let request = CrearAnimalRequest(
                name: nombre,
                species: especieSeleccionada.rawValue,
                breed: raza.isEmpty ? nil : raza,
                gender: generoSeleccionado.rawValue,
                ageEstimate: edadEstimada.isEmpty ? nil : edadEstimada,
                size: tamanoSeleccionado.rawValue,
                color: color.isEmpty ? nil : color,
                story: historia,
                personalityTraits: nil,
                specialNeeds: necesidadesEspeciales.isEmpty ? nil : necesidadesEspeciales,
                photoUrls: reporte.photoUrls,
                videoUrl: nil,
                healthInfo: CrearAnimalRequest.HealthInfoRequest(
                    isVaccinated: vacunado,
                    isSterilized: esterilizado,
                    isDewormed: desparasitado,
                    medicalNotes: notasMedicas.isEmpty ? nil : notasMedicas
                ),
                reportId: reporte.id
            )
            
            _ = try await animalService.crearAnimal(request: request)
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    private func mapAnimalType(_ type: AnimalType) -> Animal.Species {
        switch type {
        case .dog: return .dog
        case .cat: return .cat
        case .bird: return .bird
        case .rabbit: return .rabbit
        case .other: return .other
        }
    }
}
