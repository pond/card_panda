//
//  ViewWill.swift
//  Card Panda
//
//  Created by Andrew Hodgkinson on 16/10/2026.
//
import SwiftUI
import UIKit

struct ViewWill: UIViewControllerRepresentable {
    var appear:    () -> Void
    var disappear: () -> Void

    func makeUIViewController(context: Context) -> Controller { Controller() }

    func updateUIViewController(_ vc: Controller, context: Context) {
        vc.appear    = appear
        vc.disappear = disappear
    }

    final class Controller: UIViewController {
        var appear:    () -> Void = {}
        var disappear: () -> Void = {}

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            appear()
        }
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            disappear()
        }
    }
}
