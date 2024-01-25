//
//  PhotoEditor.swift
//  SimpleCameraApp
//
//  Created by Vivek Parmar on 2024-01-24.
//

import UIKit

class PhotoEditor: NSObject {

    var imageView: UIImageView

    init(imageView: UIImageView) {
        self.imageView = imageView
    }

    func addTextToImage(_ text: String) {
        guard imageView.image != nil else { return }
        // Create a label with text
        let label = createLabel(withText: text)
        // set label frame
        self.setLabelFrame(label)
        label.center = imageView.center
        // Add pan gesture recognizer for the label
        addPanGesture(to: label)
        // Add the label to the image view
        imageView.addSubview(label)
    }

    // create a label with text
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.preferredMaxLayoutWidth = imageView.bounds.width
        label.isUserInteractionEnabled = true
        
        label.sizeToFit()
        return label
    }
    
    private func setLabelFrame(_ label: UILabel) {
        guard imageView.image != nil else { return }

        let labelSize = label.sizeThatFits(CGSize(width: label.preferredMaxLayoutWidth, height: CGFloat.greatestFiniteMagnitude))
        let labelX = (imageView.bounds.width - labelSize.width) / 2
        let labelY = (imageView.bounds.height - labelSize.height) / 2

        label.frame = CGRect(x: labelX, y: labelY, width: labelSize.width, height: labelSize.height)
    }


    // add pan gesture recognizer to a view
    private func addPanGesture(to view: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }

    func applyFilter(filterName: String) {
        guard let originalImage = imageView.image else { return }
        guard let ciImage = CIImage(image: originalImage) else { return }

        let filter = CIFilter(name: filterName)
        filter?.setValue(ciImage, forKey: kCIInputImageKey)

        if let outputCIImage = filter?.outputImage {
            let context = CIContext(options: nil)
            if let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
                let filteredImage = UIImage(cgImage: outputCGImage)
                imageView.image = filteredImage
            }
        }
    }
    
    func renderImageView() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        imageView.layer.render(in: context)
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return renderedImage
    }

    func sharePhoto() {
        guard let image = renderImageView() else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func savePhoto() {
        guard let image = renderImageView() else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(title: "Error", message: "Failed to save photo. \(error.localizedDescription)")
        } else {
            showAlert(title: "Success", message: "Photo saved successfully.")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Gesture Handling
extension PhotoEditor {
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let label = gesture.view else { return }

        // Get translation
        let translation = gesture.translation(in: imageView)

        // get new center position
        let newCenterX = label.center.x + translation.x
        let newCenterY = label.center.y + translation.y

        // Check new center is within the image boundaries
        let minX = label.bounds.size.width / 2
        let minY = label.bounds.size.height / 2
        let maxX = imageView.bounds.width - minX
        let maxY = imageView.bounds.height - minY

        let clampedCenterX = max(minX, min(newCenterX, maxX))
        let clampedCenterY = max(minY, min(newCenterY, maxY))

        // Set the new center position
        label.center = CGPoint(x: clampedCenterX, y: clampedCenterY)

        // Reset the translation to avoid cumulative changes
        gesture.setTranslation(CGPoint.zero, in: imageView)
    }
}


