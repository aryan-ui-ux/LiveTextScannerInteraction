//
//  SafeView.swift
//  BarcodeTextScanner
//
//  Created by Mustafa Yusuf on 17/02/25.
//

import SwiftUI

private struct PreferenceKey: EnvironmentKey {
    static let defaultValue: Preference = .vegan
}

extension EnvironmentValues {
    var preference: Preference {
        get { self[PreferenceKey.self] }
        set { self[PreferenceKey.self] = newValue }
    }
}

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
    
    private func determineIfSafe() -> Bool {
        let hasAnimalIngredients = !nonVeganIngredients.filter { $0.ingredientType == .animal }.isEmpty
        let hasPescatarianIngredients = !nonVeganIngredients.filter { $0.ingredientType == .pescatarian }.isEmpty
        let hasEggIngredients = !nonVeganIngredients.filter { $0.ingredientType == .eggetarian }.isEmpty
        let hasDairyIngredients = !nonVeganIngredients.filter { $0.ingredientType == .vegetarian }.isEmpty
        
        switch preference {
        case .vegan:
            return !hasAnimalIngredients && !hasPescatarianIngredients && !hasEggIngredients && !hasDairyIngredients
        case .vegetarian:
            return !hasAnimalIngredients && !hasPescatarianIngredients
        case .eggetarian:
            return !hasAnimalIngredients && !hasPescatarianIngredients
        case .pescatorian:
            return !hasAnimalIngredients && !hasEggIngredients
        case .jain:
            return false
        }
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
                        let hasEggIngredients = !nonVeganIngredients.filter { $0.ingredientType == .eggetarian }.isEmpty
                        
                        Text(isSafe ? "Suitable for \(preference.title)" : 
                             hasAnimalIngredients ? "Contains Animal Ingredients" : 
                             (preference == .pescatorian && hasEggIngredients) ? "Contains Eggs" :
                             "Contains Non-Suitable Ingredients")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                        
                        if !nonVeganIngredients.isEmpty {
                            let animalIngredients = nonVeganIngredients.filter { $0.ingredientType == .animal }
                            let vegetarianIngredients = nonVeganIngredients.filter { $0.ingredientType == .vegetarian }
                            let pescatarianIngredients = nonVeganIngredients.filter { $0.ingredientType == .pescatarian }
                            let eggetarianIngredients = nonVeganIngredients.filter { $0.ingredientType == .eggetarian }
                            
                            if !animalIngredients.isEmpty {
                                Text("Contains Animal Products: " + ListFormatter.localizedString(byJoining: animalIngredients.map { $0.name }))
                                    .font(.body)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            if !pescatarianIngredients.isEmpty {
                                Text("Contains Seafood: " + ListFormatter.localizedString(byJoining: pescatarianIngredients.map { $0.name }))
                                    .font(.body)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            if !eggetarianIngredients.isEmpty {
                                Text("Contains Eggs: " + ListFormatter.localizedString(byJoining: eggetarianIngredients.map { $0.name }))
                                    .font(.body)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            if !vegetarianIngredients.isEmpty {
                                Text("Contains Dairy: " + ListFormatter.localizedString(byJoining: vegetarianIngredients.map { $0.name }))
                                    .font(.body)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
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
            
            // Determine safety using the new function
            isSafe = determineIfSafe()
        }
        .sheet(isPresented: $showDetailView) {
            IngredientsListView(
                whitelistedIngredients: $whitelistedIngredients,
                blacklistedIngredients: $blacklistedIngredients,
                veganIngredients: $veganIngredients,
                nonVeganIngredients: $nonVeganIngredients,
                unclassifiedIngredients: $unclassifiedIngredients
            )
            .environment(\.preference, preference)
            .environment(\.colorScheme, .dark)
        }
    }
}

struct IngredientsListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.preference) var preference
    @Binding var whitelistedIngredients: [Ingredient]
    @Binding var blacklistedIngredients: [Ingredient]
    @Binding var veganIngredients: [Ingredient]
    @Binding var nonVeganIngredients: [Ingredient]
    @Binding var unclassifiedIngredients: [Ingredient]
    
    private var hasRestrictedIngredients: Bool {
        let hasAnimalIngredients = !nonVeganIngredients.filter { $0.ingredientType == .animal }.isEmpty
        let hasPescatarianIngredients = !nonVeganIngredients.filter { $0.ingredientType == .pescatarian }.isEmpty
        let hasEggIngredients = !nonVeganIngredients.filter { $0.ingredientType == .eggetarian }.isEmpty
        
        switch preference {
        case .vegan:
            return !nonVeganIngredients.isEmpty
        case .vegetarian:
            return hasAnimalIngredients || hasPescatarianIngredients
        case .eggetarian:
            return hasAnimalIngredients || hasPescatarianIngredients
        case .pescatorian:
            return hasAnimalIngredients || hasEggIngredients
        case .jain:
            return false
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    NonVeganIngredientsSection(nonVeganIngredients: nonVeganIngredients)
                    
                    if !veganIngredients.isEmpty {
                        IngredientSection(
                            title: "Plant-Based Ingredients",
                            ingredients: veganIngredients.filter { $0.ingredientType == .vegan },
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
                if !hasRestrictedIngredients {
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
    @Environment(\.preference) var preference
    
    private var animalIngredients: [Ingredient] {
        nonVeganIngredients.filter { $0.ingredientType == .animal }
    }
    
    private var pescatarianIngredients: [Ingredient] {
        nonVeganIngredients.filter { $0.ingredientType == .pescatarian }
    }
    
    private var eggetarianIngredients: [Ingredient] {
        nonVeganIngredients.filter { $0.ingredientType == .eggetarian }
    }
    
    private var dairyIngredients: [Ingredient] {
        nonVeganIngredients.filter { $0.ingredientType == .vegetarian }
    }
    
    var body: some View {
        Group {
            if !nonVeganIngredients.isEmpty {
                // Animal ingredients section
                if !animalIngredients.isEmpty {
                    IngredientSection(
                        title: "Animal-Based Ingredients",
                        ingredients: animalIngredients,
                        iconName: "xmark.circle.fill",
                        iconColor: .red
                    )
                }
                
                // Seafood ingredients section
                if !pescatarianIngredients.isEmpty {
                    IngredientSection(
                        title: "Seafood Ingredients",
                        ingredients: pescatarianIngredients,
                        iconName: preference == .pescatorian ? "checkmark.circle.fill" : "xmark.circle.fill",
                        iconColor: preference == .pescatorian ? .green : .red
                    )
                }
                
                // Egg ingredients section
                if !eggetarianIngredients.isEmpty {
                    IngredientSection(
                        title: "Egg-Based Ingredients" + (preference == .eggetarian ? "" : " (Not Allowed)"),
                        ingredients: eggetarianIngredients,
                        iconName: preference == .eggetarian ? "checkmark.circle.fill" : "xmark.circle.fill",
                        iconColor: preference == .eggetarian ? .green : .red
                    )
                }
                
                // Dairy ingredients section
                if !dairyIngredients.isEmpty {
                    IngredientSection(
                        title: "Dairy Ingredients",
                        ingredients: dairyIngredients,
                        iconName: preference == .vegan ? "xmark.circle.fill" : "checkmark.circle.fill",
                        iconColor: preference == .vegan ? .red : .green
                    )
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
