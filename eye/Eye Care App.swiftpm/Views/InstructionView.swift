//
//  File.swift
//  Eye Care App
//
//  Created by Akhlak iSDP on 10/02/25.
//

import Foundation
import SwiftUI

struct InstructionRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number).")
                .font(.body)
                .foregroundColor(.black)
                .fontWeight(.bold)
            
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}
