//
//  ChangeImageViewController.swift
//  TestProject
//
//  Created by MG on 21.04.2020.
//  Copyright © 2020 MG. All rights reserved.
//

import UIKit
import Photos

class DetailImageViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var fullScreenImageView: UIImageView!
    @IBOutlet private weak var previousButton: UIBarButtonItem!
    @IBOutlet private weak var nextButton: UIBarButtonItem!
    @IBOutlet private weak var toolbar: UIToolbar!
    
    var assetCollection: PHAssetCollection?
    var photos: PHFetchResult<PHAsset>?
    var image: PHAsset?
    private var selectedImage: UIImage?
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showImage()
    }
    
    //MARK: - Private methods
    
    private func showImage() {
        guard let image = image else { return }
        
        PHImageManager.default().requestImage(for: image, targetSize: CGSize(width: 1080, height: 1080), contentMode: .aspectFill, options: nil) { (result, info) in
            
            if let image = result {
                self.imageView.image = image
                self.selectedImage = image
            }
        }
    }
    
    //MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChangeViewController, let selectedImage = selectedImage {
            vc.image = selectedImage
            vc.assetsImage = image
        }
    }
    
}

//MARK: - Zoom

private extension DetailImageViewController {
    
    @IBAction func increaseImage(_ sender: UIBarButtonItem) {
        
        let currentTransform = imageView.transform
        let newTransform = currentTransform.scaledBy(x: 1.1, y: 1.1)
        
        imageView.transform = newTransform
    }
    
    @IBAction func reduceImage(_ sender: UIBarButtonItem) {
        
        let currentTransform = imageView.transform
        let newTransform = currentTransform.scaledBy(x: 0.9, y: 0.9)
        
        imageView.transform = newTransform
    }
    
}

//MARK: - Navigation functions

private extension DetailImageViewController {
    
    @IBAction func NextImage(_ sender: UIBarButtonItem) {
        
        guard let photos = photos, let image = image else { return }
        let index = photos.index(of: image) + 1
        
        guard index < photos.count, index >= 0 else {
            sender.isEnabled = false
            return
        }
        
        if previousButton.isEnabled == false {
            previousButton.isEnabled = true
        }
        self.image = photos[index]
        
        imageView.transform = CGAffineTransform.identity
        showImage()
    }
    
    @IBAction func previousImage(_ sender: UIBarButtonItem) {
        
        guard let photos = photos, let image = image else { return }
        let index = photos.index(of: image) - 1
        
        guard index < photos.count, index >= 0  else {
            sender.isEnabled = false
            return
        }
        
        if nextButton.isEnabled == false {
            nextButton.isEnabled = true
        }
        
        self.image = photos[index]
        
        imageView.transform = CGAffineTransform.identity
        showImage()
    }
    
}

//MARK: - Gestures

private extension DetailImageViewController {
    
    @IBAction func imageTapped(_ sender: UILongPressGestureRecognizer) {
        fullScreenImageView.isHidden = false
        fullScreenImageView.backgroundColor = .black
        fullScreenImageView.image = selectedImage
        
        navigationController?.isNavigationBarHidden = true
        toolbar.isHidden = true
    }
    
    @IBAction func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        fullScreenImageView.isHidden = true
        fullScreenImageView.backgroundColor = .gray
        fullScreenImageView.image = nil
        
        navigationController?.isNavigationBarHidden = false
        toolbar.isHidden = false
    }
    
}
