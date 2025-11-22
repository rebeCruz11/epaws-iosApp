//
//  APIService.swift
//  ePaw
//

import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "https://epaws-api.onrender.com"
    
    private init() {}
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
            
            // 🐛 DEBUG: Ver qué estamos enviando
            if let jsonString = String(data: body, encoding: .utf8) {
                print("📤 REQUEST to \(endpoint):")
                print(jsonString)
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 🐛 DEBUG: Ver qué recibimos
        print("📥 RESPONSE from \(endpoint):")
        print("Status Code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Body: \(jsonString)")
        } else {
            print("Body: [No data or invalid encoding]")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        // 🐛 DEBUG: Intentar decodificar
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decoded = try decoder.decode(T.self, from: data)
            print("✅ Decodificación exitosa")
            return decoded
        } catch {
            print("❌ Error al decodificar: \(error)")
            throw APIError.decodingError(error)
        }
    }
    // Core/Network/APIService.swift
    func fetchOrganizationStats(organizationId: String, completion: @escaping (Result<OrganizationStatsData, APIError>) -> Void) {
            let endpoint = "/api/organizations/\(organizationId)/stats"
            guard let url = URL(string: "\(baseURL)\(endpoint)") else {
                completion(.failure(.invalidURL))
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            if let token = TokenManager.shared.getToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(.custom(error.localizedDescription)))
                    return
                }
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }

                print(String(data: data, encoding: .utf8) ?? "no json") // Debug directo

                do {
                    let decoded = try JSONDecoder().decode(OrganizationStatsResponse.self, from: data)
                    completion(.success(decoded.data))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            }.resume()
        }
    
    func fetchOrganizationAssignedReports(page: Int = 1, completion: @escaping (Result<OrganizationReportListResponse, APIError>) -> Void) {
           let endpoint = "/api/reports/organization/assigned?page=\(page)&limit=20"
           guard let url = URL(string: "\(baseURL)\(endpoint)") else {
               completion(.failure(.invalidURL))
               return
           }
           var request = URLRequest(url: url)
           request.httpMethod = "GET"
           if let token = TokenManager.shared.getToken() {
               request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
           }
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           URLSession.shared.dataTask(with: request) { data, _, error in
               if let error = error {
                   completion(.failure(.custom(error.localizedDescription)))
                   return
               }
               guard let data = data else {
                   completion(.failure(.noData))
                   return
               }
               do {
                   let decoded = try JSONDecoder().decode(OrganizationReportListResponse.self, from: data)
                   completion(.success(decoded))
               } catch {
                   completion(.failure(.decodingError(error)))
               }
           }.resume()
       }
    func fetchOrganizationAssignedReportsConFiltro(status: String, page: Int = 1, completion: @escaping (Result<OrganizationReportListResponse, APIError>) -> Void) {
        let endpoint = "/api/reports/organization/assigned?page=\(page)&limit=20&status=\(status)"
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(.custom(error.localizedDescription)))
                return
            }
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            do {
                let decoded = try JSONDecoder().decode(OrganizationReportListResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    func fetchReportDetail(reportId: String, completion: @escaping (Result<ReportDetail, APIError>) -> Void) {
            let endpoint = "/api/reports/\(reportId)"
            guard let url = URL(string: "\(baseURL)\(endpoint)") else {
                completion(.failure(.invalidURL))
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            if let token = TokenManager.shared.getToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(.custom(error.localizedDescription)))
                    return
                }
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(ReportDetailResponse.self, from: data)
                    completion(.success(decoded.data))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            }.resume()
        }
    
    func updateReportStatus(reportId: String, status: String, notes: String?, completion: @escaping (Result<Void, APIError>) -> Void) {
            let endpoint = "/api/reports/\(reportId)"
            guard let url = URL(string: "\(baseURL)\(endpoint)") else {
                completion(.failure(.invalidURL))
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            var bodyDict: [String: Any] = ["status": status]
            if let notes = notes { bodyDict["notes"] = notes }
            request.httpBody = try? JSONSerialization.data(withJSONObject: bodyDict)

            if let token = TokenManager.shared.getToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            URLSession.shared.dataTask(with: request) { _, resp, error in
                if let error = error {
                    completion(.failure(.custom(error.localizedDescription)))
                    return
                }
                // Puedes chequear statusCode si deseas
                completion(.success(()))
            }.resume()
        }
    
    // MARK: - Adoption Endpoints for Organizations
    
    /// Obtener solicitudes de adopción para un animal específico
    func fetchAdoptionsForAnimal(animalId: String, completion: @escaping (Result<[Adoption], APIError>) -> Void) {
        let endpoint = "/api/adoptions/animal/\(animalId)"
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(.custom(error.localizedDescription)))
                return
            }
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(APIResponse<[Adoption]>.self, from: data)
                completion(.success(response.data ?? []))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    /// Obtener solicitudes de adopción de la organización
    func fetchOrganizationAdoptions(organizationId: String, status: String? = nil, page: Int = 1, completion: @escaping (Result<[Adoption], APIError>) -> Void) {
        var endpoint = "/api/adoptions/organization/\(organizationId)?page=\(page)&limit=20"
        if let status = status {
            endpoint += "&status=\(status)"
        }
        
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(.custom(error.localizedDescription)))
                return
            }
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(APIResponse<[Adoption]>.self, from: data)
                completion(.success(response.data ?? []))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    /// Actualizar estado de adopción (aprobar/rechazar/completar)
    func updateAdoptionStatus(adoptionId: String, status: String, reviewNotes: String?, rejectionReason: String?, completion: @escaping (Result<Adoption, APIError>) -> Void) {
        let endpoint = "/api/adoptions/\(adoptionId)/status"
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var bodyDict: [String: Any] = ["status": status]
        if let reviewNotes = reviewNotes { bodyDict["reviewNotes"] = reviewNotes }
        if let rejectionReason = rejectionReason { bodyDict["rejectionReason"] = rejectionReason }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyDict)
        
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, resp, error in
            if let error = error {
                completion(.failure(.custom(error.localizedDescription)))
                return
            }
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(APIResponse<Adoption>.self, from: data)
                if let adoption = response.data {
                    completion(.success(adoption))
                } else {
                    completion(.failure(.custom(response.message ?? "Error desconocido")))
                }
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // MARK: - Medical Records Endpoints
    
    /// Crear registro médico
    func createMedicalRecord(
        animalId: String?,
        reportId: String?,
        visitType: String,
        diagnosis: String,
        treatment: String,
        medications: [[String: String]],
        notes: String?,
        estimatedCost: Double?,
        photoUrls: [String],
        visitDate: String,
        nextAppointment: String?,
        completion: @escaping (Result<MedicalRecord, APIError>) -> Void
    ) {
        let endpoint = "/api/medical-records"
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var bodyDict: [String: Any] = [
            "visitType": visitType,
            "diagnosis": diagnosis,
            "treatment": treatment,
            "medications": medications,
            "photoUrls": photoUrls,
            "visitDate": visitDate
        ]
        
        if let animalId = animalId { bodyDict["animalId"] = animalId }
        if let reportId = reportId { bodyDict["reportId"] = reportId }
        if let notes = notes { bodyDict["notes"] = notes }
        if let estimatedCost = estimatedCost { bodyDict["estimatedCost"] = estimatedCost }
        if let nextAppointment = nextAppointment { bodyDict["nextAppointment"] = nextAppointment }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyDict)
        
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(.custom(error.localizedDescription)))
                return
            }
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(APIResponse<MedicalRecord>.self, from: data)
                if let record = response.data {
                    completion(.success(record))
                } else {
                    completion(.failure(.custom(response.message ?? "Error al crear registro")))
                }
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    /// Obtener historial médico de un animal
    func fetchAnimalMedicalHistory(animalId: String, completion: @escaping (Result<[MedicalRecord], APIError>) -> Void) {
        let endpoint = "/api/medical-records/animal/\(animalId)"
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(.custom(error.localizedDescription)))
                return
            }
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(APIResponse<[MedicalRecord]>.self, from: data)
                completion(.success(response.data ?? []))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    /// Obtener casos de la veterinaria
    func fetchVeterinaryCases(status: String? = nil, page: Int = 1, completion: @escaping (Result<[MedicalRecord], APIError>) -> Void) {
        var endpoint = "/api/medical-records/my-cases?page=\(page)&limit=20"
        if let status = status {
            endpoint += "&status=\(status)"
        }
        
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(.custom(error.localizedDescription)))
                return
            }
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(APIResponse<[MedicalRecord]>.self, from: data)
                completion(.success(response.data ?? []))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    /// Actualizar registro médico
    func updateMedicalRecord(
        recordId: String,
        status: String?,
        actualCost: Double?,
        notes: String?,
        completion: @escaping (Result<MedicalRecord, APIError>) -> Void
    ) {
        let endpoint = "/api/medical-records/\(recordId)"
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var bodyDict: [String: Any] = [:]
        if let status = status { bodyDict["status"] = status }
        if let actualCost = actualCost { bodyDict["actualCost"] = actualCost }
        if let notes = notes { bodyDict["notes"] = notes }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyDict)
        
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(.custom(error.localizedDescription)))
                return
            }
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(APIResponse<MedicalRecord>.self, from: data)
                if let record = response.data {
                    completion(.success(record))
                } else {
                    completion(.failure(.custom(response.message ?? "Error al actualizar")))
                }
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }

}

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, PATCH
}
