//
//  Veterinary.swift
//  ePaw
//
//  Created by ESTUDIANTE on 07/11/25.
//

import Foundation

// Modelo simplificado de veterinaria para listados
struct VeterinaryListItem: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let phone: String?
    let address: String?
    let profilePhotoUrl: String?
    let veterinaryDetails: VeterinaryDetails?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phone
        case address
        case profilePhotoUrl
        case veterinaryDetails
    }
}

// Respuesta paginada de veterinarias
struct VeterinaryListResponse: Codable {
    let veterinaries: [VeterinaryListItem]
    let pagination: Pagination
    
    enum CodingKeys: String, CodingKey {
        case veterinaries = "data"
        case pagination
    }
}


// Para respuesta de una sola veterinaria
struct VeterinaryResponse: Codable {
    let veterinary: User
    
    enum CodingKeys: String, CodingKey {
        case veterinary = "data"
    }
}
