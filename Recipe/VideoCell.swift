//
//  VideoCell.swift
//  Recipe
//
//  Created by iOS on 24/11/15.
//  Copyright © 2015 iOS. All rights reserved.
//

import Foundation
class VideoCell: UITableViewCell {
    @IBOutlet private weak var collectionView: UICollectionView!

}
extension VideoCell {
    
    func setCollectionViewDataSourceDelegate<D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>(dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set {
            collectionView.contentOffset.x = newValue
        }
        
        get {
            return collectionView.contentOffset.x
        }
    }
}