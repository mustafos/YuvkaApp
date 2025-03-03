//
//  RecipeBookCard.swift
//  Yuvka
//
//  Created by Mustafa Bekirov on 27.11.2024.
//

import SwiftUI

struct RecipeBookCard: View {
    @State private var offset: CGFloat = -UIScreen.main.bounds.width
    let recipeData: [RecipeModel]
    let category: Category
    var filteredData: [RecipeModel] {
        if category != .all {
            return recipeData.filter { $0.category.contains(category.rawValue)}
        } else {
            return recipeData
        }
    }
    
    var body: some View {
        ForEach(filteredData, id: \.self) { data in
            NavigationLink(value: data) {
                VStack(alignment: .leading ,spacing: 7) {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(data.name)
                                    .font(.custom("Poppins-Medium", size: 17))
                                Text(data.Note)
                                    .font(.custom("Poppins-Regular", size: 14))
                                    .foregroundStyle(Color(.systemGray))
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxHeight: 90)
                            
                            Spacer()
                            
                            VStack {
                                RecipeCircleImage(imageUrl: data.imageUrl)
                            }
                            .frame(width: 60, height: 60)
                        }
                    }
                    .frame(width: 320, height: 100, alignment: .leading)
                    
                    VStack {
                        HStack {
                            HStack {
                                if data.category.count > 1 {
                                    HStack{
                                        Text("\(data.category[0]),")
                                        Text(data.category[1])
                                    }
                                    .font(.custom("Poppins-Regular", size: 13))
                                } else {
                                    Text(data.category[0])
                                        .font(.custom("Poppins-Regular", size: 13))
                                }
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "clock")
                                    Text(data.cookingTime)
                                        .font(.custom("Poppins-Regular", size: 13))
                                        .kerning(1)
                                }
                            }
                            
                            Spacer()
                            
                            HStack {
                                Image(systemName: "heart")
                                    .imageScale(.large)
                            }
                        }
                        .kerning(1)
                        .font(.custom("Poppins-Regular", size: 15))
                    }
                    .frame(width: 320, alignment: .leading)
                    .padding(.vertical, 10)
                }
                .padding(.horizontal, 10)
                .frame(maxWidth: 340,alignment: .leading)
                .padding(8)
                .background(.crispyCrust)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .tint(.primary)
        }
    }
}

#Preview {
    RecipeBookCard(
        recipeData: [.init(id: UUID(), name: "Curry", imageUrl: "https://lanesbbq.com/cdn/shop/articles/pow-pow-chicken-lollipops.jpg?v=1674056829&width=1500", ingredients: [.init(quantity: "3", nameOfIngredient: "3")], instructions: "wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd wwdd", Note: "", category: ["Dinner", "Main"], preprationTime: "12", cookingTime: "12")],
        category: .all
    )
}
