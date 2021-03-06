//
//  AuthViewController.swift
//  Subminder
//
//  Created by PoChieh Chuang on 2021/11/2.
//

import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import Lottie

class AuthViewController: SUBaseViewController {

    var user: User = User(
        uid: "",
        id: "",
        name: "",
        email: "",
        image: "",
        friendList: [],
        groupList: [],
        subList: [],
        payable: 0,
        receivable: 0,
        currency: ""
    )

    var checkUserResults: [User] = []

    @IBOutlet weak var signInBtnView: UIView!
    
    @IBOutlet weak var animationView: AnimationView!
    
    @IBOutlet weak var privacyPolicyTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animationView.contentMode = .scaleAspectFit

        animationView.loopMode = .loop

        animationView.animationSpeed = 0.5

        animationView.play()

        setupSignInButton()
        
        privacyPolicyTextField.addHyperLinksToText(originalText: "點擊登入代表您同意Subminder 隱私權政策 與 用戶許可協議",
                                                   hyperLinks: ["隱私權政策": "https://www.privacypolicies.com/live/8c0d2849-6b23-48fd-9aac-bb3c6fd92a3a",
                                                                "用戶許可協議": "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
                                                               ])
        
        privacyPolicyTextField.textColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    func setupSignInButton() {

        let button = ASAuthorizationAppleIDButton(type: .default, style: .white)

//        button.center = signInBtnView.center

        signInBtnView.addSubview(button)
        
        signInBtnView.layer.cornerRadius = 15
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: signInBtnView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: signInBtnView.centerYAnchor),
            button.widthAnchor.constraint(equalTo: signInBtnView.widthAnchor),
            button.heightAnchor.constraint(equalTo: signInBtnView.heightAnchor)
        ])

        button.addTarget(self, action: #selector(loginDidTap), for: .touchUpInside)
    }

    @objc func loginDidTap(_ sender: ASAuthorizationAppleIDButton) {

        performSignIn()

        // ...
        // after login is done, maybe put this in the login web service completion block
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let mainTabBarController = storyboard.instantiateViewController(identifier: "TabBar")
//
//        // This is to get the SceneDelegate object from your view controller
//        // then call the change root view controller function to change to main tab bar
//        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }

    func performSignIn() {

        let request = createAppleIDRequest()

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])

        // Present Apple authorization form
        authorizationController.delegate = self

        authorizationController.presentationContextProvider = self

        authorizationController.performRequests()
    }

    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {

        let appleIDProvider = ASAuthorizationAppleIDProvider()

        let request = appleIDProvider.createRequest()

        request.requestedScopes = [.fullName, .email]

        // Generate nonce for validation after authentication successful
        let nonce = randomNonceString()

        // Set the SHA256 hashed nonce to ASAuthorizationAppleIDRequest
        request.nonce = sha256(nonce)

        currentNonce = nonce

        return request
    }

    private func randomNonceString(length: Int = 32) -> String {

        precondition(length > 0)
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    // Unhashed nonce.
    fileprivate var currentNonce: String?

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

extension AuthViewController: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {

            // Save authorised user ID for future reference
            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleAuthorizedUserIdKey")

            // Retrieve the secure nonce generated during Apple sign in
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent")
            }

            // Retrieve Apple identity token
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }

            // Convert Apple identity token to string
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token strin from data: \(appleIDToken.debugDescription)")
                return
            }

            // Initialize a Firebase credential using secure nonce and Apple identity token
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)

            // Sign in with Firebase
            Auth.auth().signIn(with: credential) { (authDataResult, error) in

                if let user = authDataResult?.user {

                    print("Nice! You're now signed in as \(user.uid), email: \(user.email ?? "unknown")")

                    self.checkRegistrationStatus(userUID: user.uid) {
                    
                        if self.checkUserResults.count == 0 {
                            
                            self.user.uid = user.uid
                            self.user.email = user.email ?? ""
                            guard let firstName = appleIDCredential.fullName?.givenName else { return }
                            guard let lastName = appleIDCredential.fullName?.familyName else { return }
                            self.user.name = "\(firstName) \(lastName)"

                            self.addNewUser(with: &self.user)
                        }
                    }

//                    if self.checkUserResults.count == 0 {
//
//                        self.user.uid = user.uid
//                        self.user.email = user.email ?? ""
//
//                        self.addNewUser(with: &self.user)
//                    } else {
//
//                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//                        let mainTabBarController = storyboard.instantiateViewController(identifier: "TabBar")
//
//                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
//                    }
//                    self.performSegue(withIdentifier: "showTab", sender: nil)
                }

                if let error = error {
                    print(error.localizedDescription)

                    return
                }
                
//                 Make a request to set user's display name on Firebase
//                let changeRequest = authDataResult?.user.createProfileChangeRequest()
//                changeRequest?.displayName = appleIDCredential.fullName?.givenName
//                changeRequest?.commitChanges(completion: { (error) in
//
//                    if let error = error {
//                        print(error.localizedDescription)
//                    } else {
//                        self.user.name = Auth.auth().currentUser!.displayName ?? ""
//                        print("Updated display name: \(Auth.auth().currentUser!.displayName!)")
//                    }
//                })
            }
        }
    }

    func checkRegistrationStatus(userUID: String, completion: @escaping () -> Void) {

        UserManager.shared.checkUserRegistration(uid: userUID) { [weak self] result in

            switch result {

            case .success(let users):

                print("checkRegistrationStatus success")

                for user in users {

                    self?.checkUserResults.append(user)

                }

            case .failure(let error):

                print("checkRegistrationStatus.failure: \(error)")
            }
            completion()
        }
    }

    func addNewUser(with user: inout User) {

        UserManager.shared.addUser(user: &user) { result in

            switch result {

            case .success:

                print("Add New User, Success")

            case .failure(let error):

                print("Add New User, failuer: \(error)")
            }
        }
    }
}

extension AuthViewController: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return self.view.window!
    }
}

extension UITextView {

  func addHyperLinksToText(originalText: String, hyperLinks: [String: String]) {
    let style = NSMutableParagraphStyle()
    style.alignment = .left
    let attributedOriginalText = NSMutableAttributedString(string: originalText)
    for (hyperLink, urlString) in hyperLinks {
        let linkRange = attributedOriginalText.mutableString.range(of: hyperLink)
        let fullRange = NSRange(location: 0, length: attributedOriginalText.length)
        attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: urlString, range: linkRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: fullRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "PingFang TC Medium", size: 10), range: fullRange)
    }
    
    self.linkTextAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
    ]
    self.attributedText = attributedOriginalText
  }
}
