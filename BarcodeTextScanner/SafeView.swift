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
    let impactGenerator = UIImpactFeedbackGenerator(style: .light)
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
                                        LottieView(name: "SAFE")
                                    case .unsafe:
                                        LottieView(name: "SAFE")
                                            .scaleEffect(x: -1, y: -1)
                                    case .notSure:
                                        Image("unsure")
                                            .resizable()
                                            .scaledToFit()
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width)
                            
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
                                    impactGenerator.prepare()
                                    impactGenerator.impactOccurred()
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
                                .accessibilityLabel("View ingredients")
                                .accessibilityHint("Double tap to view all ingredients the app detected")
                                .accessibilityAddTraits(.isButton)
                            case .notSure:
                                EmptyView()
                        }
                        
                        Button {
                            impactGenerator.prepare()
                            impactGenerator.impactOccurred()
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
