//
//  PersonalSettingViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/14.
//

import UIKit

class PersonalSettingViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchUserData()
        
        setupImg()
        
        setupPictureTitleLbl()
        
        registerCell()
        
        setupBarItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        fetchUserData()
    }

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
        
        guard let user = usersInfo.first else { return }
        
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
    }
    
    func setupPictureTitleLbl() {
        
        pictureTitleLbl.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        
        pictureTitleLbl.addGestureRecognizer(gesture)
    }
    
    @objc func didTapImage() {
        
        presentPhotoActionSheet()
    }
}

extension PersonalSettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        profileSettingTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddSubTextCell", for: indexPath)
        guard let cell = cell as? AddSubTextCell else {
            return cell
        }
        
        let user = usersInfo.first
        
        switch indexPath.row {
            
        case 0:
            
            cell.titleLbl.text = profileSettingTitles[indexPath.row]
            
            cell.nameTextField.text = user?.name
            
            newUserName = cell.nameTextField.text ?? ""
            
            cell.nameTextField.addTarget(self, action: #selector(onUserNameChanged), for: .editingDidEnd)
            
            return cell
            
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSettingCell", for: indexPath)
            guard let cell = cell as? ProfileSettingCell else {
                return cell
            }
            
            let title = profileSettingTitles[indexPath.row]
            
            cell.setupCell(title: title, id: user?.id ?? "")
            
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
        
//        return UITableViewCell()
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        guard let user = usersInfo.first else { return }
//
//        UIPasteboard.generalPasteboard().string = user.id
//    }
    
    @objc func onUserNameChanged(_ sender: UITextField) {
        
        newUserName = sender.text ?? ""
    }
    
    @objc func didTapIDLbl() {
        
        guard let user = usersInfo.first else { return }
        
        UIPasteboard.general.string = "\(user.id)"
        
        showAlert(title: "系統提示", message: "ID已經複製到剪貼簿囉")
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
                    
                    self?.imageUrl = self?.usersInfo.first?.image ?? ""
                    
                    if let url = URL(string: self?.imageUrl ?? ""),
                       let data = try? Data(contentsOf: url) {
                        
                        self?.profileImg.image = UIImage(data: data)
                    }
                }
                
            case .failure(let error):
                
                print("fetchUserData.failure: \(error)")
            }
        }
    }
}

extension  PersonalSettingViewController {
    
    func registerCell() {
        
        let nib = UINib(nibName: "AddSubTextCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AddSubTextCell")
        
        let idNib = UINib(nibName: "ProfileSettingCell", bundle: nil)
        tableView.register(idNib, forCellReuseIdentifier: "ProfileSettingCell")
    }
    
    func showAlert(title: String, message: String) {
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "好", style: .default, handler: nil)
        
        controller.addAction(okAction)
        
        present(controller, animated: true, completion: nil)
    }
}
