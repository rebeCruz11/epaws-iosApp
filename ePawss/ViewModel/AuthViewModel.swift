//
//  AuthViewModel.swift
//  ePaw
//
//  Created by ESTUDIANTE on 25/10/25.
//

import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    private let authService = AuthService()
    
    init() {
        checkAuthStatus()
    }
    
    // MARK: - Check Auth Status
    func checkAuthStatus() {
        if TokenManager.shared.isLoggedIn() {
            isAuthenticated = true
            Task {
                await fetchCurrentUser()
            }
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authService.login(email: email, password: password)
            currentUser = response.user
            isAuthenticated = true
            isLoading = false
            return true
            
        } catch let error as APIError {
            handleError(error)
            isLoading = false
            return false
        } catch {
            errorMessage = "Error inesperado: \(error.localizedDescription)"
            showError = true
            isLoading = false
            return false
        }
    }
    
    // MARK: - Register User
    func registerUser(
        email: String,
        password: String,
        name: String,
        phone: String? = nil,
        address: String? = nil
    ) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authService.registerUser(
                email: email,
                password: password,
                name: name,
                phone: phone,
                address: address
            )
            currentUser = response.user
            isAuthenticated = true
            isLoading = false
            return true
            
        } catch let error as APIError {
            handleError(error)
            isLoading = false
            return false
        } catch {
            errorMessage = "Error al registrar: \(error.localizedDescription)"
            showError = true
            isLoading = false
            return false
        }
    }
    
    // MARK: - Register Organization
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
    ) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authService.registerOrganization(
                email: email,
                password: password,
                name: name,
                organizationName: organizationName,
                description: description,
                website: website,
                capacity: capacity,
                phone: phone,
                address: address
            )
            currentUser = response.user
            isAuthenticated = true
            isLoading = false
            return true
            
        } catch let error as APIError {
            handleError(error)
            isLoading = false
            return false
        } catch {
            errorMessage = "Error al registrar organización: \(error.localizedDescription)"
            showError = true
            isLoading = false
            return false
        }
    }
    
    // MARK: - Register Veterinary
    func registerVeterinary(
        email: String,
        password: String,
        name: String,
        clinicName: String,
        licenseNumber: String,
        specialties: [String]? = nil,
        businessHours: String? = nil,
        phone: String? = nil,
        address: String? = nil
    ) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authService.registerVeterinary(
                email: email,
                password: password,
                name: name,
                clinicName: clinicName,
                licenseNumber: licenseNumber,
                specialties: specialties,
                latitude: nil,
                longitude: nil,
                locationAddress: address,
                businessHours: businessHours,
                phone: phone,
                address: address
            )
            currentUser = response.user
            isAuthenticated = true
            isLoading = false
            return true
            
        } catch let error as APIError {
            handleError(error)
            isLoading = false
            return false
        } catch {
            errorMessage = "Error al registrar veterinaria: \(error.localizedDescription)"
            showError = true
            isLoading = false
            return false
        }
    }
    
    // MARK: - Fetch Current User
    func fetchCurrentUser() async {
        do {
            currentUser = try await authService.getMe()
        } catch {
            logout()
        }
    }
    
    // MARK: - Logout
    func logout() {
        authService.logout()
        currentUser = nil
        isAuthenticated = false
    }
    
    // MARK: - Change Password
    func changePassword(current: String, new: String) async -> Bool {
        isLoading = true
        
        do {
            try await authService.changePassword(
                currentPassword: current,
                newPassword: new
            )
            isLoading = false
            return true
            
        } catch {
            errorMessage = "Error al cambiar contraseña: \(error.localizedDescription)"
            showError = true
            isLoading = false
            return false
        }
    }
    
    // MARK: - Error Handler
    private func handleError(_ error: APIError) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

