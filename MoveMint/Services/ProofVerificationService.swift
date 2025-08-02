import Foundation
import SwiftUI

// MARK: - Data Models
struct VerificationResult {
    let githubVerification: GitHubVerification
    let blockchainVerification: BlockchainVerification
    let poapVerification: POAPVerification
    let finalScore: Int
    let verifiedSkills: [String]
    let verifiedProjects: [String]
    let verificationDate: Date
}

struct GitHubVerification {
    let username: String?
    let repositories: [GitHubRepo]
    let totalCommits: Int
    let languagesUsed: [String]
    let verifiedProjects: [String]
    let score: Int
}

struct GitHubRepo {
    let name: String
    let description: String?
    let language: String?
    let stars: Int
    let forks: Int
    let lastUpdated: Date
    let topics: [String]
}

struct BlockchainVerification {
    let transactions: Int
    let contractInteractions: Int
    let tokensHeld: [TokenInfo]
    let nftsOwned: [NFTInfo]
    let defiProtocols: [String]
    let score: Int
}

struct TokenInfo {
    let name: String
    let symbol: String
    let balance: String
    let contractAddress: String
}

struct NFTInfo {
    let name: String
    let collection: String
    let tokenId: String
    let contractAddress: String
}

struct POAPVerification {
    let poaps: [POAP]
    let techEvents: [POAP]
    let score: Int
}

struct POAP {
    let eventId: String
    let name: String
    let description: String
    let imageUrl: String
    let eventDate: Date
}

// MARK: - Verification Service
@MainActor
class ProofVerificationService: ObservableObject {
    @Published var verificationResult: VerificationResult?
    @Published var isVerifying = false
    @Published var verificationProgress: Double = 0.0
    @Published var errorMessage: String?
    @Published var githubUsername: String = ""
    
    // API Configuration
    private let covalentAPIKey = "cqt_rQkqQCqK6tBbHq7TKr3k7J9VKGfK" // Demo key
    private let githubAPIBase = "https://api.github.com"
    private let poapAPIBase = "https://api.poap.tech"
    
    func verifyProofs(extractedData: ExtractedData, walletAddress: String) async {
        await MainActor.run {
            isVerifying = true
            verificationProgress = 0.0
            errorMessage = nil
        }
        
        do {
            // Step 1: GitHub Verification
            await updateProgress(0.1, status: "Verifying GitHub profile...")
            let githubResult = await verifyGitHub(skills: extractedData.skills, projects: extractedData.projects)
            
            // Step 2: Blockchain Verification
            await updateProgress(0.5, status: "Analyzing blockchain activity...")
            let blockchainResult = await verifyBlockchain(walletAddress: walletAddress, skills: extractedData.skills)
            
            // Step 3: POAP Verification
            await updateProgress(0.8, status: "Checking POAP events...")
            let poapResult = await verifyPOAPs(walletAddress: walletAddress)
            
            // Step 4: Calculate Final Score
            await updateProgress(0.9, status: "Calculating final score...")
            let finalScore = calculateFinalScore(
                extractedData: extractedData,
                githubResult: githubResult,
                blockchainResult: blockchainResult,
                poapResult: poapResult
            )
            
            let verifiedSkills = getVerifiedSkills(
                extractedSkills: extractedData.skills,
                githubLanguages: githubResult.languagesUsed,
                blockchainActivity: blockchainResult
            )
            
            let verifiedProjects = getVerifiedProjects(
                extractedProjects: extractedData.projects,
                githubRepos: githubResult.repositories
            )
            
            await updateProgress(1.0, status: "Verification complete!")
            
            let result = VerificationResult(
                githubVerification: githubResult,
                blockchainVerification: blockchainResult,
                poapVerification: poapResult,
                finalScore: finalScore,
                verifiedSkills: verifiedSkills,
                verifiedProjects: verifiedProjects,
                verificationDate: Date()
            )
            
            await MainActor.run {
                self.verificationResult = result
                self.isVerifying = false
                self.verificationProgress = 0.0
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Verification failed: \(error.localizedDescription)"
                self.isVerifying = false
                self.verificationProgress = 0.0
            }
        }
    }
    
