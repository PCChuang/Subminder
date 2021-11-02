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

class AuthViewController: SUBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSignInButton()
    }

    func setupSignInButton() {

        let button = ASAuthorizationAppleIDButton()

        button.center = view.center

        view.addSubview(button)

        button.addTarget(self, action: #selector(loginDidTap), for: .touchUpInside)
    }

    @objc func loginDidTap(_ sender: ASAuthorizationAppleIDButton) {

        performSignIn()
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

                    self.performSegue(withIdentifier: "showTab", sender: nil)
                }

                if let error = error {
                    print(error.localizedDescription)

                    return
                }
                
                // Mak a request to set user's display name on Firebase
//                let changeRequest = authDataResult?.user.createProfileChangeRequest()
//                changeRequest?.displayName = appleIDCredential.fullName?.givenName
//                changeRequest?.commitChanges(completion: { (error) in
//
//                    if let error = error {
//                        print(error.localizedDescription)
//                    } else {
//                        print("Updated display name: \(Auth.auth().currentUser!.displayName!)")
//                    }
//                })
            }
        }
    }
}

extension AuthViewController: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return self.view.window!
    }
}
