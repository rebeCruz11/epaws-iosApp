//
//  TokenManager.swift
//  ePaw
//
//  Created by ESTUDIANTE on 25/10/25.
//

import Foundation

class TokenManager {
    static let shared = TokenManager()
    
    private let tokenKey = "authToken"
    private let userKey = "currentUser"
    
    private init() {}
    
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }
    
    func deleteToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
    }
    
    func isLoggedIn() -> Bool {
        return getToken() != nil
    }
}

