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
    
    @IBOutlet weak var imageView: UIImageView!
    var assetCollection: PHAssetCollection?
    var photos: PHFetchResult<PHAsset>?
    var image: PHAsset?
    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        showImage()
    }
    
    func showImage() {
        guard let image = image else { return }
        
        PHImageManager.default().requestImage(for: image, targetSize: CGSize(width: 1080, height: 1080), contentMode: .aspectFill, options: nil) { (result, info) in
            
        if let image = result {
            self.imageView.image = image
            self.selectedImage = image
            }
        }
    }
    
    @IBAction func NextImage(_ sender: UIBarButtonItem) {
        
        guard let photos = photos, let image = image else { return }
        let index = photos.index(of: image) + 1
        
        guard index < photos.count, index >= 0 else { return }
        self.image = photos[index]
        
        imageView.transform = CGAffineTransform.identity
        showImage()
    }
    
    @IBAction func previousImage(_ sender: UIBarButtonItem) {
        
        guard let photos = photos, let image = image else { return }
        let index = photos.index(of: image) - 1
        
        guard index < photos.count, index >= 0  else { return }
        self.image = photos[index]
        
        imageView.transform = CGAffineTransform.identity
        showImage()
    }
    
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
    
    @IBAction func imageTapped(_ sender: UILongPressGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        view.addSubview(newImageView)
        
        newImageView.translatesAutoresizingMaskIntoConstraints = false
        newImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        newImageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        newImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        newImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChangeViewController, let selectedImage = selectedImage {
            vc.image = selectedImage
            vc.assetsImage = image
        }
    }
    
}
