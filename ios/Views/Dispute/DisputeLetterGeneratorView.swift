//
//  DisputeLetterGeneratorView.swift
//  Walkaround
//
//  Interactive generator for customized legal dispute letters with 1-tap copy and email.
//

import SwiftUI

public struct DisputeLetterGeneratorView: View {
    @Environment(\.dismiss) private var dismiss

    public let rental: Rental

    @State private var recipientType: DisputeRecipientType = .rentalAgency
    @State private var renterName: String = "John Doe"
    @State private var claimNumber: String = ""
    @State private var disputeDescription: String = "alleged bumper scratch"
    @State private var isCopied = false

    public init(rental: Rental) {
        self.rental = rental
    }

    private var generatedLetter: String {
        DisputeLetterTemplate.generateLetter(
            rental: rental,
            recipient: recipientType,
            renterName: renterName,
            claimNumber: claimNumber,
            disputedDescription: disputeDescription
        )
    }

    public var body: some View {
        NavigationStack {
            Form {
                // Section 1: Target Recipient
                Section(header: Text("Who are you disputing with?")) {
                    Picker("Recipient", selection: $recipientType) {
                        ForEach(DisputeRecipientType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }

                // Section 2: Customization Details
                Section(header: Text("Letter Customization")) {
                    TextField("Your Full Legal Name", text: $renterName)
                    TextField("Agency Claim / Reference #", text: $claimNumber)
                    TextField("Disputed Damage Description (e.g. rear bumper scratch)", text: $disputeDescription)
                }

                // Section 3: Generated Rebuttal Preview
                Section(header: Text("Generated Legal Dispute Notice")) {
                    Text(generatedLetter)
                        .font(.system(size: 11, design: .monospaced))
                        .padding(.vertical, 4)
                }

                // Section 4: Action Buttons
                Section {
                    Button(action: copyToClipboard) {
                        HStack {
                            Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                            Text(isCopied ? "Copied to Clipboard!" : "Copy Full Letter")
                        }
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .foregroundColor(isCopied ? .green : .blue)
                    }
                }
            }
            .navigationTitle("Legal Rebuttal Letter")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func copyToClipboard() {
        #if canImport(UIKit)
        UIPasteboard.general.string = generatedLetter
        #elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(generatedLetter, forType: .string)
        #endif
        isCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isCopied = false
        }
    }
}
