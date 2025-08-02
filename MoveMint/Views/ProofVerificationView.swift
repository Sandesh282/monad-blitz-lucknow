import SwiftUI
import Foundation

struct ProofVerificationView: View {
    let extractedData: ExtractedData
    let walletAddress: String
    
    @StateObject private var verificationService = ProofVerificationService()
    @State private var navigateToScoring = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        
                        if verificationService.isVerifying {
                            verificationProgressCard
                        } else if verificationService.verificationResult == nil {
                            githubInputCard
                            summaryCard
                            startVerificationButton
                        } else {
                            verificationResultsSection
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle("Proof Verification")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
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
        .ignoresSafeArea()
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("🔍 Proof Verification")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.cyan)
                .shadow(color: .cyan, radius: 5)
            
            Text("Step 4 of 7")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top)
    }
    
    // MARK: - GitHub Input Card
    private var githubInputCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.title2)
                        .foregroundColor(.purple)
                    
                    Text("GitHub Verification")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Text("Enter your GitHub username to verify your coding projects and skills")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                TextField("GitHub Username", text: $verificationService.githubUsername)
                    .textFieldStyle(NeonTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !verificationService.githubUsername.isEmpty {
                    Text("Will verify: github.com/\(verificationService.githubUsername)")
                        .font(.caption)
                        .foregroundColor(.purple.opacity(0.8))
                }
            }
        }
    }
    
    // MARK: - Summary Card
    private var summaryCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("📊 Verification Summary")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                VStack(spacing: 8) {
                    verificationItem(icon: "🛠", title: "Skills to Verify", count: extractedData.skills.count)
                    verificationItem(icon: "🚀", title: "Projects to Verify", count: extractedData.projects.count)
                    verificationItem(icon: "💼", title: "Experience Entries", count: extractedData.experience.count)
                    verificationItem(icon: "🏆", title: "Certifications", count: extractedData.certifications.count)
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Verification Sources:")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    
                    HStack(spacing: 16) {
                        verificationSource(icon: "📱", name: "GitHub", color: .purple)
                        verificationSource(icon: "⛓", name: "Blockchain", color: .blue)
                        verificationSource(icon: "🎫", name: "POAP", color: .green)
                    }
                }
            }
        }
    }
    
    private func verificationItem(icon: String, title: String, count: Int) -> some View {
        HStack {
            Text(icon)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            Spacer()
            Text("\(count)")
                .font(.caption.bold())
                .foregroundColor(.orange)
        }
    }
    
    private func verificationSource(icon: String, name: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.title2)
            Text(name)
                .font(.caption)
                .foregroundColor(color)
        }
    }
    
    // MARK: - Verification Progress Card
    private var verificationProgressCard: some View {
        GlassCard {
            VStack(spacing: 20) {
                Text("🔄 Verifying Proofs...")
                    .font(.title2.bold())
                    .foregroundColor(.purple)
                
                ProgressView(value: verificationService.verificationProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                    .scaleEffect(1.2)
                
                Text("\(Int(verificationService.verificationProgress * 100))% Complete")
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(spacing: 8) {
                    progressStep(step: 1, title: "GitHub Analysis", progress: verificationService.verificationProgress, threshold: 0.1)
                    progressStep(step: 2, title: "Blockchain Verification", progress: verificationService.verificationProgress, threshold: 0.5)
                    progressStep(step: 3, title: "POAP Events", progress: verificationService.verificationProgress, threshold: 0.8)
                    progressStep(step: 4, title: "Final Scoring", progress: verificationService.verificationProgress, threshold: 0.9)
                }
            }
            .padding()
        }
    }
    
    private func progressStep(step: Int, title: String, progress: Double, threshold: Double) -> some View {
        HStack {
            Circle()
                .fill(progress >= threshold ? Color.green : Color.gray.opacity(0.5))
                .frame(width: 20, height: 20)
                .overlay(
                    Text("\(step)")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                )
            
            Text(title)
                .font(.caption)
                .foregroundColor(progress >= threshold ? .green : .white.opacity(0.7))
            
            Spacer()
            
            if progress >= threshold {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
            }
        }
    }
    
    // MARK: - Start Verification Button
    private var startVerificationButton: some View {
        Button("🚀 Start Verification") {
            Task {
                await verificationService.verifyProofs(
                    extractedData: extractedData,
                    walletAddress: walletAddress
                )
            }
        }
        .buttonStyle(NeonButtonStyle(color: .purple))
    }
    
    // MARK: - Verification Results Section
    @ViewBuilder
    private var verificationResultsSection: some View {
        if let result = verificationService.verificationResult {
            VStack(spacing: 20) {
                // Final Score Card
                finalScoreCard(result: result)
                
                // GitHub Results
                if result.githubVerification.username != nil {
                    githubResultsCard(github: result.githubVerification)
                }
                
                // Blockchain Results
                blockchainResultsCard(blockchain: result.blockchainVerification)
                
                // POAP Results
                if !result.poapVerification.poaps.isEmpty {
                    poapResultsCard(poap: result.poapVerification)
                }
                
                // Verified Skills & Projects
                verifiedItemsCard(result: result)
                
                // Navigation Button
                NavigationLink(destination: ScoringView(verificationResult: result)) {
                    HStack {
                        Text("Next: View Final Score")
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
            }
        }
    }
    
    private func finalScoreCard(result: VerificationResult) -> some View {
        GlassCard {
            VStack(spacing: 12) {
                Text("🎯 Verification Complete!")
                    .font(.title2.bold())
                    .foregroundColor(.mint)
                
                Text("\(result.finalScore)")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.mint)
                    .shadow(color: .mint, radius: 10)
                
                Text("Final Score")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                HStack(spacing: 16) {
                    scoreBreakdown(title: "GitHub", score: result.githubVerification.score, color: .purple)
                    scoreBreakdown(title: "Blockchain", score: result.blockchainVerification.score, color: .blue)
                    scoreBreakdown(title: "POAP", score: result.poapVerification.score, color: .green)
                }
            }
        }
    }
    
    private func scoreBreakdown(title: String, score: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(color)
            Text("\(score)")
                .font(.headline.bold())
                .foregroundColor(.white)
        }
        .padding(8)
        .background(color.opacity(0.2))
        .cornerRadius(8)
    }
    
    private func githubResultsCard(github: GitHubVerification) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.title2)
                        .foregroundColor(.purple)
                    
                    Text("GitHub Verification")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(github.score) pts")
                        .font(.headline.bold())
                        .foregroundColor(.purple)
                }
                
                if let username = github.username {
                    HStack {
                        Text("Username:")
                            .foregroundColor(.white.opacity(0.7))
                        Text("@\(username)")
                            .foregroundColor(.purple)
                            .font(.monospaced(.body)())
                    }
                    .font(.caption)
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    githubStat(title: "Repositories", value: "\(github.repositories.count)", icon: "folder")
                    githubStat(title: "Languages", value: "\(github.languagesUsed.count)", icon: "laptopcomputer")
                    githubStat(title: "Verified Projects", value: "\(github.verifiedProjects.count)", icon: "checkmark.seal")
                }
                
                if !github.languagesUsed.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Languages Found:")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 60))
                        ], spacing: 6) {
                            ForEach(github.languagesUsed.prefix(10), id: \.self) { language in
                                Text(language.capitalized)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.purple.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func githubStat(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.purple)
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(8)
        .background(Color.purple.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func blockchainResultsCard(blockchain: BlockchainVerification) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "link")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Blockchain Activity")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(blockchain.score) pts")
                        .font(.headline.bold())
                        .foregroundColor(.blue)
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    blockchainStat(title: "Transactions", value: "\(blockchain.transactions)", icon: "arrow.left.arrow.right")
                    blockchainStat(title: "Tokens", value: "\(blockchain.tokensHeld.count)", icon: "dollarsign.circle")
                    blockchainStat(title: "NFTs", value: "\(blockchain.nftsOwned.count)", icon: "photo.artframe")
                    blockchainStat(title: "DeFi Protocols", value: "\(blockchain.defiProtocols.count)", icon: "building.columns")
                }
                
                if !blockchain.defiProtocols.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DeFi Protocols Used:")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 80))
                        ], spacing: 6) {
                            ForEach(blockchain.defiProtocols, id: \.self) { defiProtocol in
                                Text(defiProtocol)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func blockchainStat(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(8)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func poapResultsCard(poap: POAPVerification) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "ticket")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    Text("POAP Events")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(poap.score) pts")
                        .font(.headline.bold())
                        .foregroundColor(.green)
                }
                
                HStack(spacing: 20) {
                    VStack {
                        Text("\(poap.poaps.count)")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        Text("Total POAPs")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    VStack {
                        Text("\(poap.techEvents.count)")
                            .font(.title.bold())
                            .foregroundColor(.green)
                        Text("Tech Events")
                            .font(.caption)
                            .foregroundColor(.green.opacity(0.8))
                    }
                }
                
                if !poap.techEvents.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Tech Events:")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                        
                        ForEach(poap.techEvents.prefix(3), id: \.eventId) { event in
                            HStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 6, height: 6)
                                
                                Text(event.name)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(1)
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func verifiedItemsCard(result: VerificationResult) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("✅ Verification Results")
                    .font(.headline)
                    .foregroundColor(.mint)
                
                if !result.verifiedSkills.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("🛠 Verified Skills")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(result.verifiedSkills.count)/\(extractedData.skills.count)")
                                .font(.caption)
                                .foregroundColor(.mint.opacity(0.8))
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 80))
                        ], spacing: 6) {
                            ForEach(result.verifiedSkills, id: \.self) { skill in
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.mint)
                                    
                                    Text(skill)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.mint.opacity(0.2))
                                .cornerRadius(6)
                            }
                        }
                    }
                }
                
                if !result.verifiedProjects.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("🚀 Verified Projects")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(result.verifiedProjects.count)/\(extractedData.projects.count)")
                                .font(.caption)
                                .foregroundColor(.mint.opacity(0.8))
                        }
                        
                        ForEach(result.verifiedProjects.prefix(5), id: \.self) { project in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.mint)
                                
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
        }
    }
}

    private var navigationToScoreCalculation: some View {
        Group {
            if let result = verificationService.verificationResult {
                NavigationLink(destination: ScoreCalculationView(
                    verifiedSkills: convertToSkillScores(result: result),
                    verifiedProjects: convertToProjectScores(result: result),
                    verifiedPOAPs: convertToPOAPScores(result: result),
                    walletAddress: walletAddress
                )) {
                    HStack {
                        Image(systemName: "calculator")
                        Text("Calculate Final Score")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .blue, radius: 10)
                }
                .padding(.horizontal)
            }
        }
    }

    
    // MARK: - Conversion Functions
    private func convertToSkillScores(result: VerificationResult) -> [SkillScore] {
        return extractedData.skills.map { skill in
            let isVerified = result.verifiedSkills.contains(skill)
            let source: VerificationSource
            
            if result.githubVerification.languagesUsed.contains(where: { $0.lowercased() == skill.lowercased() }) {
                source = .github
            } else if isBlockchainSkill(skill) && result.blockchainVerification.transactions > 10 {
                source = .onChain
            } else if result.poapVerification.techEvents.contains(where: { $0.name.lowercased().contains(skill.lowercased()) }) {
                source = .poap
            } else {
                source = .manual
            }
            
            return SkillScore(
                skill: skill,
                isVerified: isVerified,
                source: source
            )
        }
    }
    
    private func convertToProjectScores(result: VerificationResult) -> [ProjectScore] {
        return extractedData.projects.map { project in
            let isVerified = result.verifiedProjects.contains(project)
            let githubRepo = result.githubVerification.repositories.first { repo in
                repo.name.lowercased().contains(project.lowercased()) ||
                project.lowercased().contains(repo.name.lowercased()) ||
                (repo.description?.lowercased().contains(project.lowercased()) ?? false)
            }
            
            var technologies: [String] = []
            if let language = githubRepo?.language {
                technologies.append(language)
            }
            if !githubRepo?.topics.isEmpty ?? true {
                technologies.append(contentsOf: githubRepo?.topics ?? [])
            }
            
            let githubUrl = githubRepo != nil && result.githubVerification.username != nil ?
                "https://github.com/\(result.githubVerification.username!)/\(githubRepo!.name)" : nil
            
            return ProjectScore(
                name: project,
                isVerified: isVerified,
                githubUrl: githubUrl,
                technologies: technologies
            )
        }
    }
    
    private func convertToPOAPScores(result: VerificationResult) -> [POAPScore] {
        return result.poapVerification.poaps.map { poap in
            POAPScore(
                name: poap.name,
                eventId: poap.eventId,
                date: poap.eventDate,
                imageUrl: poap.imageUrl
            )
        }
    }
    
    // MARK: - Helper Functions
    private func isBlockchainSkill(_ skill: String) -> Bool {
        let blockchainKeywords = ["blockchain", "web3", "ethereum", "solidity", "defi", "nft", "crypto", "smart contract"]
        return blockchainKeywords.contains { skill.lowercased().contains($0) }
    }


