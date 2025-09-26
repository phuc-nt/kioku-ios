import Foundation
import SwiftData

public final class BatchProcessingService: @unchecked Sendable, ObservableObject {
    
    // MARK: - Batch Operation Types
    
    public struct BatchOperation: Sendable, Identifiable {
        public let id = UUID()
        public let type: OperationType
        public let entries: [UUID] // Entry IDs
        public let model: String?
        public let createdAt: Date
        public var status: OperationStatus
        public var progress: Progress
        public var results: [BatchResult]
        public var error: String?
        
        public enum OperationType: String, CaseIterable, Sendable {
            case reanalyze = "reanalyze"
            case generateConnections = "generate_connections"
            case updateAnalyses = "update_analyses"
            case cleanupAnalyses = "cleanup_analyses"
        }
        
        public enum OperationStatus: String, Sendable {
            case pending = "pending"
            case running = "running"
            case paused = "paused"
            case completed = "completed"
            case cancelled = "cancelled"
            case failed = "failed"
        }
        
        public struct Progress: Sendable {
            public var completed: Int = 0
            public var total: Int
            public var currentItem: String? = nil
            public var estimatedTimeRemaining: TimeInterval? = nil
            
            public var percentage: Double {
                guard total > 0 else { return 0.0 }
                return Double(completed) / Double(total)
            }
        }
        
        public struct BatchResult: Sendable {
            public let entryId: UUID
            public let success: Bool
            public let analysisId: UUID?
            public let error: String?
            public let processingTime: TimeInterval
        }
    }
    
    // MARK: - Properties
    
    private let dataService: DataService
    private let analysisService: AIAnalysisService
    private let knowledgeGraphService: KnowledgeGraphService
    
    // Active operations tracking
    @Published public private(set) var activeOperations: [BatchOperation] = []
    private var operationTasks: [UUID: Task<Void, Never>] = [:]
    
    // Progress tracking
    private let processingQueue = DispatchQueue(label: "batch-processing", qos: .userInitiated)
    
    // MARK: - Initialization
    
    public init(dataService: DataService, analysisService: AIAnalysisService, knowledgeGraphService: KnowledgeGraphService) {
        self.dataService = dataService
        self.analysisService = analysisService
        self.knowledgeGraphService = knowledgeGraphService
    }
    
    // MARK: - Public Methods
    
    /// Start batch reanalysis of entries
    public func startBatchReanalysis(entries: [Entry], model: String? = nil) -> BatchOperation {
        let entryIds = entries.map(\.id)
        
        var operation = BatchOperation(
            type: .reanalyze,
            entries: entryIds,
            model: model,
            createdAt: Date(),
            status: .pending,
            progress: BatchOperation.Progress(total: entries.count),
            results: []
        )
        
        operation.status = .running
        activeOperations.append(operation)
        
        // Start background processing
        let task = Task {
            await performBatchReanalysis(operation: operation, entries: entries, model: model)
        }
        
        operationTasks[operation.id] = task
        
        return operation
    }
    
    /// Start batch connection generation
    public func startBatchConnectionGeneration() -> BatchOperation {
        let allAnalyses = dataService.getAllAnalyses()
        let entryIds = Array(Set(allAnalyses.map(\.entryId))) // Unique entry IDs
        
        var operation = BatchOperation(
            type: .generateConnections,
            entries: entryIds,
            model: nil,
            createdAt: Date(),
            status: .pending,
            progress: BatchOperation.Progress(total: 1), // Single operation
            results: []
        )
        
        operation.status = .running
        activeOperations.append(operation)
        
        // Start background processing
        let task = Task {
            await performBatchConnectionGeneration(operation: operation)
        }
        
        operationTasks[operation.id] = task
        
        return operation
    }
    
    /// Cancel a batch operation
    public func cancelOperation(_ operationId: UUID) {
        guard let index = activeOperations.firstIndex(where: { $0.id == operationId }) else {
            return
        }
        
        // Cancel the task
        operationTasks[operationId]?.cancel()
        operationTasks.removeValue(forKey: operationId)
        
        // Update operation status
        activeOperations[index].status = .cancelled
        
        print("Batch operation \(operationId) cancelled")
    }
    
    /// Pause a batch operation
    public func pauseOperation(_ operationId: UUID) {
        guard let index = activeOperations.firstIndex(where: { $0.id == operationId }) else {
            return
        }
        
        activeOperations[index].status = .paused
        print("Batch operation \(operationId) paused")
    }
    
    /// Resume a paused batch operation
    public func resumeOperation(_ operationId: UUID) {
        guard let index = activeOperations.firstIndex(where: { $0.id == operationId }),
              activeOperations[index].status == .paused else {
            return
        }
        
        activeOperations[index].status = .running
        print("Batch operation \(operationId) resumed")
    }
    
    /// Get operation by ID
    public func getOperation(_ operationId: UUID) -> BatchOperation? {
        return activeOperations.first { $0.id == operationId }
    }
    
    /// Clear completed operations
    public func clearCompletedOperations() {
        activeOperations.removeAll { operation in
            operation.status == .completed || operation.status == .cancelled || operation.status == .failed
        }
    }
    
    /// Get processing statistics
    public func getProcessingStatistics() -> ProcessingStatistics {
        let completed = activeOperations.filter { $0.status == .completed }
        let running = activeOperations.filter { $0.status == .running }
        let failed = activeOperations.filter { $0.status == .failed }
        
        return ProcessingStatistics(
            totalOperations: activeOperations.count,
            completedOperations: completed.count,
            runningOperations: running.count,
            failedOperations: failed.count,
            totalEntriesProcessed: completed.reduce(0) { $0 + $1.results.count },
            averageProcessingTime: calculateAverageProcessingTime()
        )
    }
    
    // MARK: - Private Methods
    
