//
//  AuthResponse.swift
//  ePaw
//
//  Created by ESTUDIANTE on 25/10/25.
//

import Foundation

// Respuesta genérica de la API
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
}

// Respuesta de Login/Register
struct AuthResponse: Codable {
    let token: String
    let user: User
}

// Request de Login
struct LoginRequest: Codable {
    let email: String
    let password: String
}

// Request de Register (campos en camelCase para tu backend)
struct RegisterRequest: Codable {
    let email: String
    let password: String
    let name: String
    let role: String?
    let phone: String?
    let address: String?
    // Organización
    let organizationName: String?
    let description: String?
    let website: String?
    let capacity: Int?
    let logoUrl: String?
    // Veterinaria
    let clinicName: String?
    let licenseNumber: String?
    let specialties: [String]?
    let latitude: Double?
    let longitude: Double?
    let locationAddress: String?
    let businessHours: String?
    // Perfil
    let profilePhotoUrl: String?
}

// Request de cambio de contraseña
struct ChangePasswordRequest: Codable {
    let currentPassword: String
    let newPassword: String
}

// Request para actualizar perfil (campos opcionales y en camelCase)
struct UpdateProfileRequest: Codable {
    let name: String?
    let phone: String?
    let address: String?
    let profilePhotoUrl: String?
    // Organización
    let organizationName: String?
    let description: String?
    let website: String?
    let logoUrl: String?
    let capacity: Int?
    let facebook: String?
    let instagram: String?
    let twitter: String?
    // Veterinaria
    let clinicName: String?
    let licenseNumber: String?
    let specialties: [String]?
    let latitude: Double?
    let longitude: Double?
    let locationAddress: String?
    let businessHours: String?
}

