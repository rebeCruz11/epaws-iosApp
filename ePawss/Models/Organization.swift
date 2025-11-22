//
//  Organization.swift
//  ePaw
//
//  Created by ESTUDIANTE on 08/11/25.
//

import Foundation

struct Organization: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let organizationDetails: OrgDetails?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case organizationDetails
    }
    
    var displayName: String {
        organizationDetails?.organizationName ?? name
    }
}

struct OrgDetails: Codable, Hashable {
    let organizationName: String?
}
