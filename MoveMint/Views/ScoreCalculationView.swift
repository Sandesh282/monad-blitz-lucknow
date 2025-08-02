import SwiftUI
import CoreData
import Combine

struct ScoreCalculationView: View {
    
//    @StateObject private var scoreService = ScoreCalculationService.shared
    private let scoreService = ScoreCalculationService.shared
    @Environment(\.managedObjectContext) private var context
    
    // Input data from previous steps
    let verifiedSkills: [SkillScore]
    let verifiedProjects: [ProjectScore]
    let verifiedPOAPs: [POAPScore]
    let walletAddress: String
    
    @State private var calculatedScore: TotalScore?
    @State private var isCalculating = false
    @State private var showingDetails = false
    @State private var scoreComparison: ScoreComparison?
    @State private var showingShareSheet = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    if isCalculating {
                        calculatingSection
                    } else if let score = calculatedScore {
                        scoreResultSection(score)
                        scoreBreakdownSection(score)
                        comparisonSection
                        actionButtonsSection
                    } else {
                        verificationSummarySection
                        calculateButtonSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Score Calculation")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingDetails) {
            if let score = calculatedScore {
                ScoreDetailsView(score: score)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let score = calculatedScore {
                ShareScoreView(score: score, walletAddress: walletAddress)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Skill Score Calculation")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Your verified skills and projects are being scored")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Verification Summary
    private var verificationSummarySection: some View {
        VStack(spacing: 16) {
            Text("Verification Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                summaryCard(
                    title: "Skills",
                    count: verifiedSkills.filter { $0.isVerified }.count,
                    total: verifiedSkills.count,
                    icon: "brain.head.profile",
                    color: .blue
                )
                
                summaryCard(
                    title: "Projects",
                    count: verifiedProjects.filter { $0.isVerified }.count,
                    total: verifiedProjects.count,
                    icon: "folder.badge.gearshape",
                    color: .green
                )
                
                summaryCard(
                    title: "POAPs",
                    count: verifiedPOAPs.count,
                    total: verifiedPOAPs.count,
                    icon: "ticket",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    
    private func summaryCard(title: String, count: Int, total: Int, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text("\(count)/\(total)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Calculate Button
    private var calculateButtonSection: some View {
        VStack(spacing: 16) {
            Button(action: calculateScore) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                    
                    Text("Calculate Score")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(verifiedSkills.isEmpty && verifiedProjects.isEmpty && verifiedPOAPs.isEmpty)
            
            Text("Score calculation will analyze your verified skills, projects, and POAPs")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Calculating Section
    private var calculatingSection: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            
            Text("Calculating your score...")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Analyzing skill verification, project consistency, and blockchain activity")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    
    // MARK: - Score Result Section
    private func scoreResultSection(_ score: TotalScore) -> some View {
        VStack(spacing: 16) {
            Text("Your Score")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(score.totalScore)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
                .shadow(color: .blue.opacity(0.3), radius: 5)
            
            HStack(spacing: 20) {
                scoreDetailItem(label: "Skills", value: score.skillsScore, color: .blue)
                scoreDetailItem(label: "Projects", value: score.projectsScore, color: .green)
                scoreDetailItem(label: "POAPs", value: score.poapsScore, color: .orange)
                scoreDetailItem(label: "Bonus", value: score.bonusScore, color: .purple)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    
    private func scoreDetailItem(label: String, value: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Score Breakdown Section
    private func scoreBreakdownSection(_ score: TotalScore) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Score Breakdown")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                breakdownRow(
                    title: "Verified Skills",
                    score: score.skillsScore,
                    count: score.breakdown.verifiedSkills.count,
                    color: .blue
                )
                
                breakdownRow(
                    title: "Verified Projects",
                    score: score.projectsScore,
                    count: score.breakdown.verifiedProjects.count,
                    color: .green
                )
                
                breakdownRow(
                    title: "POAP Events",
                    score: score.poapsScore,
                    count: score.breakdown.verifiedPOAPs.count,
                    color: .orange
                )
                
                Divider()
                
                breakdownRow(
                    title: "Consistency Bonus",
                    score: score.breakdown.consistencyBonus,
                    color: .purple
                )
                
                breakdownRow(
                    title: "Diversity Bonus",
                    score: score.breakdown.diversityBonus,
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    
    private func breakdownRow(title: String, score: Int, count: Int? = nil, color: Color) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            if let count = count {
                Text("\(count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("\(score)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
    
    // MARK: - Comparison Section
    private var comparisonSection: some View {
        Group {
            if let comparison = scoreComparison {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Score Comparison")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Previous")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(comparison.previousScore)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Image(systemName: comparison.isImprovement ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .font(.title2)
                                .foregroundColor(comparison.isImprovement ? .green : .red)
                            
                            Text(comparison.changeDescription)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(comparison.isImprovement ? .green : .red)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Current")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(comparison.currentScore)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 2)
            }
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: { showingDetails = true }) {
                HStack {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("View Details")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            
            Button(action: { showingShareSheet = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Score")
                }
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Score Calculation
    private func calculateScore() {
        isCalculating = true
        
        // Simulate calculation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let score = scoreService.calculateTotalScore(
                skills: verifiedSkills,
                projects: verifiedProjects,
                poaps: verifiedPOAPs,
                walletAddress: walletAddress
            )
            
            // Load previous score for comparison
            if let previousScore = scoreService.loadPreviousScore(for: walletAddress, in: context) {
                scoreComparison = scoreService.compareScores(previous: previousScore, current: score)
            }
            
            // Save current score
            scoreService.saveScore(score, for: walletAddress, in: context)
            
            calculatedScore = score
            isCalculating = false
        }
    }
}

#Preview {
    NavigationView {
        ScoreCalculationView(
            verifiedSkills: [
                SkillScore(skill: "Swift", isVerified: true, source: .github),
                SkillScore(skill: "Python", isVerified: true, source: .github),
                SkillScore(skill: "Blockchain", isVerified: false, source: .manual)
            ],
            verifiedProjects: [
                ProjectScore(name: "iOS App", isVerified: true, githubUrl: "https://github.com/user/app", technologies: ["Swift", "SwiftUI"]),
                ProjectScore(name: "DeFi Protocol", isVerified: false, githubUrl: nil, technologies: ["Solidity", "Web3"])
            ],
            verifiedPOAPs: [
                POAPScore(name: "Ethereum Developer", eventId: "123", date: Date(), imageUrl: nil)
            ],
            walletAddress: "0x1234567890abcdef1234567890abcdef12345678"
        )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 
