//
//  ReportDetail.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//


import Foundation

struct ReportDetailResponse: Decodable {
    let success: Bool
    let data: ReportDetail
}

struct ReportDetail: Decodable, Identifiable {
    let id: String
    let description: String
    let urgencyLevel: String
    let animalType: String
    let status: String
    let locationAddress: String
    let photoUrls: [String]
    let reporter: ReporterDetail
    let createdAt: String
    // Historial de estados
    let statusHistory: [StatusHistoryItem]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case description, urgencyLevel, animalType, status, locationAddress, photoUrls, reporter = "reporterId", createdAt, statusHistory
    }
}

struct ReporterDetail: Decodable {
    let name: String?
    let profilePhotoUrl: String?
}

struct StatusHistoryItem: Decodable, Identifiable {
    let id = UUID()
    let status: String
    let notes: String?
    let changedAt: String

    enum CodingKeys: String, CodingKey {
        case status, notes, changedAt
    }
}
