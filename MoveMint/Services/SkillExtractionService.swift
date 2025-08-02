//
//  SkillExtractionView.swift
//  MoveMint
//
//  Created by Sandesh Raj on 02/08/25.
//

import Foundation
import SwiftUI

// MARK: - Data Models
struct ExtractedData {
    let skills: [String]
    let projects: [String]
    let experience: [String]
    let education: [String]
    let certifications: [String]
}

struct SkillCategory {
    let name: String
    let keywords: [String]
    let weight: Int 
}

// MARK: - Skill Extraction Service
class SkillExtractionService: ObservableObject {
    @Published var extractedData: ExtractedData?
    @Published var isProcessing = false
    @Published var extractionProgress: Double = 0.0
    
    // Comprehensive skill categories
    private let skillCategories: [SkillCategory] = [
        // Programming Languages
        SkillCategory(name: "Programming Languages", keywords: [
            "swift", "python", "javascript", "typescript", "java", "kotlin",
            "c++", "c#", "go", "rust", "ruby", "php", "dart", "scala",
            "r", "matlab", "sql", "html", "css", "solidity"
        ], weight: 15),
        
        // Frameworks & Libraries
        SkillCategory(name: "Frameworks & Libraries", keywords: [
            "swiftui", "uikit", "react", "react native", "flutter", "vue",
            "angular", "node.js", "express", "django", "flask", "spring",
            "laravel", "rails", "pytorch", "tensorflow", "opencv"
        ], weight: 12),
        
        // Blockchain & Web3
        SkillCategory(name: "Blockchain & Web3", keywords: [
            "blockchain", "web3", "ethereum", "bitcoin", "smart contracts",
            "defi", "nft", "dao", "metamask", "hardhat", "truffle", "polygon",
            "chainlink", "ipfs", "walletconnect", "thirdweb", "alchemy"
        ], weight: 20),
        
        // Cloud & DevOps
        SkillCategory(name: "Cloud & DevOps", keywords: [
            "aws", "azure", "gcp", "docker", "kubernetes", "jenkins",
            "terraform", "ansible", "ci/cd", "github actions", "gitlab ci",
            "nginx", "apache", "redis", "mongodb", "postgresql"
        ], weight: 12),
        
        // Data Science & AI/ML
        SkillCategory(name: "Data Science & AI/ML", keywords: [
            "machine learning", "deep learning", "neural networks", "nlp",
            "computer vision", "data science", "pandas", "numpy", "scikit-learn",
            "jupyter", "tableau", "power bi", "elasticsearch"
        ], weight: 18),
        
        // Mobile Development
        SkillCategory(name: "Mobile Development", keywords: [
            "ios", "android", "mobile development", "app store", "play store",
            "core data", "realm", "firebase", "push notifications", "in-app purchase"
        ], weight: 15),
        
        // Design & UI/UX
        SkillCategory(name: "Design & UI/UX", keywords: [
            "figma", "sketch", "adobe xd", "photoshop", "illustrator",
            "ui/ux", "user interface", "user experience", "prototyping",
            "wireframing", "design systems"
        ], weight: 10)
    ]
    
    
    private let projectKeywords = [
        "project", "built", "developed", "created", "designed", "implemented",
        "launched", "deployed", "app", "application", "system", "platform",
        "website", "portal", "dashboard", "api", "service", "tool"
    ]
    
    
    private let experienceKeywords = [
        "experience", "worked", "employed", "internship", "freelance",
        "consultant", "developer", "engineer", "analyst", "manager",
        "lead", "senior", "junior", "years", "months"
    ]
    
    
    private let educationKeywords = [
        "university", "college", "degree", "bachelor", "master", "phd",
        "computer science", "engineering", "mathematics", "physics",
        "graduated", "gpa", "coursework"
    ]
    
    private let certificationKeywords = [
        "certified", "certification", "certificate", "aws certified",
        "microsoft certified", "google certified", "oracle certified",
        "cisco", "comptia", "pmp", "scrum master", "agile"
    ]
    
