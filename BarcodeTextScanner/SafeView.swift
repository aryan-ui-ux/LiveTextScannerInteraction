//
//  SafeView.swift
//  BarcodeTextScanner
//
//  Created by Mustafa Yusuf on 17/02/25.
//

import SwiftUI
import Lottie


struct SafeView: View {
    
    enum SafetyState {
        case safe
        case unsafe
        case notSure
    }
    @Environment(\.dismiss) var dismiss
    let preference: Preference
    @State var whitelistedIngredients: [String] = []
    @State var blacklistedIngredients: [String] = []
    @State var notSureIngredients: [String] = []
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
                        ZStack {
                            Group {
                                switch state {
                                    case .safe:
                                        LottieView(name: "SAFE", loopMode: .loop, contentMode: .scaleToFill, animationSpeed: 1.0)
                                    case .unsafe:
                                        LottieView(name: "SAFE", loopMode: .loop, contentMode: .scaleToFill, animationSpeed: 1.0)
                                        .scaleEffect(x: -1, y: -1)
                                    case .notSure:
                                        Image("unsure")
                                            .resizable()
                                            .scaledToFit()
                                }
                            }
                            .frame(width:
                                    UIScreen.main.bounds.width)
                            
                            VStack {
                       
                                Group {
                                    switch state {

                                        case .safe:
                                            Text(preference.title)
                                                .fontWeight(.bold)
                                        case .unsafe:
                                            Text("Not \(preference.title)")
                                                .fontWeight(.bold)
                                        case .notSure:
                                            Text("Sorry, something went wrong")
                                                .fontWeight(.bold)
                                    
                                    }
                                                if !blacklistedIngredients.isEmpty {
                                    Text(ListFormatter.localizedString(byJoining: blacklistedIngredients.map { $0.localizedCapitalized }))
                                        .font(.body)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 20)
                                        .lineLimit(2)
                                }
                                }
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .multilineTextAlignment(.center)
                                .offset(y: blacklistedIngredients.isEmpty ? 180 : 220)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        switch state {
                            case .safe, .unsafe:
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
                            case .notSure:
                                EmptyView()
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
                    .padding(.horizontal)
                }
                .padding(.horizontal)
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
    @Binding var whitelistedIngredients: [String]
    @Binding var blacklistedIngredients: [String]
    @Binding var notSureIngredients: [String]
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
                            ForEach(blacklistedIngredients, id: \.self) { ingredient in
                                HStack {
                                    Text(ingredient.capitalized)
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
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                }
                
                if !notSureIngredients.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ambiguous ingredients")
                            .textCase(.uppercase)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 0) {
                            ForEach(notSureIngredients, id: \.self) { ingredient in
                                HStack {
                                    Text(ingredient.capitalized)
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
                        .clipShape(RoundedRectangle(cornerRadius: 16))
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
                            ForEach(whitelistedIngredients, id: \.self) { ingredient in
                                Text(ingredient.capitalized)
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
                        .clipShape(RoundedRectangle(cornerRadius: 16))
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
