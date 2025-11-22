//
//  DashboardCard.swift
//  ePaw
//
//  Created by ESTUDIANTE on 7/11/25.
//

// Components/DashboardCard.swift
import SwiftUI

struct DashboardCard: View {
    var title: String
    var value: Int

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text("\(value)")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 110, height: 85)
        .background(Color(red: 45/255, green: 66/255, blue: 84/255))
        .cornerRadius(18)
    }
}
