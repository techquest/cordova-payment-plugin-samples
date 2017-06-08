//
//  Created by Efe Ariaroo on 10/05/2016.
//  Copyright © 2016 Interswitch Limited. All rights reserved.

import UIKit
import PaymentSDK


open class PayWithUI {
    fileprivate static var cdvPlugin : PaymentPlugin?
    fileprivate static var currentVc : UIViewController?
    fileprivate static var isSdkVcShownUsingWindow  = false
    fileprivate static var window : UIWindow?
    
    
    class func payWithCardOrWallet(_ cdvPlugin: PaymentPlugin, command: CDVInvokedUrlCommand,
                                   theCustomerId: String, theCurrency:String, theDescription:String, theAmount:String) {
        PayWithUI.cdvPlugin = cdvPlugin
        
        let payWithCardOrWallet = Pay(clientId: cdvPlugin.clientId, clientSecret: cdvPlugin.clientSecret,
                                      customerId: theCustomerId, description: theDescription, amount:theAmount, currency:theCurrency)
        
        let vc = payWithCardOrWallet.start({(purchaseResponse: PurchaseResponse?, error: Error?) in
            guard error == nil else {
                let errMsg = (error?.localizedDescription)!
                
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: errMsg)
                window?.rootViewController = cdvPlugin.viewController!
                window?.makeKeyAndVisible()
                return
            }
            guard let response = purchaseResponse else {
                let failureMsg = (error?.localizedDescription)!
                
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: failureMsg)
                window?.rootViewController = cdvPlugin.viewController!
                window?.makeKeyAndVisible()
                return
            }
            
            //Handling success
            Utils.sendSuccessBackToJavascript(cdvPlugin, cdvCommand: command, successMsg: Utils.getJsonOfPurchaseResponse(response))
            window?.rootViewController = cdvPlugin.viewController!
            window?.makeKeyAndVisible()
        })
        
        let navController = UINavigationController(rootViewController: vc)
        //addBackNavigationMenuItem(vc)
        
        if(window == nil) {
            if let app = UIApplication.shared.delegate as? CDVAppDelegate, let keyWindow = app.window {
                window = keyWindow
            }
        }
        window!.rootViewController = navController
        window!.makeKeyAndVisible()
        currentVc = navController
        isSdkVcShownUsingWindow = true
    }
    
    class func payWithCard(_ cdvPlugin: PaymentPlugin, command: CDVInvokedUrlCommand,
                           theCustomerId: String, theCurrency:String, theDescription:String, theAmount:String) {
        PayWithUI.cdvPlugin = cdvPlugin
        
        let payWithCard = PayWithCard(clientId: cdvPlugin.clientId, clientSecret: cdvPlugin.clientSecret,
                                      customerId: theCustomerId, description: theDescription,
                                      amount:theAmount, currency:theCurrency)
        
        let vc = payWithCard.start({(purchaseResponse: PurchaseResponse?, error: Error?) in
            guard error == nil else {
                let errMsg = (error?.localizedDescription)!
                
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: errMsg)
                cdvPlugin.viewController?.dismiss(animated: true, completion: nil)
                return
            }
            guard let response = purchaseResponse else {
                let failureMsg = (error?.localizedDescription)!
                
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: failureMsg)
                cdvPlugin.viewController?.dismiss(animated: true, completion: nil)
                return
            }
            
            //Handling success
            Utils.sendSuccessBackToJavascript(cdvPlugin, cdvCommand: command, successMsg: Utils.getJsonOfPurchaseResponse(response))
            cdvPlugin.viewController?.dismiss(animated: true, completion: nil)
        })
        
        let screenTap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        vc.view.addGestureRecognizer(screenTap)
        
        let navController = UINavigationController(rootViewController: vc)
        //addBackNavigationMenuItem(vc)
        
        cdvPlugin.viewController?.present(navController, animated: true, completion: nil)
        currentVc = navController
        isSdkVcShownUsingWindow = false
    }
    
    class func payWithWallet(_ cdvPlugin: PaymentPlugin, command: CDVInvokedUrlCommand,
                             theCustomerId: String, theCurrency:String, theDescription:String, theAmount:String) {
        PayWithUI.cdvPlugin = cdvPlugin
        
        let payWithWallet = PayWithWallet(clientId: cdvPlugin.clientId, clientSecret: cdvPlugin.clientSecret,
                                          customerId: theCustomerId, description: theDescription,
                                          amount: theAmount, currency: theCurrency)
        let vc = payWithWallet.start({(purchaseResponse: PurchaseResponse?, error: Error?) in
            guard error == nil else {
                let errMsg = (error?.localizedDescription)!
                
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: errMsg)
                window?.rootViewController = cdvPlugin.viewController!
                window?.makeKeyAndVisible()
                return
            }
            
            guard let response = purchaseResponse else {
                let failureMsg = (error?.localizedDescription)!
                
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: failureMsg)
                window?.rootViewController = cdvPlugin.viewController!
                window?.makeKeyAndVisible()
                return
            }
            //Handling success
            Utils.sendSuccessBackToJavascript(cdvPlugin, cdvCommand: command, successMsg: Utils.getJsonOfPurchaseResponse(response))
            window?.rootViewController = cdvPlugin.viewController!
            window?.makeKeyAndVisible()
        })
        
        let screenTap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        vc.view.addGestureRecognizer(screenTap)
        
        let navController = UINavigationController(rootViewController: vc)
        //addBackNavigationMenuItem(vc)
        
        if(window == nil) {
            if let app = UIApplication.shared.delegate as? CDVAppDelegate, let keyWindow = app.window {
                window = keyWindow
            }
        }
        window!.rootViewController = navController
        window!.makeKeyAndVisible()
        
        currentVc = navController
        isSdkVcShownUsingWindow = true
    }
    
    class func payWithToken(_ cdvPlugin: PaymentPlugin, command: CDVInvokedUrlCommand, theCustomerId: String, paymentDescription:String,
                            theToken:String, theAmount:String, theCurrency:String, theExpiryDate:String, theCardType:String, thePanLast4Digits:String){
        PayWithUI.cdvPlugin = cdvPlugin
        
        let payWithToken = PayWithToken(clientId: cdvPlugin.clientId, clientSecret: cdvPlugin.clientSecret,
                                        customerId: theCustomerId, description: paymentDescription,
                                        amount:theAmount, token: theToken, currency:theCurrency,
                                        expiryDate: theExpiryDate, cardType: theCardType, last4Digits: thePanLast4Digits)
        
        let vc = payWithToken.start({(purchaseResponse: PurchaseResponse?, error: Error?) in
            guard error == nil else {
                let errMsg = (error?.localizedDescription)!
                
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: errMsg)
                cdvPlugin.viewController?.dismiss(animated: true, completion: nil)
                return
            }
            guard let response = purchaseResponse else {
                let failureMsg = (error?.localizedDescription)!
                
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: failureMsg)
                cdvPlugin.viewController?.dismiss(animated: true, completion: nil)
                return
            }
            
            //Handling success
            Utils.sendSuccessBackToJavascript(cdvPlugin, cdvCommand: command, successMsg: Utils.getJsonOfPurchaseResponse(response))
            cdvPlugin.viewController?.dismiss(animated: true, completion: nil)
        })
        
        let screenTap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        vc.view.addGestureRecognizer(screenTap)
        
        let navController = UINavigationController(rootViewController: vc)
        //addBackNavigationMenuItem(vc)
        
        cdvPlugin.viewController?.present(navController, animated: true, completion: nil)
        currentVc = navController
        isSdkVcShownUsingWindow = false
    }
    
    class func validatePaymentCard(_ cdvPlugin: PaymentPlugin, command: CDVInvokedUrlCommand, theCustomerId: String) {
        PayWithUI.cdvPlugin = cdvPlugin
        
        let validateCard = ValidateCard(clientId: cdvPlugin.clientId, clientSecret: cdvPlugin.clientSecret, customerId: theCustomerId)
        
        let vc = validateCard.start({(validateCardResponse: ValidateCardResponse?, error: Error?) in
            guard error == nil else {
                let errMsg = (error?.localizedDescription)!
                
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: errMsg)
                cdvPlugin.viewController?.dismiss(animated: true, completion: nil)
                return
            }
            
            guard let response = validateCardResponse else {
                let failureMsg = (error?.localizedDescription)!
                
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: failureMsg)
                cdvPlugin.viewController?.dismiss(animated: true, completion: nil)
                return
            }
            //Handling success
            Utils.sendSuccessBackToJavascript(cdvPlugin, cdvCommand: command, successMsg: Utils.getJsonOfPurchaseResponse(response))
            cdvPlugin.viewController?.dismiss(animated: true, completion: nil)
        })
        
        let screenTap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        vc.view.addGestureRecognizer(screenTap)
        
        let navController = UINavigationController(rootViewController: vc)
        //addBackNavigationMenuItem(vc)
        
        cdvPlugin.viewController?.present(navController, animated: true, completion: nil)
        currentVc = navController
        isSdkVcShownUsingWindow = false
    }
    
    
    @objc class func dismissKeyboard() {
        currentVc!.view.endEditing(true)
    }
    
    class func addBackNavigationMenuItem(_ currentlyDisplayedVc: UIViewController) {
        let leftButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PayWithUI.backAction))
        
        //currentlyDisplayedVc.navigationItem.title = "Pay"
        currentlyDisplayedVc.navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc class func backAction() {
        if(isSdkVcShownUsingWindow) {
            window?.rootViewController = cdvPlugin?.viewController!
            window?.makeKeyAndVisible()
        } else {
            currentVc?.dismiss(animated: true, completion: nil)
        }
    }
}
