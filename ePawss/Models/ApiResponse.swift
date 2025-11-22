//
//  ApiResponse.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//
import Foundation

struct ApiResponse<T: Codable>: Codable {
    let success: Bool
    let data: T
    let message: String?
}

