//
//  ChangeViewController.swift
//  TestProject
//
//  Created by MG on 22.04.2020.
//  Copyright © 2020 MG. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary

class ChangeViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var savingIndicator: UIActivityIndicatorView!
    
    var image: UIImage?
    private var nameTextField: UITextField?
    
    private var currentFilter = "CISepiaTone"
    
    var assetsImage: PHAsset?
    private var ciImage: CIImage?
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        if let image = imageView.image {
            ciImage = CIImage(image: image)
        }
    }
    
}

//MARK: - Saving

private extension ChangeViewController {
    
    @IBAction func saveImage(_ sender: UIBarButtonItem) {
        guard let imageToSave = ciImage else { return }
        savingIndicator.startAnimating()
         
        let softwareContext = CIContext(options:[CIContextOption.useSoftwareRenderer: true])
        if let cgimg = softwareContext.createCGImage(imageToSave, from:imageToSave.extent) {
            UIImageWriteToSavedPhotosAlbum(UIImage(cgImage: cgimg), self, #selector(completionSave), nil)
        }
    }
    
    @objc func completionSave(image: UIImage, didFinishSavingWithError error: Error?, contextInfo: Any) {
        savingIndicator.stopAnimating()
        
        if let error = error {
            let alert = UIAlertController(title: NSLocalizedString("Save Error", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            
        } else {
            guard let vc = navigationController?.viewControllers[1] else { return }
            navigationController?.popToViewController(vc, animated: false)
        }
    }
    
}

//MARK: - Rotation image

private extension ChangeViewController {
    
    @IBAction func turnImage(_ sender: UIBarButtonItem) {
        ciImage = ciImage?.transformed(by: .init(rotationAngle: -.pi / 2))
        
        guard let ciImage = ciImage else { return }
        
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        
        if let image = cgImage {
            imageView.image = UIImage(cgImage: image)
        }
    }
    
    func rotationView(viewRotate: UIView, angleRotate: CGFloat) {
        
        let currentTransform = viewRotate.transform
        let newTransform = currentTransform.rotated(by: angleRotate)
        
        UIView.animateKeyframes(withDuration: 0.5,
                                delay: 0,
                                options: [.beginFromCurrentState, .calculationModeLinear],
                                animations: {
                                    viewRotate.transform = newTransform
        })
    }
    
}

//MARK: - Filters

private extension ChangeViewController {
    
    @IBAction func sepiaSelected(_ sender: UIBarButtonItem) {
        currentFilter = "CISepiaTone"
        if let image = imageView.image {
            imageView.image = addFilter(inputImage: image)
        }
    }
    
    @IBAction func monoSelected(_ sender: UIBarButtonItem) {
        currentFilter = "CIPhotoEffectMono"
        if let image = imageView.image {
            imageView.image = addFilter(inputImage: image)
        }
    }
    
    @IBAction func invertSelected(_ sender: UIBarButtonItem) {
        currentFilter = "CIComicEffect"
        if let image = imageView.image {
            imageView.image = addFilter(inputImage: image)
        }
    }
    
    func addFilter(inputImage: UIImage) -> UIImage? {
        let cimage = ciImage
        
        let filter = CIFilter(name: currentFilter)
        filter?.setDefaults()
        filter?.setValue(cimage, forKey: "inputImage")
        
        guard let ciFiltredImage = filter?.outputImage else {
            print("addFilter error (ciFiltredImage)")
            return nil
        }
        ciImage = ciFiltredImage
        let context = CIContext(options: nil)
        
        guard let cgImage = context.createCGImage(ciFiltredImage, from: ciFiltredImage.extent) else {
            print("addFilter error (cgImage)")
            return nil
        }
        
        let resultImage = UIImage(cgImage: cgImage)
        return resultImage
    }
    
}

//MARK: - Rename

private extension ChangeViewController {
    
    @IBAction func renameImage(_ sender: UIBarButtonItem) {
        let newView = UITextField()
        view.addSubview(newView)
        
        newView.becomeFirstResponder()
        newView.translatesAutoresizingMaskIntoConstraints = false
        newView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80).isActive = true
        newView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        newView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        newView.backgroundColor = .yellow
        
        nameTextField = newView
        
        let button = UIButton()
        button.setTitle("Ok", for: .normal)
        button.addTarget(self, action: #selector(saveNewName), for: .touchUpInside)
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80).isActive = true
        button.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 130).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.backgroundColor = .red
    }
    
    @objc func saveNewName() {
        guard let text = nameTextField?.text, text != "" else { return }
        
        assetsImage?.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (input, _) in
            guard let input = input else { return }
            let url = input.fullSizeImageURL
            let newName = text + ".JPG"
            
            var oldURL = url
            oldURL?.deleteLastPathComponent()
            let newURL = oldURL?.appendingPathComponent(newName)
            
            guard let moveUrl = url, let moveNewURL = newURL else {
                print("url / newUrl = nil")
                return
            }
            
            do{
                try FileManager.default.moveItem(at: moveUrl, to: moveNewURL)
            } catch {
                print("moveItem \(error)")
            }
            
            let result = PHContentEditingOutput(contentEditingInput: input).renderedContentURL

            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: result)
            }) { (success, error) in
                if !success {
                    print(error ?? "performChanges Error")
                }
            }
        }
    }
    
}
