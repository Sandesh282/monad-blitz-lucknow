////
////  WalletView.swift
////  SkillFull
////
////  Created by Sandesh Raj on 02/08/25.
////
//import SwiftUI
//
//struct WalletView: View {
//    @StateObject var service = MetaMaskService()
//    @State private var message = "Hello from SwiftUI"
//    @State private var navigateToResumeUpload = false
//    @State private var resumeText: String = ""
//    var body: some View {
//        NavigationStack {
//            ZStack {
//            
//            ZStack {
//                        
//                        AngularGradient(gradient: Gradient(colors: [
//                            Color(red: 0.1, green: 0.1, blue: 0.4),
//                            Color.purple,
//                            Color.pink,
//                            Color(red: 0.2, green: 0.5, blue: 1.0),
//                            Color.purple
//                        ]), center: .center)
//                        .blur(radius: 100)
//
//
//                        RadialGradient(gradient: Gradient(colors: [
//                            Color.white.opacity(0.2),
//                            Color.clear
//                        ]), center: .topLeading, startRadius: 10, endRadius: 500)
//
//                        RadialGradient(gradient: Gradient(colors: [
//                            Color.pink.opacity(0.2),
//                            Color.clear
//                        ]), center: .bottomTrailing, startRadius: 10, endRadius: 400)
//                    }
//                    .ignoresSafeArea()
//
//
//
//            GeometryReader { geo in
//                VStack(spacing: 24) {
//                    
//                    Text("Neon Wallet")
//                        .font(.system(size: 32, weight: .bold, design: .monospaced))
//                        .foregroundColor(.pink)
//                        .shadow(color: .pink, radius: 5, x: 0, y: 0)
//                        .padding(.bottom, 10)
//
//                    if service.isConnected {
//                        NavigationLink(
//                                    destination: ResumeUploadView(resumeText: $resumeText, walletAddress: service.connectedAddress ?? ""),
//                                    isActive: $navigateToResumeUpload
//                                ) {
//                                    EmptyView()
//                                }
//                        VStack(spacing: 16) {
//                            Text("Connected:")
//                                .font(.headline)
//                                .foregroundColor(.mint)
//
//                            Text(service.connectedAddress ?? "—")
//                                .font(.system(.caption, design: .monospaced))
//                                .foregroundColor(.white)
//                                .padding(.horizontal, 10)
//                                .padding(.vertical, 4)
//                                .background(Color.mint.opacity(0.2))
//                                .cornerRadius(8)
//
//                            TextField("Message to sign", text: $message)
//                                .padding()
//                                .background(.white.opacity(0.1))
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.pink, lineWidth: 1))
//
//                            Button("Sign Message") {
//                                Task { await service.signMessage(message) }
//                            }
//                            .buttonStyle(NeonButtonStyle(color: .mint))
//
//                            if let sig = service.lastSignature {
//                                Text("Signature:")
//                                    .font(.caption)
//                                    .foregroundColor(.white.opacity(0.6))
//
//                                ScrollView {
//                                    Text(sig)
//                                        .font(.system(.footnote, design: .monospaced))
//                                        .foregroundColor(.green)
//                                        .padding()
//                                        .background(Color.black.opacity(0.6))
//                                        .cornerRadius(8)
//                                }
//                                .frame(height: 80)
//                            }
//
//                            Button("Continue to Resume Upload") {
//                                navigateToResumeUpload = true
//                            }
//                            .buttonStyle(NeonButtonStyle(color: .cyan))
//
//                            Button("Disconnect") {
//                                service.disconnect()
//                            }
//                            .buttonStyle(NeonButtonStyle(color: .red))
//                        }
//                    } else {
//                        VStack(spacing: 16) {
//                            Text("Not connected to MetaMask")
//                                .foregroundColor(.gray)
//
//                            Button("Connect MetaMask") {
//                                Task { await service.connect() }
//                            }
//                            .buttonStyle(NeonButtonStyle(color: .purple))
//                        }
//                    }
//
//                    if let err = service.errorMessage {
//                        Text("Error: \(err)")
//                            .foregroundColor(.red)
//                            .font(.caption)
//                    }
//                }
//                .frame(width: geo.size.width * 0.85)
//                .padding()
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//        }
//    }
//}
//}
//
//struct NeonButtonStyle: ButtonStyle {
//    var color: Color
//
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.system(.body, design: .monospaced))
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(color.opacity(configuration.isPressed ? 0.6 : 1.0))
//            .foregroundColor(.white)
//            .cornerRadius(12)
//            .shadow(color: color, radius: configuration.isPressed ? 4 : 10)
//            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
//    }
//}
//
//struct GlassCard<Content: View>: View {
//    let content: () -> Content
//
//    var body: some View {
//        content()
//            .padding()
//            .background(.ultraThinMaterial)
//            .cornerRadius(16)
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(Color.cyan.opacity(0.7), lineWidth: 1)
//            )
//            .shadow(color: Color.cyan.opacity(0.2), radius: 10, x: 0, y: 5)
//    }
//}
//struct NeonButton: View {
//    let title: String
//    let action: () -> Void
//    var color: Color = .cyan
//
//    var body: some View {
//        Button(action: action) {
//            Text(title)
//                .font(.headline)
//                .foregroundColor(.black)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(color)
//                        .shadow(color: color.opacity(0.7), radius: 10, x: 0, y: 5)
//                )
//        }
//        .padding(.horizontal)
//    }
//}

