//import Foundation
//import SwiftUI
//import metamask_ios_sdk
//
//@MainActor
//final class MetaMaskService: ObservableObject {
//    static let shared = MetaMaskService()
//
//    @Published var connectedAddress: String?
//    @Published var lastSignature: String?
//    @Published var isConnected: Bool = false
//    @Published var errorMessage: String?
//    @Published var chainId: String?
//
////    private var sdk: MetaMaskSDK
//    private var sdk: MetaMaskSDK = MetaMaskSDK.shared(
//        AppMetadata(name: "Skillfull", url: "https://example.com"),
//        transport: .socket,
//        sdkOptions: SDKOptions(infuraAPIKey: "ddae7c58ed02470a99a142b7d85a29bd")
//    )
//
//
//    init() {
//            let appMetadata = AppMetadata(name: "SkillFull", url: "https://example.com")
//            sdk = MetaMaskSDK.shared(
//                appMetadata,
//                transport: .socket,
//                sdkOptions: SDKOptions(infuraAPIKey: "your_infura_key")
//            )
//        }
//
//
//    func connect() async {
//        do {
//            let result = try await sdk.connect()
//            connectedAddress = sdk.account
//            isConnected = true
//        } catch {
//            errorMessage = "Connect failed: \(error.localizedDescription)"
//            isConnected = false
//        }
//    }
//
//    func signMessage(_ message: String) async {
//        guard isConnected, !sdk.account.isEmpty else {
//            errorMessage = "Not connected"
//            return
//        }
//
//        let account = sdk.account
//        let signRequest = EthereumRequest(method: .personalSign, params: [message, account])
//
//        do {
//            let result: Result<String, RequestError> = await sdk.request(signRequest)
//            lastSignature = try result.get()
//        } catch {
//            errorMessage = "Signing failed: \(error.localizedDescription)"
//        }
//    }
//
//    func disconnect() {
//        Task {
//            await sdk.disconnect()
//            connectedAddress = nil
//            isConnected = false
//        }
//    }
//}
import Foundation
import SwiftUI
import metamask_ios_sdk

@MainActor
final class MetaMaskService: ObservableObject {
    static let shared = MetaMaskService()

    @Published var connectedAddress: String?
    @Published var lastSignature: String?
    @Published var isConnected: Bool = false
    @Published var errorMessage: String?
    @Published var chainId: String?

    private var sdk: MetaMaskSDK

    init() {
        let appMetadata = AppMetadata(name: "SkillFull", url: "https://skillfull.app")
        
        // Use your actual Infura API key here
        sdk = MetaMaskSDK.shared(
            appMetadata,
            transport: .socket,
            sdkOptions: SDKOptions(infuraAPIKey: "ddae7c58ed02470a99a142b7d85a29bd")
        )
        
        // Clear any previous error messages
        errorMessage = nil
    }

    func connect() async {
        do {
            errorMessage = nil // Clear previous errors
            print("Attempting to connect to MetaMask...")
            
            let result = try await sdk.connect()
            print("Connect result: \(result)")
            
            // Update UI on main thread
            await MainActor.run {
                connectedAddress = sdk.account
                isConnected = !sdk.account.isEmpty
                
                if isConnected {
                    print("Successfully connected to: \(sdk.account)")
                } else {
                    errorMessage = "Connected but no account found"
                }
            }
        } catch {
            print("Connection error: \(error)")
            await MainActor.run {
                errorMessage = "Connect failed: \(error.localizedDescription)"
                isConnected = false
                connectedAddress = nil
            }
        }
    }

    func signMessage(_ message: String) async {
        guard isConnected, let account = connectedAddress, !account.isEmpty else {
            errorMessage = "Not connected to MetaMask"
            return
        }

        do {
            errorMessage = nil
            print("Signing message: \(message)")
            
            let signRequest = EthereumRequest(
                method: .personalSign,
                params: [message, account]
            )

            let result: Result<String, RequestError> = await sdk.request(signRequest)
            let signature = try result.get()
            
            await MainActor.run {
                lastSignature = signature
                print("Message signed successfully")
            }
        } catch {
            print("Signing error: \(error)")
            await MainActor.run {
                errorMessage = "Signing failed: \(error.localizedDescription)"
            }
        }
    }

    func disconnect() {
        Task {
            do {
                await sdk.disconnect()
                await MainActor.run {
                    connectedAddress = nil
                    isConnected = false
                    lastSignature = nil
                    errorMessage = nil
                }
                print("Disconnected from MetaMask")
            } catch {
                print("Disconnect error: \(error)")
                await MainActor.run {
                    errorMessage = "Disconnect failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func checkConnectionStatus() {
        isConnected = !sdk.account.isEmpty
        connectedAddress = isConnected ? sdk.account : nil
    }
}
