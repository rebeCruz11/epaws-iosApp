//
//  OrganizationHomeView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//

import SwiftUI

struct OrganizationHomeView: View {
    let user: User
    @StateObject private var reportesVM = OrganizationReportsViewModel()
    @EnvironmentObject var viewModel: AuthViewModel  // ✅ Para cerrar sesión
    @State private var showLogoutAlert = false  // ✅ Alerta de confirmación
    
    private var saludo: String {
        let hora = Calendar.current.component(.hour, from: Date())
        switch hora {
        case 6..<12: return "¡Buenos Días!"
        case 12..<19: return "¡Buenas Tardes!"
        default: return "¡Buenas Noches!"
        }
    }
    
    private var reportesPendientes: Int {
        reportesVM.reportes.filter { $0.status == .pending || $0.status == .assigned }.count
    }
    
    private var reportesRescatados: Int {
        reportesVM.reportes.filter { $0.status == .rescued }.count
    }
    
    private var reportesRecientes: [Report] {
        Array(reportesVM.reportes.prefix(5))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // Logo y campana
                    HStack {
                        Text("ePaw")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                        Spacer()
                        
                        // ✅ Botón de cerrar sesión
                        Button {
                            showLogoutAlert = true
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.title2)
                                .foregroundColor(Color.red)
                        }
                    }
                    .padding(.top, 12)

                    // Saludo
                    Text(saludo)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                        .padding(.top, 8)
                    
                    Text("Aquí está el resumen de hoy")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)

                    // Tarjetas de resumen
                    HStack(spacing: 16) {
                        OrgResumenCard(titulo: "Reportes\nnuevos", valor: reportesPendientes)
                        OrgResumenCard(titulo: "Rescatados", valor: reportesRescatados)
                        OrgResumenCard(titulo: "Total", valor: reportesVM.reportes.count)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Botones principales
                    LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 14), count: 2), spacing: 18) {
                        OrgBotonAccion(icono: "plus", texto: "Publicar ePal")
                        OrgBotonAccion(icono: "pawprint.fill", texto: "Mis ePals", color: .orange)
                        
                        NavigationLink(destination: OrganizationReportsView()) {
                            OrgBotonAccion(icono: "doc.text", texto: "Ver reportes")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        OrgBotonAccion(icono: "tray.full", texto: "Solicitudes")
                    }
                    .padding(.vertical)

                    // Sección "Reportes Recientes"
                    if !reportesRecientes.isEmpty {
                        HStack {
                            Text("Reportes Recientes")
                                .font(.headline)
                            Spacer()
                            NavigationLink(destination: OrganizationReportsView()) {
                                Text("ver más")
                                    .foregroundColor(Color.gray)
                                    .font(.subheadline)
                            }
                        }
                        
                        ForEach(reportesRecientes) { reporte in
                            NavigationLink(destination: ReporteDetalleView(reporteId: reporte.id)) {
                                OrgReporteMiniCard(reporte: reporte)
                                    .padding(.vertical, 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } else if !reportesVM.isLoading {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No hay reportes asignados")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    }
                    
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 18)
            }
            .background(Color(.white))
            .task {
                await reportesVM.cargarReportes()
            }
            .refreshable {
                await reportesVM.cargarReportes()
            }
        }
        .navigationBarBackButtonHidden(true)
        // ✅ Alerta de confirmación
        .alert("Cerrar Sesión", isPresented: $showLogoutAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Cerrar Sesión", role: .destructive) {
                viewModel.logout()
            }
        } message: {
            Text("¿Estás seguro que deseas cerrar sesión?")
        }
    }
}

// MARK: - Org Resumen Card
struct OrgResumenCard: View {
    let titulo: String
    let valor: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(valor)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
            
            Text(titulo)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Org Botón de Acción
struct OrgBotonAccion: View {
    let icono: String
    let texto: String
    var color: Color = Color(red: 0.2, green: 0.3, blue: 0.5)
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icono)
                .font(.system(size: 28))
                .foregroundColor(color)
            Text(texto)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(14)
    }
}

// MARK: - Org Reporte Mini Card
struct OrgReporteMiniCard: View {
    let reporte: Report
    private let imageStorage = ImageStorageService.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Imagen local
            if let primeraFoto = reporte.photoUrls.first,
               let image = imageStorage.loadImage(filename: primeraFoto) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Reporte #\(String(reporte.id.prefix(4)))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                    
                    Spacer()
                    
                    // Badge de urgencia
                    Text(reporte.urgencyLevel.displayName)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(urgenciaColor(reporte.urgencyLevel))
                        .cornerRadius(5)
                }
                
                Text(reporte.description)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Text(reporte.locationAddress ?? "Sin dirección")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func urgenciaColor(_ urgency: UrgencyLevel) -> Color {
        switch urgency {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
}

#Preview {
    OrganizationHomeView(user: User(
        id: "123",
        email: "test@org.com",
        name: "Org Test",
        role: .organization,
        verified: true,
        phone: nil,
        address: nil,
        profilePhotoUrl: nil,
        organizationDetails: nil,
        veterinaryDetails: nil,
        isActive: true,
        createdAt: nil,
        updatedAt: nil
    ))
    .environmentObject(AuthViewModel())
}
