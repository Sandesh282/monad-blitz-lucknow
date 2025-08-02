//import SwiftUI
//
//struct ContentView: View {
//    @StateObject var service = MetaMaskService()
//    @State private var message = "Hello from SwiftUI"
//
//    var body: some View {
//        VStack(spacing: 16) {
//            if service.isConnected {
//                Text("Connected: \(service.connectedAddress ?? "—")")
//                    .font(.headline)
//
//                TextField("Message to sign", text: $message)
//                    .textFieldStyle(.roundedBorder)
//                    .padding(.horizontal)
//
//                Button("Sign Message") {
//                    Task {
//                        await service.signMessage(message)
//                    }
//                }
//
//                if let sig = service.lastSignature {
//                    Text("Signature:")
//                        .font(.subheadline)
//                    ScrollView {
//                        Text(sig)
//                            .font(.system(.footnote, design: .monospaced))
//                            .padding(8)
//                            .background(.gray.opacity(0.1))
//                            .cornerRadius(6)
//                    }
//                    .frame(maxHeight: 100)
//                }
//
//                Button("Disconnect") {
//                    service.disconnect()
//                }
//                .foregroundColor(.red)
//            } else {
//                Text("Not connected to MetaMask")
//                Button("Connect MetaMask") {
//                    Task {
//                        await service.connect()
//                    }
//                }
//            }
//
//            if let err = service.errorMessage {
//                Text("Error: \(err)").foregroundColor(.red).font(.caption)
//            }
//
//            Spacer()
//        }
//        .padding()
//    }
//}
//
