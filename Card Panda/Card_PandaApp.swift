////
////  Card_PandaApp.swift
////  Card Panda
////
////  Created by Andrew Hodgkinson on 19/09/2025.
////
//
//import SwiftUI
//import CoreData
//
//@main
//struct Card_PandaApp: App {
//    let persistenceController = PersistenceController.shared
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
//        }
//    }
//}

import SwiftUI
import CoreData
import CloudKit
import AVFoundation
import VisionKit

@main
struct LoyaltyCardApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

// MARK: - Core Data Stack
class PersistenceController {
    static let shared = PersistenceController()
    
    lazy var container: NSPersistentCloudKitContainer = {
        let model = Self.createManagedObjectModel()
        let container = NSPersistentCloudKitContainer(name: "LoyaltyCards", managedObjectModel: model)
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve store description")
        }
        
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
    
    // Core Data Model in Code
    static func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        let entity = NSEntityDescription()
        entity.name = "LoyaltyCard"
        entity.managedObjectClassName = NSStringFromClass(LoyaltyCard.self)
        
        let nameAttribute = NSAttributeDescription()
        nameAttribute.name = "name"
        nameAttribute.attributeType = .stringAttributeType
        nameAttribute.isOptional = false
        
        let barcodeAttribute = NSAttributeDescription()
        barcodeAttribute.name = "barcode"
        barcodeAttribute.attributeType = .stringAttributeType
        barcodeAttribute.isOptional = false
        
        let barcodeTypeAttribute = NSAttributeDescription()
        barcodeTypeAttribute.name = "barcodeType"
        barcodeTypeAttribute.attributeType = .stringAttributeType
        barcodeTypeAttribute.isOptional = false
        barcodeTypeAttribute.defaultValue = "code128"

        let dateAttribute = NSAttributeDescription()
        dateAttribute.name = "dateAdded"
        dateAttribute.attributeType = .dateAttributeType
        dateAttribute.isOptional = false
        
        entity.properties = [nameAttribute, barcodeAttribute, barcodeTypeAttribute, dateAttribute]
        model.entities = [entity]
        
        return model
    }
}

// MARK: - Core Data Entity
@objc(LoyaltyCard)
class LoyaltyCard: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var barcode: String
    @NSManaged var barcodeType: String
    @NSManaged var dateAdded: Date
}

// MARK: - Main View
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: NSEntityDescription.entity(forEntityName: "LoyaltyCard", in: PersistenceController.shared.container.viewContext)!,
        sortDescriptors: [NSSortDescriptor(keyPath: \LoyaltyCard.dateAdded, ascending: false)],
        animation: .default)
    private var cards: FetchedResults<LoyaltyCard>
    
    @State private var showingScanner = false
    @State private var showingAddCard = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(cards, id: \.self) { card in
                    NavigationLink(destination: CardDetailView(card: card)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(card.name)
                                .font(.headline)
                            Text(card.barcode)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .onDelete(perform: deleteCards)
            }
            .navigationTitle("Card Panda")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Scan Barcode") {
                            showingScanner = true
                        }
                        Button("Add Manually") {
                            showingAddCard = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerView { barcode, type in
                    addCard(barcode: barcode, type: type)
                }
            }
            .sheet(isPresented: $showingAddCard) {
                AddCardView()
            }
        }
    }
    
    private func addCard(barcode: String, type: String = "code128") {
        let newCard = LoyaltyCard(context: viewContext)
        newCard.name = "Card \(cards.count + 1)"
        newCard.barcode = barcode
        newCard.barcodeType = type
        newCard.dateAdded = Date()
        
        PersistenceController.shared.save()
        showingScanner = false
    }
    
    private func deleteCards(offsets: IndexSet) {
        withAnimation {
            offsets.map { cards[$0] }.forEach(viewContext.delete)
            PersistenceController.shared.save()
        }
    }
}

// MARK: - https://stackoverflow.com/a/59746380
//
struct WillDisappearHandler: UIViewControllerRepresentable {
    func makeCoordinator() -> WillDisappearHandler.Coordinator {
        Coordinator(onWillDisappear: onWillDisappear)
    }

    let onWillDisappear: () -> Void

    func makeUIViewController(context: UIViewControllerRepresentableContext<WillDisappearHandler>) -> UIViewController {
        context.coordinator
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<WillDisappearHandler>) {
    }

    typealias UIViewControllerType = UIViewController

    class Coordinator: UIViewController {
        let onWillDisappear: () -> Void

        init(onWillDisappear: @escaping () -> Void) {
            self.onWillDisappear = onWillDisappear
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            onWillDisappear()
        }
    }
}

struct WillDisappearModifier: ViewModifier {
    let callback: () -> Void

    func body(content: Content) -> some View {
        content
            .background(WillDisappearHandler(onWillDisappear: callback))
    }
}

extension View {
    func onWillDisappear(_ perform: @escaping () -> Void) -> some View {
        self.modifier(WillDisappearModifier(callback: perform))
    }
}

// MARK: - Card Detail View

