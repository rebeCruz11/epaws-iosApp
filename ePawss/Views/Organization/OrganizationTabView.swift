import SwiftUI

enum OrganizationTab: Int, CaseIterable {
    case home = 0
    case reports
    case profile
}

struct OrganizationTabView: View {
    @State private var selectedTab: Int = OrganizationTab.home.rawValue
    let user: User

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Home
            NavigationView {
                OrganizationHomeView(user: user)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Inicio")
            }
            .tag(OrganizationTab.home.rawValue)

            // Tab 2: Reportes ✅ AGREGADO
            NavigationView {
                OrganizationReportsView()
            }
            .tabItem {
                Image(systemName: "doc.text.fill")
                Text("Reportes")
            }
            .tag(OrganizationTab.reports.rawValue)

            // Tab 3: Perfil
            NavigationView {
                OrganizationProfileView(user: user)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Perfil")
            }
            .tag(OrganizationTab.profile.rawValue)
        }
        .accentColor(.orange)
    }
}
