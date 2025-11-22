//
//  AuthService.swift
//  ePaw
//
//  Created by ESTUDIANTE on 25/10/25.
//

import Foundation

class AuthService {
    private let api = APIService.shared

    func registerUser(
        email: String,
        password: String,
        name: String,
        phone: String? = nil,
        address: String? = nil
    ) async throws -> AuthResponse {
        let requestBody = RegisterRequest(
            email: email,
            password: password,
            name: name,
            role: "user",
            phone: phone,
            address: address,
            organizationName: nil,
            description: nil,
            website: nil,
            capacity: nil,
            logoUrl: nil,
            clinicName: nil,
            licenseNumber: nil,
            specialties: nil,
            latitude: nil,
            longitude: nil,
            locationAddress: nil,
            businessHours: nil,
            profilePhotoUrl: nil
        )
        return try await executeRegister(requestBody)
    }

    func registerOrganization(
        email: String,
        password: String,
        name: String,
        organizationName: String,
        description: String? = nil,
        website: String? = nil,
        capacity: Int? = nil,
        phone: String? = nil,
        address: String? = nil
    ) async throws -> AuthResponse {
        let requestBody = RegisterRequest(
            email: email,
            password: password,
            name: name,
            role: "organization",
            phone: phone,
            address: address,
            organizationName: organizationName,
            description: description,
            website: website,
            capacity: capacity,
            logoUrl: nil,
            clinicName: nil,
            licenseNumber: nil,
            specialties: nil,
            latitude: nil,
            longitude: nil,
            locationAddress: nil,
            businessHours: nil,
            profilePhotoUrl: nil
        )
        return try await executeRegister(requestBody)
    }

    func registerVeterinary(
        email: String,
        password: String,
        name: String,
        clinicName: String,
        licenseNumber: String,
        specialties: [String]? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        locationAddress: String? = nil,
        businessHours: String? = nil,
        phone: String? = nil,
        address: String? = nil
    ) async throws -> AuthResponse {
        let requestBody = RegisterRequest(
            email: email,
            password: password,
            name: name,
            role: "veterinary",
            phone: phone,
            address: address,
            organizationName: nil,
            description: nil,
            website: nil,
            capacity: nil,
            logoUrl: nil,
            clinicName: clinicName,
            licenseNumber: licenseNumber,
            specialties: specialties,
            latitude: latitude,
            longitude: longitude,
            locationAddress: locationAddress,
            businessHours: businessHours,
            profilePhotoUrl: nil
        )
        return try await executeRegister(requestBody)
    }

    private func executeRegister(_ requestBody: RegisterRequest) async throws -> AuthResponse {
        let encoder = JSONEncoder()
        let body = try encoder.encode(requestBody)
        let response = try await api.request(
            endpoint: Endpoints.register,
            method: .POST,
            body: body,
            responseType: APIResponse<AuthResponse>.self
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        TokenManager.shared.saveToken(data.token)
        return data
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let requestBody = LoginRequest(email: email, password: password)
        let encoder = JSONEncoder()
        let body = try encoder.encode(requestBody)
        let response = try await api.request(
            endpoint: Endpoints.login,
            method: .POST,
            body: body,
            responseType: APIResponse<AuthResponse>.self
        )
        guard let data = response.data else {
            throw APIError.invalidResponse
        }
        TokenManager.shared.saveToken(data.token)
        return data
    }

    func getMe() async throws -> User {
        let response = try await api.request(
            endpoint: Endpoints.getMe,
            method: .GET,
            responseType: APIResponse<User>.self
        )
        guard let user = response.data else {
            throw APIError.invalidResponse
        }
        return user
    }

    func updateProfile(
        name: String? = nil,
        phone: String? = nil,
        address: String? = nil,
        profilePhotoUrl: String? = nil,
        // Organización
        organizationName: String? = nil,
        description: String? = nil,
        website: String? = nil,
        logoUrl: String? = nil,
        capacity: Int? = nil,
        facebook: String? = nil,
        instagram: String? = nil,
        twitter: String? = nil,
        // Veterinaria
        clinicName: String? = nil,
        licenseNumber: String? = nil,
        specialties: [String]? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        locationAddress: String? = nil,
        businessHours: String? = nil
    ) async throws -> User {

        let requestBody = UpdateProfileRequest(
            name: name,
            phone: phone,
            address: address,
            profilePhotoUrl: profilePhotoUrl,
            organizationName: organizationName,
            description: description,
            website: website,
            logoUrl: logoUrl,
            capacity: capacity,
            facebook: facebook,
            instagram: instagram,
            twitter: twitter,
            clinicName: clinicName,
            licenseNumber: licenseNumber,
            specialties: specialties,
            latitude: latitude,
            longitude: longitude,
            locationAddress: locationAddress,
            businessHours: businessHours
        )

        let encoder = JSONEncoder()
        let body = try encoder.encode(requestBody)
        let response = try await api.request(
            endpoint: Endpoints.updateProfile,
            method: .PUT,
            body: body,
            responseType: APIResponse<User>.self
        )
        guard let user = response.data else {
            throw APIError.invalidResponse
        }
        return user
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {
        let requestBody = ChangePasswordRequest(
            currentPassword: currentPassword,
            newPassword: newPassword
        )
        let encoder = JSONEncoder()
        let body = try encoder.encode(requestBody)
        let _ = try await api.request(
            endpoint: Endpoints.changePassword,
            method: .PUT,
            body: body,
            responseType: APIResponse<String>.self
        )
    }

    func logout() {
        TokenManager.shared.deleteToken()
    }
}

