//
//  BarcodeScannerView.swift
//  Card Panda
//
//  Created by Andrew Hodgkinson on 21/09/2025.
//
import SwiftUI
import Vision
import VisionKit
import AVFoundation

struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    let onBarcodeScanned: (String, VNBarcodeSymbology) -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScannerViewRepresentable(onBarcodeScanned: onBarcodeScanned)
                .ignoresSafeArea(.all)

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .padding()
        }
    }
}

struct ScannerViewRepresentable: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

    let onBarcodeScanned: (String, VNBarcodeSymbology) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes:            [.barcode()],
            qualityLevel:                   .balanced,
            recognizesMultipleItems:        false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled:           true,
            isGuidanceEnabled:              true,
            isHighlightingEnabled:          true
        )

        scanner.delegate             = context.coordinator
        scanner.view.backgroundColor = .black

        try? scanner.startScanning()
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onBarcodeScanned: onBarcodeScanned, dismiss: dismiss)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onBarcodeScanned: (String, VNBarcodeSymbology) -> Void
        let dismiss:          DismissAction

        init(onBarcodeScanned: @escaping (String, VNBarcodeSymbology) -> Void, dismiss: DismissAction) {
            self.onBarcodeScanned = onBarcodeScanned
            self.dismiss          = dismiss
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .barcode(let barcode):
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                onBarcodeScanned(barcode.payloadStringValue ?? "", barcode.observation.symbology)
                dismiss()
            default:
                break
            }
        }
    }
}
