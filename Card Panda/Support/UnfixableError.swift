//
//  UnfixableError.swift
//  Dungeon Panda
//
//  Created by Andrew Hodgkinson on 28/03/21.
//

//{
//    /**
//     Show an error message. All the user can do is dismiss it.
//
//     - Parameters:
//     - message: The error message to display.
//     - using: The UIViewController (or subclass) to be used to present the error, or `nil` to try and synthesise a top-of-stack window to use for this.
//
//     This can be called safely from any thread.
//     */
//    func display(message: String, using: UIViewController?)
//    {
//        var presenter: UIViewController
//
//        if using != nil
//        {
//            presenter = using!
//        }
//        else
//        {
//            let topWindow = UIWindow(frame: UIScreen.main.bounds)
//
//            topWindow.rootViewController = UIViewController()
//            topWindow.windowLevel = UIWindow.Level.alert + 1
//            topWindow.makeKeyAndVisible()
//
//            presenter = topWindow.rootViewController!
//        }
//
//        DispatchQueue.main.async
//        {
//            let alert = UIAlertController(title: "Bad times", message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Oh 😐", style: .default, handler: nil))
//            presenter.present(alert, animated: true, completion: nil)
//        }
//    }
//}
