//
//  BarcodeView.swift
//  Card Panda
//
//  Created by Andrew Hodgkinson on 21/09/2025.
//
import SwiftUI

struct BarcodeView: UIViewRepresentable {
    let barcode: String
    let type:    String

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        let imageView     = UIImageView()

        imageView.contentMode                               = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo:   containerView.widthAnchor, multiplier: 1),
            imageView.heightAnchor.constraint(equalTo:  containerView.heightAnchor)
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
        let data          = string.data(using: .ascii)
        let fallbackImage = UIImage(systemName: "barcode") ?? UIImage()
        let filterName    = BarcodeUtils.barcodeInternalTypeToFilterName(type)
        var filter        = CIFilter(name: filterName)
        var effectiveType = type

        if (filter == nil) {
            effectiveType = "code128"
            filter        = CIFilter(name: "CICode128BarcodeGenerator")

            if (filter == nil) { return fallbackImage }
        }

        filter!.setValue(data, forKey: "inputMessage")

        if effectiveType == "qr" {
            filter!.setValue("M", forKey: "inputCorrectionLevel")
        } else if effectiveType == "aztec" {
            filter!.setValue(23, forKey: "inputLayers")
        }

        let transform = effectiveType == "qr" ? CGAffineTransform(scaleX: 10, y: 10) : CGAffineTransform(scaleX: 3, y: 3)
        guard let output = filter!.outputImage?.transformed(by: transform) else { return fallbackImage }

        return UIImage(ciImage: output)
    }
}
