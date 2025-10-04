import SwiftUI

public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DataService.self) private var dataService
    @State private var apiKey: String = ""
    @State private var isShowingKey: Bool = false
    @State private var validationState: ValidationState = .empty
    @State private var isSaving: Bool = false
    @State private var showingHelp: Bool = false
    @State private var showClearDataAlert: Bool = false
    @State private var isImportingTestData: Bool = false
    @State private var isClearingData: Bool = false
    @State private var showError: String?
    @State private var showSuccess: Bool = false

    private let keychainService = "com.phucnt.kioku.openrouter"
    private let keychainAccount = "api-key"

    enum ValidationState: Equatable {
        case empty
        case validating
        case valid
        case invalid(String)

        var color: Color {
            switch self {
            case .empty: return .secondary
            case .validating: return .blue
            case .valid: return .green
            case .invalid: return .red
            }
        }

        var icon: String {
            switch self {
            case .empty: return ""
            case .validating: return "hourglass"
            case .valid: return "checkmark.circle.fill"
            case .invalid: return "xmark.circle.fill"
            }
        }
    }

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    apiKeySection
                } header: {
                    Text("OpenRouter API Key")
                } footer: {
                    footerText
                }

                Section {
                    knowledgeGraphSection
                } header: {
                    Text("Knowledge Graph")
                } footer: {
                    Text("Extract entities and relationships from your journal entries to build a knowledge graph.")
                }

                Section {
                    developerToolsSection
                } header: {
                    Text("Developer Tools")
                } footer: {
                    Text("Tools for testing and development. Use with caution!")
                }

                Section {
                    helpSection
                } header: {
                    Text("Help & Resources")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingHelp) {
                helpSheet
            }
            .alert("Error", isPresented: .init(
                get: { showError != nil },
                set: { if !$0 { showError = nil } }
            )) {
                Button("OK") { showError = nil }
            } message: {
                if let error = showError {
                    Text(error)
                }
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK") {}
            } message: {
                Text("Test data imported successfully! Check the Calendar tab.")
            }
            .onAppear {
                loadAPIKey()
            }
        }
    }

    private var apiKeySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if isShowingKey {
                    TextField("sk-or-v1-...", text: $apiKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onChange(of: apiKey) { _, newValue in
                            validateAPIKey(newValue)
                        }
                } else {
                    SecureField("sk-or-v1-...", text: $apiKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onChange(of: apiKey) { _, newValue in
                            validateAPIKey(newValue)
                        }
                }

                Button(action: { isShowingKey.toggle() }) {
                    Image(systemName: isShowingKey ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)

                if validationState != .empty {
                    Image(systemName: validationState.icon)
                        .foregroundColor(validationState.color)
                }
            }

            if case .invalid(let message) = validationState {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            if case .valid = validationState {
                Button(action: saveAPIKey) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("Save API Key")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSaving)
            }
        }
    }

    private var footerText: Text {
        if apiKey.isEmpty {
            return Text("Enter your OpenRouter API key to enable AI chat features. ")
                + Text("[Sign up for free](https://openrouter.ai/)")
                    .foregroundColor(.blue)
        } else {
            return Text("Your API key is securely stored in the device Keychain.")
        }
    }

    private var helpSection: some View {
        VStack(spacing: 12) {
            Button(action: { showingHelp = true }) {
                HStack {
                    Image(systemName: "info.circle")
                    Text("How to get an API key")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Link(destination: URL(string: "https://openrouter.ai/")!) {
                HStack {
                    Image(systemName: "link")
                    Text("OpenRouter Website")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var knowledgeGraphSection: some View {
        NavigationLink {
            EntityExtractionView(dataService: dataService)
        } label: {
            HStack {
                Image(systemName: "brain.head.profile")
                Text("Entity Extraction")
                Spacer()
            }
        }
    }

    private var developerToolsSection: some View {
        Group {
            // Import Test Data
            Button(action: importTestData) {
                HStack {
                    if isImportingTestData {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "square.and.arrow.down")
                    }
                    Text("Import Test Data")
                    Spacer()
                }
            }
            .disabled(isImportingTestData || isClearingData)

            // Clear All Data
            Button(role: .destructive, action: { showClearDataAlert = true }) {
                HStack {
                    if isClearingData {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "trash")
                    }
                    Text("Clear All Data")
                    Spacer()
                }
            }
            .disabled(isImportingTestData || isClearingData)
            .alert("Clear All Data?", isPresented: $showClearDataAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive, action: clearAllData)
            } message: {
                Text("This will permanently delete all journal entries, conversations, and knowledge graph data. This action cannot be undone.")
            }
        }
    }

    private var helpSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Getting Your API Key")
                        .font(.title2)
                        .fontWeight(.bold)

                    VStack(alignment: .leading, spacing: 12) {
                        helpStep(number: 1, text: "Visit openrouter.ai and sign up for a free account")
                        helpStep(number: 2, text: "Navigate to the API Keys section in your dashboard")
                        helpStep(number: 3, text: "Click 'Create New Key' to generate an API key")
                        helpStep(number: 4, text: "Copy the key (it starts with 'sk-or-v1-')")
                        helpStep(number: 5, text: "Paste it into the API Key field in Kioku")
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Free Tier")
                            .font(.headline)
                        Text("OpenRouter offers a free tier with access to various AI models including Gemini 2.0 Flash. Perfect for personal journaling!")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Security")
                            .font(.headline)
                        Text("Your API key is stored securely in your device's Keychain and never shared with third parties.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("API Key Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingHelp = false
                    }
                }
            }
        }
    }

    private func helpStep(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.accentColor)
                .clipShape(Circle())

            Text(text)
                .font(.body)

            Spacer()
        }
    }

    private func validateAPIKey(_ key: String) {
        guard !key.isEmpty else {
            validationState = .empty
            return
        }

        validationState = .validating

        // Simulate async validation
        Task {
            try? await Task.sleep(for: .milliseconds(300))

            await MainActor.run {
                // OpenRouter API keys start with "sk-or-v1-" and are at least 40 characters
                if key.hasPrefix("sk-or-v1-") && key.count >= 40 {
                    validationState = .valid
                } else if key.count < 40 {
                    validationState = .invalid("API key must be at least 40 characters")
                } else {
                    validationState = .invalid("Invalid OpenRouter API key format (should start with 'sk-or-v1-')")
                }
            }
        }
    }

    private func loadAPIKey() {
        #if DEBUG
        // In DEBUG mode, always sync from APIKeys.swift if available
        if let apiKeysType = NSClassFromString("Kioku.APIKeys") as? NSObject.Type,
           let devKey = apiKeysType.value(forKey: "openRouterAPIKey") as? String,
           !devKey.isEmpty {

            // Check if this key differs from what's in Keychain
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: keychainService,
                kSecAttrAccount as String: keychainAccount,
                kSecReturnData as String: true
            ]

            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)

            let keychainKey = (status == errSecSuccess && result is Data)
                ? String(data: result as! Data, encoding: .utf8)
                : nil

            // If keys differ or no key in keychain, update it
            if keychainKey != devKey {
                apiKey = devKey
                validationState = .validating
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    await MainActor.run {
                        if devKey.hasPrefix("sk-or-v1-") && devKey.count >= 40 {
                            validationState = .valid
                            saveAPIKey()
                        }
                    }
                }
                return
            }
        }
        #endif

        // Try to load existing key from Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess,
           let data = result as? Data,
           let key = String(data: data, encoding: .utf8) {
            apiKey = key
            validationState = .valid
        }
    }

    private func saveAPIKey() {
        isSaving = true

        Task {
            // Delete old key if exists
            let deleteQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: keychainService,
                kSecAttrAccount as String: keychainAccount
            ]
            SecItemDelete(deleteQuery as CFDictionary)

            // Save new key
            let addQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: keychainService,
                kSecAttrAccount as String: keychainAccount,
                kSecValueData as String: apiKey.data(using: .utf8)!,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
            ]

            let status = SecItemAdd(addQuery as CFDictionary, nil)

            try? await Task.sleep(for: .milliseconds(500))

            await MainActor.run {
                isSaving = false
                if status == errSecSuccess {
                    // Show success feedback
                    validationState = .valid
                }
            }
        }
    }

    // MARK: - Developer Tools

    private func importTestData() {
        isImportingTestData = true

        Task {
            do {
                let testDataService = TestDataService(dataService: dataService)
                try await testDataService.generateTestData()

                print("✅ Test data imported successfully")

                await MainActor.run {
                    isImportingTestData = false
                    showSuccess = true
                }
            } catch {
                print("❌ Error importing test data: \(error)")
                await MainActor.run {
                    isImportingTestData = false
                    showError = "Failed to import test data: \(error.localizedDescription)"
                }
            }
        }
    }

    private func clearAllData() {
        isClearingData = true

        Task {
            await MainActor.run {
                let testDataService = TestDataService(dataService: dataService)
                testDataService.clearAllData()
            }

            try? await Task.sleep(for: .milliseconds(500))

            await MainActor.run {
                isClearingData = false
            }
        }
    }
}

#Preview {
    SettingsView()
}
