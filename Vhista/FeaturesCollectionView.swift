//
//  FeaturesCollectionViewController.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 6/27/19.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import UIKit

private let reuseIdentifier = "FeatureCell"

class FeaturesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
    }

    func setUpCollectionView() {
        self.clearsSelectionOnViewWillAppear = false
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            self.view.topAnchor.constraint(equalTo: collectionView.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            self.view.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor)
        ])
        self.collectionView = collectionView
        self.collectionView.backgroundColor = .clear
        self.collectionView!.register(FeaturesCollectionViewCell.self,
                                      forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: self.view.frame.size.width/2 - LogoView.viewWidth/2, bottom: 0, right: 0)
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FeaturesManager.shared.features.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dequeCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? FeaturesCollectionViewCell
        guard let cell = dequeCell else {
            return UICollectionViewCell()
        }
        cell.configureCellWithFeature(FeaturesManager.shared.features[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let currentFeature = FeaturesManager.shared.features[indexPath.item]
        if FeaturesManager.shared.getSelectedFeature().featureName == currentFeature.featureName {
            return CGSize(width: LogoView.viewWidth, height: LogoView.viewHeight + 20)
        } else {
            return CGSize(width: LogoView.viewWidth * 0.75, height: (LogoView.viewHeight + 20) * 0.75)
        }
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        let selectedFeature = FeaturesManager.shared.features[indexPath.item]
        FeaturesManager.shared.setSelectedFeature(selectedFeature)
        collectionView.scrollToItem(at: indexPath,
                                    at: .centeredVertically,
                                    animated: true)
        collectionView.reloadData()
    }
}
