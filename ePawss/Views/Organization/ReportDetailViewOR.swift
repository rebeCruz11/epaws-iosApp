//
//  ReportDetailViewOR.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//

import SwiftUI

struct ReportDetailViewOR: View {
    @StateObject var viewModel = ReportDetailViewModel()
    let reportId: String

    @State private var showStatusSheet = false
    @State private var selectedStatus: String = ""
    @State private var notes: String = ""

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            

            ScrollView {
                if let reporte = viewModel.report {
                    VStack(alignment: .leading, spacing: 20) {
                        if let imgUrl = reporte.photoUrls.first, let url = URL(string: imgUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(height: 180)
                            .clipped()
                            .cornerRadius(14)
                            .padding(.horizontal)
                        }

                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(Color(red: 45/255, green: 66/255, blue: 84/255))
                            Text(reporte.locationAddress ?? "No disponible")
                                .font(.headline)
                        }
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Reporte #\(String(reporte.id.prefix(4)))")
                                    .bold()
                                Spacer()
                                Text(formatDate(reporte.createdAt))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            HStack(spacing: 5) {
                                Image(systemName: "person.fill")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("Reportado por: \(reporte.reporter.name ?? "-")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            HStack(spacing: 6) {
                                UrgencyChip(urgency: reporte.urgencyLevel)
                                AnimalTypeChip(type: reporte.animalType)
                                if reporte.status == "in_veterinary" {
                                    Chip(text: "Enviar a veterinaria", color: .gray.opacity(0.3))
                                }
                            }
                        }
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Descripcion")
                                .font(.headline)
                            Text(reporte.description)
                                .font(.body)
                        }
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 7) {
                            Text("Estado actual")
                                .font(.headline)
                            Text(getStatusText(reporte.status))
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                            Button(action: {
                                selectedStatus = reporte.status
                                notes = ""
                                showStatusSheet.toggle()
                            }) {
                                Text("Actualizar Estado")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 9)
                                    .background(Color.orange)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)

                        if let history = reporte.statusHistory, !history.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Historial")
                                    .font(.headline)
                                ForEach(history) { change in
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(getStatusText(change.status))
                                                .bold()
                                            Spacer()
                                            Text(formatDate(change.changedAt))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        if let notes = change.notes, !notes.isEmpty {
                                            Text(notes)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        Spacer(minLength: 40)
                    }
                } else if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $showStatusSheet) {
            VStack(spacing: 20) {
                Text("Actualizar Estado")
                    .font(.headline)
                Picker("Nuevo estado", selection: $selectedStatus) {
                    Text("Pendiente").tag("pending")
                    Text("Rescatado").tag("rescued")
                    Text("En tratamiento").tag("in_veterinary")
                    Text("Listo para Adopción").tag("ready_for_adoption")
                }
                .pickerStyle(WheelPickerStyle())

                TextField("Notas (opcional)", text: $notes)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Guardar") {
                    viewModel.updateStatus(reportId: reportId, status: selectedStatus, notes: notes)
                    showStatusSheet = false
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Cancelar") {
                    showStatusSheet = false
                }
            }
            .padding()
        }
        .onAppear { viewModel.loadReport(reportId: reportId) }
    }

    func formatDate(_ iso: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        guard let date = isoFormatter.date(from: iso) else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func getStatusText(_ status: String) -> String {
        switch status {
        case "pending": return "Pendiente"
        case "assigned": return "Asignado"
        case "rescued": return "Rescatado"
        case "in_veterinary": return "En tratamiento"
        case "ready_for_adoption": return "Listo para Adopción"
        case "recovered": return "Recuperado"
        case "adopted": return "Adoptado"
        case "closed": return "Cerrado"
        default: return status.capitalized
        }
    }
}

struct Chip: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(.caption).bold()
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct UrgencyChip: View {
    let urgency: String
    var body: some View {
        let color: Color = urgency == "high" ? .red : (urgency == "medium" ? .yellow : .gray)
        let label: String = urgency == "high" ? "Urgente" : urgency.capitalized
        return Chip(text: label, color: color)
    }
}

struct AnimalTypeChip: View {
    let type: String
    var body: some View {
        let emoji = type == "dog" ? "🐶" : type == "cat" ? "🐱" : "🐾"
        return Chip(text: "\(emoji) \(type.capitalized)", color: .gray)
    }
}
