import SwiftUI
import UniformTypeIdentifiers

struct DataManagementView: View {
    @Environment(DataService.self) private var dataService

    @State private var isExporting = false
    @State private var isImporting = false
    @State private var exportProgress: Double = 0.0
    @State private var exportMessage: String = ""
    @State private var importProgress: Double = 0.0
    @State private var importMessage: String = ""
    @State private var exportedData: Data?
    @State private var showFileExporter = false
    @State private var showFileImporter = false
    @State private var exportFilename: String = ""
    @State private var showError: String?

    var body: some View {
        Group {
            // Export to JSON
            Button(action: exportJSON) {
                HStack {
                    if isExporting {
                        ProgressView()
                            .scaleEffect(0.8)
                        if exportProgress > 0 {
                            Text("\(Int(exportProgress * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Image(systemName: "doc.text")
                    }
                    VStack(alignment: .leading) {
                        Text("Export to JSON")
                        if !exportMessage.isEmpty {
                            Text(exportMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
            }
            .disabled(isExporting || isImporting)

            // Export to Markdown
            Button(action: exportMarkdown) {
                HStack {
                    if isExporting {
                        ProgressView()
                            .scaleEffect(0.8)
                        if exportProgress > 0 {
                            Text("\(Int(exportProgress * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Image(systemName: "doc.plaintext")
                    }
                    VStack(alignment: .leading) {
                        Text("Export to Markdown")
                        if !exportMessage.isEmpty {
                            Text(exportMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
            }
            .disabled(isExporting || isImporting)

            // Import from JSON
            Button(action: { showFileImporter = true }) {
                HStack {
                    if isImporting {
                        ProgressView()
                            .scaleEffect(0.8)
                        if importProgress > 0 {
                            Text("\(Int(importProgress * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Image(systemName: "square.and.arrow.down")
                    }
                    VStack(alignment: .leading) {
                        Text("Import from JSON")
                        if !importMessage.isEmpty {
                            Text(importMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
            }
            .disabled(isExporting || isImporting)
        }
        .fileExporter(
            isPresented: $showFileExporter,
            document: TextFileDocument(data: exportedData),
            contentType: .plainText,
            defaultFilename: exportFilename
        ) { result in
            handleExportResult(result)
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.json, .plainText],
            allowsMultipleSelection: false
        ) { result in
            handleImportSelection(result)
        }
        .alert("Error", isPresented: .constant(showError != nil)) {
            Button("OK") { showError = nil }
        } message: {
            if let error = showError {
                Text(error)
            }
        }
    }

    private func exportJSON() {
        isExporting = true
        exportMessage = "Starting..."
        exportProgress = 0.0

        Task {
            do {
                let exportService = ExportService(
                    dataService: dataService,
                    encryptionService: EncryptionService.shared
                )

                let data = try await exportService.exportToJSON(
                    options: .default,
                    progress: { progress, message in
                        Task { @MainActor in
                            exportProgress = progress
                            exportMessage = message
                        }
                    }
                )

                await MainActor.run {
                    exportedData = data
                    exportFilename = "kioku-export-\(Date().ISO8601Format()).json"
                    isExporting = false
                    exportMessage = ""
                    showFileExporter = true
                }
            } catch {
                await MainActor.run {
                    isExporting = false
                    exportMessage = ""
                    showError = "Export failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private func exportMarkdown() {
        isExporting = true
        exportMessage = "Starting..."
        exportProgress = 0.0

        Task {
            do {
                let exportService = ExportService(
                    dataService: dataService,
                    encryptionService: EncryptionService.shared
                )

                let markdown = try await exportService.exportToMarkdown(
                    options: .default,
                    progress: { progress, message in
                        Task { @MainActor in
                            exportProgress = progress
                            exportMessage = message
                        }
                    }
                )

                await MainActor.run {
                    exportedData = markdown.data(using: .utf8)
                    exportFilename = "kioku-export-\(Date().ISO8601Format()).md"
                    isExporting = false
                    exportMessage = ""
                    showFileExporter = true
                }
            } catch {
                await MainActor.run {
                    isExporting = false
                    exportMessage = ""
                    showError = "Export failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private func handleExportResult(_ result: Result<URL, Error>) {
        switch result {
        case .success:
            break
        case .failure(let error):
            showError = "Failed to save: \(error.localizedDescription)"
        }
    }

    private func handleImportSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            performImport(from: url)
        case .failure(let error):
            showError = "Failed to select file: \(error.localizedDescription)"
        }
    }

    private func performImport(from url: URL) {
        isImporting = true
        importMessage = "Reading file..."
        importProgress = 0.0

        Task {
            do {
                guard url.startAccessingSecurityScopedResource() else {
                    throw NSError(domain: "DataManagementView", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot access file"])
                }
                defer { url.stopAccessingSecurityScopedResource() }

                let data = try Data(contentsOf: url)

                let importService = ImportService(
                    dataService: dataService,
                    encryptionService: EncryptionService.shared
                )

                try await importService.importFromJSON(
                    data: data,
                    conflictStrategy: .merge,
                    progress: { progress, message in
                        Task { @MainActor in
                            importProgress = progress
                            importMessage = message
                        }
                    }
                )

                await MainActor.run {
                    isImporting = false
                    importMessage = ""
                    showError = "✅ Import completed successfully!"
                }
            } catch {
                await MainActor.run {
                    isImporting = false
                    importMessage = ""
                    showError = "Import failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct TextFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }

    var data: Data?

    init(data: Data?) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = data else {
            throw NSError(domain: "DataManagementView", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data"])
        }
        return FileWrapper(regularFileWithContents: data)
    }
}
