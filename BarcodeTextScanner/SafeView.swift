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
    let ingredients: [String]
    let classifiedIngredients: (
        whitelisted: [Ingredient],
        blacklisted: [Ingredient],
        vegan: [Ingredient],
        nonVegan: [Ingredient],
        unclassified: [Ingredient]
    )
    @State var isSafe: Bool?
    @State var showDetailView: Bool = false
    
    init(
        ingredients: [String],
        classifiedIngredients: (
            whitelisted: [Ingredient],
            blacklisted: [Ingredient],
            vegan: [Ingredient],
            nonVegan: [Ingredient],
            unclassified: [Ingredient]
        )
    ) {
        self.preference = .init(rawValue: UserDefaults.standard.string(forKey: "preference") ?? "") ?? .vegan
        self.ingredients = ingredients
        self.classifiedIngredients = classifiedIngredients
        
        // Determine if safe immediately
        let hasAnimalIngredients = !classifiedIngredients.nonVegan.filter { $0.ingredientType == .animal }.isEmpty
        let hasPescatarianIngredients = !classifiedIngredients.nonVegan.filter { $0.ingredientType == .pescatarian }.isEmpty
        let hasEggIngredients = !classifiedIngredients.nonVegan.filter { $0.ingredientType == .eggetarian }.isEmpty
        let hasDairyIngredients = !classifiedIngredients.nonVegan.filter { $0.ingredientType == .vegetarian }.isEmpty
        
        switch preference {
        case .vegan:
            _isSafe = State(initialValue: !hasAnimalIngredients && !hasPescatarianIngredients && !hasEggIngredients && !hasDairyIngredients)
        case .vegetarian:
            _isSafe = State(initialValue: !hasAnimalIngredients && !hasPescatarianIngredients)
        case .eggetarian:
            _isSafe = State(initialValue: !hasAnimalIngredients && !hasPescatarianIngredients)
        case .pescatorian:
            _isSafe = State(initialValue: !hasAnimalIngredients && !hasEggIngredients)
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
                        
                        let hasAnimalIngredients = !classifiedIngredients.nonVegan.filter { $0.ingredientType == .animal }.isEmpty
                        let hasEggIngredients = !classifiedIngredients.nonVegan.filter { $0.ingredientType == .eggetarian }.isEmpty
                        
                        Text(isSafe ? "Suitable for \(preference.title)" : 
                             hasAnimalIngredients ? "Contains Animal Ingredients" : 
                             (preference == .pescatorian && hasEggIngredients) ? "Contains Eggs" :
                             "Contains Non-Suitable Ingredients")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                        
                        if !classifiedIngredients.nonVegan.isEmpty {
                            let animalIngredients = classifiedIngredients.nonVegan.filter { $0.ingredientType == .animal }
                            let vegetarianIngredients = classifiedIngredients.nonVegan.filter { $0.ingredientType == .vegetarian }
                            let pescatarianIngredients = classifiedIngredients.nonVegan.filter { $0.ingredientType == .pescatarian }
                            let eggetarianIngredients = classifiedIngredients.nonVegan.filter { $0.ingredientType == .eggetarian }
                            
                            VStack(spacing: 8) {
                                if !animalIngredients.isEmpty {
                                    Text("Contains Animal Products: " + ListFormatter.localizedString(byJoining: animalIngredients.map { $0.name }))
                                        .font(.body)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                
                                if !vegetarianIngredients.isEmpty {
                                    Text("Contains Dairy Products: " + ListFormatter.localizedString(byJoining: vegetarianIngredients.map { $0.name }))
                                        .font(.body)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                
                                if !pescatarianIngredients.isEmpty {
                                    Text("Contains Fish/Seafood: " + ListFormatter.localizedString(byJoining: pescatarianIngredients.map { $0.name }))
                                        .font(.body)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                
                                if !eggetarianIngredients.isEmpty {
                                    Text("Contains Egg Products: " + ListFormatter.localizedString(byJoining: eggetarianIngredients.map { $0.name }))
                                        .font(.body)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        if !classifiedIngredients.unclassified.isEmpty {
                            Text("Unclassified Ingredients: " + ListFormatter.localizedString(byJoining: classifiedIngredients.unclassified.map { $0.name }))
                                .font(.body)
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button {
                            showDetailView = true
                        } label: {
                            Image(systemName: "list.bullet.rectangle.portrait")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.accentColor.opacity(0.3))
                                .clipShape(.circle)
                        }

                        Button {
                            dismiss()
                        } label: {
                            Text("Scan Again")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.accentColor)
                                .clipShape(.rect(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .sheet(isPresented: $showDetailView) {
            IngredientsListView(
                whitelistedIngredients: .constant(classifiedIngredients.whitelisted),
                blacklistedIngredients: .constant(classifiedIngredients.blacklisted),
                veganIngredients: .constant(classifiedIngredients.vegan),
                nonVeganIngredients: .constant(classifiedIngredients.nonVegan),
                unclassifiedIngredients: .constant(classifiedIngredients.unclassified)
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

