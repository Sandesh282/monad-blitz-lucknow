import SwiftUI
import Charts

// MARK: - Data Models (Add these first)
struct verification_result {
    let final_score: Int
    let github_verification: github_verification_data
    let blockchain_verification: blockchain_verification_data
    let poap_verification: poap_verification_data
    let verified_skills: [String]
    let verified_projects: [String]
    let verification_date: Date = Date()
}

struct github_verification_data {
    let username: String
    let score: Int
    let repositories: [String]
    let languages_used: [String]
    let verified_projects: [String]
    let total_commits: Int = 0
}

struct blockchain_verification_data {
    let score: Int
    let transactions: Int
    let tokens_held: [token_info]
    let nfts_owned: [nft_info]
    let defi_protocols: [String]
    let contract_interactions: Int = 0
}

struct poap_verification_data {
    let score: Int
    let poaps: [poap_data]
    let tech_events: [poap_data]
}

struct token_info {
    let symbol: String
    let balance: Double
}

struct nft_info {
    let name: String
    let collection: String
}

struct poap_data: Identifiable {
    let id = UUID()
    let event_id: String
    let name: String
    let description: String = ""
    let image_url: String = ""
    let event_date: Date = Date()
}

struct final_scoring_view: View {
    let verification_result: verification_result
    @State private var animateScore = false
    @State private var showSkillBreakdown = false
    @State     private var selectedScoreCategory: score_category?
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        totalScoreCard
                        scoreBreakdownChart
                        categoryCardsSection
                        skillAnalysisSection
                        recommendationsSection
                        nextStepButton
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle("Final Score")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animateScore = true
            }
        }
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
            Text("🏆 Final Score Analysis")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.mint)
                .shadow(color: .mint, radius: 5)
            
            Text("Step 5 of 7")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top)
    }
    
    // MARK: - Total Score Card
    private var totalScoreCard: some View {
        glass_card {
            VStack(spacing: 20) {
                // Animated Score Display
                VStack(spacing: 8) {
                    Text("Total Skill Score")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(animateScore ? verification_result.final_score : 0)")
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                        .foregroundColor(.mint)
                        .shadow(color: .mint, radius: 15)
                        .contentTransition(.numericText())
                }
                
                // Score Grade
                scoreGrade
                
                // Quick Stats
                HStack(spacing: 20) {
                    quickStat(title: "Verified Skills", value: "\(verification_result.verified_skills.count)", color: .purple)
                    quickStat(title: "Verified Projects", value: "\(verification_result.verified_projects.count)", color: .blue)
                    quickStat(title: "Proof Sources", value: "3", color: .green)
                }
            }
        }
    }
    
    private var scoreGrade: some View {
        HStack(spacing: 8) {
            Text(getScoreGrade().emoji)
                .font(.title)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(getScoreGrade().grade)
                    .font(.title2.bold())
                    .foregroundColor(getScoreGrade().color)
                
                Text(getScoreGrade().description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding()
        .background(getScoreGrade().color.opacity(0.2))
        .cornerRadius(12)
    }
    
    private func quickStat(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Score Breakdown Chart
    private var scoreBreakdownChart: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("📊 Score Breakdown")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Chart
                Chart(scoreData, id: \.category) { item in
                    BarMark(
                        x: .value("Score", item.score),
                        y: .value("Category", item.category.rawValue)
                    )
                    .foregroundStyle(item.category.color.gradient)
                    .cornerRadius(6)
                }
                .frame(height: 150)
                .chartXScale(domain: 0...600)
                .chartXAxis {
                    AxisMarks(values: [0, 200, 400, 600]) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [2]))
                            .foregroundStyle(.white.opacity(0.3))
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                
                // Category Details
                VStack(spacing: 8) {
                    ForEach(scoreData, id: \.category) { data in
                        categoryRow(data: data)
                    }
                }
            }
        }
    }
    
    private func categoryRow(data: score_data) -> some View {
        Button {
            selectedScoreCategory = data.category
        } label: {
            HStack {
                Circle()
                    .fill(data.category.color)
                    .frame(width: 12, height: 12)
                
                Text(data.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(data.score)/\(data.maxScore)")
                    .font(.subheadline.bold())
                    .foregroundColor(data.category.color)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Category Cards Section
    private var categoryCardsSection: some View {
        VStack(spacing: 16) {
            // GitHub Card
            categoryCard(
                title: "🐙 GitHub Analysis",
                score: verification_result.github_verification.score,
                maxScore: 500,
                color: .purple,
                details: [
                    "Repositories: \(verification_result.github_verification.repositories.count)",
                    "Languages: \(verification_result.github_verification.languages_used.count)",
                    "Verified Projects: \(verification_result.github_verification.verified_projects.count)"
                ]
            )
            
            // Blockchain Card
            categoryCard(
                title: "⛓ Blockchain Activity",
                score: verification_result.blockchain_verification.score,
                maxScore: 600,
                color: .blue,
                details: [
                    "Transactions: \(verification_result.blockchain_verification.transactions)",
                    "Tokens: \(verification_result.blockchain_verification.tokens_held.count)",
                    "DeFi Protocols: \(verification_result.blockchain_verification.defi_protocols.count)"
                ]
            )
            
            // POAP Card
            categoryCard(
                title: "🎫 POAP Events",
                score: verification_result.poap_verification.score,
                maxScore: 300,
                color: .green,
                details: [
                    "Total POAPs: \(verification_result.poap_verification.poaps.count)",
                    "Tech Events: \(verification_result.poap_verification.tech_events.count)",
                    "Event Diversity: High"
                ]
            )
        }
    }
    
    private func categoryCard(title: String, score: Int, maxScore: Int, color: Color, details: [String]) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(score)/\(maxScore)")
                        .font(.headline.bold())
                        .foregroundColor(color)
                }
                
                // Progress Bar
                ProgressView(value: Double(score), total: Double(maxScore))
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .scaleEffect(1.2)
                
                // Details
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(details, id: \.self) { detail in
                        HStack {
                            Circle()
                                .fill(color.opacity(0.7))
                                .frame(width: 6, height: 6)
                            
                            Text(detail)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Skill Analysis Section
    private var skillAnalysisSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("🎯 Verified Skills Analysis")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("View All") {
                        showSkillBreakdown.toggle()
                    }
                    .font(.caption)
                    .foregroundColor(.mint)
                }
                
                // Skills Grid
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 100))
                ], spacing: 8) {
                    ForEach(verification_result.verified_skills.prefix(6), id: \.self) { skill in
                        skillBadge(skill: skill, isVerified: true)
                    }
                }
                
                if verification_result.verified_skills.count > 6 {
                    Text("+ \(verification_result.verified_skills.count - 6) more verified skills")
                        .font(.caption)
                        .foregroundColor(.mint.opacity(0.8))
                }
                
                // Skill Categories
                skillCategoryBreakdown
            }
        }
    }
    
    private func skillBadge(skill: String, isVerified: Bool) -> some View {
        HStack(spacing: 4) {
            if isVerified {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.mint)
            }
            
            Text(skill)
                .font(.caption)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isVerified ? Color.mint.opacity(0.2) : Color.gray.opacity(0.2))
        )
        .foregroundColor(.white)
    }
    
    private var skillCategoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Skill Categories:")
                .font(.subheadline.bold())
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                skillCategory(name: "Programming", count: 4, color: .purple)
                skillCategory(name: "Blockchain", count: 2, color: .blue)
                skillCategory(name: "Tools", count: 3, color: .green)
            }
        }
    }
    
    private func skillCategory(name: String, count: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title3.bold())
                .foregroundColor(color)
            
            Text(name)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(8)
        .background(color.opacity(0.2))
        .cornerRadius(8)
    }
    
    // MARK: - Recommendations Section
    private var recommendationsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("💡 Recommendations")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                VStack(spacing: 12) {
                    recommendationItem(
                        icon: "📈",
                        title: "Boost Your Score",
                        description: "Add more GitHub projects to increase verification",
                        action: "View Tips"
                    )
                    
                    recommendationItem(
                        icon: "🔗",
                        title: "Expand Blockchain Activity",
                        description: "Try more DeFi protocols to show Web3 expertise",
                        action: "Explore DeFi"
                    )
                    
                    recommendationItem(
                        icon: "🎪",
                        title: "Attend Tech Events",
                        description: "Collect more POAPs from hackathons and conferences",
                        action: "Find Events"
                    )
                }
            }
        }
    }
    
    private func recommendationItem(icon: String, title: String, description: String, action: String) -> some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button(action) {
                // Handle recommendation action
            }
            .font(.caption)
            .foregroundColor(.orange)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Next Step Button
    private var nextStepButton: some View {
        NavigationLink(destination: nft_minting_view(verification_result: verification_result)) {
            HStack {
                Text("🎨 Next: Mint Soulbound NFT")
                Image(systemName: "arrow.right")
            }
            .font(.headline.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.mint, .cyan],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .mint, radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - Helper Methods
    private var scoreData: [score_data] {
        [
            score_data(category: .github, score: verification_result.github_verification.score, maxScore: 500),
            score_data(category: .blockchain, score: verification_result.blockchain_verification.score, maxScore: 600),
            score_data(category: .poap, score: verification_result.poap_verification.score, maxScore: 300)
        ]
    }
    
    private func getScoreGrade() -> (grade: String, emoji: String, color: Color, description: String) {
        let score = verification_result.final_score
        
        switch score {
        case 1200...:
            return ("Expert", "🏆", .mint, "Exceptional skill verification")
        case 900..<1200:
            return ("Advanced", "⭐", .yellow, "Strong skill demonstration")
        case 600..<900:
            return ("Intermediate", "📈", .orange, "Good skill foundation")
        case 300..<600:
            return ("Beginner", "🌱", .green, "Building skill portfolio")
        default:
            return ("Getting Started", "🚀", .gray, "Begin your journey")
        }
    }
}

// MARK: - Supporting Data Models
struct score_data: Identifiable {
    let id = UUID()
    let category: score_category
    let score: Int
    let maxScore: Int
}

enum score_category: String, CaseIterable {
    case github = "GitHub"
    case blockchain = "Blockchain"
    case poap = "POAP Events"
    
    var color: Color {
        switch self {
        case .github: return .purple
        case .blockchain: return .blue
        case .poap: return .green
        }
    }
}

// MARK: - Glass Card Component
struct glass_card<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Placeholder for Step 6
struct nft_minting_view: View {
    let verification_result: verification_result
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎨 NFT Minting")
                .font(.title)
                .foregroundColor(.mint)
            
            Text("Step 6 of 7")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text("Coming Next: Mint your Soulbound NFT with verified skills!")
                .font(.headline)
                .foregroundColor(.purple)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("Mint NFT")
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        final_scoring_view(
            verification_result: verification_result(
                final_score: 850,
                github_verification: github_verification_data(
                    username: "johndoe",
                    score: 400,
                    repositories: ["iOS-App", "Web3-DApp", "ML-Project"],
                    languages_used: ["Swift", "Python", "JavaScript", "Solidity"],
                    verified_projects: ["iOS App", "DeFi Protocol"]
                ),
                blockchain_verification: blockchain_verification_data(
                    score: 350,
                    transactions: 25,
                    tokens_held: [
                        token_info(symbol: "ETH", balance: 2.5),
                        token_info(symbol: "USDC", balance: 1000.0),
                        token_info(symbol: "UNI", balance: 50.0)
                    ],
                    nfts_owned: [
                        nft_info(name: "CryptoPunk #1234", collection: "CryptoPunks"),
                        nft_info(name: "BAYC #5678", collection: "Bored Ape Yacht Club")
                    ],
                    defi_protocols: ["Uniswap", "AAVE", "Compound"]
                ),
                poap_verification: poap_verification_data(
                    score: 100,
                    poaps: [
                        poap_data(event_id: "1", name: "ETHGlobal Hackathon 2024"),
                        poap_data(event_id: "2", name: "DeFi Summit 2024")
                    ],
                    tech_events: [
                        poap_data(event_id: "1", name: "ETHGlobal Hackathon 2024")
                    ]
                ),
                verified_skills: ["Swift", "Python", "Blockchain", "React"],
                verified_projects: ["iOS App", "DeFi Protocol"]
            )
        )
    }
}
