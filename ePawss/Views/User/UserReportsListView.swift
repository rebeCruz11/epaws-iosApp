//
//  UserReportsListView.swift
//  ePaw
//
//  Created by ESTUDIANTE on 14/11/25.
//

import SwiftUI

struct UserReportsListView: View {
    @StateObject private var viewModel = UserReportsViewModel()
    @State private var selectedReport: Report?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGray6)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if viewModel.reports.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.reports) { report in
                                UserReportCardView(report: report)
                                    .onTapGesture {
                                        selectedReport = report
                                    }
                            }
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedReport) { report in
                NavigationStack {
                    UserReportDetailView(report: report)
                }
            }
            .task {
                await viewModel.loadUserReports()
            }
            .refreshable {
                await viewModel.loadUserReports()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No tienes reportes")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("Cuando reportes un ePal en peligro,\naparecerá aquí")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - ViewModel
@MainActor
class UserReportsViewModel: ObservableObject {
    @Published var reports: [Report] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = ReportService()
    
    func loadUserReports() async {
        isLoading = true
        do {
            reports = try await service.getUserReports()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("Error loading reports: \(error)")
        }
    }
}

#Preview {
    UserReportsListView()
}

