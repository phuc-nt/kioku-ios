import SwiftUI
import Security

/// Temporary debug view to add OpenRouter API key to Keychain
/// TODO: Remove this file after testing, replace with proper Settings screen
struct APIKeySetupView: View {
    @State private var message = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("API Key Setup")
                .font(.title)

            Text(message)
                .foregroundStyle(message.contains("✅") ? .green : .red)

            Button("Add OpenRouter API Key") {
                addAPIKey()
            }
            .buttonStyle(.borderedProminent)

            Button("Verify API Key") {
                verifyAPIKey()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private func addAPIKey() {
        let apiKey = "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"
        let keyIdentifier = "com.phucnt.kioku.openrouter.apikey"

        // Delete existing key first
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyIdentifier
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add new key
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyIdentifier,
            kSecValueData as String: apiKey.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        if status == errSecSuccess {
            message = "✅ API key added successfully!"
        } else {
            message = "❌ Failed to add API key: \(status)"
        }
    }

    private func verifyAPIKey() {
        let keyIdentifier = "com.phucnt.kioku.openrouter.apikey"

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyIdentifier,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess,
           let keyData = result as? Data,
           let keyString = String(data: keyData, encoding: .utf8) {
            message = "✅ API key found: \(keyString.prefix(20))..."
        } else {
            message = "❌ No API key found: \(status)"
        }
    }
}

#Preview {
    APIKeySetupView()
}
