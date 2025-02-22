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
    @State var unclassifiedIngredients: [String] = []
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
                        
                        Text(isSafe ? preference.title : "Not \(preference.title)")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                        
                        if !blacklistedIngredients.isEmpty {
                            Text(ListFormatter.localizedString(byJoining: blacklistedIngredients.map { $0.name }))
                                .font(.body)
                                .fontDesign(.rounded)
                                .foregroundStyle(.secondary)
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
            unclassifiedIngredients = result.unclassified
            
            isSafe = result.blacklisted.isEmpty
        }
        .sheet(isPresented: $showDetailView) {
            IngredientsListView(whitelistedIngredients: $whitelistedIngredients, blacklistedIngredients: $blacklistedIngredients, unclassifiedIngredients: $unclassifiedIngredients)
            .environment(\.colorScheme, .dark)
        }
    }
}


struct IngredientsListView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var whitelistedIngredients: [Ingredient]
    @Binding var blacklistedIngredients: [Ingredient]
    @Binding var unclassifiedIngredients: [String]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(blacklistedIngredients) { ingredient in
                        HStack {
                            Text(ingredient.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .font(.body)
                            
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.body)
                        }
                        .padding()
                     
                        if ingredient != blacklistedIngredients.last {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundStyle(Color.white.opacity(0.2))
                                .padding(.leading)
                        }
                    }
                }
                .background(Color.black.opacity(0.2))
                .clipShape(.rect(cornerRadius: 16))
                .padding(16)
                
                LazyVStack(spacing: 0) {
                    ForEach(unclassifiedIngredients, id: \.self) { ingredient in
                        Text(ingredient)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .padding()
                        
                        if ingredient != unclassifiedIngredients.last {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundStyle(Color.white.opacity(0.2))
                                .padding(.leading)
                        }
                    }
                }
                .background(Color.black.opacity(0.2))
                .clipShape(.rect(cornerRadius: 16))
                .padding(16)

                
                LazyVStack(spacing: 0) {
                    ForEach(whitelistedIngredients) { ingredient in
                        Text(ingredient.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .padding()
                        
                        if ingredient != whitelistedIngredients.last {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundStyle(Color.white.opacity(0.2))
                                .padding(.leading)
                        }
                    }
                }
                .background(Color.black.opacity(0.2))
                .clipShape(.rect(cornerRadius: 16))
                .padding(16)

            }
            .background {
                if blacklistedIngredients.isEmpty {
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
