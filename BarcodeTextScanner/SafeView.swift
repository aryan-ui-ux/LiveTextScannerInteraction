//
//  SafeView.swift
//  BarcodeTextScanner
//
//  Created by Mustafa Yusuf on 17/02/25.
//

import SwiftUI

struct SafeView: View {
    
    enum SafetyState {
        case safe
        case unsafe
        case notSure
    }
    @Environment(\.dismiss) var dismiss
    let preference: Preference
    @State var whitelistedIngredients: [Ingredient] = []
    @State var blacklistedIngredients: [Ingredient] = []
    @State var notSureIngredients: [Ingredient] = []
    @State var unclassifiedIngredients: [String] = []
    @State var state: SafetyState? = nil
    @State var showDetailView: Bool = false
    
    let ingredients: [String]
    
    init(ingredients: [String]) {
        self.preference = .init(rawValue: UserDefaults.standard.string(forKey: "preference") ?? "") ?? .vegan
        self.ingredients = ingredients
    }
    
    var body: some View {
        ZStack {
            if let state {
                switch state {
                    case .safe:
                        SafeBackgroundView()
                            .ignoresSafeArea()
                    case .unsafe:
                        NotSafeBackgroundView()
                            .ignoresSafeArea()
                    case .notSure:
                        UnsureBackgroundView()
                            .ignoresSafeArea()
                }
                VStack {
                    Spacer()
                
                    VStack(spacing: .zero) {
                        Group {
                            switch state {
                                case .safe:
                                    Image("safe")
                                        .resizable()
                                case .unsafe:
                                    Image("notsafe")
                                        .resizable()
                                case .notSure:
                                    Image("unsure")
                                        .resizable()
                            }
                        }
                        .scaledToFill()
                        .frame(height: 271)
                        
                        Group {
                            switch state {
                                case .safe:
                                    Text(preference.title)
                                case .unsafe:
                                    Text("Not \(preference.title)")
                                case .notSure:
                                    Text("Sorry, something went wrong")
                            }
                        }
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .multilineTextAlignment(.center)
                        
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
            notSureIngredients = result.notSure
            unclassifiedIngredients = result.unclassified
            
            if result.blacklisted.isEmpty && result.whitelisted.isEmpty && result.notSure.isEmpty {
                state = .notSure
            } else if result.blacklisted.isEmpty && result.notSure.isEmpty {
                state = .safe
            } else {
                state = .unsafe
            }
        }
        .sheet(isPresented: $showDetailView) {
            IngredientsListView(preference: preference, state: state, whitelistedIngredients: $whitelistedIngredients, blacklistedIngredients: $blacklistedIngredients, notSureIngredients: $notSureIngredients, unclassifiedIngredients: $unclassifiedIngredients)
            .environment(\.colorScheme, .dark)
        }
    }
}


struct IngredientsListView: View {
    @Environment(\.dismiss) private var dismiss
    let preference: Preference
    let state: SafeView.SafetyState?
    @Binding var whitelistedIngredients: [Ingredient]
    @Binding var blacklistedIngredients: [Ingredient]
    @Binding var notSureIngredients: [Ingredient]
    @Binding var unclassifiedIngredients: [String]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if !blacklistedIngredients.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unsafe ingredients")
                            .textCase(.uppercase)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 0) {
                            ForEach(blacklistedIngredients) { ingredient in
                                HStack {
                                    Text(ingredient.name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .font(.body)
                                    
                                    Image(systemName: "exclamationmark.circle.fill")
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
                    }
                    .padding(.horizontal)
                }
                
                if !notSureIngredients.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ambigious ingredients")
                            .textCase(.uppercase)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 0) {
                            ForEach(notSureIngredients, id: \.self) { ingredient in
                                HStack {
                                    Text(ingredient.name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .font(.body)
                                    
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.body)
                                }
                                .padding()

                                if ingredient != notSureIngredients.last {
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
                    .padding(.horizontal)
                }

                // TODO: Improve unclassified cleanup
                // if !unclassifiedIngredients.isEmpty {
                //     VStack(alignment: .leading, spacing: 8) {
                //         Text("Unknown ingredients")
                //             .textCase(.uppercase)
                //             .font(.caption)
                //             .foregroundStyle(.secondary)
                //             .padding(.horizontal)
                        
                //         LazyVStack(spacing: 0) {
                //             ForEach(unclassifiedIngredients, id: \.self) { ingredient in
                //                 Text(ingredient)
                //                     .frame(maxWidth: .infinity, alignment: .leading)
                //                     .multilineTextAlignment(.leading)
                //                     .padding()
                                
                //                 if ingredient != unclassifiedIngredients.last {
                //                     Rectangle()
                //                         .frame(height: 1)
                //                         .foregroundStyle(Color.white.opacity(0.2))
                //                         .padding(.leading)
                //                 }
                //             }
                //         }
                //         .background(Color.black.opacity(0.2))
                //         .clipShape(.rect(cornerRadius: 16))
                //     }
                //     .padding(.horizontal)
                // }
                
                if !whitelistedIngredients.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Safe ingredients")
                            .textCase(.uppercase)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
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
                    }
                    .padding(.horizontal)
                }
            }
            .background {
                switch state {
                    case .safe:
                        SafeBackgroundView()
                            .ignoresSafeArea()
                    case .unsafe:
                        NotSafeBackgroundView()
                            .ignoresSafeArea()
                    default:
                        UnsureBackgroundView()
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
