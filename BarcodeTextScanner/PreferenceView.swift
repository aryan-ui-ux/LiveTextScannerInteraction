//
//  PreferenceView.swift
//  BarcodeTextScanner
//
//  Created by Mustafa Yusuf on 17/02/25.
//

import SwiftUI

enum Preference: String, CaseIterable {
    case vegan
    case vegetarian
    case pescatorian
    case eggetarian
    case jain
    
    var title: String {
        switch self {
            case .vegan:
                return "Vegan"
            case .vegetarian:
                return "Vegetarian"
            case .pescatorian:
                return "Pescatorian"
            case .eggetarian:
                return "Eggetarian"
            case .jain:
                return "Jain"
        }
    }
    
    var icon: String {
        switch self {
            case .vegan:
                return "🌱"
            case .vegetarian:
                return "🥗"
            case .pescatorian:
                return "🐟"
            case .eggetarian:
                return "🥚"
            case .jain:
                return "🪷" // Lotus flower for Jainism
        }
    }
    
    var description: String {
        switch self {
            case .vegan:
                return "No animal products"
            case .vegetarian:
                return "No meat or fish"
            case .pescatorian:
                return "No meat but fish allowed"
            case .eggetarian:
                return "No meat or fish but eggs allowed"
            case .jain:
                return "No animal products, root vegetables, or certain vegetables"
        }
    }
    
    var blacklistedIngredientGroups: [String] {
        switch self {
            case .vegan:
                return ["Milk and milk products", "Animal foods", "Aquatic foods", "Eggs"]
            case .vegetarian:
                return ["Animal foods", "Aquatic foods", "Eggs"]
            case .pescatorian:
                return ["Animal foods"]
            case .eggetarian:
                return ["Animal foods", "Aquatic foods"]
            case .jain:
                return ["Milk and milk products", "Animal foods", "Aquatic foods", "Eggs", "Root vegetables", "Restricted vegetables"]
        }
    }
}

struct PreferenceView: View {
    
    @State private var selectedPreference: Preference? = nil
    @AppStorage("preference") private var preference: String?
    
    var body: some View {
        ZStack {
            SafeBackgroundView()
                .ignoresSafeArea()
            
            VStack {
                Text("Choose Your Dietary Preference")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 20)
                
                ForEach(Preference.allCases, id: \.self) { preference in
                    Button {
                        withAnimation {
                            selectedPreference = preference
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(preference.icon)
                                    .font(.title2)
                                
                                Text(preference.title)
                                    .font(.headline)
                                    .foregroundStyle(preference == selectedPreference ? .safeGreen : .white)
                                
                                Spacer()
                                
                                if preference == selectedPreference {
                                    Image(systemName: "checkmark")
                                        .font(.headline)
                                        .foregroundColor(Color.safeGreen)
                                }
                            }
                            
                            Text(preference.description)
                                .font(.subheadline)
                                .foregroundStyle(preference == selectedPreference ? .safeGreen.opacity(0.8) : .white.opacity(0.8))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            if preference == selectedPreference {
                                Color.white
                            } else {
                                Color.black.opacity(0.1)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.bottom, 8)
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                        preference = selectedPreference?.rawValue
                    }
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .disabled(selectedPreference == nil)
            }
            .padding()
        }
        .toolbarVisibility(.hidden)
    }
}
