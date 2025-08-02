import SwiftUI

// MARK: - NFT Minting View
struct NFTMintingView: View {
    let score: TotalScore
    let walletAddress: String
    
    var body: some View {
        VStack(spacing: 24) {
            Text("🏆")
                .font(.system(size: 80))
            
            Text("Mint Soulbound NFT")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Step 6 of 7")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                Text("Your Final Score")
                    .font(.headline)
                
                Text("\(score.totalScore)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                
                Text("Wallet: \(String(walletAddress.prefix(6)))...\(String(walletAddress.suffix(4)))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Text("NFT minting functionality coming in Step 6!")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Mint NFT")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Share Score View
struct ShareScoreView: View {
    let score: TotalScore
    let walletAddress: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("📊")
                    .font(.system(size: 60))
                
                Text("Share Your Score")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(spacing: 12) {
                    Text("Final Score: \(score.totalScore)")
                        .font(.headline)
                    
                    Text("Skills: \(score.skillsScore) | Projects: \(score.projectsScore) | POAPs: \(score.poapsScore)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Button("Share Score") {
                    // TODO: Implement sharing functionality
                    print("Sharing score: \(score.totalScore)")
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Score Details View
struct ScoreDetailsView: View {
    let score: TotalScore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("📈 Score Details")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Detailed breakdown of your skill verification score")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Overall Score
                    VStack(spacing: 16) {
                        Text("Overall Score")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("\(score.totalScore)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                        
                        Text("Verified on \(score.verificationDate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                    // Skills Breakdown
                    if !score.breakdown.verifiedSkills.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Verified Skills")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(score.breakdown.verifiedSkills) { skill in
                                    SkillCard(skill: skill)
                                }
                            }
                        }
                    }
                    
                    // Projects Breakdown
                    if !score.breakdown.verifiedProjects.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Verified Projects")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            ForEach(score.breakdown.verifiedProjects) { project in
                                ProjectCard(project: project)
                            }
                        }
                    }
                    
                    // POAPs Breakdown
                    if !score.breakdown.verifiedPOAPs.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("POAP Events")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(score.breakdown.verifiedPOAPs) { poap in
                                    POAPCard(poap: poap)
                                }
                            }
                        }
                    }
                    
                    // Bonus Breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Bonus Points")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            BonusRow(
                                title: "Consistency Bonus",
                                points: score.breakdown.consistencyBonus,
                                description: "Reward for consistent skill verification across multiple sources"
                            )
                            
                            BonusRow(
                                title: "Diversity Bonus",
                                points: score.breakdown.diversityBonus,
                                description: "Reward for diverse skill verification sources"
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Score Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct SkillCard: View {
    let skill: SkillScore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: skill.source.icon)
                    .foregroundColor(skill.source.displayColor)
                
                Text(skill.skill)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if skill.isVerified {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            Text(skill.source.displayName)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ProjectCard: View {
    let project: ProjectScore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(project.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if project.isVerified {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            if let githubUrl = project.githubUrl {
                Link("View on GitHub", destination: URL(string: githubUrl)!)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            if !project.technologies.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(project.technologies, id: \.self) { tech in
                            Text(tech)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct POAPCard: View {
    let poap: POAPScore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "ticket")
                    .foregroundColor(.orange)
                
                Text(poap.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Spacer()
            }
            
            Text(poap.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct BonusRow: View {
    let title: String
    let points: Int
    let description: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text("+\(points)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.purple)
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Extensions
extension VerificationSource {
    var displayColor: Color {
        switch self {
        case .github: return .blue
        case .onChain: return .green
        case .poap: return .orange
        case .manual: return .gray
        }
    }
} 