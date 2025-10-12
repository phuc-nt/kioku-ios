import SwiftUI

/// View for configuring AI model for a conversation
public struct ModelConfigurationView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var conversation: Conversation

    @State private var selectedModelId: String
    @State private var customModelId: String = ""
    @State private var showCustomInput: Bool = false
    @State private var validationError: String?

    public init(conversation: Conversation) {
        self.conversation = conversation
        self._selectedModelId = State(initialValue: conversation.modelIdentifier ?? ModelValidationService.defaultModel)
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Choose which AI model to use for this conversation. Different models have different strengths in quality, speed, and cost.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } header: {
                    Text("About AI Models")
                }

                Section {
                    ForEach(ModelValidationService.popularModels) { model in
                        ModelRow(
                            model: model,
                            isSelected: selectedModelId == model.id
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedModelId = model.id
                            showCustomInput = false
                            validationError = nil
                        }
                    }

                    // Custom model option
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Custom Model")
                                .font(.body)
                                .fontWeight(.medium)
                            Text("Enter any OpenRouter model ID")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if showCustomInput {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showCustomInput = true
                        customModelId = selectedModelId
                    }

                    if showCustomInput {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("provider/model-name", text: $customModelId)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()

                            if let error = validationError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }

                            Button("Validate Format") {
                                validateCustomModel()
                            }
                            .font(.caption)
                            .buttonStyle(.bordered)
                        }
                    }
                } header: {
                    Text("Select Model")
                }

                Section {
                    Text("Note: Entity extraction and relationship discovery will continue using GPT-4o Mini for consistency.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("About Model Scope")
                }
            }
            .navigationTitle("AI Model Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveConfiguration()
                    }
                    .disabled(!isValidSelection)
                }
            }
        }
    }

    private var isValidSelection: Bool {
        if showCustomInput {
            return ModelValidationService.validateFormat(customModelId)
        }
        return true
    }

    private func validateCustomModel() {
        let trimmed = customModelId.trimmingCharacters(in: .whitespacesAndNewlines)

        if ModelValidationService.validateFormat(trimmed) {
            validationError = nil
            selectedModelId = trimmed
        } else {
            validationError = "Invalid format. Expected: provider/model-name"
        }
    }

    private func saveConfiguration() {
        let finalModel = showCustomInput ? customModelId.trimmingCharacters(in: .whitespacesAndNewlines) : selectedModelId

        conversation.modelIdentifier = finalModel
        conversation.updatedAt = Date()

        dismiss()
    }
}

// MARK: - Model Row

private struct ModelRow: View {
    let model: ModelValidationService.ModelInfo
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(model.name)
                        .font(.body)
                        .fontWeight(.medium)

                    if model.id == ModelValidationService.defaultModel {
                        Text("DEFAULT")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .cornerRadius(4)
                    }
                }

                Text(model.provider)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(model.description)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let pricing = model.pricing {
                    Text(pricing)
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    ModelConfigurationView(conversation: Conversation())
}
