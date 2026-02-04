//
//  LoginView.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 2/09/25.
//  This file is part of the Multitrack Player project.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject private var viewModel: LoginViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.scenePhase) var scenePhase
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Header(showInfoButton: false)
                ZStack {
                    if horizontalSizeClass == .compact {
                        portraitScreen
                            .isVisible(viewModel.showInitialView)
                    } else {
                        landscapeScreen
                            .isVisible(viewModel.showInitialView)
                    }
                    loader
                        .isVisible(!viewModel.showInitialView)
                }
                .frame(maxHeight: .infinity)
            }
            .navigationDestination(
                isPresented: $viewModel.loginSuccessful,
                destination: {
                    DashboardScreen(
                        viewModel: .init(
                            multitrackRepository: MultitrackLocalRepository(dataManager: .init()),
                            loginViewModel: viewModel
                        )
                    )
                    .navigationBarHidden(true)
            })
            .onAppear {
                // Unlock orientation on login screen
                OrientationManager.shared.unlockOrientation()
                viewModel.onAppear()
            }
        }
    }
    
    var loader: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }
    
    var portraitScreen: some View {
        VStack {
            Spacer()
            Text(String(localized: "welcome"))
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            Text(String(localized: "login_prompt"))
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.vertical)
            
            // Sign in with Apple button
            Button(action: {
                viewModel.onTapLoginWithApple()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 16, weight: .semibold))
                    Text(String(localized: "sign_in_with_apple"))
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundColor(.white)
                .background(Color(UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark ? UIColor.systemGray5 : UIColor.black
                }))
                .cornerRadius(8)
            }
            .frame(width: 199)
            .padding(.horizontal, 40)
            .padding(.bottom, 10)
            
            // Google Sign-In button
            Button(action: {
                viewModel.onTapLoginWithGoogle()
            }) {
                Image("ios_neutral_rd_ctn")
            }
            
            Spacer()
        }
        .padding()
    }
    
    var landscapeScreen: some View {
        HStack(spacing: 30) {
            Spacer()
            VStack(alignment: .center, spacing: 12) {
                Text(String(localized: "welcome"))
                    .font(.title)
                    .multilineTextAlignment(.center)
                Text(String(localized: "login_prompt"))
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            
            VStack(spacing: 12) {
                // Sign in with Apple button
                Button(action: {
                    viewModel.onTapLoginWithApple()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 16, weight: .semibold))
                        Text(String(localized: "sign_in_with_apple"))
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundColor(.white)
                    .background(Color(UIColor { traitCollection in
                        traitCollection.userInterfaceStyle == .dark ? UIColor.systemGray5 : UIColor.black
                    }))
                    .cornerRadius(8)
                }
                
                // Google Sign-In button
                Button(action: {
                    viewModel.onTapLoginWithGoogle()
                }) {
                    Image("ios_neutral_rd_ctn")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                }
            }
            .frame(maxWidth: 180)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel(authService: AuthenticationService()))
}
