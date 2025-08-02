# Resume Matcher dApp
A decentralized web application that allows users to upload their resumes, extract structured information (e.g., name, skills, education), and match their profiles with relevant job opportunities — all with the privacy-first ethos of Web3.

# Features
✅ Web3 Wallet (MetaMask) authentication

✅ Resume PDF upload using native file picker

✅ Real-time PDF parsing and structured JSON generation

✅ AI-powered job matching system (in progress)

✅ Smart contract integration for decentralized resume verification

# Tech Stack
Frontend    Backend (planned)    Misc
SwiftUI (iOS)    Python + FastAPI (REST)    ResumeParser (NLP)
WalletConnect    PostgreSQL (future)    MetaMask Integration

# How It Works
Connect Wallet
Users connect their MetaMask wallet to authenticate.

Upload Resume
Users upload their resume as a PDF. The document is parsed on-device to extract structured information like:
```json
{
  "name": "John Doe",
  "email": "john.doe@example.com",
  "skills": ["Swift", "Python", "React"],
  "education": "B.Tech in CSE",
  "experience": "2 years at XYZ Inc."
}
```
# Future Flow (Coming Soon)

Resume will be matched against job postings via ML-based relevance scoring

Users will receive personalized job recommendations

Data optionally stored on-chain for transparency and verification

# Privacy & Web3
No centralized server required for authentication

All parsing done on-device for user privacy

Future plans include zkProof-based skill verification


