//
//  MenuDetailView.swift
//  MealFetch
//
//  Created by Atharva Kulkarni on 14/05/24.
//

import SwiftUI

struct MenuDetailView: View {
    
    @StateObject private var viewModel = MenuDetailViewModel()
    private(set) var meal: Menu
   
    @Environment(\.colorScheme) var colorScheme
    
    let headingColor = Color.blue
    let lightModeRecipeBackground = Color(UIColor.systemGray6)
    let darkModeRecipeBackground = Color(UIColor.systemGray)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                mealImage
            
                mealTitle
                
                if let area = viewModel.meal?.area, !area.isEmpty {
                    DetailRow(label: "Country of Origin", content: area)
                        .font(.headline)
                }
                
                ingredientsAndMeasurementsSection
                
                recipeInstructionsSection
            }
            .padding(.horizontal)
            .foregroundColor(.primary)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(meal.strMeal)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchMealDetails(byId: meal.idMeal)
        }
    }

    private var mealTitle: some View {
        Text(meal.strMeal.capitalized)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(headingColor)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var mealImage: some View {
        AsyncImage(url: viewModel.meal?.imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            case .success(let image):
                image.resizable()
                     .scaledToFit()
                     .cornerRadius(20)
                     .shadow(radius: 10)
            case .failure:
                Image(systemName: "photo")
                    .foregroundColor(.secondary)
                    .frame(width: 300, height: 300)
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(contentMode: .fit)
    }
    
    private var ingredientsAndMeasurementsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Ingredients and Measurements")
                .font(.title2)
                .foregroundColor(headingColor)
                .bold()
                .padding(.bottom, 5)
            
            ForEach(Array(viewModel.meal?.ingredientsAndMeasurements.enumerated() ?? [].enumerated()), id: \.offset) { _, ingredientMeasurement in
                HStack(alignment: .firstTextBaseline) {
                    Circle()
                        .foregroundColor(.accentColor)
                        .frame(width: 5, height: 5)
                    Text("\(ingredientMeasurement.ingredient):")
                        .fontWeight(.semibold)
                        .padding(.leading, 5)
                    Text(ingredientMeasurement.measurement)
                        .padding(.leading, 2)
                }
                .padding(.vertical, 2)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var recipeInstructionsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            if let instructions = viewModel.meal?.instructions, !instructions.isEmpty {
                Text("Recipe")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .bold()
                    .padding(.bottom, 5)

                Text(instructions)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DetailRow: View {
    var label: String
    var content: String

    var body: some View {
        HStack {
            Text("\(label):")
                .bold()
            Text(content)
            Spacer()
        }
        .font(.subheadline)
        .padding(.vertical, 1)
        .foregroundColor(.secondary)
    }
}

