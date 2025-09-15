//
//  FaceDetector.swift
//  VLensLib
//
//  Created by Mohamed Taher on 10/09/2025.
//

import Vision
import CoreGraphics

public actor FaceDetector {
    public init() {}

    public func detectFace(in image: CGImage) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectFaceRectanglesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let results = request.results as? [VNFaceObservation] ?? []
                // Return true if exactly one face
                continuation.resume(returning: results.count == 1)
            }

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
