//
//  ContentView.swift
//  Shared
//
//  Created by Esteban Rafael Trivino Guerra on 8/09/22.
//

import SwiftUI

struct DashboardScreen: View {
    @State private var showPicker: Bool = false
    @State private var showNewMultitrackNameInputDialog: Bool = false
    @State private var showEditMultitrackNameInputDialog: Bool = false
    @StateObject var viewModel = DashboardViewModel(multitrackRepository: MultitrackLocalRepository(dataManager: .init()),
                                                    authenticator: GoogleAuthenticatorManager())
    @State private var presentModalDelete: Bool = false
    @State private var newMultitrackNameTmp: String = ""
    
    var body: some View {
        VStack {
            Header()
            switch viewModel.isLoading {
                case true:
                LoadingScreen()
                case false:
                content
            }
        }
        .onAppear(){
            self.viewModel.onAppear()
        }
    }
    
    @ViewBuilder
    var content: some View {
        VStack(spacing: 0) {
            if viewModel.multitracks.isEmpty {
                noMultitracksView
            } else {
                playerView
            }
        }
        .sheet(isPresented: $showPicker) {
            DocumentPicker() { urls in
                self.viewModel.createMultitrack(
                    withName: newMultitrackNameTmp,
                    using: urls
                )
            }
        }
        .sheet(isPresented: $showNewMultitrackNameInputDialog, content: {
            NameInputDialogView { newMultitrackName in
                newMultitrackNameTmp = newMultitrackName
                showNewMultitrackNameInputDialog = false
                showPicker = true
            } onCancel: {
                newMultitrackNameTmp = ""
                showNewMultitrackNameInputDialog = false
            }
        })
        .sheet(isPresented: $showEditMultitrackNameInputDialog, content: {
            NameInputDialogView(name: viewModel.getSelectedMultitrackName()) { newMultitrackName in
                viewModel.editMultitrackName(newMultitrackName)
                showEditMultitrackNameInputDialog = false
            } onCancel: {
                showEditMultitrackNameInputDialog = false
            }
        })
        .confirmationDialog("Do you want to delete the multitrack?", isPresented: self.$presentModalDelete) {
            Button("Delete \(viewModel.getSelectedMultitrackName())", role: .destructive) {
                self.viewModel.deleteSelectedMultitrack()
            }
        }
    }
    
    var noMultitracksView: some View {
        VStack {
            Spacer()
            Text("Add a multitrack to start")
                .font(.largeTitle)
            Button(action: { self.showNewMultitrackNameInputDialog = true }) {
                Image(systemName: "folder.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150, alignment: .center)
            }
            .padding(.leading)
            Spacer()
        }
    }
    
    var playerView: some View {
        VStack(alignment: .leading, spacing: 0) {
            controlButtons
                .frame(height: 40)
            Divider().padding(.top, 8)
            HStack(spacing: 16) {
                // MARK: Multitrack Picker
                if let selectedMultitrackIndex = viewModel.selectedMultitrackIndex {
                    HStack {
                        Text("Current multitrack: ")
                        MultitrackPicker(
                            selectedMultitrackIndex: selectedMultitrackIndex,
                            multitracks: Array(viewModel.multitracks.values)) { selectedMultitrackIndex in
                                self.viewModel.selectMultitrack(selectedMultitrackIndex)
                            }
                    }
                }
                Spacer()
                if let _ = self.viewModel.selectedMultitrackIndex {
                    Button(action: {
                        showEditMultitrackNameInputDialog = true
                    }) {
                        Image(systemName: "pencil.line")
                            .resizable()
                            .scaledToFit()
                    }
                    Button(action: {
                        self.presentModalDelete.toggle()
                    }) {
                        Image(systemName: "trash")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color("PSRed"))
                    }
                }
            }
            .frame(minHeight:30, maxHeight: 40)
            .padding(.vertical)
            Divider().padding(.bottom, 8)
            Spacer()
            SequenceControlsScreen(viewModel: viewModel)
        }
        .padding(.horizontal, 30)
    }
    
    @ViewBuilder
    var controlButtons: some View {
        HStack(spacing: 16) {
            Button(action: { self.viewModel.playTracks() }) {
                Image(systemName: "play.square")
                    .resizable()
                    .scaledToFit()
            }
            Button(action: { self.viewModel.stopTracks() }) {
                Image(systemName: "stop.circle")
                    .resizable()
                    .scaledToFit()
            }
            Spacer()
            // MARK: Add new multitrack button
            Button(action: { self.showNewMultitrackNameInputDialog = true }) {
                Image(systemName: "folder.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30, alignment: .center)
            }
            .padding(.leading)
            // MARK: Logout button
            Button(action: { viewModel.didTapOnLogOut() }) {
                Image(systemName: "rectangle.portrait.and.arrow.forward")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30, alignment: .center)
                    .foregroundStyle(Color("PSRed"))
            }
            .padding(.leading)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = DashboardViewModel(multitrackRepository: MultitrackLocalRepository(dataManager: .init()),
                                           authenticator: GoogleAuthenticatorManager())
        let id1 = UUID()
        viewModel.multitracks[id1] = (
            .init(
                id: id1,
                name: "Rey de reyes",
                tracks: [.init(
                    id: id1,
                    name: "Click",
                    relativePath: "",
                    config: .init(pan: 0, volume: 0.5, isMuted: false)
                )]
            )
        )
        viewModel.appendTrackController(
            using: Track(
                id: UUID(),
                name: "Click",
                relativePath: "",
                config: .init(pan: -1, volume: 0.5, isMuted: false)
            )
        )
        return DashboardScreen(viewModel: viewModel)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
