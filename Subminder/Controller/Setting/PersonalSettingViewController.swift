//
//  PersonalSettingViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/14.
//

import UIKit
import SVProgressHUD

class PersonalSettingViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var pictureTitleLbl: UILabel!
    
    @IBOutlet weak var profileImg: UIImageView!
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    
    var usersInfo: [User] = [] {
        
        didSet {
            
            tableView.reloadData()
        }
    }
    
    var newUserName: String = ""
    
    var imageUrl: String = ""
    
    var profileSettingTitles = ["用戶名稱", "個人ID"]
    
    var isProfilePicUpdated: Bool = false
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPictureTitleLbl()
        
        registerCell()
        
        setupBarItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // fetch data only when there is no data in data model to enhance loading speed
        let currentUserInfo = SubminderDataModel.shared.currentUserInfo
        if currentUserInfo == nil {
            fetchUserDataAndSetupProfilePic()
        }
        
        setupImg()
    }
    
    // MARK: - Private Implementation

    func setupBarItems() {
        
        self.navigationItem.title = "個人資料"

        navigationController?.navigationBar.tintColor = .white
        
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
        
        guard let user = SubminderDataModel.shared.currentUserInfo else { return }
        
        guard let image = self.profileImg.image,
              let data = image.jpegData(compressionQuality: 0.15) else {
                  return
              }
        
        let fileName = "\(user.uid)_profile_picture.jpeg"
        
        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
            
            switch result {
                
            case .success(let downloadUrl):
                UserManager.shared.updateProfilePicture(userID: user.id, image: downloadUrl) { result in
                    
                    switch result {
                        
                    case .success:
                        
                        print("update user picture success")
                        
                        self.imageUrl = downloadUrl
                        SubminderDataModel.shared.currentUserInfo?.image = downloadUrl // update data in data model
                    
                    case .failure(let error):
                        
                        print("update user picture failure: \(error)")
                    }
                }
                print(downloadUrl)
                
            case .failure(let error):
                print("Storage manager error: \(error)")
            }
        }
        
        UserManager.shared.updateProfileName(userID: user.id, name: newUserName) { result in
            
            switch result {
                
            case .success:
                
                print("update user name success")
                
                SubminderDataModel.shared.currentUserInfo?.name = self.newUserName // update data in data model
            
            case .failure(let error):
                
                print("update user name failure: \(error)")
            }
        }
        
        showAlert(title: "系統提示", message: "個人檔案已更新")
    }
    
    func setupImg() {
        
        profileImg.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        profileImg.addGestureRecognizer(gesture)
        
        profileImg.layer.masksToBounds = true
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2.0
        
        if !isProfilePicUpdated {
            guard let imageUrl = SubminderDataModel.shared.currentUserInfo?.image else { return }
            if let url = URL(string: imageUrl),
               let data = try? Data(contentsOf: url) {
                profileImg.image = UIImage(data: data)
            }
        }
    }
    
    func setupPictureTitleLbl() {
        
        pictureTitleLbl.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        
        pictureTitleLbl.addGestureRecognizer(gesture)
    }
    
    func registerCell() {
        
        let nib = UINib(nibName: "AddSubTextCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AddSubTextCell")
        
        let idNib = UINib(nibName: "ProfileSettingCell", bundle: nil)
        tableView.register(idNib, forCellReuseIdentifier: "ProfileSettingCell")
    }
    
    func showAlert(title: String, message: String) {
        let alert = AlertManager.simpleConfirmAlert(in: self, title: title, message: message, confirmTitle: "好")
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func didTapImage() {
        
        presentPhotoActionSheet()
    }
    
    @objc func onUserNameChanged(_ sender: UITextField) {
        
        newUserName = sender.text ?? ""
    }
    
    @objc func didTapIDLbl() {
        
        guard let user = usersInfo.first else { return }
        
        UIPasteboard.general.string = "\(user.id)"
        
        showAlert(title: "系統提示", message: "ID已經複製到剪貼簿囉")
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension PersonalSettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        profileSettingTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubTextCell", for: indexPath)
        guard let cell = cell as? AddSubTextCell else {
            return cell
        }
        
        guard let currentUserInfo = SubminderDataModel.shared.currentUserInfo else { return cell }
        
        switch indexPath.row {
            
        case 0:
            
            cell.titleLbl.text = profileSettingTitles[indexPath.row]
            
            cell.nameTextField.text = currentUserInfo.name
            
            newUserName = cell.nameTextField.text ?? ""
            
            cell.nameTextField.addTarget(self, action: #selector(onUserNameChanged), for: .editingDidEnd)
            
            return cell
            
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSettingCell", for: indexPath)
            guard let cell = cell as? ProfileSettingCell else {
                return cell
            }
            
            let title = profileSettingTitles[indexPath.row]
            
            cell.setupCell(title: title, id: currentUserInfo.id)
            
            cell.idLbl.isUserInteractionEnabled = true
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapIDLbl))
            
            cell.idLbl.addGestureRecognizer(gesture)
            
            cell.copyImg.isUserInteractionEnabled = true
            
            let copy = UITapGestureRecognizer(target: self, action: #selector(didTapIDLbl))
            
            cell.copyImg.addGestureRecognizer(copy)
            
            return cell
            
        default:
            
            return cell
        }
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
        
        let viewController = UIImagePickerController()
        
        viewController.sourceType = .camera
        
        viewController.delegate = self
        
        viewController.allowsEditing = true
        
        present(viewController, animated: true)
    }
    
    func presentPhotoPicker() {
        
        let viewController = UIImagePickerController()
        
        viewController.sourceType = .photoLibrary
        
        viewController.delegate = self
        
        viewController.allowsEditing = true
        
        present(viewController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.isProfilePicUpdated = true
        self.profileImg.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - API Methods

extension PersonalSettingViewController {
    
    func fetchUserDataAndSetupProfilePic() {
        
        guard let userUID = KeyChainManager.shared.userUID else { return }
        
        SVProgressHUD.show()
        
        UserManager.shared.searchUser(uid: userUID) { [weak self] result in
            
            switch result {
                
            case .success(let users):
                
                print("fetchUserData success")
                
                for user in users {
                    self?.usersInfo.append(user)
                    
                    SubminderDataModel.shared.currentUserInfo = user
                    
                    guard let imageUrl = SubminderDataModel.shared.currentUserInfo?.image else { return }

                    if !(self?.isProfilePicUpdated ?? false) {
                        if let url = URL(string: imageUrl),
                           let data = try? Data(contentsOf: url) {
                            
                            self?.profileImg.image = UIImage(data: data)
                        }
                    }
                    
                    SVProgressHUD.dismiss()
                }
                
            case .failure(let error):
                
                print("fetchUserData.failure: \(error)")
            }
        }
    }
}
