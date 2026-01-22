//
//  Header.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 8/09/22.
//

import SwiftUI

struct Header: View {
    @State var showInfoSheet: Bool = false
    var showAccountScreenBinding: Binding<Bool>?
    
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
                    showInfoSheet = true
                }
        }
        .padding(25)
        .frame(height: 40)
        .background(Color("PSNavy"))
        .foregroundColor(Color("PSWhite"))
        .sheet(isPresented: $showInfoSheet) {
            AppInfoView(showInfoSheet: $showInfoSheet)
        }
    }
}

struct AppInfoView: View {
    @Binding var showInfoSheet: Bool
    var body: some View {
        VStack(spacing: 16) {
            Text(String(localized: "app_title")).bold().font(.system(size: 18))
            Text(String(localized: "developer")).italic().font(.system(size: 14))
            if let version = SystemInfo.version, let buildNumber = SystemInfo.build {
                Text("v\(version) - \(buildNumber)").italic().font(.system(size: 14))
            }
            Button {
                showInfoSheet = false
            } label: {
                Text(String(localized: "close"))
                    .foregroundStyle(Color("PSRed"))
            }
            .padding(.vertical)

        }
    }
}

struct Header_Previews: PreviewProvider {
    static var previews: some View {
        Header()
    }
}