    func extractSkillsAndProjects(from resumeText: String) async {
        await MainActor.run {
            isProcessing = true
            extractionProgress = 0.0
        }
        
        let cleanedText = preprocessText(resumeText)
        
        
        await updateProgress(0.2)
        let skills = extractSkills(from: cleanedText)
        
        await updateProgress(0.4)
        let projects = extractProjects(from: cleanedText)
        
        await updateProgress(0.6)
        let experience = extractExperience(from: cleanedText)
        
        await updateProgress(0.8)
        let education = extractEducation(from: cleanedText)
        
        await updateProgress(0.9)
        let certifications = extractCertifications(from: cleanedText)
        
        await updateProgress(1.0)
        
        let extractedData = ExtractedData(
            skills: skills,
            projects: projects,
            experience: experience,
            education: education,
            certifications: certifications
        )
        
        await MainActor.run {
            self.extractedData = extractedData
            self.isProcessing = false
            self.extractionProgress = 0.0
        }
    }
    
    private func updateProgress(_ progress: Double) async {
        await MainActor.run {
            extractionProgress = progress
        }
        try? await Task.sleep(nanoseconds: 100_000_000)
    }
    
    private func preprocessText(_ text: String) -> String {
        return text.lowercased()
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
    }
    
    private func extractSkills(from text: String) -> [String] {
        var foundSkills: [String] = []
        
        for category in skillCategories {
            for skill in category.keywords {
                if text.contains(skill.lowercased()) {
                    foundSkills.append(skill.capitalized)
                }
            }
        }
        
        return Array(Set(foundSkills)).sorted()
    }
    
    private func extractProjects(from text: String) -> [String] {
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        var projects: [String] = []
        
        for sentence in sentences {
            let sentence = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            if sentence.count > 20 { // Minimum length for a meaningful project description
                for keyword in projectKeywords {
                    if sentence.contains(keyword) {
                        // Extract project name (simple heuristic)
                        let words = sentence.components(separatedBy: " ")
                        if let projectIndex = words.firstIndex(where: { $0.contains(keyword) }) {
                            let startIndex = max(0, projectIndex - 2)
                            let endIndex = min(words.count - 1, projectIndex + 5)
                            let projectDesc = Array(words[startIndex...endIndex]).joined(separator: " ")
                            projects.append(projectDesc.capitalized)
                        }
                        break
                    }
                }
            }
        }
        
        return Array(Set(projects)).prefix(10).map { String($0) }
    }
    
    private func extractExperience(from text: String) -> [String] {
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        var experience: [String] = []
        
        for sentence in sentences {
            let sentence = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            for keyword in experienceKeywords {
                if sentence.contains(keyword) && sentence.count > 15 {
                    experience.append(sentence.capitalized)
                    break
                }
            }
        }
        
        return Array(Set(experience)).prefix(5).map { String($0) }
    }
    
    private func extractEducation(from text: String) -> [String] {
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        var education: [String] = []
        
        for sentence in sentences {
            let sentence = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            for keyword in educationKeywords {
                if sentence.contains(keyword) && sentence.count > 10 {
                    education.append(sentence.capitalized)
                    break
                }
            }
        }
        
        return Array(Set(education)).prefix(3).map { String($0) }
    }
    
    private func extractCertifications(from text: String) -> [String] {
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        var certifications: [String] = []
        
        for sentence in sentences {
            let sentence = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            for keyword in certificationKeywords {
                if sentence.contains(keyword) && sentence.count > 10 {
                    certifications.append(sentence.capitalized)
                    break
                }
            }
        }
        
        return Array(Set(certifications)).prefix(5).map { String($0) }
    }
    

    func calculatePreliminaryScore() -> Int {
        guard let data = extractedData else { return 0 }
        
        var score = 0
        

        for skill in data.skills {
            for category in skillCategories {
                if category.keywords.contains(skill.lowercased()) {
                    score += category.weight
                    break
                }
            }
        }
        
        
        score += data.projects.count * 25
        score += data.experience.count * 15
        score += data.education.count * 20
        score += data.certifications.count * 30
        
        return min(score, 1000)
    }
}

// MARK: - Extensions for easier categorization
extension SkillExtractionService {
    func getSkillsByCategory() -> [String: [String]] {
        guard let skills = extractedData?.skills else { return [:] }
        
        var categorizedSkills: [String: [String]] = [:]
        
        for category in skillCategories {
            let categorySkills = skills.filter { skill in
                category.keywords.contains(skill.lowercased())
            }
            if !categorySkills.isEmpty {
                categorizedSkills[category.name] = categorySkills
            }
        }
        
        return categorizedSkills
    }
}
