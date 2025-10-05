import SwiftUI
import SwiftData

struct InsightsView: View {
    @Environment(DataService.self) private var dataService
    @State private var insightsService: InsightsService?
    @State private var selectedTimeframe: TimeframeType = .daily
    @State private var insights: [Insight] = []
    @State private var isGenerating = false
    @State private var error: Error?
    @State private var selectedDate = Date()
    @State private var showAPIKeyAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Timeframe Picker
                Picker("Timeframe", selection: $selectedTimeframe) {
                    Text("Daily").tag(TimeframeType.daily)
                    Text("Weekly").tag(TimeframeType.weekly)
                }
                .pickerStyle(.segmented)
                .padding()

                // Content
                if isGenerating {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Generating insights...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = error {
                    ErrorView(error: error) {
                        Task { await loadInsights() }
                    }
                } else if insights.isEmpty {
                    EmptyInsightsView {
                        Task { await loadInsights() }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(insights) { insight in
                                InsightCard(insight: insight)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Insights")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await loadInsights() }
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .disabled(isGenerating)
                }
            }
            .alert("API Key Required", isPresented: $showAPIKeyAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please configure your OpenRouter API key in Settings to generate insights.")
            }
        }
        .onAppear {
            setupService()
            Task { await loadInsights() }
        }
        .onChange(of: selectedTimeframe) {
            Task { await loadInsights() }
        }
    }

    private func setupService() {
        if insightsService == nil {
            insightsService = InsightsService(dataService: dataService)
        }
    }

    private func loadInsights() async {
        guard let service = insightsService else { return }

        await MainActor.run {
            isGenerating = true
            error = nil
        }

        do {
            // Try loading from database first
            let existingInsights = try await loadInsightsFromDatabase()

            if !existingInsights.isEmpty {
                // Use cached insights if available
                await MainActor.run {
                    insights = existingInsights
                    isGenerating = false
                }
                return
            }

            // No cached insights - check for API key before generating
            guard OpenRouterService.shared.hasAPIKey else {
                await MainActor.run {
                    showAPIKeyAlert = true
                    isGenerating = false
                }
                return
            }

            // Generate new insights
            let result: [Insight]
            switch selectedTimeframe {
            case .daily:
                result = try await service.generateDailyInsights(for: selectedDate)
            case .weekly:
                result = try await service.generateWeeklyInsights(endDate: selectedDate)
            case .monthly:
                result = [] // Not implemented yet
            }

            await MainActor.run {
                insights = result
                isGenerating = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                isGenerating = false
            }
        }
    }

    private func loadInsightsFromDatabase() async throws -> [Insight] {
        return await MainActor.run {
            let calendar = Calendar.current
            let descriptor = FetchDescriptor<Insight>(
                sortBy: [SortDescriptor(\.generatedAt, order: .reverse)]
            )

            do {
                let allInsights = try dataService.modelContext.fetch(descriptor)

                // Filter by timeframe and date
                return allInsights.filter { insight in
                    guard insight.timeframe == selectedTimeframe else { return false }

                    switch selectedTimeframe {
                    case .daily:
                        return calendar.isDate(insight.generatedAt, inSameDayAs: selectedDate)
                    case .weekly:
                        let weekDiff = calendar.dateComponents([.weekOfYear], from: insight.generatedAt, to: selectedDate).weekOfYear ?? 999
                        return abs(weekDiff) == 0
                    case .monthly:
                        return calendar.isDate(insight.generatedAt, equalTo: selectedDate, toGranularity: .month)
                    }
                }
            } catch {
                return []
            }
        }
    }
}

// MARK: - Insight Card

struct InsightCard: View {
    let insight: Insight

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label {
                    Text(insight.title)
                        .font(.headline)
                } icon: {
                    Image(systemName: insight.type.iconName)
                        .foregroundStyle(insight.type.displayColor)
                }

                Spacer()

                ConfidenceBadge(confidence: insight.confidence)
            }

            Text(insight.insightDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !insight.evidence.isEmpty {
                Text(insight.evidence)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}

// MARK: - Confidence Badge

struct ConfidenceBadge: View {
    let confidence: Double

    var body: some View {
        Text("\(Int(confidence * 100))%")
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(confidenceColor.opacity(0.2))
            .foregroundStyle(confidenceColor)
            .clipShape(Capsule())
    }

    private var confidenceColor: Color {
        if confidence >= 0.9 {
            return .green
        } else if confidence >= 0.7 {
            return .blue
        } else {
            return .orange
        }
    }
}

// MARK: - Empty State

struct EmptyInsightsView: View {
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Insights Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Write more journal entries to generate insights")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Generate Insights", action: action)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error View

struct ErrorView: View {
    let error: Error
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            Text("Error")
                .font(.title2)
                .fontWeight(.semibold)

            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - InsightType Extensions

extension InsightType {
    var iconName: String {
        switch self {
        case .frequency: return "chart.bar.fill"
        case .temporal: return "clock.fill"
        case .emotional: return "heart.fill"
        case .social: return "person.2.fill"
        case .topical: return "tag.fill"
        case .suggestion: return "lightbulb.fill"
        }
    }

    var displayColor: Color {
        switch self {
        case .frequency: return .blue
        case .temporal: return .purple
        case .emotional: return .pink
        case .social: return .green
        case .topical: return .orange
        case .suggestion: return .yellow
        }
    }
}

#Preview {
    InsightsView()
        .environment(DataService.preview)
}
