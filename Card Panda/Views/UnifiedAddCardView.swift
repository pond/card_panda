//
//  UnifiedAddCardView.swift
//  Card Panda
//
//  Created by Andrew Hodgkinson on 22/09/2025.
//
import SwiftUI
import CoreData
import PhotosUI
import Vision

struct UnifiedAddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LoyaltyCard.name, ascending: true)],
        animation: .default
    )

    private var cards: FetchedResults<LoyaltyCard>

    @State private var name = ""
    @State private var selectedColor = Constants.defaultCardColour
    @State private var barcode = ""
    @State private var barcodeType = "code128"

    @State private var showingScanner = false
    @State private var showingPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isProcessingPhoto = false
    @State private var showError = false
    @State private var errorMessage = ""

    @FocusState private var isNameFocused: Bool
    @FocusState private var isBarcodeNumberFocused: Bool

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                            .labelsHidden()
                            .frame(width: 30, height: 30)

                        TextField("Card name", text: $name)
                            .autocapitalization(.words)
                            .autocorrectionDisabled()
                            .focused($isNameFocused)
                    }
                } header: {
                    Text("COLOUR AND NAME")
                }

                Section {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Button(action: {
                                showingScanner = true
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "barcode.viewfinder")
                                        .font(.title2)
                                    Text("Scan")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Button(action: {
                                showingPhotoPicker = true
                            }) {
                                VStack(spacing: 8) {
                                    Group {
                                        if isProcessingPhoto {
                                            ProgressView()
                                        } else {
                                            Image(systemName: "photo.on.rectangle")
                                        }
                                    }
                                    .font(.title2)

                                    Text(isProcessingPhoto ? "Processing..." : "Photo")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(isProcessingPhoto)
                            .id("photoPicker")
                        }

                        TextField("Or enter barcode number", text: $barcode)
                            .keyboardType(.numbersAndPunctuation)
                            .autocorrectionDisabled()
                            .focused($isBarcodeNumberFocused)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                } header: {
                    Text("Barcode")
                } footer: {
                    Text("Use the camera to scan a barcode or select a photo containing one. Things like QR codes and boarding passes work too, or you can enter a number manually.")
                }
            }
            .navigationTitle("Add Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCard()
                    }
                    .disabled(barcode.isEmpty)
                }
            }
            .onAppear {
                isNameFocused = true
            }
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerView { scannedBarcode, symbology in
                    barcode = scannedBarcode
                    barcodeType = BarcodeUtils.barcodeSymbologyToInternalType(symbology)
                }
                .ignoresSafeArea(.all)
            }
            .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { newItem in
                guard let newItem = newItem else { return }
                Task {
                    isProcessingPhoto = true
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await processImage(image)
                    }
                    isProcessingPhoto = false
                }
            }
            .alert("Scan error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func saveCard() {
        let newCard = LoyaltyCard(context: viewContext)

        newCard.name        = name.isEmpty ? "Card \(cards.count + 1)" : name
        newCard.uiColor     = selectedColor
        newCard.barcode     = barcode
        newCard.barcodeType = barcodeType
        newCard.dateAdded   = Date()

        try? viewContext.save()
        dismiss()
    }

    private func processImage(_ image: UIImage) async {
        guard let cgImage = image.cgImage else {
            showError(message: "Could not process that photo")
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNDetectBarcodesRequest { [self] request, error in
            if let error = error {
                showError(message: "Scan failed: \(error.localizedDescription)")
                return
            }

            guard let results = request.results as? [VNBarcodeObservation],
                  let barcodeResult = results.first else {
                showError(message: "No barcode found in the photo")
                return
            }

            if let payload = barcodeResult.payloadStringValue {
                DispatchQueue.main.async {
                    self.barcode = payload
                    self.barcodeType = BarcodeUtils.barcodeSymbologyToInternalType(barcodeResult.symbology)
                }
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
        DispatchQueue.main.async {
            errorMessage = message
            showError = true
        }
    }
}
