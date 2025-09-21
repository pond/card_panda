//
//  CameraRollScannerView.swift
//  Card Panda
//
//  Created by Andrew Hodgkinson on 21/09/2025.
//
import SwiftUI
import PhotosUI
import Vision

struct CameraRollScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var showError = false
    @State private var errorMessage = ""
    
    let onBarcodeScanned: (String, VNBarcodeSymbology) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Choose Photo", systemImage: "photo.on.rectangle")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)

                Text("Select an image containing a barcode")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationTitle("Scan from Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await processImage(image)
                    }
                }
            }
            .alert("Scan error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func processImage(_ image: UIImage) async {
        guard let cgImage = image.cgImage else {
            showError(message: "Could not process the selected image")
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNDetectBarcodesRequest { [self] request, error in
            if let error = error {
                showError(message: "Scan failed: \(error.localizedDescription)")
                return
            }
            
            guard let results = request.results as? [VNBarcodeObservation],
                  let barcode = results.first else {
                showError(message: "No barcode found in the image")
                return
            }
            
            // Get the barcode payload
            if let payload = barcode.payloadStringValue {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                onBarcodeScanned(payload, barcode.symbology)
                dismiss()
            } else {
                showError(message: "Could not read barcode data")
            }
        }
        
        do {
            try requestHandler.perform([request])
        } catch {
            showError(message: "Scan failed: \(error.localizedDescription)")
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
