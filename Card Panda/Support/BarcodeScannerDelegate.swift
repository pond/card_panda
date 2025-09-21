//
//  BarcodeScannerDelegate.swift
//  Card Panda
//
//  Created by Andrew Hodgkinson on 21/09/2025.
//
protocol BarcodeScannerDelegate: AnyObject {
    func barcodeScanned(_ barcode: String, type: String)
}
