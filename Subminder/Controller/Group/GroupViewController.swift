//
//  GroupViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/10/18.
//

import UIKit

class GroupViewController: SUBaseViewController {

    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var profileCollection: UICollectionView! {

        didSet {

            profileCollection.delegate = self

            profileCollection.dataSource = self
        }
    }

    let manager = ProfileManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2.0

        setupCollectionView()
    }

    private func setupCollectionView() {

        let nib = UINib(nibName: "ProfileCell", bundle: nil)

        profileCollection.register(nib, forCellWithReuseIdentifier: "ProfileCell")

        setupCollectionViewLayout()
    }

    private func setupCollectionViewLayout() {

        let flowLayout = UICollectionViewFlowLayout()

        flowLayout.itemSize = CGSize(
            width: Int(UIScreen.main.bounds.width - 156) / 3,
            height: 60
        )

        flowLayout.minimumInteritemSpacing = 0

        flowLayout.minimumLineSpacing = 0

        profileCollection.collectionViewLayout = flowLayout
    }

}

extension GroupViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return manager.profileItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath)

        guard let profileCell = cell as? ProfileCell else { return cell }

        let title = manager.profileItems[indexPath.row].title

        profileCell.itemLbl.text = title

        return profileCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch indexPath.item {

        case 0:
            _ = navigationController?.popViewController(animated: true)

        default:

            if let controller = storyboard?.instantiateViewController(withIdentifier: "Friend") as? FriendViewController {

                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}
