//
//  MenuDetailViewModel.swift
//  MealFetch
//
//  Created by Atharva Kulkarni on 14/05/24.
//

import Foundation

@MainActor
class MenuDetailViewModel: ObservableObject {
    
    @Published var meal: MenuDetail?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private struct MealListResponse: Decodable {
        let meals: [MenuDetail]?
    }
    
    func fetchMealDetails(byId id: String) async {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)") else {
            errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "Server error"
                return
            }
            
            let mealResponse = try JSONDecoder().decode(MealListResponse.self, from: data)
            if let fetchedMeal = mealResponse.meals?.first {
                self.meal = fetchedMeal
            } else {
                errorMessage = "Error: Unable to fetch meal details."
            }
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

