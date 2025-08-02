//
//  MoveMintApp.swift
//  MoveMint
//
//
import metamask_ios_sdk
import SwiftUI

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if URLComponents(url: url, resolvingAgainstBaseURL: true)?.host == "mmsdk" {
        MetaMaskSDK.sharedInstance?.handleUrl(url)
    }
    return true
}


@main
struct MoveMintApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            WalletView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
