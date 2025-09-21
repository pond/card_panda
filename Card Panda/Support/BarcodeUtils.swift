//
//  BarcodeUtils.swift
//  Card Panda
//
//  Created by Andrew Hodgkinson on 21/09/2025.
//
import Vision

enum BarcodeUtils {
    static func barcodeSymbologyToInternalType(_ symbology: VNBarcodeSymbology) -> String {
        switch symbology {
            case .aztec:                   return "aztec"
            case .code39:                  return "code39"
            case .code39Checksum:          return "code93"
            case .code39FullASCII:         return "code93"
            case .code39FullASCIIChecksum: return "code93"
            case .code93:                  return "code93"
            case .code93i:                 return "code93"
            case .dataMatrix:              return "dataMatrix"
            case .ean13:                   return "ean13"
            case .ean8:                    return "ean8"
            case .microPDF417:             return "pdf417"
            case .microQR:                 return "qr"
            case .pdf417:                  return "pdf417"
            case .qr:                      return "qr"
            case .upce:                    return "upce"

            default:                       return "code128"
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
