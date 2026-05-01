//
//  CatsView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import SwiftUI

struct CatsView: View {
    @StateObject private var viewModel = CatsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.cats) { cat in
                        catCard(cat: cat)
                    }
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle(L10n.cats)
            .onAppear {
                viewModel.loadSelectedCat()
            }
        }
    }

    @ViewBuilder
    private func catCard(cat: CatItem) -> some View {
        Button {
            viewModel.selectCat(cat)
        } label: {
            CardContainer {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppColors.catAccent.opacity(0.15))
                            .frame(width: 64, height: 64)

                        Image(systemName: cat.systemImageName)
                            .font(.system(size: 28))
                            .foregroundStyle(AppColors.catAccent)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(cat.name)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(cat.isPremium ? L10n.premium : L10n.free)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondaryText)
                    }

                    Spacer()

                    if cat.isPremium {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(AppColors.secondaryText)
                    } else if viewModel.isSelected(cat) {
                        Text(L10n.selected)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.success.opacity(0.15))
                            .foregroundStyle(AppColors.success)
                            .clipShape(Capsule())
                    } else {
                        Text(L10n.use)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppColors.primary.opacity(0.12))
                            .foregroundStyle(AppColors.primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}
