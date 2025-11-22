import SwiftUI

struct UserHomeView: View {
    let user: User
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject private var animalVM = AnimalViewModel()
    
    @State private var activeAdoptions: [Adoption] = []
    @State private var isLoadingAdoptions = false
    @State private var showingDetail: Animal? = nil
    @State private var showAdoptedMessage = false
    @State private var selectedTab = 0
    @State private var selectedFilter: Animal.Species? = nil
    @State private var isShowingCreateReport = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "¡Buenos Días!"
        case 12..<18: return "¡Buenas Tardes!"
        default: return "¡Buenas Noches!"
        }
    }

    private var filteredAnimals: [Animal] {
        if let filter = selectedFilter {
            return animalVM.animals.filter { $0.species == filter }
        } else {
            return animalVM.animals
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("ePaw")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 3, y: 1)

                // Main Content
                Group {
                    switch selectedTab {
                    case 0:
                        homeContent
                    case 1:
                        UserReportsListView()
                    case 2:
                        MyAdoptionsView()
                    case 3:
                        notificationsContent
                    case 4:
                        ProfileView(selectedTab: $selectedTab)
                            .environmentObject(viewModel)
                    default:
                        homeContent
                    }
                }

                MainMenuBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(edges: .bottom)
            .sheet(item: $showingDetail) { animal in
                AnimalDetailView(
                    animal: animal,
                    userActiveAdoptions: $activeAdoptions,  // ✅ Binding
                    onAdoptionSubmitted: {
                        await loadUserAdoptions()  // ✅ Recarga después de enviar
                    }
                )
            }
            .sheet(isPresented: $isShowingCreateReport) {
                NavigationStack {
                    CreateReportView()
                }
                .environmentObject(viewModel)
            }
            .task {
                await animalVM.fetchAnimals()
                await loadUserAdoptions()
            }
            .refreshable {
                await animalVM.fetchAnimals()
                await loadUserAdoptions()
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                // ✅ Recarga cuando vuelves al tab de inicio
                if newValue == 0 && oldValue != 0 {
                    Task {
                        await loadUserAdoptions()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func loadUserAdoptions() async {
        isLoadingAdoptions = true
        do {
            let adoptions = try await AdoptionService().getMyApplications()
            activeAdoptions = adoptions
        } catch {
            activeAdoptions = []
        }
        isLoadingAdoptions = false
    }

    private var homeContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Saludo
                Text(greeting)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                    .padding(.top, 8)

                // Subtítulo
                Text("¿Viste un ePal en apuros? ¡Repórtalo aquí!")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)

                // Banner de reporte
                Button {
                    isShowingCreateReport = true
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tu comunidad de ePawers y nuestros ePal te necesitan. Si ves uno en peligro, repórtalo aquí.")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                            .padding(12)
                            .background(Color.white.opacity(0.25))
                            .clipShape(Circle())
                    }
                    .padding(16)
                    .background(Color(red: 0.3, green: 0.35, blue: 0.45))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())

                // Título galería
                Text("Galería de ePals en adopción")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                    .padding(.top, 8)

                Text("Tu compañero te espera")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)

                // Filtros
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterButton(title: "Todos", selected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        FilterButton(title: "Perro", selected: selectedFilter == .dog) {
                            selectedFilter = .dog
                        }
                        FilterButton(title: "Gato", selected: selectedFilter == .cat) {
                            selectedFilter = .cat
                        }
                        FilterButton(title: "Aves", selected: selectedFilter == .bird) {
                            selectedFilter = .bird
                        }
                    }
                }
                .padding(.vertical, 4)

                // Grid de animales
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(filteredAnimals) { animal in
                        AnimalCardView(animal: animal) {
                            showAdoptedMessage = true
                        }
                        .onTapGesture {
                            showingDetail = animal
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 16)
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
    }

    private var notificationsContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash")
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.4))

            Text("No tienes notificaciones")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.gray)

            Text("Aquí aparecerán las actualizaciones\nde tus reportes y adopciones")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: selected ? .semibold : .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(selected ? Color.orange : Color.white)
                .foregroundColor(selected ? .white : Color.gray)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(selected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - Main Menu Bar
struct MainMenuBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            MenuButton(icon: "house.fill", title: "Inicio", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            MenuButton(icon: "doc.text.fill", title: "Reportes", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            MenuButton(icon: "heart.fill", title: "Adopciones", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            MenuButton(icon: "bell.fill", title: "Alertas", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
            MenuButton(icon: "person.crop.circle.fill", title: "Perfil", isSelected: selectedTab == 4) {
                selectedTab = 4
            }
        }
        .padding(.vertical, 10)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.04), radius: 6, y: -2)
        )
    }
}

// MARK: - Menu Button
struct MenuButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(isSelected ? Color.orange : Color.gray.opacity(0.6))
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var selectedTab: Int
    
    @State private var showEditProfile = false
    @State private var showChangePassword = false
    @State private var showLogoutAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let currentUser = viewModel.currentUser {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                        .padding(.top, 30)

                    VStack(spacing: 6) {
                        Text(currentUser.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                        
                        Text(currentUser.email)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        if let phone = currentUser.phone {
                            HStack(spacing: 4) {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 12))
                                Text(phone)
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    VStack(spacing: 12) {
                        ProfileOptionButton(
                            icon: "person.circle",
                            title: "Editar Perfil"
                        ) {
                            showEditProfile = true
                        }
                        
                        ProfileOptionButton(
                            icon: "lock.circle",
                            title: "Cambiar Contraseña"
                        ) {
                            showChangePassword = true
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    Button {
                        showLogoutAlert = true
                    } label: {
                        Text("Cerrar sesión")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showChangePassword) {
            ChangePasswordView()
                .environmentObject(viewModel)
        }
        .alert("Cerrar Sesión", isPresented: $showLogoutAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Cerrar Sesión", role: .destructive) {
                viewModel.logout()
            }
        } message: {
            Text("¿Estás seguro que deseas cerrar sesión?")
        }
    }
}

// MARK: - Profile Option Button
struct ProfileOptionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5))
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)
        }
    }
}
