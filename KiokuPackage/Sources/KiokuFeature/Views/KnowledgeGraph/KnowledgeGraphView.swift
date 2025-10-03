import SwiftUI
import SwiftData

public struct KnowledgeGraphView: View {
    @Environment(DataService.self) private var dataService

    @State private var entities: [Entity] = []
    @State private var relationships: [EntityRelationship] = []
    @State private var selectedEntity: Entity?
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    // Layout positions
    @State private var nodePositions: [UUID: CGPoint] = [:]

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                if entities.isEmpty {
                    emptyStateView
                } else {
                    graphView
                }
            }
            .navigationTitle("Knowledge Graph")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: resetZoom) {
                            Label("Reset Zoom", systemImage: "arrow.counterclockwise")
                        }
                        Button(action: reloadGraph) {
                            Label("Reload", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onAppear {
                loadGraphData()
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "network")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("No Knowledge Graph Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Extract entities from your journal entries to build your knowledge graph.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            NavigationLink {
                SettingsView()
            } label: {
                Label("Go to Settings", systemImage: "gear")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Graph View

    private var graphView: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                // Graph content
                Canvas { context, size in
                    // Draw edges first (behind nodes)
                    drawEdges(context: context, size: size)

                    // Draw nodes
                    drawNodes(context: context, size: size)
                }
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = value
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = value.translation
                        }
                )

                // Selected entity detail
                if let selected = selectedEntity {
                    VStack {
                        Spacer()
                        entityDetailCard(entity: selected)
                            .padding()
                    }
                }
            }
            .onAppear {
                if nodePositions.isEmpty {
                    layoutNodes(in: geometry.size)
                }
            }
        }
    }

    // MARK: - Drawing Methods

    private func drawEdges(context: GraphicsContext, size: CGSize) {
        for relationship in relationships {
            guard let fromPos = nodePositions[relationship.fromEntity.id],
                  let toPos = nodePositions[relationship.toEntity.id] else {
                continue
            }

            let adjustedFrom = applyTransform(fromPos, size: size)
            let adjustedTo = applyTransform(toPos, size: size)

            var path = Path()
            path.move(to: adjustedFrom)
            path.addLine(to: adjustedTo)

            // Color by relationship type
            let color = colorForRelationshipType(relationship.type)
            context.stroke(
                path,
                with: .color(color.opacity(0.4)),
                lineWidth: 2 * scale
            )
        }
    }

    private func drawNodes(context: GraphicsContext, size: CGSize) {
        for entity in entities {
            guard let position = nodePositions[entity.id] else { continue }

            let adjustedPos = applyTransform(position, size: size)

            // Node circle
            let radius: CGFloat = 20 * scale
            let isSelected = selectedEntity?.id == entity.id

            let circle = Path(ellipseIn: CGRect(
                x: adjustedPos.x - radius,
                y: adjustedPos.y - radius,
                width: radius * 2,
                height: radius * 2
            ))

            // Fill color by entity type
            let color = colorForEntityType(entity.type)
            context.fill(circle, with: .color(color.opacity(isSelected ? 1.0 : 0.7)))

            // Border
            context.stroke(
                circle,
                with: .color(isSelected ? .accentColor : .gray),
                lineWidth: isSelected ? 3 : 1
            )

            // Label
            if scale > 0.5 {
                let text = Text(entity.value)
                    .font(.caption)
                    .foregroundColor(.primary)

                context.draw(
                    text,
                    at: CGPoint(x: adjustedPos.x, y: adjustedPos.y + radius + 15)
                )
            }
        }
    }

    // MARK: - Layout

    private func layoutNodes(in size: CGSize) {
        guard !entities.isEmpty else { return }

        // Simple circular layout
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) * 0.35
        let angleStep = (2 * .pi) / Double(entities.count)

        for (index, entity) in entities.enumerated() {
            let angle = Double(index) * angleStep
            let x = center.x + radius * CGFloat(cos(angle))
            let y = center.y + radius * CGFloat(sin(angle))
            nodePositions[entity.id] = CGPoint(x: x, y: y)
        }
    }

    // MARK: - Transform

    private func applyTransform(_ point: CGPoint, size: CGSize) -> CGPoint {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let scaledX = (point.x - center.x) * scale + center.x + offset.width
        let scaledY = (point.y - center.y) * scale + center.y + offset.height
        return CGPoint(x: scaledX, y: scaledY)
    }

    // MARK: - Entity Detail Card

    private func entityDetailCard(entity: Entity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: entity.type.icon)
                    .foregroundColor(colorForEntityType(entity.type))

                VStack(alignment: .leading, spacing: 4) {
                    Text(entity.value)
                        .font(.headline)
                    Text(entity.type.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: { selectedEntity = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mentions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(entity.mentionCount)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Relationships")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(entity.relationshipCount)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Confidence")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(entity.confidence * 100))%")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
    }

    // MARK: - Helper Methods

    private func loadGraphData() {
        entities = dataService.fetchAllEntities()

        // Get all relationships
        let descriptor = FetchDescriptor<EntityRelationship>(
            sortBy: [SortDescriptor(\.confidence, order: .reverse)]
        )
        relationships = (try? dataService.modelContext.fetch(descriptor)) ?? []
    }

    private func reloadGraph() {
        loadGraphData()
        nodePositions.removeAll()
        selectedEntity = nil
    }

    private func resetZoom() {
        withAnimation {
            scale = 1.0
            offset = .zero
        }
    }

    private func colorForEntityType(_ type: EntityType) -> Color {
        switch type {
        case .people: return .blue
        case .places: return .green
        case .events: return .orange
        case .emotions: return .pink
        case .topics: return .purple
        }
    }

    private func colorForRelationshipType(_ type: RelationshipType) -> Color {
        switch type {
        case .temporal: return .blue
        case .causal: return .orange
        case .emotional: return .pink
        case .topical: return .green
        }
    }
}

#Preview {
    KnowledgeGraphView()
        .environment(DataService.preview)
}
