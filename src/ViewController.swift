import MobileCoreServices
import UIKit
import WebKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let webView: WKWebView

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = false

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences

        webView = WKWebView()
        webView.backgroundColor = .white
        webView.allowsBackForwardNavigationGestures = false
        webView.allowsLinkPreview = false

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraButtonTapped))
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(libraryButtonTapped))
        }
    }

    override func loadView() {
        self.view = webView
    }

    @objc func cameraButtonTapped() {
        presentImagePicker(sourceType: .camera)
    }

    @objc func libraryButtonTapped() {
        presentImagePicker(sourceType: .photoLibrary)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else {
            return
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
            if self == nil {
                return
            }

            do {
                let data = try Lib.vectorize(image: image)
                DispatchQueue.main.async { [weak self] in
                    self?.showSVG(data)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.showError(error)
                }
            }
        }
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        // TODO: On iPads UIImagePickerController must potentially be presented using a UIPopoverPresentationController.
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }

    private func showSVG(_ data: String) {
        webView.loadHTMLString(data, baseURL: Bundle.main.bundleURL)
    }

    private func showError(_ error: Error) {
        let controller = UIAlertController(title: "Failed to Vectorize", message: error.localizedDescription, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(controller, animated: true)
    }
}
