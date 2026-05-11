//
//  SplashView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 11.05.2026.
//

import SwiftUI

struct SplashView: View {
    @State private var animate = false
    @State private var showMain = false
    var body: some View {
        ZStack {
            
            Image("launchScreen") // Assets'e ekleyeceğin görsel
                .resizable()
                //.scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                //.scaleEffect(animate ? 1.0 : 0.92)
                //.opacity(animate ? 1 : 0.7)
                .ignoresSafeArea()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showMain = true
                    }
                }
        }
        
    }
}
