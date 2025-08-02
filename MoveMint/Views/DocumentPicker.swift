import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedFileURL: URL?
    @Binding var pdfData: Data?
    @Binding var resumeText: String
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let types: [UTType] = [.pdf, .plainText, .item]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.selectedFileURL = url
            
            let ext = url.pathExtension.lowercased()

            do {
                let data = try Data(contentsOf: url)

                if ext == "pdf" {
                    if let pdfDoc = PDFDocument(data: data) {
                        let text = (0..<pdfDoc.pageCount)
                            .compactMap { pdfDoc.page(at: $0)?.string }
                            .joined(separator: "\n")
                        parent.resumeText = text
                    }
                } else if ext == "json" {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        parent.resumeText = jsonString
                    }
                } else {
                    parent.resumeText = "Unsupported file type"
                }
            } catch {
                print("Error reading file: \(error)")
            }
        }
    }

}

//
//#Preview {
//    DocumentPicker()
//}
