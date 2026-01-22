//
//  AccountScreen.swift
//  Multitrack Player
//
//  Created by Esteban Rafael Trivino Guerra on 1/22/26.
//

import SwiftUI

struct AccountScreen: View {
    @ObservedObject var loginViewModel: LoginViewModel
    @Binding var showAccountScreen: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // MARK: Header
            HStack {
                Button(action: { showAccountScreen = false }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(Color("PSBlack"))
                        .frame(width: 44, height: 44)
                }
                Spacer()
                Text(String(localized: "account"))
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Color.clear
                    .frame(width: 44)
            }
            .padding(.horizontal)
            .padding(.top)
            
            Spacer()
            
            // MARK: Account Information
            VStack(spacing: 20) {
                // User Icon
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(Color("PSBlue"))
                
                // Email
                if let userEmail = loginViewModel.userEmail {
                    VStack(spacing: 4) {
                        Text(String(localized: "email"))
                            .font(.caption)
                            .foregroundStyle(Color("PSNavy").opacity(0.7))
                        Text(userEmail)
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("PSLight"))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // MARK: Actions
            VStack(spacing: 12) {
                // MARK: Logout Button
                Button(action: { 
                    loginViewModel.logOut()
                    showAccountScreen = false
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "rectangle.portrait.and.arrow.forward")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                        Text(String(localized: "logout"))
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(Color("PSRed"))
                    .background(Color("PSRed").opacity(0.1))
                    .cornerRadius(8)
                }
                
                // MARK: Delete Account Button
                Button(action: { loginViewModel.requestAccountDeletion() }) {
                    HStack(spacing: 12) {
                        Image(systemName: "trash")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                        Text(String(localized: "delete_account_title"))
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(Color("PSRed"))
                    .background(Color("PSRed").opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
            
            Spacer()
        }
        .background(Color("PSWhite"))
        .confirmationDialog(
            String(localized: "delete_account_title"),
            isPresented: $loginViewModel.showDeleteConfirmation
        ) {
            Button(String(localized: "delete_account_confirm"), role: .destructive) {
                loginViewModel.confirmAccountDeletion()
                showAccountScreen = false
            }
            Button(String(localized: "cancel"), role: .cancel) {
                loginViewModel.cancelAccountDeletion()
            }
        } message: {
            Text(String(localized: "delete_account_warning"))
        }
    }
}

#Preview {
    @State var showAccount = true
    return AccountScreen(
        loginViewModel: LoginViewModel(authService: AuthenticationService()),
        showAccountScreen: $showAccount
    )
}
