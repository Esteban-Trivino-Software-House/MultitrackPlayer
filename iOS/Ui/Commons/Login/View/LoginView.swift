//
//  LoginView.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 2/09/25.
//  This file is part of the Multitrack Player project.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject private var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Header()
                ZStack {
                    initialScreen
                        .isVisible(viewModel.showInitialView)
                    loader
                        .isVisible(!viewModel.showInitialView)
                }
                Spacer()
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
    
    var initialScreen: some View {
        VStack {
            Spacer()
            Text(String(localized: "welcome"))
                .font(.largeTitle)
            Text(String(localized: "login_prompt"))
                .font(.title2)
                .padding(.vertical)
            
            // Sign in with Apple button
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { _ in
                    viewModel.onTapLoginWithApple()
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(width: 199, height: 50)
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
}

#Preview {
    LoginView(viewModel: LoginViewModel(authService: AuthenticationService()))
}
