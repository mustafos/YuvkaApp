//
//  Bookmarks.swift
//  Yuvka
//
//  Created by Mustafa Bekirov on 28.11.2024.
//

import Firebase
import Foundation
import FirebaseAuth

struct Bookmarks {
    
    enum RecipeType {
        case UserCreated(recipeId: UUID)
        case SearchedRecipes(recipeId: Int)
    }

    //Problem: one is type of UUID and one is Int
    static func isRecipeBookmarked(recipeId: Int) async -> Bool {
        
        let db = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else {
            print("Could not the get user uid")
            return false
        }

        do {
            let documentSnapshot = try await db.collection("bookmarks").document(user.uid).getDocument()
            
            // Check if the document exists and has the "recipes" field
            guard let data = documentSnapshot.data(), let recipesData = data["recipes"] as? [[String: Any]] else {
                return false
            }
            
            let decoder = Firestore.Decoder()
            let bookmarks = try recipesData.map { try decoder.decode(FetchedRecipe.self, from: $0) }
            print("IS BOOKMARKED = \( bookmarks.contains { $0.id == recipeId })")
            return bookmarks.contains { $0.id == recipeId }
        } catch {
            print("Error checking if recipe is bookmarked: \(error.localizedDescription)")
            return false
        }
    }
}
