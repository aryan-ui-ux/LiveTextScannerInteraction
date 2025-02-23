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
    case pescatarian
    case eggetarian
    
    var title: String {
        switch self {
            case .vegan:
                return "Vegan"
            case .vegetarian:
                return "Vegetarian"
            case .pescatarian:
                return "Pescatarian"
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
            case .pescatarian:
                return ["Animal foods", "Eggs"]
            case .eggetarian:
                return ["Animal foods", "Aquatic foods"]
        }
    }
    
    var unsureIngredients: [String] {
        switch self {
            case .vegan:
                return ["Animal & Plant Derived"]
            default:
                return []
        }
    }
}
    
struct PreferenceView: View {
    
    @State var selectedPreference: Preference? = nil
    @AppStorage("preference") var preference: String?
    
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
                        Text(preference.title)
                            .font(.headline)
                            .foregroundStyle(preference == selectedPreference ? .safeGreen : .white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 20)
                            .overlay(alignment: .trailing) {
                                if preference == selectedPreference {
                                    Image(systemName: "checkmark")
                                        .font(.headline)
                                        .foregroundColor(Color.safeGreen)
                                        .frame(width: 20)
                                }
                            }
                            .padding(.horizontal, 20)
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
                    .accessibilityLabel(preference.title)
                    .accessibilityHint("Double tap to go set \(preference.title) as your dietary restriction")
                    .accessibilityAddTraits(.isButton)
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
                .opacity(selectedPreference == nil ? 0.5 : 1)
                .accessibilityLabel("Get started", isEnabled: selectedPreference != nil)
                .accessibilityHint("Double tap to go to the home screen of the app")
                .accessibilityAddTraits(.isButton)
            }
            .padding()
        }
        .toolbarVisibility(.hidden)
    }
}
    
