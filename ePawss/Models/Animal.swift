//
//  Animal.swift
//  ePaw
//

import Foundation

struct Animal: Codable, Identifiable {
    let id: String
    let reportId: String?
    let organizationId: String?
    let name: String
    let species: Species
    let breed: String?
    let gender: Gender
    let ageEstimate: String?
    let size: Size
    let color: String?
    let story: String?
    let personalityTraits: [String]?
    let specialNeeds: String?
    let photoUrls: [String]
    let videoUrl: String?
    let status: Status
    let healthInfo: HealthInfo?
    let adoptedAt: String?
    let isDeleted: Bool?
    let createdAt: String?
    let updatedAt: String?
    
    // Populated fields (cuando vienen como objetos)
    var reportDetails: ReportReference?
    var organizationDetails: OrganizationReference?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case reportId  // ✅ Solo una vez
        case organizationId  // ✅ Solo una vez
        case name, species, breed, gender
        case ageEstimate, size, color, story
        case personalityTraits, specialNeeds
        case photoUrls, videoUrl, status
        case healthInfo, adoptedAt, isDeleted
        case createdAt, updatedAt
        case reportDetails  // ✅ Campo separado para cuando viene populated
        case organizationDetails  // ✅ Campo separado para cuando viene populated
    }
    
    // ✅ Custom decoder para manejar ambos casos
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        species = try container.decode(Species.self, forKey: .species)
        breed = try container.decodeIfPresent(String.self, forKey: .breed)
        gender = try container.decode(Gender.self, forKey: .gender)
        ageEstimate = try container.decodeIfPresent(String.self, forKey: .ageEstimate)
        size = try container.decode(Size.self, forKey: .size)
        color = try container.decodeIfPresent(String.self, forKey: .color)
        story = try container.decodeIfPresent(String.self, forKey: .story)
        personalityTraits = try container.decodeIfPresent([String].self, forKey: .personalityTraits)
        specialNeeds = try container.decodeIfPresent(String.self, forKey: .specialNeeds)
        photoUrls = try container.decode([String].self, forKey: .photoUrls)
        videoUrl = try container.decodeIfPresent(String.self, forKey: .videoUrl)
        status = try container.decode(Status.self, forKey: .status)
        healthInfo = try container.decodeIfPresent(HealthInfo.self, forKey: .healthInfo)
        adoptedAt = try container.decodeIfPresent(String.self, forKey: .adoptedAt)
        isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        
        // Intentar decodificar como String (ID simple)
        reportId = try? container.decode(String.self, forKey: .reportId)
        organizationId = try? container.decode(String.self, forKey: .organizationId)
        
        // Intentar decodificar como objeto (populated)
        reportDetails = try? container.decode(ReportReference.self, forKey: .reportId)
        organizationDetails = try? container.decode(OrganizationReference.self, forKey: .organizationId)
    }

    // MARK: - Species
    enum Species: String, Codable, CaseIterable {
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
            case .rabbit: return "🐰"
            case .other: return "🐾"
            }
        }
    }

    // MARK: - Gender
    enum Gender: String, Codable {
        case male = "male"
        case female = "female"
        case unknown = "unknown"
        
        var displayName: String {
            switch self {
            case .male: return "Macho"
            case .female: return "Hembra"
            case .unknown: return "Desconocido"
            }
        }
    }

    // MARK: - Size
    enum Size: String, Codable {
        case small = "small"
        case medium = "medium"
        case large = "large"
        
        var displayName: String {
            switch self {
            case .small: return "Pequeño"
            case .medium: return "Mediano"
            case .large: return "Grande"
            }
        }
    }

    // MARK: - Status
    enum Status: String, Codable {
        case available = "available"
        case pendingAdoption = "pending_adoption"
        case adopted = "adopted"
        case deceased = "deceased"
        
        var displayName: String {
            switch self {
            case .available: return "Disponible"
            case .pendingAdoption: return "Adopción Pendiente"
            case .adopted: return "Adoptado"
            case .deceased: return "Fallecido"
            }
        }
        
        var color: String {
            switch self {
            case .available: return "green"
            case .pendingAdoption: return "orange"
            case .adopted: return "blue"
            case .deceased: return "gray"
            }
        }
    }

    // MARK: - Health Info
    struct HealthInfo: Codable {
        let isVaccinated: Bool
        let isSterilized: Bool
        let isDewormed: Bool
        let medicalNotes: String?
    }

    // MARK: - Report Reference
    struct ReportReference: Codable {
        let id: String
        let locationAddress: String?
        let urgencyLevel: String?
        let description: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case locationAddress, urgencyLevel, description
        }
    }

    // MARK: - Organization Reference
    struct OrganizationReference: Codable {
        let id: String
        let name: String?
        let email: String?
        let phone: String?
        let organizationDetails: OrganizationDetails?
        
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name, email, phone, organizationDetails
        }
    }

    // MARK: - Organization Details
    struct OrganizationDetails: Codable {
        let organizationName: String?
        let logoUrl: String?
        let description: String?
        let website: String?
    }
}