// MARK: - Custom Text Field Style
struct NeonTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.black.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.purple.opacity(0.7), lineWidth: 1)
            )
    }
}

// MARK: - Placeholder for Next Step
struct ScoringView: View {
    let verificationResult: VerificationResult
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🏆 Final Scoring")
                .font(.title)
                .foregroundColor(.mint)
            
            Text("Step 5 of 7")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Score Breakdown:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                scoreBreakdownRow(title: "GitHub Verification", score: verificationResult.githubVerification.score, maxScore: 500)
                scoreBreakdownRow(title: "Blockchain Activity", score: verificationResult.blockchainVerification.score, maxScore: 600)
                scoreBreakdownRow(title: "POAP Events", score: verificationResult.poapVerification.score, maxScore: 300)
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                HStack {
                    Text("Total Score:")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(verificationResult.finalScore)")
                        .font(.title.bold())
                        .foregroundColor(.mint)
                }
            }
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(16)
            
            Text("Next: Mint your Soulbound NFT!")
                .font(.headline)
                .foregroundColor(.purple)
        }
        .padding()
        .navigationTitle("Final Score")
    }
    
    private func scoreBreakdownRow(title: String, score: Int, maxScore: Int) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text("\(score)/\(maxScore)")
                .font(.monospaced(.body)())
                .foregroundColor(.mint)
        }
    }
}

#Preview {
    NavigationView {
        ProofVerificationView(
            extractedData: ExtractedData(
                skills: ["Swift", "Python", "Blockchain", "React"],
                projects: ["iOS App", "DeFi Protocol", "Web Dashboard"],
                experience: ["Senior iOS Developer at TechCorp"],
                education: ["Computer Science Degree"],
                certifications: ["AWS Certified Developer"]
            ),
            walletAddress: "0x1234567890abcdef1234567890abcdef12345678"
        )
    }
}
