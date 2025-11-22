//
//  OrganizationAdoptionsView.swift
//  ePaw
//

import SwiftUI

struct OrganizationAdoptionsView: View {
    @StateObject private var viewModel = OrganizationAdoptionsViewModel()
    @State private var selectedFilter: AdoptionStatus? = .pending
    @State private var selectedAdoption: Adoption?
    @State private var showDetailSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterPill(title: "Todas", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        FilterPill(title: "Pendientes", isSelected: selectedFilter == .pending) {
                            selectedFilter = .pending
                        }
                        FilterPill(title: "En Revisión", isSelected: selectedFilter == .underReview) {
                            selectedFilter = .underReview
                        }
                        FilterPill(title: "Aprobadas", isSelected: selectedFilter == .approved) {
                            selectedFilter = .approved
                        }
                        FilterPill(title: "Completadas", isSelected: selectedFilter == .completed) {
                            selectedFilter = .completed
                        }
                    }
                    .padding()
                }
                
                // Content
                if viewModel.isLoading {
                    ProgressView("Cargando solicitudes...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredAdoptions.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredAdoptions) { adoption in
                                OrganizationAdoptionCard(adoption: adoption)
                                    .onTapGesture {
                                        selectedAdoption = adoption
                                        showDetailSheet = true
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Solicitudes de Adopción")
            .refreshable {
                await viewModel.loadAdoptions()
            }
            .task {
                await viewModel.loadAdoptions()
            }
            .sheet(isPresented: $showDetailSheet) {
                if let adoption = selectedAdoption {
                    OrganizationAdoptionDetailView(adoption: adoption) {
                        Task {
                            await viewModel.loadAdoptions()
                        }
                    }
                }
            }
        }
    }
    
    private var filteredAdoptions: [Adoption] {
        if let filter = selectedFilter {
            return viewModel.adoptions.filter { $0.status == filter }
        }
        return viewModel.adoptions
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No hay solicitudes")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("Cuando alguien solicite adoptar\nun ePal, aparecerá aquí")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Adoption Card for Organizations
struct OrganizationAdoptionCard: View {
    let adoption: Adoption
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Animal photo
                if let photoUrl = adoption.animalDetails?.photoUrls.first {
                    AsyncImage(url: URL(string: photoUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(adoption.animalDetails?.name ?? "Animal")
                        .font(.headline)
                    
                    if let adopterName = adoption.adopterDetails?.name {
                        Text("Solicitante: \(adopterName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: adoption.status.icon)
                        Text(adoption.status.displayName)
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(adoption.status.color).opacity(0.2))
                    .foregroundColor(Color(adoption.status.color))
                    .cornerRadius(6)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Adoption Detail for Organizations
struct OrganizationAdoptionDetailView: View {
    let adoption: Adoption
    var onUpdate: (() -> Void)? = nil
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = OrganizationAdoptionActionViewModel()
    
    @State private var reviewNotes = ""
    @State private var rejectionReason = ""
    @State private var showApproveConfirm = false
    @State private var showRejectConfirm = false
    @State private var showCompleteConfirm = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Animal Info
                    if let animal = adoption.animalDetails {
                        animalSection(animal)
                    }
                    
                    Divider()
                    
                    // Status Badge
                    statusBadge
                    
                    Divider()
                    
                    // Adopter Info
                    adopterSection
                    
                    Divider()
                    
                    // Application Message
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mensaje de Solicitud")
                            .font(.headline)
                        Text(adoption.applicationMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Action Section (if pending or under_review)
                    if adoption.status == .pending || adoption.status == .underReview {
                        actionSection
                    } else if adoption.status == .approved {
                        completeSection
                    }
                    
                    // Review Notes (if exists)
                    if let notes = adoption.reviewNotes {
                        Divider()
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notas de Revisión")
                                .font(.headline)
                            Text(notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Detalle de Solicitud")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
            .alert("¿Aprobar solicitud?", isPresented: $showApproveConfirm) {
                Button("Cancelar", role: .cancel) {}
                Button("Aprobar") {
                    Task {
                        await viewModel.approveAdoption(adoptionId: adoption.id, reviewNotes: reviewNotes.isEmpty ? nil : reviewNotes)
                        if viewModel.success {
                            onUpdate?()
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("Esta acción notificará al solicitante que su adopción ha sido aprobada.")
            }
            .alert("¿Rechazar solicitud?", isPresented: $showRejectConfirm) {
                Button("Cancelar", role: .cancel) {}
                Button("Rechazar", role: .destructive) {
                    Task {
                        await viewModel.rejectAdoption(adoptionId: adoption.id, rejectionReason: rejectionReason.isEmpty ? "No especificado" : rejectionReason)
                        if viewModel.success {
                            onUpdate?()
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("Esta acción notificará al solicitante que su adopción ha sido rechazada.")
            }
            .alert("¿Completar adopción?", isPresented: $showCompleteConfirm) {
                Button("Cancelar", role: .cancel) {}
                Button("Completar") {
                    Task {
                        await viewModel.completeAdoption(adoptionId: adoption.id, reviewNotes: reviewNotes.isEmpty ? nil : reviewNotes)
                        if viewModel.success {
                            onUpdate?()
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("Esto marcará la adopción como completada y actualizará el estado del animal.")
            }
        }
    }
    
    private func animalSection(_ animal: AdoptionAnimalDetails) -> some View {
        HStack(spacing: 12) {
            if let photoUrl = animal.photoUrls.first {
                AsyncImage(url: URL(string: photoUrl)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(animal.name)
                    .font(.title3)
                    .bold()
                Text(animal.species.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let breed = animal.breed {
                    Text(breed)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var statusBadge: some View {
        HStack {
            Image(systemName: adoption.status.icon)
            Text(adoption.status.displayName)
                .fontWeight(.semibold)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(adoption.status.color).opacity(0.2))
        .foregroundColor(Color(adoption.status.color))
        .cornerRadius(12)
    }
    
    private var adopterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Información del Solicitante")
                .font(.headline)
            
            if let adopter = adoption.adopterDetails {
                InfoRow(icon: "person.fill", title: "Nombre", value: adopter.name)
                InfoRow(icon: "envelope.fill", title: "Email", value: adopter.email)
                if let phone = adopter.phone {
                    InfoRow(icon: "phone.fill", title: "Teléfono", value: phone)
                }
            }
            
            InfoRow(icon: "house.fill", title: "Tipo de vivienda", value: adoption.adopterInfo.homeType.displayName)
            InfoRow(icon: "pawprint.fill", title: "Experiencia", value: adoption.adopterInfo.hasExperience ? "Sí" : "No")
            
            if let experience = adoption.adopterInfo.experienceDetails {
                Text(experience)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 32)
            }
        }
    }
    
    private var actionSection: some View {
        VStack(spacing: 16) {
            Text("Notas de Revisión (Opcional)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextEditor(text: $reviewNotes)
                .frame(height: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            HStack(spacing: 12) {
                Button {
                    showApproveConfirm = true
                } label: {
                    Text("Aprobar")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button {
                    showRejectConfirm = true
                } label: {
                    Text("Rechazar")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            if adoption.status == .pending {
                Text("Si necesitas más tiempo para revisar, puedes moverla a 'En Revisión'")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var completeSection: some View {
        VStack(spacing: 16) {
            Text("Esta adopción ha sido aprobada")
                .font(.headline)
            
            Text("¿El adoptante ya recogió al animal?")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextEditor(text: $reviewNotes)
                .frame(height: 80)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            Button {
                showCompleteConfirm = true
            } label: {
                Text("Marcar como Completada")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Filter Pill
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - ViewModels
@MainActor
class OrganizationAdoptionsViewModel: ObservableObject {
    @Published var adoptions: [Adoption] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = AdoptionService()
    
    func loadAdoptions() async {
        isLoading = true
        
        // Get organization ID from current user
        guard let userId = TokenManager.shared.getUserId() else {
            errorMessage = "No se pudo obtener el ID de la organización"
            isLoading = false
            return
        }
        
        do {
            adoptions = try await service.getOrganizationAdoptions(organizationId: userId, status: nil, page: 1)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("Error loading adoptions: \(error)")
        }
    }
}

@MainActor
class OrganizationAdoptionActionViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var success = false
    @Published var errorMessage: String?
    
    private let service = AdoptionService()
    
    func approveAdoption(adoptionId: String, reviewNotes: String?) async {
        isLoading = true
        
        do {
            _ = try await service.updateAdoptionStatus(
                adoptionId: adoptionId,
                status: .approved,
                reviewNotes: reviewNotes
            )
            success = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func rejectAdoption(adoptionId: String, rejectionReason: String) async {
        isLoading = true
        
        do {
            _ = try await service.updateAdoptionStatus(
                adoptionId: adoptionId,
                status: .rejected,
                rejectionReason: rejectionReason
            )
            success = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func completeAdoption(adoptionId: String, reviewNotes: String?) async {
        isLoading = true
        
        do {
            _ = try await service.updateAdoptionStatus(
                adoptionId: adoptionId,
                status: .completed,
                reviewNotes: reviewNotes
            )
            success = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

// MARK: - Info Row Helper
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
        }
    }
}