    private func updateProgress(_ progress: Double, status: String) async {
        await MainActor.run {
            verificationProgress = progress
            print("Verification: \(status)")
        }
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
    }
    
    // MARK: - GitHub Verification
    private func verifyGitHub(skills: [String], projects: [String]) async -> GitHubVerification {
        guard !githubUsername.isEmpty else {
            return GitHubVerification(
                username: nil,
                repositories: [],
                totalCommits: 0,
                languagesUsed: [],
                verifiedProjects: [],
                score: 0
            )
        }
        
        do {
            // Fetch user repositories
            let repos = try await fetchGitHubRepositories(username: githubUsername)
            
            // Extract languages from repositories
            let languages = extractLanguagesFromRepos(repos)
            
            // Verify projects by matching repo names/descriptions with extracted projects
            let verifiedProjects = verifyProjectsWithRepos(projects: projects, repos: repos)
            
            // Calculate GitHub score
            let score = calculateGitHubScore(repos: repos, languages: languages, verifiedProjects: verifiedProjects)
            
            return GitHubVerification(
                username: githubUsername,
                repositories: repos,
                totalCommits: repos.reduce(0) { $0 + ($1.stars + $1.forks) }, // Approximation
                languagesUsed: languages,
                verifiedProjects: verifiedProjects,
                score: score
            )
            
        } catch {
            print("GitHub verification error: \(error)")
            return GitHubVerification(
                username: githubUsername,
                repositories: [],
                totalCommits: 0,
                languagesUsed: [],
                verifiedProjects: [],
                score: 0
            )
        }
    }
    
    private func fetchGitHubRepositories(username: String) async throws -> [GitHubRepo] {
        let url = URL(string: "\(githubAPIBase)/users/\(username)/repos?per_page=30&sort=updated")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let repoResponse = try decoder.decode([GitHubRepoResponse].self, from: data)
        
        return repoResponse.map { repo in
            GitHubRepo(
                name: repo.name,
                description: repo.description,
                language: repo.language,
                stars: repo.stargazers_count,
                forks: repo.forks_count,
                lastUpdated: repo.updated_at,
                topics: repo.topics ?? []
            )
        }
    }
    
    private func extractLanguagesFromRepos(_ repos: [GitHubRepo]) -> [String] {
        let languages = repos.compactMap { $0.language }.map { $0.lowercased() }
        return Array(Set(languages))
    }
    
    private func verifyProjectsWithRepos(projects: [String], repos: [GitHubRepo]) -> [String] {
        var verified: [String] = []
        
        for project in projects {
            for repo in repos {
                let projectLower = project.lowercased()
                let repoName = repo.name.lowercased()
                let repoDesc = repo.description?.lowercased() ?? ""
                
                if repoName.contains(projectLower) || projectLower.contains(repoName) ||
                   repoDesc.contains(projectLower) || projectLower.contains(repoDesc) {
                    verified.append(project)
                    break
                }
            }
        }
        
        return verified
    }
    
    private func calculateGitHubScore(repos: [GitHubRepo], languages: [String], verifiedProjects: [String]) -> Int {
        var score = 0
        
        // Points for repositories
        score += repos.count * 10
        
        // Points for stars and forks
        let totalStars = repos.reduce(0) { $0 + $1.stars }
        let totalForks = repos.reduce(0) { $0 + $1.forks }
        score += totalStars * 2
        score += totalForks * 3
        
        // Points for languages
        score += languages.count * 15
        
        // Points for verified projects
        score += verifiedProjects.count * 25
        
        return min(score, 500) // Cap at 500 points
    }
    
