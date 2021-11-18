//
//  PersonalSettingViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/14.
//

import UIKit

class PersonalSettingViewController: UIViewController {

    @IBOutlet weak var profileImg: UIImageView!
    
    var usersInfo: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupImg()
        
        setupBarItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchUserData()
    }

    func setupBarItems() {
        
        self.navigationItem.title = "個人資料"
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = UIColor.hexStringToUIColor(hex: "#94959A")
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(updateProfile)
        )
    }
    
    @objc func updateProfile() {
        
        guard let user = usersInfo.first else { return }
        
        guard let image = self.profileImg.image,
              let data = image.pngData() else {
                  return
              }
        
        let fileName = "\(user.uid)_profile_picture.png"
        
        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
            
            switch result {
                
            case .success(let downloadUrl):
                UserManager.shared.updateProfile(userID: user.id, name: user.name, image: downloadUrl) { result in
                    
                    switch result {
                        
                    case .success:
                        
                        print("update user data success")
                    
                    case .failure(let error):
                        
                        print("update user data failure: \(error)")
                    }
                }
                print(downloadUrl)
                
            case .failure(let error):
                print("Storage manager error: \(error)")
            }
        }
    }
    
    func setupImg() {
        
        profileImg.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        
        profileImg.addGestureRecognizer(gesture)
        
        profileImg.layer.masksToBounds = true
        
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2.0
    }
    
    @objc func didTapImage() {
        
        presentPhotoActionSheet()
    }
}

extension PersonalSettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        
        let actionSheet = UIAlertController(title: "個人頭貼",
                                            message: "拍照或從相簿更新頭貼",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "取消",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "拍照",
                                            style: .default,
                                            handler: { [weak self] _ in
            
            self?.presentCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "從相簿選擇",
                                            style: .default,
                                            handler: { [weak self] _ in
            
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        
        let vc = UIImagePickerController()
        
        vc.sourceType = .camera
        
        vc.delegate = self
        
        vc.allowsEditing = true
        
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        
        let vc = UIImagePickerController()
        
        vc.sourceType = .photoLibrary
        
        vc.delegate = self
        
        vc.allowsEditing = true
        
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.profileImg.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PersonalSettingViewController {
    
    func fetchUserData() {
        
        guard let userUID = KeyChainManager.shared.userUID else { return }
        
        UserManager.shared.searchUser(uid: userUID) { [weak self] result in
            
            switch result {
                
            case .success(let users):
                
                print("fetchUserData success")
                
                for user in users {
                    self?.usersInfo.append(user)
                }
                
            case .failure(let error):
                
                print("fetchUserData.failure: \(error)")
            }
        }
    }
}
