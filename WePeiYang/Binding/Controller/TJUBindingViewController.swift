//
//  TJUBindingViewController.swift
//  WePeiYang
//
//  Created by Tigris on 23/11/2017.
//  Copyright © 2017 twtstudio. All rights reserved.
//

import UIKit

class TJUBindingViewController: UIViewController {

    var usernameTextField: UITextField!
    var passwordTextField: UITextField!
    var bindButton: UIButton!
    var logoutButton: UIButton!
    var dismissButton: UIButton!
    var logoImage: UIImage!
    var logoImageView: UIImageView!
    var warningText: UITextView!
    var completion: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.

        self.navigationController?.navigationBar.barStyle = .black

        self.title = "办公网绑定"

        logoImage = UIImage(named: "TJUAccoundBinding")
        let imageRatio: CGFloat = logoImage.size.width / logoImage.size.height
        let imageViewWidth: CGFloat = UIScreen.main.bounds.width * 0.5
        logoImageView = UIImageView.init(image: logoImage)
        logoImageView.frame = CGRect(center: CGPoint(x: self.view.center.x, y: self.view.frame.size.height*1.0/5.0), size: CGSize(width: imageViewWidth, height: imageViewWidth / imageRatio))
        self.view.addSubview(logoImageView)

        let textFieldWidth: CGFloat = 250
        usernameTextField = UITextField()
        usernameTextField.text = TWTKeychain.username(for: .tju)
        usernameTextField.frame = CGRect(center: CGPoint(x: self.view.center.x, y: self.view.frame.size.height*2.0/5.0), size: CGSize(width: textFieldWidth, height: 40))
        usernameTextField.placeholder = "请输入账号"
        usernameTextField.keyboardType = .numberPad
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.clearButtonMode = .always
        usernameTextField.autocapitalizationType = .none
        passwordTextField = UITextField()
        passwordTextField.text = TWTKeychain.password(for: .tju)
        passwordTextField.frame = CGRect(center: CGPoint(x: self.view.center.x, y: usernameTextField.frame.origin.y + usernameTextField.frame.size.height + 30), size: CGSize(width: textFieldWidth, height: 40))
        passwordTextField.placeholder = "请输入密码"
        passwordTextField.keyboardType = .default
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.clearButtonMode = .always
        self.view.addSubview(usernameTextField)
        self.view.addSubview(passwordTextField)

        bindButton = UIButton()
        bindButton.frame = CGRect(x: (self.view.frame.size.width-textFieldWidth)/2, y: passwordTextField.frame.origin.y + passwordTextField.frame.size.height + 20, width: textFieldWidth, height: 38)
        bindButton.setTitle("绑 定", for: .normal)
        bindButton.setTitleColor(.white, for: .normal)
        bindButton.isUserInteractionEnabled = true
        bindButton.backgroundColor = UIColor(hex6: 0x00a1e9)
        // to make button rounded rect
        bindButton.layer.borderColor = UIColor(hex6: 0x00a1e9).cgColor
        bindButton.layer.borderWidth = 2
        bindButton.layer.cornerRadius = 5
        bindButton.addTarget(self, action: #selector(bind), for: .touchUpInside)
        self.view.addSubview(bindButton)

        dismissButton = UIButton(frame: CGRect(x: self.view.frame.width, y: bindButton.y + bindButton.height + 20, width: 30, height: 20))
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        dismissButton.setTitleColor(UIColor.gray, for: .normal)
        dismissButton.setTitle("暂不绑定", for: .normal)
        dismissButton.sizeToFit()
        dismissButton.center = CGPoint(x: self.view.center.x, y: bindButton.y + bindButton.height + 20)
        dismissButton.addTarget(self, action: #selector(dismissBinding), for: .touchUpInside)
        self.view.addSubview(dismissButton)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func bind() {
        guard let username = usernameTextField.text,
            let password = passwordTextField.text else {
                SwiftMessages.showWarningMessage(body: "请填写账号或密码")
                return
        }

        TWTKeychain.set(username: username, password: password, of: .tju)

        SolaSessionManager.solaSession(type: .get, url: "/auth/bind/tju", parameters: ["tjuuname": username, "tjupasswd": password], success: { dictionary in
            guard let errorCode: Int = dictionary["error_code"] as? Int,
                let errMsg = dictionary["message"] as? String else {
                    SwiftMessages.showErrorMessage(body: "绑定错误")
                    return
            }

            if errorCode == -1 {
                TwTUser.shared.tjuBindingState = true
                TwTUser.shared.save()
                NotificationCenter.default.post(name: NotificationName.NotificationBindingStatusDidChange.name, object: ("tju", true))
                SwiftMessages.showSuccessMessage(body: "绑定成功！")
                self.dismiss(animated: true, completion: {
                    self.completion?(true)
                })
            } else {
                TWTKeychain.erase(.tju)
                SwiftMessages.showErrorMessage(body: errMsg)
            }
        }, failure: { error in
            if error.localizedDescription == "您已绑定" {
                TwTUser.shared.tjuBindingState = true
                TwTUser.shared.save()
                self.dismiss(animated: true, completion: {
                    self.completion?(true)
                })
            }
            SwiftMessages.showErrorMessage(body: error.localizedDescription)
        })
    }

    func cancelLogin() {

        // unbind tju account
        var loginInfo: [String: String] = [String: String]()
        loginInfo["tjuuname"] = usernameTextField.text
        loginInfo["tjupasswd"] = passwordTextField.text

        SolaSessionManager.solaSession(type: .get, url: "/auth/unbind/tju", token: TwTUser.shared.token, parameters: loginInfo, success: { dictionary in

            guard let errorCode: Int = dictionary["error_code"] as? Int else {
                SwiftMessages.showErrorMessage(body: "解绑错误")
                return
            }

            if errorCode == -1 {
                TwTUser.shared.tjuBindingState = false
                TwTUser.shared.save()
                self.dismiss(animated: true, completion: {
                    self.completion?(true)
                })
            } else {
                let message = dictionary["message"] as? String
                SwiftMessages.showErrorMessage(body: message ?? "解析错误")
            }
        }, failure: { error in
            SwiftMessages.showErrorMessage(body: error.localizedDescription)
            self.dismiss(animated: true, completion: {
                self.completion?(false)
            })

        })
    }

    @objc func dismissBinding() {
        self.dismiss(animated: true, completion: {
            self.completion?(false)
        })
    }

    @objc func keyboardWillShow(notification: Notification) {
        self.view.frame.origin.y = -40
    }

    @objc func keyboardWillHide(notification: Notification) {
        self.view.frame.origin.y = 0
    }
}
