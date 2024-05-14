//
//  MenuListView.swift
//  MealFetch
//
//  Created by Atharva Kulkarni on 14/05/24.
//

import SwiftUI

struct MenuListView: View {
    
    @StateObject var dessertsVM = MenuListViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(dessertsVM.DessertsArray.sorted(by: { $0.strMeal < $1.strMeal }), id: \.self) { dessert in
                        NavigationLink(destination: MenuDetailView(meal: dessert)) {
                            dessertCard(for: dessert)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: dessertsVM.DessertsArray.count)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .navigationTitle("Menu")
            .background(Color(UIColor.systemGroupedBackground))
        }
        .accentColor(Color(.label))
        .task {
            await dessertsVM.getData()
        }
    }

    private func dessertCard(for dessert: Menu) -> some View {
        ZStack {
            GeometryReader { geometry in
                dessertImage(for: dessert.strMealThumb)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .aspectRatio(4/3, contentMode: .fill)
            .overlay(
                Text(dessert.strMeal.capitalized)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    .padding([.top, .leading], 8),
                alignment: .topLeading
            )
        }
        .cornerRadius(20)
        .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
    }

    private func dessertImage(for url: URL?) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                placeholderImage
            @unknown default:
                EmptyView()
            }
        }
    }

    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
            .cornerRadius(10)
            .foregroundColor(.gray)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MenuListView()
    }
}
