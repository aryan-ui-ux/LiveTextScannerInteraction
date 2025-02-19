//
//  SafeView.swift
//  BarcodeTextScanner
//
//  Created by Mustafa Yusuf on 17/02/25.
//

import SwiftUI

struct SafeView: View {
    
    @Environment(\.dismiss) var dismiss
    let preference: Preference
    @State var whitelistedIngredients: [Ingredient] = []
    @State var blacklistedIngredients: [Ingredient] = []
    @State var veganIngredients: [Ingredient] = []
    @State var nonVeganIngredients: [Ingredient] = []
    @State var unclassifiedIngredients: [Ingredient] = []
    @State var isSafe: Bool?
    @State var showDetailView: Bool = false
    
    let ingredients: [String]
    
    init(ingredients: [String]) {
        self.preference = .init(rawValue: UserDefaults.standard.string(forKey: "preference") ?? "") ?? .vegan
        self.ingredients = ingredients
    }
    
    var body: some View {
        ZStack {
            if let isSafe {
                if isSafe {
                    SafeBackgroundView()
                        .ignoresSafeArea()
                } else {
                    NotSafeBackgroundView()
                        .ignoresSafeArea()
                }
                VStack {
                    Spacer()
                
                    VStack(spacing: .zero) {
                        Image(isSafe ? "safe" : "notsafe")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 271)
                        
                        let hasAnimalIngredients = !nonVeganIngredients.filter { $0.ingredientType == .animal }.isEmpty
                        let hasVegetarianIngredients = !nonVeganIngredients.filter { $0.ingredientType == .vegetarian }.isEmpty
                        
                        Text(isSafe ? "Suitable for \(preference.title)" : 
                             hasAnimalIngredients ? "Contains Animal Ingredients" : 
                             hasVegetarianIngredients ? "Contains Vegetarian Ingredients" : 
                             "Contains Non-Vegan Ingredients")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                        
                        if !nonVeganIngredients.isEmpty {
                            let animalIngredients = nonVeganIngredients.filter { $0.ingredientType == .animal }
                            let vegetarianIngredients = nonVeganIngredients.filter { $0.ingredientType == .vegetarian }
                            
                            if !animalIngredients.isEmpty {
                                Text("Contains Animal Products: " + ListFormatter.localizedString(byJoining: animalIngredients.map { $0.name }))
                                    .font(.body)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            } else if !vegetarianIngredients.isEmpty {
                                Text("Contains: " + ListFormatter.localizedString(byJoining: vegetarianIngredients.map { $0.name }))
                                    .font(.body)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        } else if !blacklistedIngredients.isEmpty {
                            Text("Contains: " + ListFormatter.localizedString(byJoining: blacklistedIngredients.map { $0.name }))
                                .font(.body)
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button {
                            showDetailView = true
                        } label: {
                            Circle()
                                .frame(height: 50)
                                .aspectRatio(1, contentMode: .fit)
                                .foregroundStyle(Color.black.opacity(0.1))
                                .overlay {
                                    Image(systemName: "list.bullet.rectangle.portrait")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                }
                        }
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Scan again")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            let result = IngredientStore.shared.getIngredients(
                from: ingredients,
                for: preference
            )
            
            whitelistedIngredients = result.whitelisted
            blacklistedIngredients = result.blacklisted
            veganIngredients = result.vegan
            nonVeganIngredients = result.nonVegan
            unclassifiedIngredients = result.unclassified
            
            // Print ingredients for debugging
            print("\n=== Vegan Ingredients ===")
            veganIngredients.forEach { print($0.name) }
            print("\n=== Non-Vegan Ingredients ===")
            nonVeganIngredients.forEach { print($0.name) }
            print("\n=== Unclassified Ingredients ===")
            unclassifiedIngredients.forEach { print($0.name) }
            
            // Product is safe only if:
            // 1. No animal ingredients (for vegetarians, dairy/eggs are ok)
            // 2. No blacklisted ingredients
            // 3. No unclassified ingredients (to be safe)
            let hasAnimalIngredients = !nonVeganIngredients.filter { $0.ingredientType == .animal }.isEmpty
            isSafe = !hasAnimalIngredients && 
                    blacklistedIngredients.isEmpty && 
                    unclassifiedIngredients.isEmpty
        }
        .sheet(isPresented: $showDetailView) {
            IngredientsListView(
                whitelistedIngredients: $whitelistedIngredients,
                blacklistedIngredients: $blacklistedIngredients,
                veganIngredients: $veganIngredients,
                nonVeganIngredients: $nonVeganIngredients,
                unclassifiedIngredients: $unclassifiedIngredients
            )
            .environment(\.colorScheme, .dark)
        }
    }
}

struct IngredientsListView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var whitelistedIngredients: [Ingredient]
    @Binding var blacklistedIngredients: [Ingredient]
    @Binding var veganIngredients: [Ingredient]
    @Binding var nonVeganIngredients: [Ingredient]
    @Binding var unclassifiedIngredients: [Ingredient]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if !nonVeganIngredients.isEmpty {
                        // Animal ingredients (strictly non-vegetarian)
                        IngredientSection(
                            title: "Animal Ingredients",
                            ingredients: nonVeganIngredients.filter { $0.ingredientType == .animal },
                            iconName: "xmark.circle.fill",
                            iconColor: .red
                        )
                        
                        // Vegetarian ingredients (like dairy and eggs)
                        if !nonVeganIngredients.filter({ $0.ingredientType == .vegetarian }).isEmpty {
                            IngredientSection(
                                title: "Vegetarian Ingredients",
                                ingredients: nonVeganIngredients.filter { $0.ingredientType == .vegetarian },
                                iconName: "leaf.circle.fill",
                                iconColor: .orange
                            )
                        }
                        
                        // Uncertain ingredients
                        if !nonVeganIngredients.filter({ $0.ingredientType == .both }).isEmpty {
                            IngredientSection(
                                title: "Potentially Animal-Derived",
                                ingredients: nonVeganIngredients.filter { $0.ingredientType == .both },
                                iconName: "exclamationmark.triangle.fill",
                                iconColor: .yellow
                            )
                        }
                    }
                    
                    if !blacklistedIngredients.isEmpty {
                        IngredientSection(
                            title: "Blacklisted Ingredients",
                            ingredients: blacklistedIngredients,
                            iconName: "exclamationmark.triangle.fill",
                            iconColor: .red
                        )
                    }
                    
                    if !veganIngredients.isEmpty {
                        IngredientSection(
                            title: "Plant-Based Ingredients",
                            ingredients: veganIngredients,
                            iconName: "leaf.fill",
                            iconColor: .green
                        )
                    }
                    
                    if !whitelistedIngredients.isEmpty {
                        IngredientSection(
                            title: "Safe Ingredients",
                            ingredients: whitelistedIngredients,
                            iconName: "checkmark.circle.fill",
                            iconColor: .green
                        )
                    }
                    
                    if !unclassifiedIngredients.isEmpty {
                        IngredientSection(
                            title: "Unclassified Ingredients",
                            ingredients: unclassifiedIngredients,
                            iconName: "questionmark.circle.fill",
                            iconColor: .yellow
                        )
                    }
                }
                .padding(16)
            }
            .background {
                if blacklistedIngredients.isEmpty && 
                   nonVeganIngredients.filter({ $0.ingredientType == .animal }).isEmpty {
                    SafeBackgroundView()
                        .ignoresSafeArea()
                } else {
                    NotSafeBackgroundView()
                        .ignoresSafeArea()
                }
            }
            .navigationTitle("Detected Ingredients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark.circle.fill") {
                        dismiss()
                    }
                    .tint(.white)
                }
            }
        }
    }
}

struct IngredientSection: View {
    let title: String
    let ingredients: [Ingredient]
    let iconName: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 0) {
                ForEach(ingredients, id: \.publicId) { ingredient in
                    HStack {
                        Text(ingredient.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .font(.body)
                        
                        if ingredient.ingredientType == .both {
                            Text("(Uncertain)")
                                .font(.caption)
                                .foregroundColor(.yellow)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Capsule())
                        }
                        
                        Image(systemName: iconName)
                            .foregroundColor(iconColor)
                            .font(.body)
                    }
                    .padding()
                    
                    if ingredient != ingredients.last {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(Color.white.opacity(0.2))
                            .padding(.leading)
                    }
                }
            }
            .background(Color.black.opacity(0.2))
            .clipShape(.rect(cornerRadius: 16))
        }
        .onAppear {
            print("\n=== Displaying ingredients for section: \(title) ===")
            ingredients.forEach { print($0.name) }
        }
    }
}
