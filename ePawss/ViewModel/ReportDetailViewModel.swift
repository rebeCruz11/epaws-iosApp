//
//  ReportDetailViewModel.swift
//  ePaw
//
//  Created by ESTUDIANTE on 8/11/25.
//



import Foundation

class ReportDetailViewModel: ObservableObject {
    @Published var report: ReportDetail?
    @Published var error: String?
    @Published var isLoading = false
    @Published var showStatusSheet = false
    @Published var notes: String = ""
    @Published var selectedStatus: String = ""

    let statusOptions = ["pending": "Pendiente", "rescued": "Rescatado", "in_veterinary": "En tratamiento", "ready_for_adoption": "Listo para Adopción"]

    func loadReport(reportId: String) {
        isLoading = true
        APIService.shared.fetchReportDetail(reportId: reportId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let report):
                    self?.report = report
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }

    func updateStatus(reportId: String, status: String, notes: String?) {
        APIService.shared.updateReportStatus(reportId: reportId, status: status, notes: notes) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self?.loadReport(reportId: reportId) // recarga el detalle con historial actualizado
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
}
