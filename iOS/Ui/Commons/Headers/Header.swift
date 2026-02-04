//
//  Header.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 8/09/22.
//

import SwiftUI

struct Header: View {
    /// Binding to show/hide AccountScreen in the parent (DashboardScreen)
    /// Purpose: Lift state up - when user taps profile button, it triggers
    /// the parent to show AccountScreen as a sheet
    /// Owner: DashboardScreen (parent view)
    /// Reason for binding: AccountScreen is managed by parent, not Header
    var showAccountScreenBinding: Binding<Bool>?
    
    /// Binding to show/hide AppInfoView overlay in the parent (DashboardScreen)
    /// Purpose: Lift state up - when user taps info button, it triggers
    /// the parent to show AppInfoView overlay (centered on entire screen)
    /// Owner: DashboardScreen (parent view)
    /// Reason for binding: Overlay must be in parent ZStack to center
    /// on entire screen, not just on Header bounds
    var showAppInfoBinding: Binding<Bool>?
    
    var body: some View {
        HStack {
            Image(systemName: "iphone.badge.play")
                .resizable()
                .scaledToFit()
                .frame(height: 35, alignment: .center)
            Text(String(localized: "app_title")).bold().font(.system(size: 18))
            if let version = SystemInfo.version {
                Text("v\(version)").italic().font(.system(size: 14))
            }
            Spacer()
            if let showAccountScreenBinding = showAccountScreenBinding {
                Button(action: { showAccountScreenBinding.wrappedValue = true }) {
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                        .foregroundStyle(Color("PSBlue"))
                }
                .accessibilityLabel(String(localized: "profile"))
                .padding(.trailing, 8)
            }
            Image(systemName: "info.circle")
                .resizable()
                .scaledToFit()
                .frame(height: 20)
                .onTapGesture {
                    if let binding = showAppInfoBinding {
                        binding.wrappedValue = true
                    }
                }
        }
        .padding(25)
        .frame(height: 40)
        .background(Color("PSNavy"))
        .foregroundColor(Color("PSWhite"))
    }
}

struct AppInfoView: View {
    @Binding var showAppInfo: Bool
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        // Responsive sizes based on device type
        let isCompact = horizontalSizeClass == .compact // iPhone
        let maxWidth = isCompact ? 300.0 : 480.0
        let maxHeight = isCompact ? 220.0 : 260.0
        
        VStack(spacing: 16) {
            Text(String(localized: "app_title")).bold().font(.system(size: 18))
            Text(String(localized: "developer")).italic().font(.system(size: 14))
            if let version = SystemInfo.version, let buildNumber = SystemInfo.build {
                Text("v\(version) - \(buildNumber)").italic().font(.system(size: 14))
            }
            Button {
                showAppInfo = false
            } label: {
                Text(String(localized: "close"))
                    .foregroundStyle(Color("PSRed"))
            }
            .padding(.vertical)
        }
        .padding()
        .frame(maxWidth: maxWidth, maxHeight: maxHeight)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

struct Header_Previews: PreviewProvider {
    static var previews: some View {
        Header()
    }
}
