//
//  CreateReportViewModel.swift
//  ePaw
//
//  Created by ESTUDIANTE on 07/11/25.
//

import Foundation
import UIKit

@MainActor
class CreateReportViewModel: ObservableObject {
    @Published var description: String = ""
    @Published var selectedUrgency: UrgencyLevel = .medium
    @Published var selectedAnimalType: AnimalType = .dog
    @Published var locationAddress: String = ""
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var selectedImages: [UIImage] = []
    @Published var isLoading: Bool = false
    @Published var showSuccess: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String?
    
    // ✅ NUEVO: Organizaciones
    @Published var organizations: [Organization] = []
    @Published var selectedOrganization: Organization?
    @Published var isLoadingOrganizations: Bool = false
    
    private let reportService = ReportService()
    private let cloudinaryService = CloudinaryService.shared
    private let organizationService = OrganizationService()
    
    var canSubmit: Bool {
        !description.isEmpty &&
        description.count >= 10 &&
        !locationAddress.isEmpty &&
        selectedOrganization != nil
    }
    
    // ✅ NUEVO: Cargar organizaciones
    func loadOrganizations() async {
        print("🟡 [ViewModel] Iniciando carga de organizaciones...")
        isLoadingOrganizations = true
        
        do {
            organizations = try await organizationService.getAllOrganizations()
            
            print("🟢 [ViewModel] Organizaciones cargadas: \(organizations.count)")
            
            if selectedOrganization == nil, let first = organizations.first {
                selectedOrganization = first
                print("🟢 [ViewModel] Organización seleccionada por defecto: \(first.name)")
            }
            
            isLoadingOrganizations = false
        } catch {
            print("❌ [ViewModel] Error cargando organizaciones: \(error)")
            errorMessage = "Error cargando organizaciones: \(error.localizedDescription)"
            showError = true
            isLoadingOrganizations = false
        }
    }

    
    func submitReport() async {
        guard canSubmit else { return }
        guard let selectedOrg = selectedOrganization else {
            errorMessage = "Debes seleccionar una organización"
            showError = true
            return
        }
        
        print("📤 Iniciando envío de reporte...")
        print("📷 Imágenes a subir a Cloudinary: \(selectedImages.count)")
        print("🏢 Organización seleccionada: \(selectedOrg.name)")
        
        isLoading = true
        
        do {
            // 1. Subir imágenes a Cloudinary
            var photoUrls: [String] = []
            if !selectedImages.isEmpty {
                print("☁️ Subiendo imágenes a Cloudinary...")
                photoUrls = try await cloudinaryService.uploadImages(selectedImages, folder: "epaws/reports")
                print("✅ \(photoUrls.count) imágenes subidas a Cloudinary")
            }
            
            // 2. Crear reporte con las URLs de Cloudinary
            print("📝 Creando reporte...")
            _ = try await reportService.createReport(
                description: description,
                urgencyLevel: selectedUrgency,
                animalType: selectedAnimalType,
                latitude: latitude,
                longitude: longitude,
                locationAddress: locationAddress,
                photoUrls: photoUrls,
                organizationId: selectedOrg.id
            )
            
            print("✅ Reporte creado exitosamente")
            
            showSuccess = true
            resetForm()
            isLoading = false
        } catch {
            print("❌ Error: \(error)")
            errorMessage = "Error: \(error.localizedDescription)"
            showError = true
            isLoading = false
        }
    }
    
    private func resetForm() {
        description = ""
        selectedUrgency = .medium
        selectedAnimalType = .dog
        locationAddress = ""
        latitude = 0.0
        longitude = 0.0
        selectedImages = []
        selectedOrganization = organizations.first
    }
}
