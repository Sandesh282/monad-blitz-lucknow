import Foundation
import CoreData

// MARK: - Score Calculation Service
class ScoreCalculationService {
    static let shared = ScoreCalculationService()
    
    private init() {}
    
    // MARK: - Score Constants
    private let skillPointValue = 10
    private let projectPointValue = 15
    private let poapPointValue = 5
    private let consistencyBonusMultiplier = 1.2
    private let diversityBonusThreshold = 5
    
    // MARK: - Main Score Calculation
    func calculateTotalScore(
        skills: [SkillScore],
        projects: [ProjectScore],
        poaps: [POAPScore],
        walletAddress: String
    ) -> TotalScore {
        
        let verifiedSkills = skills.filter { $0.isVerified }
        let verifiedProjects = projects.filter { $0.isVerified }
        let verifiedPOAPs = poaps
        
        // Base scores
        let skillsScore = verifiedSkills.count * skillPointValue
        let projectsScore = verifiedProjects.count * projectPointValue
        let poapsScore = verifiedPOAPs.count * poapPointValue
        
        // Bonus calculations
        let consistencyBonus = calculateConsistencyBonus(
            skills: verifiedSkills,
            projects: verifiedProjects,
            poaps: verifiedPOAPs
        )
        
        let diversityBonus = calculateDiversityBonus(skills: verifiedSkills)
        
        let bonusScore = consistencyBonus + diversityBonus
        let baseTotal = skillsScore + projectsScore + poapsScore
        let totalScore = Int(Double(baseTotal + bonusScore) * getConsistencyMultiplier(
            skills: verifiedSkills,
            projects: verifiedProjects
        ))
        
        let breakdown = ScoreBreakdown(
            verifiedSkills: verifiedSkills,
            verifiedProjects: verifiedProjects,
            verifiedPOAPs: verifiedPOAPs,
            consistencyBonus: consistencyBonus,
            diversityBonus: diversityBonus
        )
        
        return TotalScore(
            skillsScore: skillsScore,
            projectsScore: projectsScore,
            poapsScore: poapsScore,
            bonusScore: bonusScore,
            totalScore: totalScore,
            verificationDate: Date(),
            breakdown: breakdown
        )
    }
    
    // MARK: - Bonus Calculations
    private func calculateConsistencyBonus(
        skills: [SkillScore],
        projects: [ProjectScore],
        poaps: [POAPScore]
    ) -> Int {
        let totalVerified = skills.count + projects.count + poaps.count
        let consistencyScore = min(totalVerified * 2, 50) // Max 50 points
        return consistencyScore
    }
    
    private func calculateDiversityBonus(skills: [SkillScore]) -> Int {
        let uniqueSources = Set(skills.map { $0.source })
        let diversityScore = uniqueSources.count * 5 // 5 points per unique source
        return min(diversityScore, 30) // Max 30 points
    }
    
    private func getConsistencyMultiplier(
        skills: [SkillScore],
        projects: [ProjectScore]
    ) -> Double {
        let totalItems = skills.count + projects.count
        if totalItems >= 10 {
            return consistencyBonusMultiplier
        } else if totalItems >= 5 {
            return 1.1
        }
        return 1.0
    }
    
    // MARK: - Score Comparison
    func compareScores(previous: TotalScore, current: TotalScore) -> ScoreComparison {
        let improvement = current.totalScore - previous.totalScore
        let improvementPercentage = previous.totalScore > 0 ? 
            Double(improvement) / Double(previous.totalScore) * 100 : 0
        
        return ScoreComparison(
            previousScore: previous.totalScore,
            currentScore: current.totalScore,
            improvement: improvement,
            improvementPercentage: improvementPercentage
        )
    }
    
    // MARK: - Score Persistence
    func saveScore(_ score: TotalScore, for walletAddress: String, in context: NSManagedObjectContext) {
        let scoreEntity = ScoreEntity(context: context)
        scoreEntity.walletAddress = walletAddress
        scoreEntity.totalScore = Int32(score.totalScore)
        scoreEntity.skillsScore = Int32(score.skillsScore)
        scoreEntity.projectsScore = Int32(score.projectsScore)
        scoreEntity.poapsScore = Int32(score.poapsScore)
        scoreEntity.bonusScore = Int32(score.bonusScore)
        scoreEntity.verificationDate = score.verificationDate
        
        do {
            try context.save()
        } catch {
            print("Error saving score: \(error)")
        }
    }
    
    func loadPreviousScore(for walletAddress: String, in context: NSManagedObjectContext) -> TotalScore? {
        let request: NSFetchRequest<ScoreEntity> = ScoreEntity.fetchRequest()
        request.predicate = NSPredicate(format: "walletAddress == %@", walletAddress)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ScoreEntity.verificationDate, ascending: false)]
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            guard let scoreEntity = results.first else { return nil }
            
            return TotalScore(
                skillsScore: Int(scoreEntity.skillsScore),
                projectsScore: Int(scoreEntity.projectsScore),
                poapsScore: Int(scoreEntity.poapsScore),
                bonusScore: Int(scoreEntity.bonusScore),
                totalScore: Int(scoreEntity.totalScore),
                verificationDate: scoreEntity.verificationDate ?? Date(),
                breakdown: ScoreBreakdown(
                    verifiedSkills: [],
                    verifiedProjects: [],
                    verifiedPOAPs: [],
                    consistencyBonus: Int(scoreEntity.bonusScore),
                    diversityBonus: 0
                )
            )
        } catch {
            print("Error loading previous score: \(error)")
            return nil
        }
    }
}

