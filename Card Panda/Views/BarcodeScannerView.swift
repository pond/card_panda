//
//  BarcodeScannerView.swift
//  Card Panda
//
//  Created by Andrew Hodgkinson on 21/09/2025.
//
import UIKit
import SwiftUI

struct BarcodeScannerView: UIViewControllerRepresentable {
    let onBarcodeScanned: (String, String) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let scanner = BarcodeScannerViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onBarcodeScanned)
    }

    class Coordinator: NSObject, BarcodeScannerDelegate {
        let onBarcodeScanned: (String, String) -> Void

        init(_ onBarcodeScanned: @escaping (String, String) -> Void) {
            self.onBarcodeScanned = onBarcodeScanned
        }

        func barcodeScanned(_ barcode: String, type: String) {
            onBarcodeScanned(barcode, type)
        }
    }
}
