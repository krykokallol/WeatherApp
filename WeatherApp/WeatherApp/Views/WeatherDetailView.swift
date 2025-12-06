//
//  WeatherDetailView.swift
//  WeatherApp
//
//  Created by Najmul Hasan on 12/5/25.
//

import SwiftUI

struct WeatherDetailView: View {

    let model: WeatherDisplayModel

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    mainTemperatureSection
                    extraDetailsSection
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.7),
                Color(.systemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var headerSection: some View {
        HStack(alignment: .center, spacing: 16) {
            if let url = model.iconURL {
                WeatherIconView(url: url)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(model.city + (model.country.map { ", \($0)" } ?? ""))
                    .font(.title)
                    .bold()
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Text(model.description)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground).opacity(0.9))
                .shadow(radius: 4)
        )
        .accessibilityElement(children: .combine)
    }

    private var mainTemperatureSection: some View {
        VStack(spacing: 12) {
            Text(model.temperatureC)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .accessibilityLabel(Text("temperature"))

            Text(model.feelsLikeC)
                .font(.body)
                .foregroundStyle(.secondary)
                .accessibilityLabel(Text("feels_like"))

            HStack {
                Text(model.minTemperatureC)
                Spacer()
                Text(model.maxTemperatureC)
            }
            .font(.subheadline)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground).opacity(0.95))
                .shadow(radius: 4)
        )
    }

    private var extraDetailsSection: some View {
        VStack(spacing: 16) {
            detailRow(
                systemImage: "humidity",
                titleKey: NSLocalizedString("Humidity", comment: ""),
                value: model.humidity
            )
            .accessibilityIdentifier("humidityRow")

            detailRow(
                systemImage: "wind",
                titleKey: NSLocalizedString("Wind", comment: ""),
                value: model.windSpeed
            )
            .accessibilityIdentifier("windRow")

            detailRow(
                systemImage: "sunrise.fill",
                titleKey: NSLocalizedString("detail_sunrise_title", comment: ""),
                value: model.sunrise
            )
            .accessibilityIdentifier("sunriseRow")

            detailRow(
                systemImage: "sunset.fill",
                titleKey: NSLocalizedString("detail_sunset_title", comment: ""),
                value: model.sunset
            )
            .accessibilityIdentifier("sunsetRow")

            detailRow(
                systemImage: "eye.fill",
                titleKey: NSLocalizedString("detail_visibility_title", comment: ""),
                value: model.visibility
            )
            .accessibilityIdentifier("visibilityRow")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground).opacity(0.95))
                .shadow(radius: 4)
        )
    }

    private func detailRow(systemImage: String, titleKey: String, value: String) -> some View {
        HStack {
            Image(systemName: systemImage)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)

            VStack(alignment: .leading) {
                Text(titleKey)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }
}

