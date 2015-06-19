//
//  LoginByMobileViewController.swift
//  Yep
//
//  Created by NIX on 15/3/17.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit

class LoginByMobileViewController: UIViewController {

    @IBOutlet weak var pickMobileNumberPromptLabel: UILabel!
    @IBOutlet weak var pickMobileNumberPromptLabelTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var areaCodeTextField: BorderTextField!
    @IBOutlet weak var areaCodeTextFieldWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var mobileNumberTextField: BorderTextField!
    @IBOutlet weak var mobileNumberTextFieldTopConstraint: NSLayoutConstraint!
    
    lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""), style: .Plain, target: self, action: "next:")
        return button
        }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = NavigationTitleLabel(title: NSLocalizedString("Login", comment: ""))
   
        navigationItem.rightBarButtonItem = nextButton

        pickMobileNumberPromptLabel.text = NSLocalizedString("What's your number?", comment: "")

        areaCodeTextField.text = NSLocale.areaCode
        
        areaCodeTextField.delegate = self
        areaCodeTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)

        mobileNumberTextField.delegate = self
        mobileNumberTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)

        pickMobileNumberPromptLabelTopConstraint.constant = UIDevice.matchFrom(30, 50, 60, 60)
        mobileNumberTextFieldTopConstraint.constant = UIDevice.matchFrom(30, 40, 50, 50)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        nextButton.enabled = false
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        mobileNumberTextField.becomeFirstResponder()
    }

    // MARK: Actions

    func textFieldDidChange(textField: UITextField) {

        nextButton.enabled = !areaCodeTextField.text.isEmpty && !mobileNumberTextField.text.isEmpty

        if textField == areaCodeTextField {
            let text = textField.text
            let size = text.sizeWithAttributes(textField.typingAttributes)

            let width = 32 + (size.width + 22) + 20

            if width > 100 {
                UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveLinear, animations: { _ in
                    self.areaCodeTextFieldWidthConstraint.constant = width
                    self.view.layoutIfNeeded()
                }, completion: { finished in
                })
            }
        }
    }

    func next(sender: UIBarButtonItem) {
        tryShowLoginVerifyMobile()
    }

    private func tryShowLoginVerifyMobile() {
        
        view.endEditing(true)

        let mobile = mobileNumberTextField.text
        let areaCode = areaCodeTextField.text

        YepHUD.showActivityIndicator()
        
        sendVerifyCodeOfMobile(mobile, withAreaCode: areaCode, useMethod: .SMS, failureHandler: { (reason, errorMessage) in
            defaultFailureHandler(reason, errorMessage)

            YepHUD.hideActivityIndicator()

            if let errorMessage = errorMessage {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    YepAlert.alertSorry(message: errorMessage, inViewController: self, withDismissAction: { () -> Void in
                        mobileNumberTextField.becomeFirstResponder()
                    })
                })
            }
            
        }, completion: { success in

            YepHUD.hideActivityIndicator()

            if success {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.showLoginVerifyMobile()
                })

            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    YepAlert.alertSorry(message: NSLocalizedString("Failed to send verification code", comment: ""), inViewController: self, withDismissAction: { () -> Void in
                        mobileNumberTextField.becomeFirstResponder()
                    })
                })
            }
        })
    }

    func showLoginVerifyMobile() {
        let mobile = mobileNumberTextField.text
        let areaCode = areaCodeTextField.text

        self.performSegueWithIdentifier("showLoginVerifyMobile", sender: ["mobile" : mobile, "areaCode": areaCode])
    }

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLoginVerifyMobile" {

            if let info = sender as? [String: String] {
                let vc = segue.destinationViewController as! LoginVerifyMobileViewController

                vc.mobile = info["mobile"]
                vc.areaCode = info["areaCode"]
            }
        }
    }

}

extension LoginByMobileViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if !textField.text.isEmpty {
            tryShowLoginVerifyMobile()
        }
        
        return true
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == areaCodeTextField {
            let text = textField.text
            let size = text.sizeWithAttributes(textField.defaultTextAttributes)

            let width = 32 + (size.width + 22) + 20
            
            UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveLinear, animations: { _ in
                self.areaCodeTextFieldWidthConstraint.constant = max(width, 100)
                self.view.layoutIfNeeded()
            }, completion: { finished in
            })
        }

        return true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if textField == areaCodeTextField {
            UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveLinear, animations: { _ in
                self.areaCodeTextFieldWidthConstraint.constant = 60
                self.view.layoutIfNeeded()
            }, completion: { finished in
            })
        }
    }
}
