//
//  RiskAnalyzerApp.swift
//  RiskAnalyzer
//
//  Created by Никита Поляков on 11.12.2025.
//

import SwiftUI

@main
struct RiskAnalyzerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationTitle("Анализатор рисков ИБ")
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
    }
}
