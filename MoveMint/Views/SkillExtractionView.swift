//
//  SkillExtractionView.swift
//  MoveMint
//
//  Created by Sandesh Raj on 02/08/25.
//
import SwiftUI

struct SkillExtractionView: View {
    let resumeText: String
    let walletAddress: String
    
    @StateObject private var extractionService = SkillExtractionService()
    @State private var showFullResume = false
    @State private var navigateToVerification = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Neon background gradient
                ZStack {
                    AngularGradient(gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.4),
                        Color.purple,
                        Color.pink,
                        Color(red: 0.2, green: 0.5, blue: 1.0),
                        Color.purple
                    ]), center: .center)
                    .blur(radius: 100)

                    RadialGradient(gradient: Gradient(colors: [
                        Color.white.opacity(0.2),
                        Color.clear
                    ]), center: .topLeading, startRadius: 10, endRadius: 500)
                }
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("🧠 AI Skill Extraction")
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundColor(.cyan)
                                .shadow(color: .cyan, radius: 5)
                            
                            Text("Step 3 of 7")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top)
                        
                        // Resume Preview Card
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("📄 Resume Preview")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Button("View Full") {
                                        showFullResume.toggle()
                                    }
                                    .font(.caption)
                                    .foregroundColor(.cyan)
                                }
                                
                                Text(resumeText.prefix(200) + "...")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(showFullResume ? nil : 4)
                                
                                Text("Characters: \(resumeText.count)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Processing State
                        if extractionService.isProcessing {
                            GlassCard {
                                VStack(spacing: 16) {
                                    Text("🔍 Analyzing Resume...")
                                        .font(.headline)
                                        .foregroundColor(.purple)
                                    
                                    ProgressView(value: extractionService.extractionProgress)
                                        .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                                        .scaleEffect(1.2)
                                    
                                    Text("\(Int(extractionService.extractionProgress * 100))% Complete")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding()
                            }
                        }
                        
                        // Results
                        if let extractedData = extractionService.extractedData {
                            VStack(spacing: 16) {
                                // Score Card
                                GlassCard {
                                    VStack {
                                        Text("🎯 Preliminary Score")
                                            .font(.headline)
                                            .foregroundColor(.mint)
                                        
                                        Text("\(extractionService.calculatePreliminaryScore())")
                                            .font(.system(size: 42, weight: .bold, design: .monospaced))
                                            .foregroundColor(.mint)
                                            .shadow(color: .mint, radius: 5)
                                        
                                        Text("Points (Before Verification)")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                
                                // Skills by Category
                                let categorizedSkills = extractionService.getSkillsByCategory()
                                if !categorizedSkills.isEmpty {
                                    GlassCard {
                                        VStack(alignment: .leading, spacing: 12) {
                                            HStack {
                                                Text("🛠 Extracted Skills")
                                                    .font(.headline)
                                                    .foregroundColor(.orange)
                                                
                                                Spacer()
                                                
                                                Text("\(extractedData.skills.count) found")
                                                    .font(.caption)
                                                    .foregroundColor(.orange.opacity(0.8))
                                            }
                                            
                                            ForEach(categorizedSkills.keys.sorted(), id: \.self) { category in
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(category)
                                                        .font(.subheadline.bold())
                                                        .foregroundColor(.white)
                                                    
                                                    LazyVGrid(columns: [
                                                        GridItem(.adaptive(minimum: 80))
                                                    ], spacing: 8) {
                                                        ForEach(categorizedSkills[category] ?? [], id: \.self) { skill in
                                                            Text(skill)
                                                                .font(.caption)
                                                                .padding(.horizontal, 8)
                                                                .padding(.vertical, 4)
                                                                .background(Color.orange.opacity(0.3))
                                                                .foregroundColor(.white)
                                                                .cornerRadius(8)
                                                        }
                                                    }
                                                }
                                                .padding(.bottom, 8)
                                            }
                                        }
                                    }
                                }
                                
                                // Projects
                                if !extractedData.projects.isEmpty {
                                    GlassCard {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Text("🚀 Projects Found")
                                                    .font(.headline)
                                                    .foregroundColor(.green)
                                                
                                                Spacer()
                                                
                                                Text("\(extractedData.projects.count)")
                                                    .font(.caption)
                                                    .foregroundColor(.green.opacity(0.8))
                                            }
                                            
                                            ForEach(extractedData.projects.prefix(5), id: \.self) { project in
                                                HStack {
                                                    Circle()
                                                        .fill(Color.green)
                                                        .frame(width: 6, height: 6)
                                                    
                                                    Text(project)
                                                        .font(.caption)
                                                        .foregroundColor(.white.opacity(0.9))
                                                        .lineLimit(2)
                                                    
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // Experience & Education Summary
                                HStack(spacing: 12) {
                                    if !extractedData.experience.isEmpty {
                                        GlassCard {
                                            VStack {
                                                Text("💼")
                                                    .font(.title2)
                                                Text("Experience")
                                                    .font(.caption.bold())
                                                    .foregroundColor(.blue)
                                                Text("\(extractedData.experience.count)")
                                                    .font(.title3.bold())
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                    
                                    if !extractedData.education.isEmpty {
                                        GlassCard {
                                            VStack {
                                                Text("🎓")
                                                    .font(.title2)
                                                Text("Education")
                                                    .font(.caption.bold())
                                                    .foregroundColor(.purple)
                                                Text("\(extractedData.education.count)")
                                                    .font(.title3.bold())
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                    
                                    if !extractedData.certifications.isEmpty {
                                        GlassCard {
                                            VStack {
                                                Text("🏆")
                                                    .font(.title2)
                                                Text("Certifications")
                                                    .font(.caption.bold())
                                                    .foregroundColor(.yellow)
                                                Text("\(extractedData.certifications.count)")
                                                    .font(.title3.bold())
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            if extractionService.extractedData == nil && !extractionService.isProcessing {
                                Button("🔍 Extract Skills & Projects") {
                                    Task {
                                        await extractionService.extractSkillsAndProjects(from: resumeText)
                                    }
                                }
                                .buttonStyle(NeonButtonStyle(color: .purple))
                            }
                            
                            if extractionService.extractedData != nil {
                                NavigationLink(
                                    destination: ProofVerificationStruct(
                                        extractedData: extractionService.extractedData!,
                                        walletAddress: walletAddress
                                    )
                                ) {
                                    HStack {
                                        Text("Next: Verify Proofs")
                                        Image(systemName: "arrow.right")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(12)
                                    .shadow(color: .green, radius: 10)
                                }
                                .padding(.horizontal)
                                
                                Button("🔄 Re-analyze Resume") {
                                    Task {
                                        await extractionService.extractSkillsAndProjects(from: resumeText)
                                    }
                                }
                                .buttonStyle(NeonButtonStyle(color: .orange))
                            }
                        }
                        .padding(.bottom, 100)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Skill Extraction")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Auto-start extraction when view appears
            if extractionService.extractedData == nil && !extractionService.isProcessing {
                Task {
                    await extractionService.extractSkillsAndProjects(from: resumeText)
                }
            }
        }
    }
}

// Placeholder for the next step
struct ProofVerificationStruct: View {
    let extractedData: ExtractedData
    let walletAddress: String
    
    var body: some View {
        VStack {
            Text("🔍 Proof Verification")
                .font(.title)
            Text("Coming Next: Step 4")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Show summary of what will be verified
            VStack(alignment: .leading, spacing: 8) {
                Text("Will verify:")
                Text("• \(extractedData.skills.count) skills")
                Text("• \(extractedData.projects.count) projects")
                Text("• GitHub repositories")
                Text("• On-chain activity for \(walletAddress.prefix(10))...")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
        .navigationTitle("Verification")
    }
}



#Preview {
    NavigationView {
        SkillExtractionView(
            resumeText: "I am a Swift developer with 5 years of experience. I have built iOS apps using SwiftUI and UIKit. I worked on blockchain projects using Ethereum and Solidity. I have a Computer Science degree from MIT. I am AWS certified and have experience with Python, React, and Node.js. Built a DeFi trading app and an NFT marketplace.",
            walletAddress: "0x1234567890abcdef"
        )
    }
}
