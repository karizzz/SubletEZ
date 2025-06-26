//
//  VideoPicker.swift
//  SubletEZ
//
//  Created by Kartik Saxena on 2025-06-19.
//

import SwiftUI
import PhotosUI

struct VideoPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var videoURL: URL?

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: VideoPicker

        init(parent: VideoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()

            guard let provider = results.first?.itemProvider else { return }

            if provider.hasItemConformingToTypeIdentifier("public.movie") {
                provider.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, error in
                    guard let url = url else { return }

                    // Copy the video file to a temp location
                    let tempDir = FileManager.default.temporaryDirectory
                    let targetURL = tempDir.appendingPathComponent("\(UUID().uuidString).mov")
                    try? FileManager.default.copyItem(at: url, to: targetURL)

                    DispatchQueue.main.async {
                        self.parent.videoURL = targetURL
                    }
                }
            }
        }
    }
}
