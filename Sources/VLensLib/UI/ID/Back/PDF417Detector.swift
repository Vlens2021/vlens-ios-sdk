//
//  PDF417Detector.swift
//  VLensLib
//
//  Created by Mohamed Taher on 10/09/2025.
//

import Vision
import CoreGraphics

public actor PDF417Detector {
    public init() {}

    public func detectPDF417(in image: CGImage) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectBarcodesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let results = request.results as? [VNBarcodeObservation] else {
                    continuation.resume(returning: false)
                    return
                }

                // ✅ Check if any result is PDF417
                let found = results.contains { $0.symbology == .PDF417 }
                continuation.resume(returning: found)
            }

            // Limit detection to only PDF417 for better performance
            request.symbologies = [.PDF417]

            DispatchQueue.global(qos: .userInitiated).async {
                let handler = VNImageRequestHandler(cgImage: image, orientation: .right, options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
