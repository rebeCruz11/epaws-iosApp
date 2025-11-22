//
//  Endpoints.swift
//  ePaw
//
//  Created by ESTUDIANTE on 25/10/25.
//

import Foundation

struct Endpoints {
    // Auth
    static let register = "/api/auth/register"
    static let login = "/api/auth/login"
    static let getMe = "/api/auth/me"
    static let updateProfile = "/api/auth/profile"
    static let changePassword = "/api/auth/change-password"
    
    // Usuarios (si tienes más endpoints)
    static let users = "/api/users"
    static func user(id: String) -> String { "/api/users/\(id)" }
    
    // Animales (ejemplo - ajusta según tu API)
    static let animals = "/api/animals"
    static func animal(id: String) -> String { "/api/animals/\(id)" }
    
    // Adopciones (ejemplo)
    static let adoptions = "/api/adoptions"
    static func adoption(id: String) -> String { "/api/adoptions/\(id)" }
    
    static let reports = "/api/reports"
        static let reportsNearby = "/api/reports/nearby"
        static let myReports = "/api/reports/my-reports"
        static let organizationReports = "/api/reports/organization/assigned"
    static let veterinaryReports = "/api/reports/veterinary/assigned"  // ✅ NUEVO

        
        static func reportDetail(id: String) -> String {
            return "/api/reports/\(id)"
        }
        
        // Veterinarias
        static let veterinaries = "/api/veterinaries"
        static let veterinariesNearby = "/api/veterinaries/nearby"
        static let veterinariesSearch = "/api/veterinaries/search"
        
        static func veterinaryDetail(id: String) -> String {
            return "/api/veterinaries/\(id)"
        }
}
