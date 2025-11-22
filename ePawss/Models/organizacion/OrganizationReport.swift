//
//  OrganizationReport.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//

import Foundation


struct OrganizationReportListResponse: Decodable {
    let success: Bool
    let data: [OrganizationReport]
    let pagination: PaginationMeta
}

struct OrganizationReport: Decodable, Identifiable {
    let id: String
    let description: String
    let animalType: String
    let urgencyLevel: String
    let status: String
    let locationAddress: String
    let photoUrls: [String]
    let reporterId: Reporter?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case description, animalType, urgencyLevel, status, locationAddress, photoUrls, reporterId, createdAt
    }
}

struct Reporter: Decodable {
    let name: String?
}

struct PaginationMeta: Decodable {
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let itemsPerPage: Int
    let hasNextPage: Bool
    let hasPrevPage: Bool
}

