//
//  VeterinaryHomeView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 07/11/25.
//

import SwiftUI

struct VeterinaryHomeView: View {
    let user: User
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var reportViewModel = ReportViewModel()
    
    var clinicName: String {
        user.veterinaryDetails?.clinicName ?? "Clínica Veterinaria"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Saludo
                    greetingSection
                    
                    // Sección de ePals que necesitan atención
                    medicalReportsSection
                    
                    Spacer()
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("ePaw")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            // Perfil
                        } label: {
                            Label("Mi Perfil", systemImage: "person.circle")
                        }
                        Button(role: .destructive) {
                            authViewModel.logout()
                        } label: {
                            Label("Cerrar Sesión", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "person.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                if reportViewModel.reports.isEmpty {
                    Task {
                        await reportViewModel.loadVeterinaryReports()  // ✅ Ya no necesitas pasar el ID
                    }
                }
            }
            .refreshable {
                await reportViewModel.loadVeterinaryReports()  // ✅ Más simple
            }
            .alert("Error", isPresented: $reportViewModel.showError) {
                Button("OK") {}
            } message: {
                Text(reportViewModel.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - Greeting Section
    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("¡Buenos Días!")
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Medical Reports Section
    private var medicalReportsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mis casos asignados:")  // ✅ Texto más claro
                .font(.headline)
                .padding(.horizontal, 20)
            
            if reportViewModel.isLoading && reportViewModel.reports.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if reportViewModel.reports.isEmpty {
                emptyStateView
            } else {
                reportsListView
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")  // ✅ Ícono más apropiado
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No tienes casos asignados")  // ✅ Mensaje actualizado
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("Los reportes aparecerán aquí cuando una organización te los asigne")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var reportsListView: some View {
        VStack(spacing: 12) {
            ForEach(reportViewModel.reports) { report in
                NavigationLink(destination: ReportDetailView(reportId: report.id)) {
                    ReportCardView(report: report)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if reportViewModel.currentPage < reportViewModel.totalPages {
                Button {
                    Task {
                        await reportViewModel.loadVeterinaryReports(
                            page: reportViewModel.currentPage + 1
                        )
                    }
                } label: {
                    if reportViewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Cargar más")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}
