//
//  Report.swift
//  ePaw
//
//  Created by ESTUDIANTE on 07/11/25.
//

import Foundation

struct Report: Codable, Identifiable {
    let id: String
    let reporterId: String
    let organizationId: String?
    let veterinaryId: String?
    let description: String
    let urgencyLevel: UrgencyLevel
    let animalType: AnimalType
    let status: ReportStatus
    let location: ReportLocation
    let locationAddress: String?
    let photoUrls: [String]
    let rescuedAt: String?
    let closedAt: String?
    let notes: String?
    let createdAt: String
    let updatedAt: String
    
    // Información poblada del reportero
    let reporterInfo: ReporterInfo?
    let organizationInfo: OrganizationInfo?
    let veterinaryInfo: VeterinaryInfo?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case reporterId
        case organizationId
        case veterinaryId
        case description
        case urgencyLevel
        case animalType
        case status
        case location
        case locationAddress
        case photoUrls
        case rescuedAt
        case closedAt
        case notes
        case createdAt
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // IDs simples
        if let idObj = try? container.decode([String: String].self, forKey: .id) {
            id = idObj["$oid"] ?? ""
        } else {
            id = try container.decode(String.self, forKey: .id)
        }
        
        // reporterId puede venir como string o como objeto poblado
        if let reporterObj = try? container.decode(ReporterInfo.self, forKey: .reporterId) {
            reporterInfo = reporterObj
            reporterId = reporterObj.id
        } else {
            reporterId = try container.decode(String.self, forKey: .reporterId)
            reporterInfo = nil
        }
        
        // organizationId puede venir como string o como objeto poblado
        if let orgObj = try? container.decode(OrganizationInfo.self, forKey: .organizationId) {
            organizationInfo = orgObj
            organizationId = orgObj.id
        } else {
            organizationId = try? container.decode(String.self, forKey: .organizationId)
            organizationInfo = nil
        }
        
        // veterinaryId puede venir como string o como objeto poblado
        if let vetObj = try? container.decode(VeterinaryInfo.self, forKey: .veterinaryId) {
            veterinaryInfo = vetObj
            veterinaryId = vetObj.id
        } else {
            veterinaryId = try? container.decode(String.self, forKey: .veterinaryId)
            veterinaryInfo = nil
        }
        
        description = try container.decode(String.self, forKey: .description)
        urgencyLevel = try container.decode(UrgencyLevel.self, forKey: .urgencyLevel)
        animalType = try container.decode(AnimalType.self, forKey: .animalType)
        status = try container.decode(ReportStatus.self, forKey: .status)
        location = try container.decode(ReportLocation.self, forKey: .location)
        locationAddress = try? container.decode(String.self, forKey: .locationAddress)
        photoUrls = (try? container.decode([String].self, forKey: .photoUrls)) ?? []
        rescuedAt = try? container.decode(String.self, forKey: .rescuedAt)
        closedAt = try? container.decode(String.self, forKey: .closedAt)
        notes = try? container.decode(String.self, forKey: .notes)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

// MARK: - Enums
enum UrgencyLevel: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var displayName: String {
        switch self {
        case .low: return "Baja"
        case .medium: return "Media"
        case .high: return "Alta"
        case .critical: return "Crítica"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}

enum AnimalType: String, Codable {
    case dog = "dog"
    case cat = "cat"
    case bird = "bird"
    case rabbit = "rabbit"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .dog: return "Perro"
        case .cat: return "Gato"
        case .bird: return "Ave"
        case .rabbit: return "Conejo"
        case .other: return "Otro"
        }
    }
    
    var icon: String {
        switch self {
        case .dog: return "🐕"
        case .cat: return "🐈"
        case .bird: return "🐦"
        case .rabbit: return "🐇"
        case .other: return "🐾"
        }
    }
}

enum ReportStatus: String, Codable {
    case pending = "pending"
    case assigned = "assigned"
    case rescued = "rescued"
    case inVeterinary = "in_veterinary"
    case recovered = "recovered"
    case adopted = "adopted"
    case closed = "closed"
    
    var displayName: String {
        switch self {
        case .pending: return "Pendiente"
        case .assigned: return "Asignado"
        case .rescued: return "Rescatado"
        case .inVeterinary: return "En Veterinaria"
        case .recovered: return "Recuperado"
        case .adopted: return "Adoptado"
        case .closed: return "Cerrado"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .assigned: return "blue"
        case .rescued: return "green"
        case .inVeterinary: return "purple"
        case .recovered: return "teal"
        case .adopted: return "pink"
        case .closed: return "gray"
        }
    }
}

// MARK: - Supporting Structures
struct ReportLocation: Codable {
    let type: String
    let coordinates: [Double] // [longitude, latitude]
    
    var latitude: Double? {
        coordinates.count > 1 ? coordinates[1] : nil
    }
    
    var longitude: Double? {
        coordinates.count > 0 ? coordinates[0] : nil
    }
}

struct ReporterInfo: Codable {
    let id: String
    let name: String
    let email: String
    let phone: String?
    let profilePhotoUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case phone
        case profilePhotoUrl
    }
}

struct OrganizationInfo: Codable {
    let id: String
    let name: String
    let email: String?
    let phone: String?
    let organizationDetails: OrganizationDetailsSimple?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case phone
        case organizationDetails
    }
}

struct OrganizationDetailsSimple: Codable {
    let organizationName: String?
}

struct VeterinaryInfo: Codable {
    let id: String
    let name: String
    let email: String?
    let phone: String?
    let veterinaryDetails: VeterinaryDetailsSimple?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case phone
        case veterinaryDetails
    }
}

struct VeterinaryDetailsSimple: Codable {
    let clinicName: String?
}

// Response de lista de reportes (coincide con tu backend)
struct ReportListResponse: Codable {
    let success: Bool
    let data: [Report]
    let pagination: Pagination
}



