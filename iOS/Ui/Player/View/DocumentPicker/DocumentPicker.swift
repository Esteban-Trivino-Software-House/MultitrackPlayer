//
//  DocumentPicker.swift
//  Play Secuence (iOS)
//
//  Created by Esteban Rafael Trivino Guerra on 8/09/22.
//

import Foundation
import SwiftUI

struct DocumentPicker: UIViewControllerRepresentable {
    
    let onPickElements: (_ urls: [URL]) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker: UIDocumentPickerViewController
        picker = UIDocumentPickerViewController(forOpeningContentTypes: [.mp3, .wav], asCopy: false)
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        DocumentPicker.DocumentPickerCoordinator(documentPicker: self)
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {
        
    }
    
    class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
        var documentPicker: DocumentPicker
        
        init(documentPicker: DocumentPicker) {
            self.documentPicker = documentPicker
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            self.documentPicker.onPickElements(urls)
        }
    }
    
}
