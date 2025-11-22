//
//  MedicalRecordService.swift
//  ePaw
//

import Foundation

class MedicalRecordService {
    private let api = APIService.shared
    
    // MARK: - Create Medical Record
    func createMedicalRecord(
        animalId: String?,
        reportId: String?,
        visitType: MedicalVisitType,
        diagnosis: String,
        treatment: String,
        medications: [Medication],
        notes: String?,
        estimatedCost: Double?,
        photoUrls: [String],
        visitDate: Date,
        nextAppointment: Date?
    ) async throws -> MedicalRecord {
        // Convert medications to dictionary format
        let medicationsDict = medications.map { medication in
            return [
                "name": medication.name,
                "dosage": medication.dosage,
                "frequency": medication.frequency,
                "duration": medication.duration
            ]
        }
        
        // Format dates
        let dateFormatter = ISO8601DateFormatter()
        let visitDateString = dateFormatter.string(from: visitDate)
        let nextAppointmentString = nextAppointment != nil ? dateFormatter.string(from: nextAppointment!) : nil
        
        print("🔵 [MedicalRecordService] Creando registro médico")
        
        return try await withCheckedThrowingContinuation { continuation in
            api.createMedicalRecord(
                animalId: animalId,
                reportId: reportId,
                visitType: visitType.rawValue,
                diagnosis: diagnosis,
                treatment: treatment,
                medications: medicationsDict,
                notes: notes,
                estimatedCost: estimatedCost,
                photoUrls: photoUrls,
                visitDate: visitDateString,
                nextAppointment: nextAppointmentString
            ) { result in
                switch result {
                case .success(let record):
                    print("🟢 [MedicalRecordService] Registro creado: \(record.id)")
                    continuation.resume(returning: record)
                case .failure(let error):
                    print("🔴 [MedicalRecordService] Error: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Get Animal Medical History
    func getAnimalMedicalHistory(animalId: String) async throws -> [MedicalRecord] {
        print("🔵 [MedicalRecordService] Obteniendo historial médico del animal: \(animalId)")
        
        return try await withCheckedThrowingContinuation { continuation in
            api.fetchAnimalMedicalHistory(animalId: animalId) { result in
                switch result {
                case .success(let records):
                    print("🟢 [MedicalRecordService] \(records.count) registros obtenidos")
                    continuation.resume(returning: records)
                case .failure(let error):
                    print("🔴 [MedicalRecordService] Error: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Get Veterinary Cases
    func getVeterinaryCases(status: MedicalRecordStatus? = nil, page: Int = 1) async throws -> [MedicalRecord] {
        print("🔵 [MedicalRecordService] Obteniendo casos de la veterinaria")
        
        return try await withCheckedThrowingContinuation { continuation in
            api.fetchVeterinaryCases(status: status?.rawValue, page: page) { result in
                switch result {
                case .success(let records):
                    print("🟢 [MedicalRecordService] \(records.count) casos obtenidos")
                    continuation.resume(returning: records)
                case .failure(let error):
                    print("🔴 [MedicalRecordService] Error: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Update Medical Record
    func updateMedicalRecord(
        recordId: String,
        status: MedicalRecordStatus? = nil,
        actualCost: Double? = nil,
        notes: String? = nil
    ) async throws -> MedicalRecord {
        print("🔵 [MedicalRecordService] Actualizando registro: \(recordId)")
        
        return try await withCheckedThrowingContinuation { continuation in
            api.updateMedicalRecord(
                recordId: recordId,
                status: status?.rawValue,
                actualCost: actualCost,
                notes: notes
            ) { result in
                switch result {
                case .success(let record):
                    print("🟢 [MedicalRecordService] Registro actualizado")
                    continuation.resume(returning: record)
                case .failure(let error):
                    print("🔴 [MedicalRecordService] Error: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
