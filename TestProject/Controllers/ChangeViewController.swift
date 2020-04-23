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
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var savingIndicator: UIActivityIndicatorView!
    
    var image: UIImage?
    var nameTextField: UITextField?
    
    var currentFilter = "CISepiaTone"
    
    var assetsImage: PHAsset?
    var ciImage: CIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        ciImage = CIImage(image: imageView.image!)
    }
    
    @IBAction func saveImage(_ sender: UIButton) {
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
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
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
        
        guard nameTextField?.text != "" else { return }
        
        
    }
    
    @IBAction func turnImage(_ sender: UIBarButtonItem) {
        ciImage = ciImage?.transformed(by: .init(rotationAngle: -.pi / 2))
        
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciImage!, from: ciImage!.extent)!
        
        imageView.image = UIImage(cgImage: cgImage)
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

extension ChangeViewController {
    
    @IBAction func sepiaSelected(_ sender: UIBarButtonItem) {
        currentFilter = "CISepiaTone"
        if imageView.image != nil {
            imageView.image = addFilter(inputImage: imageView.image!, orientation: nil)
        }
    }
    
    @IBAction func monoSelected(_ sender: UIBarButtonItem) {
        currentFilter = "CIPhotoEffectMono"
        if imageView.image != nil {
            imageView.image = addFilter(inputImage: imageView.image!, orientation: nil)
        }
    }
    
    @IBAction func invertSelected(_ sender: UIBarButtonItem) {
        currentFilter = "CIComicEffect"
        if imageView.image != nil {
            imageView.image = addFilter(inputImage: imageView.image!, orientation: nil)
        }
    }
    
    func addFilter(inputImage: UIImage, orientation: Int32?) -> UIImage? {
        let cimage = ciImage
        
        let filter = CIFilter(name: currentFilter)
        filter?.setDefaults()
        filter?.setValue(cimage, forKey: "inputImage")
        
        let ciFiltredImage = filter?.outputImage
        ciImage = ciFiltredImage
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciFiltredImage!, from: ciFiltredImage!.extent)!
        
        let resultImage = UIImage(cgImage: cgImage)
        return resultImage
    }
    
}