struct CardDetailView: View {
    @ObservedObject var card: LoyaltyCard
    @Environment(\.managedObjectContext) private var viewContext
    @State private var editingName = false
    @State private var editingBarcode = false
    @State private var newName = ""
    @State private var newBarcode = ""
    @State private var originalBrightness: CGFloat = UIScreen.main.brightness
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if editingName {
                    VStack(spacing: 10) {
                        TextField("Card name", text: $newName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        HStack {
                            Button("Save") {
                                card.name = newName
                                PersistenceController.shared.save()
                                editingName = false
                            }
                            .buttonStyle(.borderedProminent)
                            Button("Cancel") {
                                editingName = false
                                newName = card.name
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                } else {
                    HStack {
                        Text(card.name)
                            .font(.title)
                        Spacer()
                        Button("Edit") {
                            newName = card.name
                            editingName = true
                        }
                    }
                    .padding()
                }
                
                BarcodeView(barcode: card.barcode, type: card.barcodeType)
                    .frame(height: 200)
                
                if editingBarcode {
                    VStack(spacing: 10) {
                        TextField("Barcode number", text: $newBarcode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numbersAndPunctuation)
                        HStack {
                            Button("Save") {
                                card.barcode = newBarcode
                                PersistenceController.shared.save()
                                editingBarcode = false
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(newBarcode.isEmpty)
                            Button("Cancel") {
                                editingBarcode = false
                                newBarcode = card.barcode
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                } else {
                    VStack {
                        Text(card.barcode)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        Button("Edit") {
                            newBarcode = card.barcode
                            editingBarcode = true
                        }
                    }
                    .padding(.vertical)
                }
                
                Spacer(minLength: 100)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            originalBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = 1.0
        }
        .onWillDisappear {
            UIScreen.main.brightness = originalBrightness
        }
    }
}

// MARK: - Add Card View
struct AddCardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var barcode = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Card name", text: $name)
                    .textContentType(.name)
                    .autocapitalization(.words)
                TextField("Barcode number", text: $barcode)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Add Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newCard = LoyaltyCard(context: viewContext)
                        newCard.name = name.isEmpty ? "Card" : name
                        newCard.barcode = barcode
                        newCard.barcodeType = "code128"
                        newCard.dateAdded = Date()
                        
                        PersistenceController.shared.save()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(barcode.isEmpty)
                }
            }
        }
    }
}

// MARK: - Barcode Scanner
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

protocol BarcodeScannerDelegate: AnyObject {
    func barcodeScanned(_ barcode: String, type: String)
}

class BarcodeScannerViewController: UIViewController {
    weak var delegate: BarcodeScannerDelegate?
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else { return }
        
        captureSession.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .code128, .code39, .code93, .upce, .aztec, .dataMatrix, .qr]
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
}

extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            captureSession.stopRunning()
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            let typeString = barcodeTypeToString(readableObject.type)
            delegate?.barcodeScanned(stringValue, type: typeString)
        }
    }

    private func barcodeTypeToString(_ type: AVMetadataObject.ObjectType) -> String {
        switch type {
            case .ean8: return "ean8"
            case .ean13: return "ean13"
            case .pdf417: return "pdf417"
            case .code128: return "code128"
            case .code39: return "code39"
            case .code93: return "code93"
            case .upce: return "upce"
            case .aztec: return "aztec"
            case .dataMatrix: return "dataMatrix"
            case .qr: return "qr"
    
            default: return "code128"
        }
    }
}

// MARK: - Barcode Display View
struct BarcodeView: UIViewRepresentable {
    let barcode: String
    let type: String

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        let imageView = UIImageView()

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1),
            imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let imageView = uiView.subviews.first as? UIImageView {
            let cleanBarcode = barcode.filter { $0.isNumber }
            imageView.image = generateBarcode(from: cleanBarcode, type: type)
        }
    }
    
    private func generateBarcode(from string: String, type: String) -> UIImage {
        let data = string.data(using: .ascii)
        let filterName = barcodeTypeToFilter(type)
        let fallbackImage = UIImage(systemName: "barcode") ?? UIImage()

        guard let filter = CIFilter(name: filterName) else {
            guard let fallbackFilter = CIFilter(name: "CICode128BarcodeGenerator") else { return fallbackImage }
            fallbackFilter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            guard let output = fallbackFilter.outputImage?.transformed(by: transform) else { return fallbackImage }
            return UIImage(ciImage: output)
        }
        
        filter.setValue(data, forKey: "inputMessage")

        if type == "qr" {
            filter.setValue("M", forKey: "inputCorrectionLevel")
        } else if type == "aztec" {
            filter.setValue(23, forKey: "inputLayers")
        }
        
        let transform = type == "qr" ? CGAffineTransform(scaleX: 10, y: 10) : CGAffineTransform(scaleX: 3, y: 3)
        guard let output = filter.outputImage?.transformed(by: transform) else { return fallbackImage }

        return UIImage(ciImage: output)
    }

    private func barcodeTypeToFilter(_ type: String) -> String {
        switch type {
            case "qr": return "CIQRCodeGenerator"
            case "aztec": return "CIAztecCodeGenerator"
            case "pdf417": return "CIPDF417BarcodeGenerator"
            case "dataMatrix": return "CIDataMatrixCodeGenerator"
            default: return "CICode128BarcodeGenerator"
        }
    }
}
