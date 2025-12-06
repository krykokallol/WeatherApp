//
//  WeatherSearchView.swift
//  WeatherApp
//
//  Created by Najmul Hasan on 12/4/25.
//

import SwiftUI

struct WeatherSearchView: View {
    
    @ObservedObject var viewModel: WeatherSearchViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 16) {
                    searchSection
                    locationSection
                    if viewModel.isLoading {
                        ProgressView()
                            .accessibilityLabel(Text("loading"))
                    }
                    if let weather = viewModel.weather {
                        Button {
                            viewModel.didTapWeatherCard()
                        } label: {
                            weatherSection(weather)
                        }
                        .buttonStyle(.plain) // so it still looks like a card
                        .accessibilityIdentifier("weatherPreviewCard")
                    }
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                            .accessibilityLabel(Text("error_message"))
                    }
                }
                .padding()
                .frame(minHeight: geometry.size.height, alignment: .top)
            }
        }
        .onAppear { viewModel.onAppear() }
    }
    
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey("search_city_title"))
                .font(.title2)
                .bold()
            HStack {
                TextField(
                    NSLocalizedString("search_city_placeholder", comment: ""),
                    text: $viewModel.cityQuery
                )
                .textInputAutocapitalization(.words)
                .submitLabel(.search)
                .onSubmit { viewModel.searchTapped() }
                .accessibilityIdentifier("cityTextField")
                .textFieldStyle(.roundedBorder)  
                
                Button {
                    viewModel.searchTapped()
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("searchButton")
            }
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                viewModel.requestLocationAccess()
            } label: {
                HStack {
                    Image(systemName: "location.fill")
                    Text(LocalizedStringKey("use_current_location"))
                }
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("currentLocationButton")
            
            if viewModel.isUsingLocation {
                Text(LocalizedStringKey("using_location_label"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func weatherSection(_ model: WeatherDisplayModel) -> some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                if let url = model.iconURL {
                    WeatherIconView(url: url)
                        .id(url)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.city + (model.country.map { ", \($0)" } ?? ""))
                        .font(.title)
                        .bold()
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text(model.description)
                        .font(.body)
                        .accessibilityLabel(Text("weather_description"))
                }
                Spacer()
            }
            
            HStack {
                Text(model.temperatureC)
                    .font(.largeTitle)
                    .bold()
                    .accessibilityLabel(Text("temperatureLabel"))
                Spacer()
                Text(model.feelsLikeC)
                    .accessibilityLabel(Text("feels_like"))
            }
            
            HStack {
                Text(model.humidity)
                Spacer()
                Text(model.windSpeed)
            }
            .font(.subheadline)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        .accessibilityElement(children: .contain)
    }
}

struct WeatherIconView: View {
    @StateObject private var loader = ImageLoader()
    let url: URL
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .background(
                        // Circular badge behind the icon
                        Circle()
                            .fill(Color(.systemBackground))   // works in light & dark mode
                            .shadow(radius: 3)                // small shadow for separation
                    )
                    .accessibilityHidden(true)
            } else {
                ProgressView()
                    .frame(width: 64, height: 64)
            }
        }
        .onAppear { loader.load(from: url) }
        .onDisappear { loader.cancel() }
    }
}

