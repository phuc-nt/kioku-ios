import Foundation
import CryptoKit
import Security

@Observable
public final class EncryptionService: @unchecked Sendable {
    private let keyIdentifier = "com.phucnt.kioku.encryption.key"
    
    public enum EncryptionError: Error, LocalizedError {
        case keyGenerationFailed
        case keyRetrievalFailed
        case encryptionFailed
        case decryptionFailed
        case invalidData
        case keychainError(OSStatus)
        
        public var errorDescription: String? {
            switch self {
            case .keyGenerationFailed:
                return "Failed to generate encryption key"
            case .keyRetrievalFailed:
                return "Failed to retrieve encryption key from Keychain"
            case .encryptionFailed:
                return "Failed to encrypt data"
            case .decryptionFailed:
                return "Failed to decrypt data"
            case .invalidData:
                return "Invalid encrypted data format"
            case .keychainError(let status):
                return "Keychain operation failed with status: \(status)"
            }
        }
    }
    
    // MARK: - Singleton
    
    public static let shared = EncryptionService()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Encrypts a string and returns encrypted data
    public func encrypt(_ content: String) throws -> Data {
        let key = try getOrCreateKey()
        let data = Data(content.utf8)
        
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined ?? Data()
        } catch {
            print("Encryption failed: \(error)")
            throw EncryptionError.encryptionFailed
        }
    }
    
    /// Decrypts data and returns the original string
    public func decrypt(_ encryptedData: Data) throws -> String {
        let key = try getOrCreateKey()
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            
            guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
                throw EncryptionError.invalidData
            }
            
            return decryptedString
        } catch {
            print("Decryption failed: \(error)")
            throw EncryptionError.decryptionFailed
        }
    }
    
    /// Checks if encryption is available and working
    public func validateEncryption() throws {
        let testString = "test encryption validation"
        let encrypted = try encrypt(testString)
        let decrypted = try decrypt(encrypted)
        
        guard decrypted == testString else {
            throw EncryptionError.decryptionFailed
        }
    }
    
    // MARK: - Private Methods
    
    /// Gets existing key from Keychain or creates a new one
    private func getOrCreateKey() throws -> SymmetricKey {
        // Try to get existing key first
        if let existingKeyData = try? getKeyFromKeychain() {
            return SymmetricKey(data: existingKeyData)
        }
        
        // Generate new key if none exists
        let newKey = SymmetricKey(size: .bits256)
        let keyData = newKey.withUnsafeBytes { Data($0) }
        
        try storeKeyInKeychain(keyData)
        return newKey
    }
    
    /// Retrieves encryption key from iOS Keychain
    private func getKeyFromKeychain() throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyIdentifier,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw EncryptionError.keyRetrievalFailed
            }
            throw EncryptionError.keychainError(status)
        }
        
        guard let keyData = result as? Data else {
            throw EncryptionError.keyRetrievalFailed
        }
        
        return keyData
    }
    
    /// Stores encryption key in iOS Keychain
    private func storeKeyInKeychain(_ keyData: Data) throws {
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyIdentifier,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            print("Failed to store key in Keychain with status: \(status)")
            throw EncryptionError.keychainError(status)
        }
    }
    
    /// Removes encryption key from Keychain (for testing/reset purposes)
    public func removeKeyFromKeychain() throws {
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyIdentifier
        ]
        
        let status = SecItemDelete(deleteQuery as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw EncryptionError.keychainError(status)
        }
    }
}

// MARK: - Preview Support

extension EncryptionService {
    /// Creates a test instance for previews/testing (uses in-memory key)
    public static let preview: EncryptionService = {
        let service = EncryptionService()
        return service
    }()
}