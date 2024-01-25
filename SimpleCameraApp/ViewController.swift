//
//  ViewController.swift
//  SimpleCameraApp
//
//  Created by Vivek Parmar on 2024-01-22.
//

import AVFoundation
import UIKit

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!

    // MARK: - Properties
    var imagePicker = UIImagePickerController()
    var originalImage: UIImage?
    var photoEditor: PhotoEditor?

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        photoEditor = PhotoEditor(imageView: imageView)
    }

    // MARK: - UI Setup
    func setupUI() {
        imageView.image = nil
        imageView.subviews.forEach { $0.removeFromSuperview() }
        closeButton.isHidden = true
        editPhotoButton.isHidden = true
        saveButton.isHidden = true
        shareButton.isHidden = true
    }

    // MARK: - Button Actions
    @IBAction func takePhotoButtonTapped(_ sender: UIButton) {
        setupUI()
        requestCameraPermission()
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        setupUI()
    }

    @IBAction func editPhotoButtonTapped(_ sender: UIButton) {
        showEditOptions()
    }

    @IBAction func shareButtonTapped(_ sender: UIButton) {
        photoEditor?.sharePhoto()
    }

    @IBAction func savePhotoButtonTapped(_ sender: UIButton) {
        photoEditor?.savePhoto()
    }

    // MARK: - Camera Permission
    func requestCameraPermission() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            openImagePicker()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.openImagePicker()
                    } else {
                        self?.showCameraPermissionAlert()
                    }
                }
            }
        }
    }

    func showCameraPermissionAlert() {
        let alertController = UIAlertController(
            title: "Camera Permission",
            message: "App needs access to your camera. Please enable camera access in Settings.",
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Image Picker
    func openImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Device has no camera library.")
            return
        }
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }

    // MARK: - Edit Options
    func showEditOptions() {
        let alertController = UIAlertController(title: "Edit Photo", message: nil, preferredStyle: .actionSheet)

        let filterAction = UIAlertAction(title: "Apply Filter", style: .default) { _ in
            self.showFilterOptions()
        }
        alertController.addAction(filterAction)

        let addTextAction = UIAlertAction(title: "Add Text", style: .default) { _ in
            self.showTextInputAlert()
        }
        alertController.addAction(addTextAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Filter Options
    func showFilterOptions() {
        guard let originalImage = originalImage else { return }

        let alertController = UIAlertController(title: "Select Filter", message: nil, preferredStyle: .actionSheet)

        let filterActions: [(String, (String) -> Void)] = [
            ("No Filter", { _ in self.imageView.image = originalImage }),
            ("Sepia", { _ in self.photoEditor?.applyFilter(filterName: "CISepiaTone") }),
            ("Black & White", { _ in self.photoEditor?.applyFilter(filterName: "CIPhotoEffectMono") }),
            // Add more filter options as needed
        ]

        for (filterName, action) in filterActions {
            let filterAction = UIAlertAction(title: filterName, style: .default) { _ in
                action(filterName)
            }
            alertController.addAction(filterAction)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Text Alert
    func showTextInputAlert() {
        let alertController = UIAlertController(title: "Add Text", message: "Enter the text to be added", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter text here"
        }

        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            if let text = alertController.textFields?.first?.text {
                self.photoEditor?.addTextToImage(text)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(addAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            originalImage = pickedImage
            imageView.image = pickedImage
            displayImageOption()
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func displayImageOption() {
        editPhotoButton.isHidden = false
        shareButton.isHidden = false
        saveButton.isHidden = false
        closeButton.isHidden = false
    }
}