    // MARK: - Blockchain Verification
    private func verifyBlockchain(walletAddress: String, skills: [String]) async -> BlockchainVerification {
        do {
            // Fetch transaction history using Covalent API
            let transactions = try await fetchTransactionHistory(walletAddress: walletAddress)
            
            // Fetch token balances
            let tokens = try await fetchTokenBalances(walletAddress: walletAddress)
            
            // Fetch NFTs
            let nfts = try await fetchNFTs(walletAddress: walletAddress)
            
            // Analyze DeFi protocol interactions
            let defiProtocols = analyzeDeFiInteractions(transactions: transactions)
            
            let score = calculateBlockchainScore(
                transactions: transactions,
                tokens: tokens,
                nfts: nfts,
                defiProtocols: defiProtocols,
                skills: skills
            )
            
            return BlockchainVerification(
                transactions: transactions,
                contractInteractions: transactions / 2, // Approximation
                tokensHeld: tokens,
                nftsOwned: nfts,
                defiProtocols: defiProtocols,
                score: score
            )
            
        } catch {
            print("Blockchain verification error: \(error)")
            return BlockchainVerification(
                transactions: 0,
                contractInteractions: 0,
                tokensHeld: [],
                nftsOwned: [],
                defiProtocols: [],
                score: 0
            )
        }
    }
    
