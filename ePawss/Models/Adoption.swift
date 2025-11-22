//
//  Adoption.swift
//  ePaw
//
//  Created by ESTUDIANTE on 14/11/25.
//

import Foundation

struct Adoption: Codable, Identifiable {
    let id: String
    let animalId: String?  // ✅ Ahora opcional
    let adopterId: String?  // ✅ Ahora opcional
    let organizationId: String?  // ✅ Ahora opcional
    let applicationMessage: String
    let adopterInfo: AdopterInfo
    let status: AdoptionStatus
    let reviewNotes: String?
    let rejectionReason: String?
    let appliedAt: String
    let reviewedAt: String?
    let completedAt: String?
    let createdAt: String
    let updatedAt: String
    
    // Populated fields (cuando vienen como objetos del backend)
    var animalDetails: AdoptionAnimalDetails?
    var adopterDetails: AdoptionUserDetails?
    var organizationDetails: AdoptionUserDetails?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case animalId  // ✅ Sin duplicar
        case adopterId  // ✅ Sin duplicar
        case organizationId  // ✅ Sin duplicar
        case applicationMessage, adopterInfo, status
        case reviewNotes, rejectionReason
        case appliedAt, reviewedAt, completedAt
        case createdAt, updatedAt
        case animalDetails  // ✅ Campo separado
        case adopterDetails  // ✅ Campo separado
        case organizationDetails  // ✅ Campo separado
    }
    
    // ✅ Custom decoder para manejar ambos casos
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        applicationMessage = try container.decode(String.self, forKey: .applicationMessage)
        adopterInfo = try container.decode(AdopterInfo.self, forKey: .adopterInfo)
        status = try container.decode(AdoptionStatus.self, forKey: .status)
        reviewNotes = try container.decodeIfPresent(String.self, forKey: .reviewNotes)
        rejectionReason = try container.decodeIfPresent(String.self, forKey: .rejectionReason)
        appliedAt = try container.decode(String.self, forKey: .appliedAt)
        reviewedAt = try container.decodeIfPresent(String.self, forKey: .reviewedAt)
        completedAt = try container.decodeIfPresent(String.self, forKey: .completedAt)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        
        // Intentar decodificar como String (ID simple)
        animalId = try? container.decode(String.self, forKey: .animalId)
        adopterId = try? container.decode(String.self, forKey: .adopterId)
        organizationId = try? container.decode(String.self, forKey: .organizationId)
        
        // Intentar decodificar como objeto completo (populated)
        animalDetails = try? container.decode(AdoptionAnimalDetails.self, forKey: .animalId)
        adopterDetails = try? container.decode(AdoptionUserDetails.self, forKey: .adopterId)
        organizationDetails = try? container.decode(AdoptionUserDetails.self, forKey: .organizationId)
    }
}

// MARK: - Adopter Info
struct AdopterInfo: Codable {
    let hasExperience: Bool
    let experienceDetails: String?
    let hasOtherPets: Bool
    let otherPetsDetails: String?
    let homeType: AdoptionHomeType
    let hasYard: Bool
    let householdMembers: Int
    let householdDetails: String?
    let workSchedule: String?
    let reasonForAdoption: String?
}

// MARK: - Home Type
enum AdoptionHomeType: String, Codable, CaseIterable {
    case house = "house"
    case apartment = "apartment"
    case farm = "farm"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .house: return "Casa"
        case .apartment: return "Apartamento"
        case .farm: return "Granja"
        case .other: return "Otro"
        }
    }
    
    var icon: String {
        switch self {
        case .house: return "🏠"
        case .apartment: return "🏢"
        case .farm: return "🚜"
        case .other: return "🏘️"
        }
    }
}

// MARK: - Adoption Status
enum AdoptionStatus: String, Codable {
    case pending = "pending"
    case underReview = "under_review"
    case approved = "approved"
    case rejected = "rejected"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending: return "Pendiente"
        case .underReview: return "En Revisión"
        case .approved: return "Aprobada"
        case .rejected: return "Rechazada"
        case .completed: return "Completada"
        case .cancelled: return "Cancelada"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .underReview: return "blue"
        case .approved: return "green"
        case .rejected: return "red"
        case .completed: return "purple"
        case .cancelled: return "gray"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .underReview: return "doc.text.magnifyingglass"
        case .approved: return "checkmark.circle"
        case .rejected: return "xmark.circle"
        case .completed: return "heart.circle"
        case .cancelled: return "xmark.octagon"
        }
    }
}

// MARK: - Animal Details (Populated)
struct AdoptionAnimalDetails: Codable {
    let id: String
    let name: String
    let species: String
    let breed: String?
    let photoUrls: [String]
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, species, breed, photoUrls, status
    }
}

// MARK: - User Details (Populated)
struct AdoptionUserDetails: Codable {
    let id: String
    let name: String
    let email: String
    let phone: String?
    let profilePhotoUrl: String?
    let organizationDetails: AdoptionOrgInfo?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, email, phone, profilePhotoUrl, organizationDetails
    }
}

// MARK: - Organization Info
struct AdoptionOrgInfo: Codable {
    let organizationName: String?
    let description: String?
    let logoUrl: String?
    let website: String?
    let capacity: Int?
    let currentAnimals: Int?
}
