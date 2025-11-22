//
//  OrganizationDashboardViewModel.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//

import Foundation

class OrganizationDashboardViewModel: ObservableObject {
    @Published var stats: OrganizationStatsData?
    @Published var isLoading = false
    @Published var error: String?

    func loadDashboard(organizationId: String) {
        isLoading = true
        APIService.shared.fetchOrganizationStats(organizationId: organizationId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let stats):
                    self?.stats = stats
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
}

