//
//  BarcodeUtils.swift
//  Card Panda
//
//  Created by Andrew Hodgkinson on 21/09/2025.
//
import AVFoundation

enum BarcodeUtils {
    static func barcodeAVFoundationTypeToString(_ type: AVMetadataObject.ObjectType) -> String {
        switch type {
            case .ean8:       return "ean8"
            case .ean13:      return "ean13"
            case .pdf417:     return "pdf417"
            case .code39:     return "code39"
            case .code93:     return "code93"
            case .upce:       return "upce"
            case .aztec:      return "aztec"
            case .dataMatrix: return "dataMatrix"
            case .qr:         return "qr"

            default:          return "code128"
        }
    }

    static func barcodeInternalTypeToFilterName(_ type: String) -> String {
        switch type {
            case "qr":         return "CIQRCodeGenerator"
            case "aztec":      return "CIAztecCodeGenerator"
            case "pdf417":     return "CIPDF417BarcodeGenerator"
            case "dataMatrix": return "CIDataMatrixCodeGenerator"

            default:           return "CICode128BarcodeGenerator"
        }
    }
}
