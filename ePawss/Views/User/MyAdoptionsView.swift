//
//  MyAdoptionsView.swift
//  ePaw
//

import SwiftUI

struct MyAdoptionsView: View {
    @StateObject private var viewModel = MyAdoptionsViewModel()
    @State private var selectedAdoption: Adoption?  // ✅ Para sheet
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.adoptions.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.adoptions) { adoption in
                            AdoptionCardView(adoption: adoption)
                                .onTapGesture {
                                    selectedAdoption = adoption
                                }
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .navigationTitle("Mis Solicitudes")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedAdoption) { adoption in  // ✅ Usa sheet
            NavigationStack {
                AdoptionDetailView(adoption: adoption)
            }
        }
        .task {
            await viewModel.loadAdoptions()
        }
        .refreshable {
            await viewModel.loadAdoptions()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No tienes solicitudes")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("Cuando solicites adoptar un ePal,\naparecerá aquí")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
// MARK: - Adoption Card
struct AdoptionCardView: View {
    let adoption: Adoption
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Imagen del animal
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
                    
                    Text(adoption.status.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor(adoption.status))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    
                    Text(formatDate(adoption.appliedAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
    
    private func statusColor(_ status: AdoptionStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .underReview: return .blue
        case .approved: return .green
        case .rejected: return .red
        case .completed: return .purple
        case .cancelled: return .gray
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
class MyAdoptionsViewModel: ObservableObject {
    @Published var adoptions: [Adoption] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = AdoptionService()
    
    func loadAdoptions() async {
        isLoading = true
        do {
            adoptions = try await service.getMyApplications()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("Error loading adoptions: \(error)")
        }
    }
}