import SwiftUI

struct WalletView: View {
    @StateObject var service = MetaMaskService()
    @State private var message = "Hello from SwiftUI"
    @State private var navigateToResumeUpload = false
    @State private var resumeText: String = ""
    @State private var isConnecting = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
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

                    RadialGradient(gradient: Gradient(colors: [
                        Color.pink.opacity(0.2),
                        Color.clear
                    ]), center: .bottomTrailing, startRadius: 10, endRadius: 400)
                }
                .ignoresSafeArea()

                GeometryReader { geo in
                    VStack(spacing: 24) {
                        
                        Text("Neon Wallet")
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(.pink)
                            .shadow(color: .pink, radius: 5, x: 0, y: 0)
                            .padding(.bottom, 10)

                        if service.isConnected {
                            // Connected state
                            NavigationLink(
                                destination: ResumeUploadView(
                                    resumeText: $resumeText,
                                    walletAddress: service.connectedAddress ?? ""
                                ),
                                isActive: $navigateToResumeUpload
                            ) {
                                EmptyView()
                            }
                            
                            VStack(spacing: 16) {
                                Text("✅ Connected")
                                    .font(.headline)
                                    .foregroundColor(.mint)

                                Text(service.connectedAddress ?? "—")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.mint.opacity(0.2))
                                    .cornerRadius(8)

                                TextField("Message to sign", text: $message)
                                    .padding()
                                    .background(.white.opacity(0.1))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.pink, lineWidth: 1))

                                Button("Sign Message") {
                                    Task {
                                        await service.signMessage(message)
                                    }
                                }
                                .buttonStyle(NeonButtonStyle(color: .mint))

                                if let sig = service.lastSignature {
                                    Text("Signature:")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))

                                    ScrollView {
                                        Text(sig)
                                            .font(.system(.footnote, design: .monospaced))
                                            .foregroundColor(.green)
                                            .padding()
                                            .background(Color.black.opacity(0.6))
                                            .cornerRadius(8)
                                    }
                                    .frame(height: 80)
                                }

                                Button("Continue to Resume Upload") {
                                    navigateToResumeUpload = true
                                }
                                .buttonStyle(NeonButtonStyle(color: .cyan))

                                Button("Disconnect") {
                                    service.disconnect()
                                }
                                .buttonStyle(NeonButtonStyle(color: .red))
                            }
                        } else {
                            // Not connected state
                            VStack(spacing: 16) {
                                if isConnecting {
                                    VStack {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                                            .scaleEffect(1.5)
                                        
                                        Text("Connecting to MetaMask...")
                                            .foregroundColor(.purple)
                                            .font(.headline)
                                            .padding(.top)
                                    }
                                } else {
                                    Text("Not connected to MetaMask")
                                        .foregroundColor(.gray)
                                        .font(.headline)

                                    Button("Connect MetaMask") {
                                        connectToMetaMask()
                                    }
                                    .buttonStyle(NeonButtonStyle(color: .purple))
                                    .disabled(isConnecting)
                                }
                            }
                        }

                        // Error message display
                        if let err = service.errorMessage {
                            VStack {
                                Text("⚠️ Error")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                Text(err)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                                
                                Button("Try Again") {
                                    service.errorMessage = nil
                                    connectToMetaMask()
                                }
                                .buttonStyle(NeonButtonStyle(color: .orange))
                            }
                        }
                    }
                    .frame(width: geo.size.width * 0.85)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .onAppear {
            // Check if already connected when view appears
            service.checkConnectionStatus()
        }
    }
    
    private func connectToMetaMask() {
        isConnecting = true
        service.errorMessage = nil
        
        Task {
            await service.connect()
            
            await MainActor.run {
                isConnecting = false
            }
        }
    }
}

struct NeonButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .monospaced))
            .padding()
            .frame(maxWidth: .infinity)
            .background(color.opacity(configuration.isPressed ? 0.6 : 1.0))
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: color, radius: configuration.isPressed ? 4 : 10)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct GlassCard<Content: View>: View {
    let content: () -> Content

    var body: some View {
        content()
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.cyan.opacity(0.7), lineWidth: 1)
            )
            .shadow(color: Color.cyan.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct NeonButton: View {
    let title: String
    let action: () -> Void
    var color: Color = .cyan

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color)
                        .shadow(color: color.opacity(0.7), radius: 10, x: 0, y: 5)
                )
        }
        .padding(.horizontal)
    }
}

#Preview {
    WalletView()
}
