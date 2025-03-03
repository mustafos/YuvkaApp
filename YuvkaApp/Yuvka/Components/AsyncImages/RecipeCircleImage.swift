//
//  RecipeCircleImage.swift
//  Yuvka
//
//  Created by Mustafa Bekirov on 26.11.2024.
//

import SwiftUI
import Kingfisher

struct RecipeCircleImage: View {
    
    let imageUrl: String
    
    var body: some View {
        VStack {
            KFImage(URL(string: imageUrl))
                .placeholder {
                    ProgressView()
                }
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
        }
    }
}