    private func performBatchReanalysis(operation: BatchOperation, entries: [Entry], model: String?) async {
        let operationId = operation.id
        guard let operationIndex = activeOperations.firstIndex(where: { $0.id == operationId }) else {
            return
        }
        
        let startTime = Date()
        var results: [BatchOperation.BatchResult] = []
        
        for (index, entry) in entries.enumerated() {
            // Check for cancellation or pause
            guard !Task.isCancelled else {
                await updateOperationStatus(operationId, status: .cancelled)
                return
            }
            
            // Check if paused
            while activeOperations[operationIndex].status == .paused {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                
                if Task.isCancelled {
                    await updateOperationStatus(operationId, status: .cancelled)
                    return
                }
            }
            
            // Update progress
            await updateProgress(operationId) { progress in
                progress.completed = index
                progress.currentItem = "Analyzing entry \(index + 1) of \(entries.count)"
                
                // Estimate time remaining
                if index > 0 {
                    let elapsed = Date().timeIntervalSince(startTime)
                    let averageTimePerItem = elapsed / Double(index)
                    progress.estimatedTimeRemaining = averageTimePerItem * Double(entries.count - index)
                }
            }
            
            // Perform analysis
            let itemStartTime = Date()
            do {
                let analysis = try await analysisService.analyzeEntry(entry, model: model, persist: true)
                
                let result = BatchOperation.BatchResult(
                    entryId: entry.id,
                    success: true,
                    analysisId: nil, // We'd need to get this from the saved analysis
                    error: nil,
                    processingTime: Date().timeIntervalSince(itemStartTime)
                )
                
                results.append(result)
                print("✅ Successfully analyzed entry \(entry.id)")
                
            } catch {
                let result = BatchOperation.BatchResult(
                    entryId: entry.id,
                    success: false,
                    analysisId: nil,
                    error: error.localizedDescription,
                    processingTime: Date().timeIntervalSince(itemStartTime)
                )
                
                results.append(result)
                print("❌ Failed to analyze entry \(entry.id): \(error)")
            }
            
            // Small delay to prevent overwhelming the API
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
        // Update final results
        await updateOperationResults(operationId, results: results, status: .completed)
        await updateProgress(operationId) { progress in
            progress.completed = entries.count
            progress.currentItem = "Completed"
            progress.estimatedTimeRemaining = nil
        }
        
        // Clear cache to reflect new analyses
        knowledgeGraphService.clearCache()
        
        // Remove from active tasks
        operationTasks.removeValue(forKey: operationId)
        
        print("✅ Batch reanalysis completed: \(results.filter(\.success).count)/\(results.count) successful")
    }
    
    private func performBatchConnectionGeneration(operation: BatchOperation) async {
        let operationId = operation.id
        
        await updateProgress(operationId) { progress in
            progress.currentItem = "Generating knowledge graph connections..."
            progress.completed = 0
        }
        
        do {
            // Generate connections
            let connections = await knowledgeGraphService.generateKnowledgeGraph()
            
            await updateProgress(operationId) { progress in
                progress.completed = 1
                progress.currentItem = "Generated \(connections.count) connections"
            }
            
            let result = BatchOperation.BatchResult(
                entryId: UUID(), // Not applicable for this operation
                success: true,
                analysisId: nil,
                error: nil,
                processingTime: 1.0 // Placeholder
            )
            
            await updateOperationResults(operationId, results: [result], status: .completed)
            
        } catch {
            let result = BatchOperation.BatchResult(
                entryId: UUID(),
                success: false,
                analysisId: nil,
                error: error.localizedDescription,
                processingTime: 1.0
            )
            
            await updateOperationResults(operationId, results: [result], status: .failed)
        }
        
        // Remove from active tasks
        operationTasks.removeValue(forKey: operationId)
    }
    
    @MainActor
    private func updateOperationStatus(_ operationId: UUID, status: BatchOperation.OperationStatus) {
        guard let index = activeOperations.firstIndex(where: { $0.id == operationId }) else {
            return
        }
        activeOperations[index].status = status
    }
    
    @MainActor
    private func updateProgress(_ operationId: UUID, update: (inout BatchOperation.Progress) -> Void) {
        guard let index = activeOperations.firstIndex(where: { $0.id == operationId }) else {
            return
        }
        update(&activeOperations[index].progress)
    }
    
    @MainActor
    private func updateOperationResults(_ operationId: UUID, results: [BatchOperation.BatchResult], status: BatchOperation.OperationStatus) {
        guard let index = activeOperations.firstIndex(where: { $0.id == operationId }) else {
            return
        }
        activeOperations[index].results = results
        activeOperations[index].status = status
    }
    
    private func calculateAverageProcessingTime() -> TimeInterval {
        let completedOperations = activeOperations.filter { $0.status == .completed }
        guard !completedOperations.isEmpty else { return 0 }
        
        let totalTime = completedOperations.reduce(0.0) { total, operation in
            total + operation.results.reduce(0.0) { $0 + $1.processingTime }
        }
        
        let totalItems = completedOperations.reduce(0) { $0 + $1.results.count }
        
        return totalItems > 0 ? totalTime / Double(totalItems) : 0
    }
}

// MARK: - Supporting Types

public struct ProcessingStatistics: Sendable {
    public let totalOperations: Int
    public let completedOperations: Int
    public let runningOperations: Int
    public let failedOperations: Int
    public let totalEntriesProcessed: Int
    public let averageProcessingTime: TimeInterval
}

// MARK: - Preview Support

extension BatchProcessingService {
    public static let preview: BatchProcessingService = {
        return BatchProcessingService(
            dataService: DataService.preview,
            analysisService: AIAnalysisService.preview,
            knowledgeGraphService: KnowledgeGraphService.preview
        )
    }()
}