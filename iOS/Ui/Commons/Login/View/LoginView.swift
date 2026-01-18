//
//  LoginView.swift
//  Play Secuence
//
//  Created by Esteban Triviño on 2/09/25.
//

import SwiftUI

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
    LoginView(viewModel: LoginViewModel(authenticator: GoogleAuthenticatorManager()))
}
