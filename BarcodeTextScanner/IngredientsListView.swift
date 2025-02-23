//
//  IngredientsListView.swift
//  BarcodeTextScanner
//
//  Created by Mustafa Yusuf on 24/02/25.
//

import SwiftUI

struct IngredientsListView: View {
    @Environment(\.dismiss) var dismiss
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
                /*if !unclassifiedIngredients.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unknown ingredients")
                            .textCase(.uppercase)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
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
                    }
                    .padding(.horizontal)
                }*/
                
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

