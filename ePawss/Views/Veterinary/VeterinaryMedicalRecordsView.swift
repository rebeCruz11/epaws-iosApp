//
//  VeterinaryMedicalRecordsView.swift
//  ePaw
//

import SwiftUI
import PhotosUI

struct VeterinaryMedicalRecordsView: View {
    @StateObject private var viewModel = VeterinaryMedicalRecordsViewModel()
    @State private var showCreateSheet = false
    @State private var selectedFilter: MedicalRecordStatus? = .inProgress
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterPill(title: "Todos", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        FilterPill(title: "Programados", isSelected: selectedFilter == .scheduled) {
                            selectedFilter = .scheduled
                        }
                        FilterPill(title: "En Progreso", isSelected: selectedFilter == .inProgress) {
                            selectedFilter = .inProgress
                        }
                        FilterPill(title: "Completados", isSelected: selectedFilter == .completed) {
                            selectedFilter = .completed
                        }
                    }
                    .padding()
                }
                
                // Content
                if viewModel.isLoading {
                    ProgressView("Cargando registros...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredRecords.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredRecords) { record in
                                MedicalRecordCard(record: record)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Registros Médicos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .refreshable {
                await viewModel.loadRecords()
            }
            .task {
                await viewModel.loadRecords()
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateMedicalRecordView {
                    Task {
                        await viewModel.loadRecords()
                    }
                }
            }
        }
    }
    
    private var filteredRecords: [MedicalRecord] {
        if let filter = selectedFilter {
            return viewModel.records.filter { $0.status == filter }
        }
        return viewModel.records
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No hay registros")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("Crea un registro médico\ncon el botón +")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Medical Record Card
struct MedicalRecordCard: View {
    let record: MedicalRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let animalName = record.animalDetails?.name {
                        Text(animalName)
                            .font(.headline)
                    }
                    
                    HStack {
                        Image(systemName: record.visitType.icon)
                        Text(record.visitType.displayName)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.caption)
                        Text(record.status.displayName)
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(record.status.color).opacity(0.2))
                    .foregroundColor(Color(record.status.color))
                    .cornerRadius(6)
                    
                    Text(formatDate(record.visitDate))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Text("Diagnóstico: \(record.diagnosis)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if let cost = record.estimatedCost {
                Text("Costo estimado: $\(String(format: "%.2f", cost))")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .short
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}

// MARK: - Create Medical Record View
struct CreateMedicalRecordView: View {
    var onSuccess: (() -> Void)? = nil
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CreateMedicalRecordViewModel()
    
    @State private var animalId = ""
    @State private var reportId = ""
    @State private var selectedVisitType: MedicalVisitType = .initialExam
    @State private var diagnosis = ""
    @State private var treatment = ""
    @State private var notes = ""
    @State private var estimatedCost = ""
    @State private var visitDate = Date()
    @State private var hasNextAppointment = false
    @State private var nextAppointment = Date()
    
    // Medications
    @State private var medications: [MedicationInput] = []
    @State private var showAddMedication = false
    
    // Images
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información del Paciente") {
                    TextField("ID del Animal (opcional)", text: $animalId)
                    TextField("ID del Reporte (opcional)", text: $reportId)
                }
                
                Section("Tipo de Visita") {
                    Picker("Tipo de visita", selection: $selectedVisitType) {
                        ForEach(MedicalVisitType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                }
                
                Section("Diagnóstico y Tratamiento") {
                    TextEditor(text: $diagnosis)
                        .frame(height: 100)
                    Text("Diagnóstico detallado del animal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $treatment)
                        .frame(height: 100)
                    Text("Tratamiento recomendado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Medicamentos") {
                    ForEach(medications) { med in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(med.name)
                                .font(.headline)
                            Text("\(med.dosage) - \(med.frequency)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button {
                        showAddMedication = true
                    } label: {
                        Label("Agregar Medicamento", systemImage: "plus.circle")
                    }
                }
                
                Section("Detalles Adicionales") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                    Text("Notas adicionales (opcional)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Costo Estimado (opcional)", text: $estimatedCost)
                        .keyboardType(.decimalPad)
                }
                
                Section("Fechas") {
                    DatePicker("Fecha de Visita", selection: $visitDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Toggle("¿Hay próxima cita?", isOn: $hasNextAppointment)
                    
                    if hasNextAppointment {
                        DatePicker("Próxima Cita", selection: $nextAppointment, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section("Fotos") {
                    if !selectedImages.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0..<selectedImages.count, id: \.self) { index in
                                    Image(uiImage: selectedImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                    
                    Button {
                        showImagePicker = true
                    } label: {
                        Label("Agregar Fotos", systemImage: "photo.on.rectangle.angled")
                    }
                }
            }
            .navigationTitle("Nuevo Registro Médico")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        Task {
                            await saveRecord()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $showAddMedication) {
                AddMedicationView { medication in
                    medications.append(medication)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImages: $selectedImages)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !diagnosis.isEmpty && !treatment.isEmpty
    }
    
    private func saveRecord() async {
        let cost = Double(estimatedCost)
        
        await viewModel.createRecord(
            animalId: animalId.isEmpty ? nil : animalId,
            reportId: reportId.isEmpty ? nil : reportId,
            visitType: selectedVisitType,
            diagnosis: diagnosis,
            treatment: treatment,
            medications: medications.map { Medication(name: $0.name, dosage: $0.dosage, frequency: $0.frequency, duration: $0.duration) },
            notes: notes.isEmpty ? nil : notes,
            estimatedCost: cost,
            images: selectedImages,
            visitDate: visitDate,
            nextAppointment: hasNextAppointment ? nextAppointment : nil
        )
        
        if viewModel.success {
            onSuccess?()
            dismiss()
        }
    }
}

// MARK: - Add Medication View
struct AddMedicationView: View {
    var onAdd: (MedicationInput) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var dosage = ""
    @State private var frequency = ""
    @State private var duration = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información del Medicamento") {
                    TextField("Nombre", text: $name)
                    TextField("Dosis (ej: 250mg)", text: $dosage)
                    TextField("Frecuencia (ej: Cada 8 horas)", text: $frequency)
                    TextField("Duración (ej: 7 días)", text: $duration)
                }
            }
            .navigationTitle("Agregar Medicamento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Agregar") {
                        let medication = MedicationInput(name: name, dosage: dosage, frequency: frequency, duration: duration)
                        onAdd(medication)
                        dismiss()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty)
                }
            }
        }
    }
}

// MARK: - Medication Input Model
struct MedicationInput: Identifiable {
    let id = UUID()
    let name: String
    let dosage: String
    let frequency: String
    let duration: String
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 5
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.selectedImages.append(image)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - ViewModels
@MainActor
class VeterinaryMedicalRecordsViewModel: ObservableObject {
    @Published var records: [MedicalRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = MedicalRecordService()
    
    func loadRecords() async {
        isLoading = true
        
        do {
            records = try await service.getVeterinaryCases(status: nil, page: 1)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("Error loading records: \(error)")
        }
    }
}

@MainActor
class CreateMedicalRecordViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var success = false
    @Published var errorMessage: String?
    
    private let service = MedicalRecordService()
    private let cloudinary = CloudinaryService.shared
    
    func createRecord(
        animalId: String?,
        reportId: String?,
        visitType: MedicalVisitType,
        diagnosis: String,
        treatment: String,
        medications: [Medication],
        notes: String?,
        estimatedCost: Double?,
        images: [UIImage],
        visitDate: Date,
        nextAppointment: Date?
    ) async {
        isLoading = true
        
        do {
            // Upload images to Cloudinary
            var photoUrls: [String] = []
            if !images.isEmpty {
                photoUrls = try await cloudinary.uploadImages(images, folder: "epaws/medical-records")
            }
            
            // Create record
            _ = try await service.createMedicalRecord(
                animalId: animalId,
                reportId: reportId,
                visitType: visitType,
                diagnosis: diagnosis,
                treatment: treatment,
                medications: medications,
                notes: notes,
                estimatedCost: estimatedCost,
                photoUrls: photoUrls,
                visitDate: visitDate,
                nextAppointment: nextAppointment
            )
            
            success = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
