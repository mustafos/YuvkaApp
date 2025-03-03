//
//  UserRecipesView.swift
//  Yuvka
//
//  Created by Mustafa Bekirov on 28.11.2024.
//

import SwiftUI
import Kingfisher
import FirebaseAuth

struct UserRecipesView: View {
    @ObservedObject var vm = RecipeDetailsViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State var isRecipeBookmarked: Bool = false
    @State private var showAlert: Bool = false
    
    let recipeData: RecipeModel
    
    @MainActor
    func isBookmarked() async {
        let val = await Bookmarks
            .isRecipeBookmarked(
                recipeId: 2)
        isRecipeBookmarked = val
    }
    
    var body: some View {
        VStack {
            ScrollView {
                // header
                VStack {
                    ZStack(alignment: .topLeading) {
                        VStack {
                            KFImage(URL(string: recipeData.imageUrl))
                                .resizable()
                                .scaledToFill()
                        }
                        .frame(width: 400,height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        
                        VStack {
                            Button(action: {
                                print("Hello..")
                                dismiss()
                            }, label: {
                                VStack {
                                    Image(systemName: "chevron.left")
                                        .imageScale(.large)
                                        .foregroundStyle(Color.accentColor)
                                        .background(
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 42, height: 42)
                                        )
                                }
                                .padding(.vertical, 70)
                                .padding(.horizontal, 40)
                            })
                        }
                        
                        VStack {
                            Button(action: {
                                print("Deleting this....")
                                showAlert.toggle()
                            }, label: {
                                VStack {
                                    Image(systemName: "trash.fill")
                                        .imageScale(.large)
                                        .foregroundStyle(Color.accentColor)
                                        .background(
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 42, height: 42)
                                        )
                                }
                            })
                        }
                        .alert("Delete this recipe", isPresented: $showAlert) {
                            Button("Delete", role: .destructive) {
                                print("Okay")
                                Task {
                                    await vm.deleteRecipe(id: recipeData.id, from: .FromRecipeBook)
                                }
                                dismiss()
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("Do you want to remove this recipe from your book?")
                        }
                        .offset(x: 340, y: 250)
                    }
                }
                
                VStack {
                    HStack {
                        VStack {
                            Text(recipeData.name)
                                .font(.custom("Poppins-Medium", size: 22))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack {
                            Button {
                                Task {
                                    await vm.uploadBookmarkedRecipe(recipe: recipeData, .UserCreated)
                                }
                            } label: {
                                Image(systemName: isRecipeBookmarked ? "heart.fill" : "heart")
                                    .imageScale(.large)
                            }
                            .tint(Color.accentColor)
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.horizontal, 15)
                    
                    VStack {
                        HStack {
                            HStack {
                                Image(systemName: "clock")
                                Text("\(recipeData.cookingTime) min")
                                    .font(.custom("Poppins-Regular", size: 15))
                            }
                        }
                        .padding(.horizontal, 15)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 2)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.custom("Poppins-Medium", size: 18))
                        
                        VStack {
                            Text(recipeData.Note)
                                .font(.custom("Poppins-Regular", size: 15))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 160, alignment: .topLeading)
                        .background(Color(.crispyCrust))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 14)
                    
                    VStack(alignment: .leading) {
                        Text("Ingredients")
                            .font(.custom("Poppins-Medium", size: 18))
                        
                        // ingredients show
                        VStack(spacing: 10) {
                            ForEach(recipeData.ingredients, id: \.self) { ingredient in
                                VStack {
                                    HStack {
                                        HStack {
                                            Text("\(capitalizedString(ingredient.nameOfIngredient))")
                                                .font(.custom("Poppins-Regular", size: 15))
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(ingredient.quantity)")
                                            .font(.custom("Poppins-Regular", size: 15))
                                    }
                                }
                                .padding(17)
                                .frame(maxWidth: .infinity,alignment: .leading)
                                .background(Color(.crispyCrust))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 14)
                    
                    VStack(alignment: .leading) {
                        Text("Instructions")
                            .font(.custom("Poppins-Medium", size: 18))
                        
                        VStack {
                            VStack(alignment: .leading) {
                                // todo: we already have the instructions we do not need to fetch any more
                                if !recipeData.instructions.isEmpty {
                                    Text(recipeData.instructions)
                                } else {
                                    Text("Sorry Couldn't find any instructions")
                                }
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .background(Color(.crispyCrust))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 14)
                }
                .padding(.horizontal,3)
                .padding(.top, 30)
                .padding(.bottom, 60)
            }
            .onAppear(perform: {
                Task {
                    try await vm.getUserCreatedRecipes(recipeID: recipeData.id)
                }
            })
            .scrollIndicators(.hidden)
        }
        .ignoresSafeArea()
    }
    
    private func capitalizedString(_ string: String) -> String {
        return string.capitalized // Capitalizes the first letter of each word
    }
    
    private func getImageUrlOfIngredient(imageName: String) -> String {
        return "https://img.spoonacular.com/ingredients_100x100/\(imageName)"
    }
}

#Preview {
    UserRecipesView(
        recipeData: .init(
            id: UUID.init(uuidString: "3351150E-C443-49E9-934F-6223752F999F"
                         )!,
            name: "Manu",
            imageUrl: "https://firebasestorage.googleapis.com:443/v0/b/anya-s-kitchen.appspot.com/o/recipe_images%2FFC449B0F-185B-4CED-A5FB-AF7F962563C6?alt=media&token=da553c30-82ac-4ccc-8b3f-ca5472cd3f3a"
            ,
            ingredients: [],
            instructions: "asdas", Note:
                "",
            category: [],
            preprationTime: "as",
            cookingTime: "da"
        )
    )
}
