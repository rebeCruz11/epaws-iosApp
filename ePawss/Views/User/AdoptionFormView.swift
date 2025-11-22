//
//  AdoptionFormView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 14/11/25.
//

import SwiftUI

struct AdoptionFormView: View {
    let animal: Animal
    var onSuccess: (() -> Void)? = nil
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AdoptionFormViewModel()
    
    @State private var applicationMessage = ""
    @State private var hasExperience = false
    @State private var experienceDetails = ""
    @State private var hasOtherPets = false
    @State private var otherPetsDetails = ""
    @State private var selectedHomeType: AdoptionHomeType = .house
    @State private var hasYard = false
    @State private var householdMembers = "1"
    @State private var householdDetails = ""
    @State private var workSchedule = ""
    @State private var reasonForAdoption = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: animal.photoUrls.first ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        VStack(alignment: .leading) {
                            Text(animal.name)
                                .font(.headline)
                            Text(animal.species.displayName)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("Mensaje de Solicitud") {
                    TextEditor(text: $applicationMessage)
                        .frame(height: 120)
                    Text("\(applicationMessage.count)/2000 caracteres (mínimo 50)")
                        .font(.caption)
                        .foregroundColor(applicationMessage.count < 50 ? .red : .gray)
                }
                
                Section("Experiencia con Mascotas") {
                    Toggle("¿Tienes experiencia con mascotas?", isOn: $hasExperience)
                    
                    if hasExperience {
                        TextField("Describe tu experiencia", text: $experienceDetails, axis: .vertical)
                            .lineLimit(3...5)
                    }
                }
                
                Section("Otras Mascotas") {
                    Toggle("¿Tienes otras mascotas?", isOn: $hasOtherPets)
                    
                    if hasOtherPets {
                        TextField("Describe tus otras mascotas", text: $otherPetsDetails, axis: .vertical)
                            .lineLimit(3...5)
                    }
                }
                
                Section("Información del Hogar") {
                    Picker("Tipo de hogar", selection: $selectedHomeType) {
                        ForEach(AdoptionHomeType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    
                    Toggle("¿Tienes patio?", isOn: $hasYard)
                    
                    Stepper("Miembros del hogar: \(householdMembers)", value: Binding(
                        get: { Int(householdMembers) ?? 1 },
                        set: { householdMembers = "\($0)" }
                    ), in: 1...20)
                    
                    TextField("Detalles del hogar", text: $householdDetails, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Horario Laboral") {
                    TextField("Describe tu horario de trabajo", text: $workSchedule, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("¿Por qué quieres adoptar?") {
                    TextEditor(text: $reasonForAdoption)
                        .frame(height: 100)
                }
                
                Section {
                    Button {
                        Task {
                            await submitAdoption()
                        }
                    } label: {
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Enviar Solicitud")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(Color.blue)
                    .disabled(!isFormValid || viewModel.isLoading)
                }
            }
            .navigationTitle("Solicitud de Adopción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .alert("¡Solicitud Enviada!", isPresented: $viewModel.showSuccess) {
                Button("OK") {
                    onSuccess?()
                    dismiss()
                }
            } message: {
                Text("Tu solicitud de adopción ha sido enviada exitosamente. La organización la revisará pronto.")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage ?? "Error al enviar solicitud")
            }
        }
    }
    
    private var isFormValid: Bool {
        applicationMessage.count >= 50 &&
        !householdMembers.isEmpty &&
        Int(householdMembers) ?? 0 >= 1
    }
    
    private func submitAdoption() async {
        let adopterInfo = AdopterInfo(
            hasExperience: hasExperience,
            experienceDetails: hasExperience ? experienceDetails : nil,
            hasOtherPets: hasOtherPets,
            otherPetsDetails: hasOtherPets ? otherPetsDetails : nil,
            homeType: selectedHomeType,
            hasYard: hasYard,
            householdMembers: Int(householdMembers) ?? 1,
            householdDetails: householdDetails.isEmpty ? nil : householdDetails,
            workSchedule: workSchedule.isEmpty ? nil : workSchedule,
            reasonForAdoption: reasonForAdoption.isEmpty ? nil : reasonForAdoption
        )
        
        await viewModel.submitAdoption(
            animalId: animal.id,
            applicationMessage: applicationMessage,
            adopterInfo: adopterInfo
        )
    }
}
@MainActor
class AdoptionFormViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showSuccess = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    private let service = AdoptionService()
    
    func submitAdoption(animalId: String, applicationMessage: String, adopterInfo: AdopterInfo) async {
        isLoading = true
        
        do {
            let _ = try await service.submitAdoption(
                animalId: animalId,
                applicationMessage: applicationMessage,
                adopterInfo: adopterInfo
            )
            isLoading = false
            showSuccess = true
        } catch {
            // ✅ Captura el mensaje específico del error
            if let nsError = error as NSError? {
                errorMessage = nsError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
            isLoading = false
            showError = true
            print("🔴 Error en submitAdoption: \(errorMessage ?? "desconocido")")
        }
    }
}
