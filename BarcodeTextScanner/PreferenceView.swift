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
}

struct PreferenceView: View {
    
    @State private var selectedPreference: Preference? = nil
    @AppStorage("preference") private var preference: String?
    
    var body: some View {
        ZStack {
            SafeBackgroundView()
                .ignoresSafeArea()
            
            VStack {
                ForEach(Preference.allCases, id: \.self) { preference in
                    Button {
                        withAnimation {
                            selectedPreference = preference
                        }
                    } label: {
                        HStack {
                            Text(preference.title)
                                .font(.headline)
                                .foregroundStyle(preference == selectedPreference ? .safeGreen : .white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if preference == selectedPreference {
                                Image(systemName: "checkmark")
                                    .font(.headline)
                                    .foregroundColor(Color.safeGreen)
                            }
                        }
                        .frame(height: 50)
                        .padding(.horizontal)
                        .background {
                            if preference == selectedPreference {
                                Color.white
                            } else {
                                Color.black
                                    .opacity(0.1)
                            }
                        }
                        .clipShape(Capsule())
                    }
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
