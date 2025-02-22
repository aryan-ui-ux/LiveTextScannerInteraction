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
        }
    }
    
    var unsureIngredients: [String] {
        return ["Animal & Plant Derived"]
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
                                Spacer()
                                Text(preference.title)
                                    .font(.headline)
                                    .foregroundStyle(preference == selectedPreference ? .safeGreen : .white)
                                Spacer()
                                
                                // Reserve space with the same width
                                Group {
                                    if preference == selectedPreference {
                                        Image(systemName: "checkmark")
                                            .font(.headline)
                                            .foregroundColor(Color.safeGreen)
                                    } else {
                                        Image(systemName: "checkmark")
                                            .font(.headline)
                                            .foregroundColor(.clear)
                                    }
                                }
                                .frame(width: 20)
                            }
                            
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .background {
                            if preference == selectedPreference {
                                Color.white
                            } else {
                                Color.black.opacity(0.1)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24))
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
    
