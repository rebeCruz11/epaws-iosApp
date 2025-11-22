//
//  User.swift
//  ePaw
//
//  Created by ESTUDIANTE on 25/10/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let role: UserRole
    let verified: Bool
    let phone: String?
    let address: String?
    let profilePhotoUrl: String?
    let organizationDetails: OrganizationDetails?
    let veterinaryDetails: VeterinaryDetails?
    let isActive: Bool?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"  // ← CAMBIADO: Ya no es "_id"
        case email
        case name
        case role
        case verified
        case phone
        case address
        case profilePhotoUrl
        case organizationDetails
        case veterinaryDetails
        case isActive
        case createdAt
        case updatedAt
    }
}

enum UserRole: String, Codable {
    case user = "user"
    case organization = "organization"
    case veterinary = "veterinary"
}

struct OrganizationDetails: Codable {
    let organizationName: String?
    let description: String?
    let website: String?
    let socialMedia: SocialMedia?
    let logoUrl: String?
    let capacity: Int?
    let currentAnimals: Int?
    let totalRescues: Int?
}

struct SocialMedia: Codable {
    let facebook: String?
    let instagram: String?
    let twitter: String?
}

struct VeterinaryDetails: Codable {
    let clinicName: String?
    let licenseNumber: String?
    let specialties: [String]?
    let location: GeoLocation?
    let locationAddress: String?
    let businessHours: String?
    let totalCasesHandled: Int?
    let rating: Double?
}

struct GeoLocation: Codable {
    let type: String?
    let coordinates: [Double]? // [longitude, latitude]
}
