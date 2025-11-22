//
//  CreateReportView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 07/11/25.
//

import SwiftUI
import PhotosUI

struct CreateReportView: View {
    @StateObject private var viewModel = CreateReportViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showImagePicker = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Subir fotos
                photoSection
                
                // ✅ NUEVO: Seleccionar organización
                organizationSection
                
                // Ubicación
                locationSection
                
                // Descripción
                descriptionSection
                
                // Nivel de urgencia
                urgencySection
                
                // Tipo de animal
                animalTypeSection
                
                // Botón enviar
                submitButton
            }
            .padding()
        }
        .navigationTitle("Reportar ePal")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadOrganizations()
        }
        .alert("¡Reporte Enviado!", isPresented: $viewModel.showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Gracias por reportar. Tu comunidad de ePawers y nuestros ePals te lo agradecen.")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "Error desconocido")
        }
    }
    
    // MARK: - Photo Section
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Subir fotos")
                .font(.headline)
            
            Button {
                showImagePicker = true
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text("Subir fotos")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    if viewModel.selectedImages.isEmpty {
                        Text("Ninguna imagen seleccionada")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        Text("\(viewModel.selectedImages.count) imagen(es) seleccionada(s)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundColor(.orange)
                )
            }
            
            if !viewModel.selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                Button {
                                    viewModel.selectedImages.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .background(Color.white.clipShape(Circle()))
                                }
                                .padding(4)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(images: $viewModel.selectedImages)
        }
    }
    
    // MARK: - Organization Section
    // MARK: - Organization Section
    private var organizationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Organización")
                .font(.headline)
            
            if viewModel.isLoadingOrganizations {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            } else if viewModel.organizations.isEmpty {
                Text("No hay organizaciones disponibles")
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
            } else {
                Picker("Selecciona una organización", selection: $viewModel.selectedOrganization) {
                    ForEach(viewModel.organizations, id: \.self) { org in
                        Text(org.displayName).tag(org as Organization?)  // ✅ CAMBIO AQUÍ
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                if let selectedOrg = viewModel.selectedOrganization {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Seleccionada: \(selectedOrg.displayName)")  // ✅ CAMBIO AQUÍ
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
            }
        }
    }


    // MARK: - Location Section
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                // Abrir mapa o usar ubicación actual
            } label: {
                HStack {
                    Image(systemName: "mappin.circle")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Ubicación")
                        .font(.body)
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            
            TextField("Dirección exacta", text: $viewModel.locationAddress)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
        }
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Descripción")
                .font(.headline)
            
            TextEditor(text: $viewModel.description)
                .frame(height: 120)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    Group {
                        if viewModel.description.isEmpty {
                            Text("Describe la situacion del ePal")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
        }
    }
    
    // MARK: - Urgency Section
    private var urgencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nivel de urgencia")
                .font(.headline)
            
            HStack(spacing: 12) {
                urgencyButton(.low, title: "Bajo", color: .green)
                urgencyButton(.medium, title: "Medio", color: .orange)
                urgencyButton(.high, title: "Alto", color: .red)
            }
        }
    }
    
    private func urgencyButton(_ level: UrgencyLevel, title: String, color: Color) -> some View {
        Button {
            viewModel.selectedUrgency = level
        } label: {
            Text(title)
                .font(.subheadline)
                .fontWeight(viewModel.selectedUrgency == level ? .semibold : .regular)
                .foregroundColor(viewModel.selectedUrgency == level ? .white : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(viewModel.selectedUrgency == level ? color : Color.gray.opacity(0.1))
                .cornerRadius(12)
        }
    }
    
    // MARK: - Animal Type Section
    private var animalTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tipo de animal")
                .font(.headline)
            
            HStack(spacing: 12) {
                animalButton(.dog, emoji: "🐕")
                animalButton(.cat, emoji: "🐈")
                animalButton(.bird, emoji: "🐦")
                animalButton(.other, emoji: "🐾")
            }
        }
    }
    
    private func animalButton(_ type: AnimalType, emoji: String) -> some View {
        Button {
            viewModel.selectedAnimalType = type
        } label: {
            Text(emoji)
                .font(.system(size: 32))
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(viewModel.selectedAnimalType == type ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(viewModel.selectedAnimalType == type ? Color.blue : Color.clear, lineWidth: 2)
                )
        }
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button {
            Task {
                await viewModel.submitReport()
            }
        } label: {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            } else {
                Text("Enviar Reporte")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
        }
        .background(viewModel.canSubmit && !viewModel.isLoading ? Color.blue : Color.gray)
        .cornerRadius(12)
        .disabled(!viewModel.canSubmit || viewModel.isLoading)
        .padding(.top, 20)
    }
}

// MARK: - Image Picker Helper
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 5
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            for result in results {  // ← Sin enumerated(), solo el result
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self?.parent.images.append(image)
                        }
                    }
                }
            }
        }
    }

}

#Preview {
    NavigationView {
        CreateReportView()
    }
}
