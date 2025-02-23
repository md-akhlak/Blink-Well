//
//  File.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 10/02/25.
//

import Foundation
import SwiftUI

struct BenefitRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .foregroundColor(.green)
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}
