//
//  OrganizationModels.swift
//  ePaw
//
//  Created by ESTUDIANTE on 15/11/25.
//

import Foundation

// MARK: - Organization Stats Response
struct OrganizationStatsResponse: Codable {
    let success: Bool
    let data: OrganizationStatsData
}

struct OrganizationStatsData: Codable {
    let reports: ReportsStats
    let animals: AnimalsStats
    let recent: RecentData
}

struct ReportsStats: Codable {
    let total: Int
    let pending: Int
    let rescued: Int
    let inVeterinary: Int
    let readyForAdoption: Int
}

struct AnimalsStats: Codable {
    let total: Int
    let available: Int
    let adopted: Int
}

struct RecentData: Codable {
    let reports: [RecentReport]
    let animals: [RecentAnimal]
}

// MARK: - Recent Report (para dashboard)
struct RecentReport: Codable, Identifiable {
    let id: String
    let description: String
    let animalType: String
    let urgencyLevel: String
    let locationAddress: String
    let photoUrls: [String]?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case description
        case animalType
        case urgencyLevel
        case locationAddress
        case photoUrls
        case createdAt
    }
}

// MARK: - Recent Animal (para dashboard)
struct RecentAnimal: Codable, Identifiable {
    let id: String
    let name: String
    let species: String
    let photoUrls: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case species
        case photoUrls
    }
}

// MARK: - Organization Report List Response
struct OrganizationReportListResponse: Codable {
    let success: Bool
    let data: [OrganizationReport]
    let pagination: PaginationInfo?
}

// MARK: - Organization Report (para lista completa)
struct OrganizationReport: Codable, Identifiable {
    let id: String
    let description: String
    let animalType: String
    let urgencyLevel: String
    let locationAddress: String
    let photoUrls: [String]
    let status: String
    let createdAt: String
    let reporterId: ReporterInfo?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case description
        case animalType
        case urgencyLevel
        case locationAddress
        case photoUrls
        case status
        case createdAt
        case reporterId
    }
}

struct ReporterInfo: Codable {
    let id: String
    let name: String?
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
    }
}

struct PaginationInfo: Codable {
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let itemsPerPage: Int
}

// MARK: - Report Detail Response
struct ReportDetailResponse: Codable {
    let success: Bool
    let data: ReportDetail
}

struct ReportDetail: Codable {
    let id: String
    let description: String
    let animalType: String
    let urgencyLevel: String
    let locationAddress: String?
    let photoUrls: [String]
    let status: String
    let createdAt: String
    let reporter: ReporterDetail
    let statusHistory: [StatusChange]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case description
        case animalType
        case urgencyLevel
        case locationAddress
        case photoUrls
        case status
        case createdAt
        case reporter = "reporterId"
        case statusHistory
    }
}

struct ReporterDetail: Codable {
    let id: String?
    let name: String?
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
    }
}

struct StatusChange: Codable, Identifiable {
    let id: String?
    let status: String
    let changedAt: String
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case status
        case changedAt
        case notes
    }
}