    private func fetchTransactionHistory(walletAddress: String) async throws -> Int {
        // Using Covalent API to get transaction count
        let url = URL(string: "https://api.covalenthq.com/v1/1/address/\(walletAddress)/transactions_v2/?key=\(covalentAPIKey)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Parse the response and return transaction count
        // For demo purposes, returning a mock value
        return Int.random(in: 10...500)
    }
    
    private func fetchTokenBalances(walletAddress: String) async throws -> [TokenInfo] {
        // Mock token data for demo
        return [
            TokenInfo(name: "Ethereum", symbol: "ETH", balance: "0.5", contractAddress: ""),
            TokenInfo(name: "USD Coin", symbol: "USDC", balance: "100.0", contractAddress: "0xa0b86a33e6776843db3db6c9d8b6ba6c6b4c5b2d"),
            TokenInfo(name: "Chainlink", symbol: "LINK", balance: "50.0", contractAddress: "0x514910771AF9Ca656af840dff83E8264EcF986CA")
        ]
    }
    
    private func fetchNFTs(walletAddress: String) async throws -> [NFTInfo] {
        // Mock NFT data for demo
        return [
            NFTInfo(name: "Bored Ape #123", collection: "Bored Ape Yacht Club", tokenId: "123", contractAddress: "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D"),
            NFTInfo(name: "CryptoPunk #456", collection: "CryptoPunks", tokenId: "456", contractAddress: "0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB")
        ]
    }
    
    private func analyzeDeFiInteractions(transactions: Int) -> [String] {
        // Mock DeFi protocol detection based on transaction count
        if transactions > 100 {
            return ["Uniswap", "Compound", "Aave"]
        } else if transactions > 50 {
            return ["Uniswap", "SushiSwap"]
        } else {
            return ["Uniswap"]
        }
    }
    
    private func calculateBlockchainScore(transactions: Int, tokens: [TokenInfo], nfts: [NFTInfo], defiProtocols: [String], skills: [String]) -> Int {
        var score = 0
        
        // Points for transaction activity
        score += min(transactions, 100) * 2
        
        // Points for token diversity
        score += tokens.count * 20
        
        // Points for NFT ownership
        score += nfts.count * 30
        
        // Points for DeFi protocol usage
        score += defiProtocols.count * 40
        
        // Bonus for blockchain-related skills
        let blockchainSkills = skills.filter { skill in
            ["blockchain", "web3", "ethereum", "solidity", "defi", "nft"].contains(skill.lowercased())
        }
        score += blockchainSkills.count * 50
        
        return min(score, 600) // Cap at 600 points
    }
    
    // MARK: - POAP Verification
    private func verifyPOAPs(walletAddress: String) async -> POAPVerification {
        do {
            let poaps = try await fetchPOAPs(walletAddress: walletAddress)
            let techEvents = filterTechEvents(poaps: poaps)
            let score = calculatePOAPScore(poaps: poaps, techEvents: techEvents)
            
            return POAPVerification(
                poaps: poaps,
                techEvents: techEvents,
                score: score
            )
            
        } catch {
            print("POAP verification error: \(error)")
            return POAPVerification(poaps: [], techEvents: [], score: 0)
        }
    }
    
    private func fetchPOAPs(walletAddress: String) async throws -> [POAP] {
        // Mock POAP data for demo
        return [
            POAP(
                eventId: "1",
                name: "ETHGlobal Hackathon 2024",
                description: "Participated in ETHGlobal hackathon",
                imageUrl: "https://example.com/poap1.png",
                eventDate: Date()
            ),
            POAP(
                eventId: "2",
                name: "Polygon Developer Conference",
                description: "Attended Polygon developer conference",
                imageUrl: "https://example.com/poap2.png",
                eventDate: Date()
            )
        ]
    }
    
    private func filterTechEvents(poaps: [POAP]) -> [POAP] {
        let techKeywords = ["eth", "blockchain", "developer", "hackathon", "web3", "defi", "nft", "crypto"]
        
        return poaps.filter { poap in
            let name = poap.name.lowercased()
            return techKeywords.contains { name.contains($0) }
        }
    }
    
    private func calculatePOAPScore(poaps: [POAP], techEvents: [POAP]) -> Int {
        var score = 0
        
        // Points for total POAPs
        score += poaps.count * 20
        
        // Bonus for tech-related events
        score += techEvents.count * 40
        
        return min(score, 300) // Cap at 300 points
    }
    
    // MARK: - Final Score Calculation
    private func calculateFinalScore(
        extractedData: ExtractedData,
        githubResult: GitHubVerification,
        blockchainResult: BlockchainVerification,
        poapResult: POAPVerification
    ) -> Int {
        var finalScore = 0
        
        let baseScore = extractedData.skills.count * 5 + extractedData.projects.count * 10
        
        finalScore += githubResult.score
        finalScore += blockchainResult.score
        finalScore += poapResult.score
        finalScore += baseScore
        
        let consistencyBonus = calculateConsistencyBonus(
            extractedSkills: extractedData.skills,
            githubLanguages: githubResult.languagesUsed,
            blockchainActivity: blockchainResult
        )
        
        finalScore += consistencyBonus
        
        return min(finalScore, 2000)
    }
    
    private func calculateConsistencyBonus(
        extractedSkills: [String],
        githubLanguages: [String],
        blockchainActivity: BlockchainVerification
    ) -> Int {
        var bonus = 0
        
        // Check if extracted programming skills match GitHub languages
        for skill in extractedSkills {
            if githubLanguages.contains(skill.lowercased()) {
                bonus += 30
            }
        }
        
        // Check if blockchain skills match on-chain activity
        let hasBlockchainSkills = extractedSkills.contains { skill in
            ["blockchain", "web3", "ethereum", "solidity"].contains(skill.lowercased())
        }
        
        if hasBlockchainSkills && (blockchainActivity.transactions > 10 || !blockchainActivity.defiProtocols.isEmpty) {
            bonus += 100
        }
        
        return min(bonus, 200) // Cap consistency bonus
    }
    
    private func getVerifiedSkills(
        extractedSkills: [String],
        githubLanguages: [String],
        blockchainActivity: BlockchainVerification
    ) -> [String] {
        var verified: [String] = []
        
        // Skills verified through GitHub
        for skill in extractedSkills {
            if githubLanguages.contains(skill.lowercased()) {
                verified.append(skill)
            }
        }
        
        // Blockchain skills verified through on-chain activity
        let blockchainSkills = ["blockchain", "web3", "ethereum", "solidity", "defi", "nft"]
        if blockchainActivity.transactions > 10 {
            for skill in extractedSkills {
                if blockchainSkills.contains(skill.lowercased()) && !verified.contains(skill) {
                    verified.append(skill)
                }
            }
        }
        
        return verified
    }
    
    private func getVerifiedProjects(
        extractedProjects: [String],
        githubRepos: [GitHubRepo]
    ) -> [String] {
        return verifyProjectsWithRepos(projects: extractedProjects, repos: githubRepos)
    }
}

// MARK: - GitHub API Response Models
private struct GitHubRepoResponse: Codable {
    let name: String
    let description: String?
    let language: String?
    let stargazers_count: Int
    let forks_count: Int
    let updated_at: Date
    let topics: [String]?
}
