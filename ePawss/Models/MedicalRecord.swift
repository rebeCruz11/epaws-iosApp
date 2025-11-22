//
//  MedicalRecord.swift
//  ePaw
//

import Foundation

// MARK: - Medical Record
struct MedicalRecord: Codable, Identifiable {
    let id: String
    let animalId: String?
    let reportId: String?
    let veterinaryId: String?
    let visitType: MedicalVisitType
    let diagnosis: String
    let treatment: String
    let medications: [Medication]
    let notes: String?
    let status: MedicalRecordStatus
    let estimatedCost: Double?
    let actualCost: Double?
    let photoUrls: [String]
    let visitDate: String
    let nextAppointment: String?
    let createdAt: String
    let updatedAt: String
    
    // Populated fields
    var animalDetails: MedicalAnimalDetails?
    var veterinaryDetails: MedicalVeterinaryDetails?
    var reportDetails: MedicalReportDetails?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case animalId, reportId, veterinaryId
        case visitType, diagnosis, treatment, medications
        case notes, status
        case estimatedCost, actualCost
        case photoUrls, visitDate, nextAppointment
        case createdAt, updatedAt
        case animalDetails, veterinaryDetails, reportDetails
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        visitType = try container.decode(MedicalVisitType.self, forKey: .visitType)
        diagnosis = try container.decode(String.self, forKey: .diagnosis)
        treatment = try container.decode(String.self, forKey: .treatment)
        medications = try container.decode([Medication].self, forKey: .medications)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        status = try container.decode(MedicalRecordStatus.self, forKey: .status)
        estimatedCost = try container.decodeIfPresent(Double.self, forKey: .estimatedCost)
        actualCost = try container.decodeIfPresent(Double.self, forKey: .actualCost)
        photoUrls = try container.decode([String].self, forKey: .photoUrls)
        visitDate = try container.decode(String.self, forKey: .visitDate)
        nextAppointment = try container.decodeIfPresent(String.self, forKey: .nextAppointment)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        
        // Decode IDs
        animalId = try? container.decode(String.self, forKey: .animalId)
        reportId = try? container.decode(String.self, forKey: .reportId)
        veterinaryId = try? container.decode(String.self, forKey: .veterinaryId)
        
        // Decode populated fields
        animalDetails = try? container.decode(MedicalAnimalDetails.self, forKey: .animalId)
        veterinaryDetails = try? container.decode(MedicalVeterinaryDetails.self, forKey: .veterinaryId)
        reportDetails = try? container.decode(MedicalReportDetails.self, forKey: .reportId)
    }
}

// MARK: - Medication
struct Medication: Codable, Identifiable {
    var id = UUID()
    let name: String
    let dosage: String
    let frequency: String
    let duration: String
    
    enum CodingKeys: String, CodingKey {
        case name, dosage, frequency, duration
    }
}

// MARK: - Visit Type
enum MedicalVisitType: String, Codable, CaseIterable {
    case initialExam = "initial_exam"
    case followUp = "follow_up"
    case emergency = "emergency"
    case vaccination = "vaccination"
    case surgery = "surgery"
    case checkup = "checkup"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .initialExam: return "Examen Inicial"
        case .followUp: return "Seguimiento"
        case .emergency: return "Emergencia"
        case .vaccination: return "Vacunación"
        case .surgery: return "Cirugía"
        case .checkup: return "Chequeo"
        case .other: return "Otro"
        }
    }
    
    var icon: String {
        switch self {
        case .initialExam: return "stethoscope"
        case .followUp: return "arrow.clockwise"
        case .emergency: return "cross.case.fill"
        case .vaccination: return "syringe"
        case .surgery: return "bandage"
        case .checkup: return "checklist"
        case .other: return "doc.text"
        }
    }
}

// MARK: - Medical Record Status
enum MedicalRecordStatus: String, Codable {
    case scheduled = "scheduled"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .scheduled: return "Programada"
        case .inProgress: return "En Progreso"
        case .completed: return "Completada"
        case .cancelled: return "Cancelada"
        }
    }
    
    var color: String {
        switch self {
        case .scheduled: return "blue"
        case .inProgress: return "orange"
        case .completed: return "green"
        case .cancelled: return "gray"
        }
    }
}

// MARK: - Populated Details
struct MedicalAnimalDetails: Codable {
    let id: String
    let name: String
    let species: String
    let breed: String?
    let photoUrls: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, species, breed, photoUrls
    }
}

struct MedicalVeterinaryDetails: Codable {
    let id: String
    let name: String
    let email: String
    let phone: String?
    let veterinaryDetails: VeterinaryInfo?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, email, phone, veterinaryDetails
    }
}

struct VeterinaryInfo: Codable {
    let clinicName: String?
    let licenseNumber: String?
    let specialties: [String]
}

struct MedicalReportDetails: Codable {
    let id: String
    let description: String
    let urgencyLevel: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case description, urgencyLevel, status
    }
}
