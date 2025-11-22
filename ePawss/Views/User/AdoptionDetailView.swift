//
//  AdoptionDetailView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 14/11/25.
//

import SwiftUI

struct AdoptionDetailView: View {
    let adoption: Adoption
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AdoptionDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Animal Info Card
                if let animalDetails = adoption.animalDetails {
                    animalCard(animalDetails)
                }
                
                // Status Badge
                statusSection
                
                Divider()
                
                // Application Message
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mensaje de Solicitud")
                            .font(.headline)
                        Text(adoption.applicationMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Adopter Info
                adopterInfoSection
                
                Divider()
                
                // Organization Info
                if let orgDetails = adoption.organizationDetails {
                    organizationSection(orgDetails)
                    Divider()
                }
                
                // Review Notes
                if let notes = adoption.reviewNotes {
                    reviewNotesSection(notes)
                    Divider()
                }
                
                // Rejection Reason
                if let reason = adoption.rejectionReason {
                    rejectionReasonSection(reason)
                    Divider()
                }
                
                // Timeline
                timelineSection
                
                // Cancel Button
                if adoption.status == .pending || adoption.status == .underReview {
                    cancelButton
                }
            }
            .padding()
        }
        .navigationTitle("Solicitud #\(adoption.id.suffix(6))")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .alert("Cancelar Solicitud", isPresented: $viewModel.showCancelAlert) {
            Button("No", role: .cancel) {}
            Button("Sí, cancelar", role: .destructive) {
                Task {
                    await viewModel.cancelAdoption(id: adoption.id)
                }
            }
        } message: {
            Text("¿Estás seguro que deseas cancelar esta solicitud?")
        }
        .alert("Solicitud Cancelada", isPresented: $viewModel.showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Tu solicitud ha sido cancelada exitosamente")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "Error al cancelar solicitud")
        }
    }
    
    // MARK: - Animal Card
    private func animalCard(_ animal: AdoptionAnimalDetails) -> some View {
        HStack(spacing: 16) {
            // Animal Photo
            if let photoUrl = animal.photoUrls.first {
                AsyncImage(url: URL(string: photoUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(animal.name)
                    .font(.title2)
                    .bold()
                
                Text(animal.species.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if let breed = animal.breed {
                    Text(breed)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Status Section
    private var statusSection: some View {
        HStack {
            Image(systemName: adoption.status.icon)
                .font(.title2)
                .foregroundColor(Color(adoption.status.color))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Estado")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(adoption.status.displayName)
                    .font(.headline)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(adoption.status.color).opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Adopter Info Section
    private var adopterInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Información del Solicitante")
                .font(.headline)
            
            InfoRow(icon: "checkmark.circle", title: "Experiencia con mascotas", value: adoption.adopterInfo.hasExperience ? "Sí" : "No")
            
            if let details = adoption.adopterInfo.experienceDetails {
                Text(details)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 32)
            }
            
            InfoRow(icon: "pawprint", title: "Otras mascotas", value: adoption.adopterInfo.hasOtherPets ? "Sí" : "No")
            
            if let details = adoption.adopterInfo.otherPetsDetails {
                Text(details)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 32)
            }
            
            InfoRow(icon: "house", title: "Tipo de hogar", value: adoption.adopterInfo.homeType.displayName)
            InfoRow(icon: "leaf", title: "Tiene patio", value: adoption.adopterInfo.hasYard ? "Sí" : "No")
            InfoRow(icon: "person.3", title: "Miembros del hogar", value: "\(adoption.adopterInfo.householdMembers)")
            
            if let schedule = adoption.adopterInfo.workSchedule {
                InfoRow(icon: "clock", title: "Horario laboral", value: schedule)
            }
            
            if let reason = adoption.adopterInfo.reasonForAdoption {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Razón de adopción")
                        .font(.subheadline)
                        .bold()
                    Text(reason)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Organization Section
    private func organizationSection(_ org: AdoptionUserDetails) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Organización")
                .font(.headline)
            
            if let orgName = org.organizationDetails?.organizationName {
                Text(orgName)
                    .font(.body)
            }
            
            
            if let phone = org.phone, !phone.isEmpty {
                HStack {
                    Image(systemName: "phone")
                        .font(.caption)
                    Text(phone)
                        .font(.caption)
                }
                .foregroundColor(.gray)
            }
        }
    }
    
    // MARK: - Review Notes Section
    private func reviewNotesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notas de Revisión")
                .font(.headline)
            Text(notes)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Rejection Reason Section
    private func rejectionReasonSection(_ reason: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Razón de Rechazo")
                .font(.headline)
            Text(reason)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Timeline Section
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Línea de Tiempo")
                .font(.headline)
            
            TimelineItem(icon: "paperplane", title: "Solicitud enviada", date: adoption.appliedAt, color: .blue)
            
            if let reviewedAt = adoption.reviewedAt {
                TimelineItem(icon: "eye", title: "Revisada", date: reviewedAt, color: .orange)
            }
            
            if let completedAt = adoption.completedAt {
                TimelineItem(icon: "checkmark.circle", title: "Completada", date: completedAt, color: .green)
            }
        }
    }
    
    // MARK: - Cancel Button
    private var cancelButton: some View {
        Button {
            viewModel.showCancelAlert = true
        } label: {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            } else {
                Text("Cancelar Solicitud")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
        }
        .background(Color.red)
        .cornerRadius(12)
        .disabled(viewModel.isLoading)
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .bold()
        }
    }
}

// MARK: - Timeline Item Component
struct TimelineItem: View {
    let icon: String
    let title: String
    let date: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                Text(formatDate(date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.locale = Locale(identifier: "es_ES")
        
        return displayFormatter.string(from: date)
    }
}

// MARK: - ViewModel
@MainActor
class AdoptionDetailViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showCancelAlert = false
    @Published var showSuccess = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    private let service = AdoptionService()
    
    func cancelAdoption(id: String) async {
        isLoading = true
        
        do {
            let _ = try await service.cancelAdoption(id: id)
            isLoading = false
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            showError = true
        }
    }
}

