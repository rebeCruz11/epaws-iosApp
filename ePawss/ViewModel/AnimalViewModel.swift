//
//  AnimalViewModel.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//

import Foundation

@MainActor
class AnimalViewModel: ObservableObject {
    @Published var animals: [Animal] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let animalService = AnimalService()

    func fetchAnimals() async {
        isLoading = true
        do {
            let response = try await animalService.fetchAnimals()
            animals = response.data
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

