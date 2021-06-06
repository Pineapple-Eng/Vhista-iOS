//  Created by Juan David Cruz Serrano on 6/27/19. Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.

import UIKit

private let reuseIdentifier = "FeatureCell"

class FeaturesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    static let viewTopPadding: CGFloat = 8.0
    static let viewHeight: CGFloat = 100.0

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func setUpCollectionView() {
        self.clearsSelectionOnViewWillAppear = false
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor)
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
        didSelectFeature(collectionView, didSelectItemAt: indexPath)
    }

    func didSelectFeature(_ collectionView: UICollectionView,
                          didSelectItemAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let selectedFeature = FeaturesManager.shared.features[indexPath.item]
        FeaturesManager.shared.setSelectedFeature(selectedFeature)
        collectionView.scrollToItem(at: indexPath,
                                    at: .centeredVertically,
                                    animated: true)
        collectionView.reloadData()
    }

    // MARK: UIScrollViewDelegate

    // This keeps the cells of the collection view centered.
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                            withVelocity velocity: CGPoint,
                                            targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing

        var offset = targetContentOffset.pointee
        let index = round((offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing)
        offset = CGPoint(x: index * cellWidthIncludingSpacing - scrollView.contentInset.left,
                         y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }

    /**
        In `scrollViewDidScroll`, we calculate our new centered cell's index, then find the corresponding `Feature`
        in our array and update our current `Feature`. We also animate in or out the gallery button based on
        whether or not we want to show it for the new dog.
    */
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        let itemWidth = flowLayout.itemSize.width
        let offset = self.collectionView.contentOffset.x / itemWidth
        let index = Int(round(offset))

        guard (0..<FeaturesManager.shared.features.count).contains(index) else {
            return
        }

        let selectedFeature = FeaturesManager.shared.features[index]
        FeaturesManager.shared.setSelectedFeature(selectedFeature)
        didSelectFeature(self.collectionView, didSelectItemAt: IndexPath(row: index, section: 0))

        /*
            The information for the Feature displayed below the collection view updates as you scroll,
            but VoiceOver isn't aware that the views have changed their values. So we need to post
            a layout changed notification to let VoiceOver know it needs to update its current
            understanding of what's on screen.
        */
        UIAccessibility.post(notification: .layoutChanged, argument: nil)
    }
}
