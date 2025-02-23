//
//  File.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 10/02/25.
//

import Foundation
import SwiftUI


struct CardView<Content: View>: View {
    let icon: String
    var iconColor: Color = .blue
    let title: String
    let content: Content
    
    init(
        icon: String,
        iconColor: Color = .blue,
        title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            content
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}
