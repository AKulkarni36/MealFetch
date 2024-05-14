//
//  MenuDetail.swift
//  MealFetch
//
//  Created by Atharva Kulkarni on 14/05/24.
//

import Foundation

struct MenuDetail: Decodable {
    
    let name: String
    let area: String
    let id: String
    let instructions: String
    let imageURL: URL?

    private var ingredients: [String] = []
    private var measurements: [String] = []

    var ingredientsAndMeasurements: [IngredientMeasurement] {
        zip(ingredients, measurements)
            .map(IngredientMeasurement.init)
            .filter { !$0.ingredient.isEmpty && !$0.measurement.isEmpty }
    }

    struct IngredientMeasurement: Decodable, Equatable {
        let ingredient: String
        let measurement: String
    }

    private enum CodingKeys: String, CodingKey {
        case name = "strMeal"
        case area = "strArea"
        case id = "idMeal"
        case instructions = "strInstructions"
        case imageURL = "strMealThumb"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        area = try container.decode(String.self, forKey: .area)
        id = try container.decode(String.self, forKey: .id)
        instructions = try container.decode(String.self, forKey: .instructions)
        imageURL = try container.decodeIfPresent(URL.self, forKey: .imageURL)

        var index = 1
        let additionalContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        while let ingredientKey = DynamicCodingKeys(stringValue: "strIngredient\(index)"),
              let measurementKey = DynamicCodingKeys(stringValue: "strMeasure\(index)") {
            if let ingredient = try additionalContainer.decodeIfPresent(String.self, forKey: ingredientKey),
               let measurement = try additionalContainer.decodeIfPresent(String.self, forKey: measurementKey),
               !ingredient.isEmpty {
                ingredients.append(ingredient)
                measurements.append(measurement)
            } else {
                break
            }
            index += 1
        }
    }

    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }

        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }
}

