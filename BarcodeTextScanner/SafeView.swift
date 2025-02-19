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
                        
                        if !unclassifiedIngredients.isEmpty {
                            Text("⚠️ Contains unclassified ingredients")
                                .foregroundColor(.orange)
                                .padding(.horizontal)
                                .padding(.top, 8)
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
            
            // Product safety determination:
            // 1. Check for animal ingredients
            let hasAnimalIngredients = !nonVeganIngredients.filter { $0.ingredientType == .animal }.isEmpty
            
            // 2. Check for blacklisted ingredients based on preference
            let hasBlacklistedIngredients = !blacklistedIngredients.isEmpty
            
            // 3. Determine safety - now unclassified ingredients don't automatically make it unsafe
            isSafe = !hasAnimalIngredients && !hasBlacklistedIngredients
            
            // Print debug information
            print("\n=== Safety Determination ===")
            print("Has animal ingredients: \(hasAnimalIngredients)")
            print("Has blacklisted ingredients: \(hasBlacklistedIngredients)")
            print("Has unclassified ingredients: \(!unclassifiedIngredients.isEmpty)")
            print("Final safety determination: \(isSafe)")
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
                    NonVeganIngredientsSection(nonVeganIngredients: nonVeganIngredients)
                    
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

struct NonVeganIngredientsSection: View {
    let nonVeganIngredients: [Ingredient]
    
    var body: some View {
        Group {
            if !nonVeganIngredients.isEmpty {
                // Animal ingredients section
                AnimalIngredientsSection(nonVeganIngredients: nonVeganIngredients)
                
                // Seafood ingredients section
                SeafoodIngredientsSection(nonVeganIngredients: nonVeganIngredients)
                
                // Egg ingredients section
                EggIngredientsSection(nonVeganIngredients: nonVeganIngredients)
                
                // Dairy ingredients section
                DairyIngredientsSection(nonVeganIngredients: nonVeganIngredients)
                
                // Uncertain ingredients section
                UncertainIngredientsSection(nonVeganIngredients: nonVeganIngredients)
            }
        }
    }
}

struct AnimalIngredientsSection: View {
    let nonVeganIngredients: [Ingredient]
    
    var body: some View {
        let animalIngredients = nonVeganIngredients.filter { $0.ingredientType == .animal }
        if !animalIngredients.isEmpty {
            IngredientSection(
                title: "Animal Ingredients",
                ingredients: animalIngredients,
                iconName: "xmark.circle.fill",
                iconColor: .red
            )
        }
    }
}

struct SeafoodIngredientsSection: View {
    let nonVeganIngredients: [Ingredient]
    
    private var pescatarianIngredients: [Ingredient] {
        nonVeganIngredients.filter { $0.ingredientType == .pescatarian }
    }
    
    private var fishIngredients: [Ingredient] {
        pescatarianIngredients.filter { ingredient in
            let fishTypes = ["fish", "salmon", "tuna", "cod", "halibut", "mackerel", "sardines", "anchovies"]
            return fishTypes.contains { ingredient.name.lowercased().contains($0) }
        }
    }
    
    private var otherSeafoodIngredients: [Ingredient] {
        pescatarianIngredients.filter { !fishIngredients.contains($0) }
    }
    
    var body: some View {
        Group {
            if !pescatarianIngredients.isEmpty {
                if !fishIngredients.isEmpty {
                    IngredientSection(
                        title: "Fish Ingredients",
                        ingredients: fishIngredients,
                        iconName: "fish.fill",
                        iconColor: .blue
                    )
                }
                
                if !otherSeafoodIngredients.isEmpty {
                    IngredientSection(
                        title: "Other Seafood Ingredients",
                        ingredients: otherSeafoodIngredients,
                        iconName: "water.waves",
                        iconColor: .cyan
                    )
                }
            }
        }
    }
}

struct EggIngredientsSection: View {
    let nonVeganIngredients: [Ingredient]
    
    var body: some View {
        let eggetarianIngredients = nonVeganIngredients.filter { $0.ingredientType == .eggetarian }
        if !eggetarianIngredients.isEmpty {
            IngredientSection(
                title: "Egg-Based Ingredients",
                ingredients: eggetarianIngredients,
                iconName: "egg.fill",
                iconColor: .yellow
            )
        }
    }
}

struct DairyIngredientsSection: View {
    let nonVeganIngredients: [Ingredient]
    
    var body: some View {
        let vegetarianIngredients = nonVeganIngredients.filter { $0.ingredientType == .vegetarian }
        if !vegetarianIngredients.isEmpty {
            IngredientSection(
                title: "Dairy Ingredients",
                ingredients: vegetarianIngredients,
                iconName: "leaf.circle.fill",
                iconColor: .orange
            )
        }
    }
}

struct UncertainIngredientsSection: View {
    let nonVeganIngredients: [Ingredient]
    
    var body: some View {
        let uncertainIngredients = nonVeganIngredients.filter { $0.ingredientType == .both }
        if !uncertainIngredients.isEmpty {
            IngredientSection(
                title: "Potentially Animal-Derived",
                ingredients: uncertainIngredients,
                iconName: "exclamationmark.triangle.fill",
                iconColor: .yellow
            )
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
