//
//  OrganizationStats.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//
// Models/OrganizationStats.swift

import Foundation

struct OrganizationStatsResponse: Decodable {
    let success: Bool
    let message: String?
    let data: OrganizationStatsData
}

struct OrganizationStatsData: Decodable {
    let animals: AnimalsStats
    let reports: ReportsStats
    let recent: RecentStats
    let capacity: CapacityStats
}

struct AnimalsStats: Decodable {
    let total: Int
    let available: Int
    let pendingAdoption: Int
    let adopted: Int
}

struct ReportsStats: Decodable {
    let total: Int
    let pending: Int
    let rescued: Int
}

struct RecentStats: Decodable {
    let animals: [AnimalResumen]
    let reports: [ReporteResumen]
}

struct CapacityStats: Decodable {
    let max: Int
    let current: Int
    let available: Int
}

struct AnimalResumen: Decodable, Identifiable {
    let id: String
    let name: String
    let species: String
    let photoUrls: [String]?
    let status: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, species, photoUrls, status, createdAt
    }
}

struct ReporteResumen: Decodable, Identifiable {
    let id: String
    let description: String
    let animalType: String
    let urgencyLevel: String
    let status: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case description, animalType, urgencyLevel, status, createdAt
    }
}

