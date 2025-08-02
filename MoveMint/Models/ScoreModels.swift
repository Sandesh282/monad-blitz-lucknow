import Foundation

// MARK: - Verification Source Enum
enum VerificationSource: String, Codable, CaseIterable {
    case github = "github"
    case onChain = "onChain"
    case poap = "poap"
    case manual = "manual"
    
    var displayName: String {
        switch self {
        case .github: return "GitHub"
        case .onChain: return "Blockchain"
        case .poap: return "POAP"
        case .manual: return "Manual"
        }
    }
    
    var icon: String {
        switch self {
        case .github: return "person.crop.circle.badge.checkmark"
        case .onChain: return "link"
        case .poap: return "ticket"
        case .manual: return "hand.raised"
        }
    }
}

// MARK: - Score Models
struct SkillScore: Codable, Identifiable {
    let id = UUID()
    let skill: String
    let isVerified: Bool
    let source: VerificationSource
    
    private enum CodingKeys: String, CodingKey {
        case skill, isVerified, source
    }
}

struct ProjectScore: Codable, Identifiable {
    let id = UUID()
    let name: String
    let isVerified: Bool
    let githubUrl: String?
    let technologies: [String]
    
    private enum CodingKeys: String, CodingKey {
        case name, isVerified, githubUrl, technologies
    }
}

struct POAPScore: Codable, Identifiable {
    let id = UUID()
    let name: String
    let eventId: String
    let date: Date
    let imageUrl: String?
    
    private enum CodingKeys: String, CodingKey {
        case name, eventId, date, imageUrl
    }
}

struct ScoreBreakdown: Codable {
    let verifiedSkills: [SkillScore]
    let verifiedProjects: [ProjectScore]
    let verifiedPOAPs: [POAPScore]
    let consistencyBonus: Int
    let diversityBonus: Int
}

struct TotalScore: Codable {
    let skillsScore: Int
    let projectsScore: Int
    let poapsScore: Int
    let bonusScore: Int
    let totalScore: Int
    let verificationDate: Date
    let breakdown: ScoreBreakdown
}

struct ScoreComparison {
    let previousScore: Int
    let currentScore: Int
    let improvement: Int
    let improvementPercentage: Double
    
    var isImprovement: Bool {
        return improvement > 0
    }
    
    var changeDescription: String {
        let sign = improvement >= 0 ? "+" : ""
        return "\(sign)\(improvement) points (\(String(format: "%.1f", improvementPercentage))%)"
    }
}
