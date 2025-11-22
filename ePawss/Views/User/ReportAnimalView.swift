import SwiftUI
import CoreLocation

struct ReportData: Codable {
    let description: String
    let urgencyLevel: String
    let animalType: String
    let latitude: Double
    let longitude: Double
    let locationAddress: String?
    let photoUrls: [String]
}

struct IdentifiableString: Identifiable {
    let id = UUID()
    let value: String
}

struct ReportAnimalView: View {
    let user: User
    @EnvironmentObject var viewModel: AuthViewModel

    @State private var description = ""
    @State private var urgencyLevel = "medium"
    @State private var animalType = "dog"
    @State private var address = ""
    @State private var image: UIImage?
    @State private var showImagePicker = false
    @State private var lat: Double = 0.0
    @State private var lng: Double = 0.0
    @State private var isSaving = false
    @State private var errorMsg: IdentifiableString?
    @Environment(\.dismiss) var dismiss

    let urgencies = ["low", "medium", "high", "critical"]
    let animals = ["dog", "cat", "bird", "rabbit", "other"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Detalles del animal")) {
                    TextField("Descripción", text: $description)
                    Picker("Nivel de urgencia", selection: $urgencyLevel) {
                        ForEach(urgencies, id: \.self) { Text($0.capitalized) }
                    }
                    Picker("Tipo de animal", selection: $animalType) {
                        ForEach(animals, id: \.self) { Text($0.capitalized) }
                    }
                    TextField("Dirección", text: $address)
                }

                Section(header: Text("Imagen")) {
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                    }
                    Button("Seleccionar/tomar foto") {
                        showImagePicker = true
                    }
                }

                Button("Enviar Reporte") {
                    submit()
                }
                .disabled(!formValido)
            }
            .navigationTitle("Reportar Animal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
            .alert(item: $errorMsg) { msg in
                Alert(title: Text("Error"), message: Text(msg.value), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $image)
            }
        }
    }

    var formValido: Bool {
        !description.isEmpty && description.count >= 10 && !address.isEmpty && image != nil
    }

    private func submit() {
        lat = 13.7002 // Mock location - reemplaza con CoreLocation real si quieres
        
        lng = -89.2243 // Mock location

        guard let img = image else {
            errorMsg = IdentifiableString(value: "Selecciona una imagen")
            return
        }
        let name = UUID().uuidString
        guard let fileURL = FileManager.saveImage(img, withName: name) else {
            errorMsg = IdentifiableString(value: "Error guardando la imagen")
            return
        }

        let report = ReportData(
            description: description,
            urgencyLevel: urgencyLevel,
            animalType: animalType,
            latitude: lat,
            longitude: lng,
            locationAddress: address,
            photoUrls: [fileURL.absoluteString]
        )
    }
}

