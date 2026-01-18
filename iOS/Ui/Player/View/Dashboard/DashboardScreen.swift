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
    @StateObject var viewModel = DashboardViewModel()
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
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                Divider().padding(.top, 8)
                HStack {
                    // MARK: Multitrack Picker
                    if let selectedMultitrackIndex = viewModel.selectedMultitrackIndex {
                        Text("Current multitrack: ")
                        MultitrackPicker(
                            selectedMultitrackIndex: selectedMultitrackIndex,
                            multitracks: Array(viewModel.multitracks.values)) { selectedMultitrackIndex in
                                self.viewModel.selectMultitrack(selectedMultitrackIndex)
                            }
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
                }
                
                .frame(minHeight:30, maxHeight: 40)
                Divider().padding(.bottom, 8)
                controlButtons
                Spacer()
                SequenceControlsScreen(viewModel: viewModel)
            }
            .padding(.horizontal, 30)
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
        .confirmationDialog("¿Deseas eliminar el multitrack?", isPresented: self.$presentModalDelete) {
            Button("Eliminar \(viewModel.getSelectedMultitrackName())", role: .destructive) {
                self.viewModel.deleteSelectedMultitrack()
            }
        }
    }
    
    @ViewBuilder
    var controlButtons: some View {
        HStack(spacing: 16) {
            Button(action: { self.viewModel.playTracks() }) {
                Image(systemName: "play.square")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50, alignment: .center)
            }
            Button(action: { self.viewModel.stopTracks() }) {
                Image(systemName: "stop.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50, alignment: .center)
            }
            if let _ = self.viewModel.selectedMultitrackIndex {
                Spacer()
                Button(action: {
                    self.presentModalDelete.toggle()
                }) {
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50, alignment: .center)
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = DashboardViewModel()
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
