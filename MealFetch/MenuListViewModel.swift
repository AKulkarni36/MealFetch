//
//  MenuListViewModel.swift
//  MealFetch
//
//  Created by Atharva Kulkarni on 14/05/24.
//

import Foundation

@MainActor
class MenuListViewModel: ObservableObject {
    
    private struct ReturnedList: Decodable {
        var meals: [Menu]
    }

    @Published var DessertsArray: [Menu] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let baseUrl: URL
    
    init(baseUrl: URL? = nil) {
        let defaultUrlString = "https://themealdb.com/api/json/v1/1"
        if let baseUrl = baseUrl {
            self.baseUrl = baseUrl
        } else if let defaultUrl = URL(string: defaultUrlString) {
            self.baseUrl = defaultUrl
        } else {
            fatalError("Invalid default URL string: \(defaultUrlString)")
        }
    }
    
    func getData() async {
        isLoading = true
        errorMessage = nil
        let endpoint = baseUrl.appendingPathComponent("filter.php")
        
        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: true)
        components?.queryItems = [URLQueryItem(name: "c", value: "Dessert")]
        
        guard let url = components?.url else {
            errorMessage = "Error: Could not create a URL for desserts data."
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let returned = try JSONDecoder().decode(ReturnedList.self, from: data)
                self.DessertsArray = returned.meals
            } else {
                errorMessage = "Error: Server responded with status code \(String(describing: (response as? HTTPURLResponse)?.statusCode))"
            }
        } catch {
            errorMessage = "Error: Could not get data from \(url.absoluteString)"
        }
        
        isLoading = false
    }
}

