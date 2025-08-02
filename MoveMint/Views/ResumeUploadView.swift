//import SwiftUI
//import PDFKit
//import UniformTypeIdentifiers
//
//struct ResumeUploadView: View {
//    @State private var selectedFileURL: URL? = nil
//    @State private var pdfData: Data? = nil
//    @State private var fileName: String = ""
//    @State private var showPicker = false
//    @Binding var resumeText: String
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(self)
//    }
//    let walletAddress: String
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Upload Your Resume")
//                .font(.title2.bold())
//
//            Button(action: {
//                showPicker = true
//            }) {
//                Label("Choose Resume", systemImage: "doc.fill")
//                    .font(.headline)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .clipShape(Capsule())
//            }
//
//            if let pdfData = pdfData {
//                PDFKitView(data: pdfData)
//                    .frame(height: 300)
//                    .cornerRadius(10)
//                    .shadow(radius: 5)
//            }
//
//            if let url = selectedFileURL {
//                Text("Selected: \(url.lastPathComponent)")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//
//            Button("Next Step") {
//                // 🔜 Navigate to SkillExtractView or similar here
//                print("File ready: \(selectedFileURL?.lastPathComponent ?? "")")
//            }
//            .disabled(selectedFileURL == nil)
//            .padding()
//            .background(selectedFileURL == nil ? Color.gray : Color.green)
//            .foregroundColor(.white)
//            .cornerRadius(8)
//        }
//        .padding()
//        .sheet(isPresented: $showPicker) {
//            DocumentPicker(selectedFileURL: $selectedFileURL, pdfData: $pdfData, resumeText: $resumeText)
//        }
//    }
//    class Coordinator: NSObject, UIDocumentPickerDelegate {
//            let parent: ResumeUploadView
//
//            init(_ parent: ResumeUploadView) {
//                self.parent = parent
//            }
//
//            func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//                guard let url = urls.first else { return }
//
//                if let data = try? Data(contentsOf: url),
//                   let pdf = PDFDocument(data: data) {
//                    var fullText = ""
//                    for pageIndex in 0..<pdf.pageCount {
//                        if let page = pdf.page(at: pageIndex),
//                           let text = page.string {
//                            fullText += text + "\n"
//                        }
//                    }
//                    parent.resumeText = fullText
//                }
//            }
//        }
//}
//
//struct PDFKitView: UIViewRepresentable {
//    let data: Data
//
//    func makeUIView(context: Context) -> PDFView {
//        let pdfView = PDFView()
//        pdfView.document = PDFDocument(data: data)
//        pdfView.autoScales = true
//        return pdfView
//    }
//
//    func updateUIView(_ uiView: PDFView, context: Context) {}
//}
//
//struct StatefulPreviewWrapper<Value, Content: View>: View {
//    @State private var value: Value
//    var content: (Binding<Value>) -> Content
//
//    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
//        _value = State(initialValue: value)
//        self.content = content
//    }
//
//    var body: some View {
//        content($value)
//    }
//}
//
//#Preview {
//    StatefulPreviewWrapper("") { binding in
//        ResumeUploadView(resumeText: binding, walletAddress: "0x123...")
//    }
//}
//
import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct ResumeUploadView: View {
    @State private var selectedFileURL: URL? = nil
    @State private var pdfData: Data? = nil
    @State private var fileName: String = ""
    @State private var showPicker = false
    @State private var navigateToSkillExtraction = false
    @Binding var resumeText: String
    let walletAddress: String

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        walletInfoCard
                        uploadSection
                        
                        if let pdfData = pdfData {
                            pdfPreviewCard(data: pdfData)
                        }
                        
                        if !resumeText.isEmpty && resumeText != "Unsupported file type" {
                            textPreviewCard
                        }
                        
                        if resumeText == "Unsupported file type" {
                            errorCard
                        }
                        
                        Spacer(minLength: 50)
                        navigationButtons
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                }
            }
        }
        .navigationTitle("Resume Upload")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPicker) {
            DocumentPicker(
                selectedFileURL: $selectedFileURL,
                pdfData: $pdfData,
                resumeText: $resumeText
            )
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            angularGradient
            topLeadingRadialGradient
            bottomTrailingRadialGradient
        }
        .ignoresSafeArea()
    }
    
    private var angularGradient: some View {
        AngularGradient(
            gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.1, blue: 0.4),
                Color.purple,
                Color.pink,
                Color(red: 0.2, green: 0.5, blue: 1.0),
                Color.purple
            ]),
            center: .center
        )
        .blur(radius: 100)
    }
    
    private var topLeadingRadialGradient: some View {
        RadialGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.2),
                Color.clear
            ]),
            center: .topLeading,
            startRadius: 10,
            endRadius: 500
        )
    }
    
    private var bottomTrailingRadialGradient: some View {
        RadialGradient(
            gradient: Gradient(colors: [
                Color.pink.opacity(0.2),
                Color.clear
            ]),
            center: .bottomTrailing,
            startRadius: 10,
            endRadius: 400
        )
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("📄 Upload Resume")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.pink)
                .shadow(color: .pink, radius: 5)
            
            Text("Step 2 of 7")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top)
    }
    
    // MARK: - Wallet Info Card
    private var walletInfoCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("🔗 Connected Wallet")
                    .font(.headline)
                    .foregroundColor(.mint)
                
                Text(walletAddressDisplay)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    private var walletAddressDisplay: String {
        let prefix = walletAddress.prefix(10)
        let suffix = walletAddress.suffix(10)
        return "\(prefix)...\(suffix)"
    }
    
    // MARK: - Upload Section
    private var uploadSection: some View {
        VStack(spacing: 16) {
            uploadButton
            supportedFormatsText
        }
    }
    
    private var uploadButton: some View {
        Button(action: { showPicker = true }) {
            VStack(spacing: 12) {
                uploadIcon
                uploadText
                
                if let url = selectedFileURL {
                    fileNameText(url: url)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(uploadButtonBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var uploadIcon: some View {
        Image(systemName: selectedFileURL == nil ? "doc.badge.plus" : "doc.checkmark")
            .font(.system(size: 40))
            .foregroundColor(selectedFileURL == nil ? .blue : .green)
    }
    
    private var uploadText: some View {
        Text(selectedFileURL == nil ? "Choose Resume" : "Resume Selected ✓")
            .font(.headline)
            .foregroundColor(.white)
    }
    
    private func fileNameText(url: URL) -> some View {
        Text(url.lastPathComponent)
            .font(.caption)
            .foregroundColor(.gray)
    }
    
    private var uploadButtonBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.blue.opacity(0.2))
            .overlay(dashedBorder)
    }
    
    private var dashedBorder: some View {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [10]))
        }
    
    private var supportedFormatsText: some View {
        Text("Supported formats: PDF, TXT, JSON")
            .font(.caption)
            .foregroundColor(.white.opacity(0.6))
    }
    
    // MARK: - PDF Preview Card
    private func pdfPreviewCard(data: Data) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("📋 Resume Preview")
                    .font(.headline)
                    .foregroundColor(.white)
                
                PDFKitView(data: data)
                    .frame(height: 250)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
    }
    
    // MARK: - Text Preview Card
    private var textPreviewCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                textPreviewHeader
                textPreviewScrollView
            }
        }
    }
    
    private var textPreviewHeader: some View {
        HStack {
            Text("📝 Extracted Text")
                .font(.headline)
                .foregroundColor(.orange)
            
            Spacer()
            
            Text("\(resumeText.count) chars")
                .font(.caption)
                .foregroundColor(.orange.opacity(0.8))
        }
    }
    
    private var textPreviewScrollView: some View {
        ScrollView {
            Text(textPreview)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 120)
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
    }
    
    private var textPreview: String {
        let maxLength = 500
        if resumeText.count > maxLength {
            return String(resumeText.prefix(maxLength)) + "..."
        }
        return resumeText
    }
    
    // MARK: - Error Card
    private var errorCard: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 30))
                    .foregroundColor(.red)
                
                Text("Unsupported File Type")
                    .font(.headline)
                    .foregroundColor(.red)
                
                Text("Please upload a PDF, TXT, or JSON file")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        VStack(spacing: 12) {
            nextStepButton
            
            if selectedFileURL != nil {
                reUploadButton
            }
        }
        .padding(.horizontal)
    }
    
    private var nextStepButton: some View {
        NavigationLink(
            destination: SkillExtractionView(
                resumeText: resumeText,
                walletAddress: walletAddress
            )
        ) {
            nextStepButtonContent
        }
        .disabled(isNextStepDisabled)
        .opacity(isNextStepDisabled ? 0.5 : 1.0)
    }
    
    private var nextStepButtonContent: some View {
        HStack {
            Text("Next: Extract Skills")
            Image(systemName: "brain.head.profile")
        }
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(nextStepButtonGradient)
        .cornerRadius(12)
        .shadow(color: .green, radius: 10)
    }
    
    private var nextStepButtonGradient: LinearGradient {
        LinearGradient(
            colors: [Color.green, Color.mint],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var isNextStepDisabled: Bool {
        resumeText.isEmpty || resumeText == "Unsupported file type"
    }
    
    private var reUploadButton: some View {
        Button("📁 Choose Different File") {
            resetFileSelection()
            showPicker = true
        }
        .buttonStyle(NeonButtonStyle(color: .orange))
    }
    
    private func resetFileSelection() {
        selectedFileURL = nil
        pdfData = nil
        resumeText = ""
    }
}

// MARK: - PDFKit View
struct PDFKitView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}


// MARK: - Preview Helper
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    var content: (Binding<Value>) -> Content

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}

#Preview {
    NavigationView {
        StatefulPreviewWrapper("") { binding in
            ResumeUploadView(
                resumeText: binding,
                walletAddress: "0x1234567890abcdef1234567890abcdef12345678"
            )
        }
    }
}
