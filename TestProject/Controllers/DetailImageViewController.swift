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
    @IBOutlet private weak var increaseButton: UIBarButtonItem!
    @IBOutlet private weak var reduceButton: UIBarButtonItem!
    @IBOutlet private weak var toolbar: UIToolbar!
    
    var assetCollection: PHAssetCollection?
    var photos: PHFetchResult<PHAsset>?
    var touchOfSet = CGPoint()
    var image: PHAsset?
    private var selectedImage: UIImage? {
        didSet {
            imageView.image = selectedImage
            fullScreenImageView.image = selectedImage
        }
    }
    
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
        if imageView.frame.width > view.frame.width * 2 {
            increaseButton.isEnabled = false
            return
        }
        reduceButton.isEnabled = true
        
        let currentTransform = imageView.transform
        let newTransform = currentTransform.scaledBy(x: 1.1, y: 1.1)
        
        imageView.transform = newTransform
    }
    
    @IBAction func reduceImage(_ sender: UIBarButtonItem) {
        if imageView.frame.width < view.frame.width / 2 {
            reduceButton.isEnabled = false
            return
        }
        increaseButton.isEnabled = true
        
        if imageView.frame.width < view.frame.width {
            UIView.animate(withDuration: 0.5) {
                self.imageView.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            }
        }
        let currentTransform = imageView.transform
        let newTransform = currentTransform.scaledBy(x: 0.9, y: 0.9)
        
        imageView.transform = newTransform
    }
    
}

//MARK: - Touches

extension DetailImageViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: imageView)
        touchOfSet = CGPoint(x: imageView.bounds.midX - touchPoint.x, y: imageView.bounds.midY - touchPoint.y)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        guard imageView.frame.width > view.frame.width || imageView.frame.height > view.frame.height else { return }
        
        let pointOnMainView = touch.location(in: view)
        let correction = CGPoint(x: pointOnMainView.x + touchOfSet.x, y: pointOnMainView.y + touchOfSet.y)
        
        imageView.center = correction
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        onTouchesEnded()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        onTouchesEnded()
    }
    
    func onTouchesEnded() {
        if imageView.center.x < view.frame.minX || imageView.center.x > view.frame.maxX ||
            imageView.center.y < view.frame.minY || imageView.center.y > view.frame.maxY {
            
            UIView.animate(withDuration: 0.2) {
                self.imageView.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            }
        }
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
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        fullScreenImageView.isHidden = true
        navigationController?.isNavigationBarHidden = false
    }
    
}
