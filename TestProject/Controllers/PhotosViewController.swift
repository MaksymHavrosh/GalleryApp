//
//  PhotosViewController.swift
//  TestProject
//
//  Created by MG on 21.04.2020.
//  Copyright © 2020 MG. All rights reserved.
//

import UIKit
import Photos

class PhotosViewController: UICollectionViewController {
    
    private var assetCollection: PHAssetCollection?
    private var photos: PHFetchResult<PHAsset>?
    private var selectedImage: PHAsset?
    
    private let sectionInsets = UIEdgeInsets(top: 30.0, left: 10.0, bottom: 30.0, right: 10.0)
    private let itemsPerRow: CGFloat = 3
    
    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                self.photos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .denied:
                DispatchQueue.main.async {
                    self.showNoAccessAlert()
                }
            case .restricted:
                print("restricted")
            case .notDetermined:
                print("Not determined yet")
            @unknown default:
                fatalError("fatalError in PhotosViewController (viewWillAppear)")
            }
        }
    }
    
    //MARK: - Private
    
    private func showNoAccessAlert() {
        let alert = UIAlertController(title: NSLocalizedString("No Photo Access", comment: ""),
                                      message: "Please grant Stitch photo access in Settings -> Privacy",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            alert.dismiss(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:])
            }
        }))
        self.present(alert, animated: true)
    }
    
    //MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailImageViewController, let selectedImage = selectedImage { 
            vc.image = selectedImage
            vc.photos = photos
            vc.assetCollection = assetCollection
        }
    }
    
}

//MARK: - UICollectionViewDataSource

extension PhotosViewController {
       
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos?.count ?? 0
    }
       
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CollectionViewCell.self), for: indexPath) as! CollectionViewCell
        
        if let asset = photos?[indexPath.row] {
            PHImageManager.default().requestImage(for: asset, targetSize: cell.image.frame.size, contentMode: .aspectFill, options: nil) { (result, info) in
                
                if let image = result {
                    cell.image.image = image
                    cell.nameLabel.text = "   "
                    
                    asset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (input, _) in
                        let url = input?.fullSizeImageURL
                        cell.nameLabel.text = url?.lastPathComponent
                    }
                }
            }
        }
        return cell
    }
       
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = photos?[indexPath.row]
        self.performSegue(withIdentifier: "ShowSelectImage", sender: nil)
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout
    
extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let guide = view.safeAreaLayoutGuide
        let width = guide.layoutFrame.size.width

        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}

