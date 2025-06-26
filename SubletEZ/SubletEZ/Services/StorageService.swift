//
//  StorageService.swift
//  SubletEZ
//
//  Created by Kartik Saxena on 2025-06-19.
//

// StorageService.swift

import Foundation
import FirebaseStorage
import UIKit

class StorageService {
    static let shared = StorageService()
    private init() {}

    private let storageRef = Storage.storage().reference()

    func uploadImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageConversionError", code: 0, userInfo: nil)))
            return
        }

        let filename = UUID().uuidString + ".jpg"
        let imageRef = storageRef.child("images/\(filename)")

        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let downloadURL = url {
                    completion(.success(downloadURL.absoluteString))
                }
            }
        }
    }

    func uploadVideo(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let filename = UUID().uuidString + ".mov"
        let videoRef = storageRef.child("videos/\(filename)")

        videoRef.putFile(from: fileURL, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            videoRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let downloadURL = url {
                    completion(.success(downloadURL.absoluteString))
                }
            }
        }
    }
}
