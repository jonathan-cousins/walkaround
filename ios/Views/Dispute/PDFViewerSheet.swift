//
//  PDFViewerSheet.swift
//  Walkaround
//
//  Full-screen PDFKit document viewer with native iOS Share Sheet integration.
//

#if canImport(UIKit)
import SwiftUI
import PDFKit
import UIKit

public struct PDFViewerSheet: View {
    @Environment(\.dismiss) private var dismiss

    public let pdfData: Data
    public let title: String

    @State private var showingShareSheet = false

    public init(pdfData: Data, title: String = "Walkaround Dispute Dossier") {
        self.pdfData = pdfData
        self.title = title
    }

    public var body: some View {
        NavigationStack {
            PDFKitRepresentable(data: pdfData)
                .edgesIgnoringSafeArea(.bottom)
                .navigationTitle(title)
                .inlineNavigationTitle()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: { showingShareSheet = true }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                .sheet(isPresented: $showingShareSheet) {
                    ActivityView(activityItems: [pdfData])
                }
        }
    }
}

// PDFKit UIViewRepresentable wrapper
struct PDFKitRepresentable: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = PDFDocument(data: data)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document == nil {
            uiView.document = PDFDocument(data: data)
        }
    }
}

// UIActivityViewController wrapper for iOS Share Sheet
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif
