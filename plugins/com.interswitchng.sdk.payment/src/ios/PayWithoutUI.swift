//
//  Created by Efe Ariaroo on 10/05/2016.
//  Copyright © 2016 Interswitch Limited. All rights reserved.

import UIKit
import PaymentSDK
import SwiftyJSON


open class PayWithoutUI {
    
    class func makePayment(_ cdvPlugin: PaymentPlugin, command: CDVInvokedUrlCommand, thePan: String,
                           theAmount:String, theCvv: String, thePin: String, theExpiryDate: String,
                           theCustomerId: String, theCurrency: String) {
        let purchaseSdk : PaymentSDK = PaymentSDK(clientId: cdvPlugin.clientId, clientSecret: cdvPlugin.clientSecret)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let request = PurchaseRequest(customerId: theCustomerId, amount: theAmount, pan: thePan,
                                      pin: thePin, expiryDate: theExpiryDate, cvv2: theCvv, transactionRef: Payment.randomStringWithLength(12),
                                      currency: theCurrency, requestorId: "")
        
        purchaseSdk.purchase(request, completionHandler:{(purchaseResponse: PurchaseResponse?, error: Error?) in
            guard error == nil else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let errMsg = (error?.localizedDescription)!
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: errMsg)
                return
            }
            
            guard let response = purchaseResponse else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let failureMsg = (error?.localizedDescription)!
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: failureMsg)
                return
            }
            //Success or OTP
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            Utils.sendSuccessBackToJavascript(cdvPlugin, cdvCommand: command, successMsg: Utils.getJsonOfPurchaseResponse(response))
        })
    }
    
    class func loadWallet(_ cdvPlugin: PaymentPlugin, command: CDVInvokedUrlCommand) {
        let walletSdk : WalletSDK = WalletSDK(clientId: cdvPlugin.clientId, clientSecret: cdvPlugin.clientSecret)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        walletSdk.getPaymentMethods({ (response: WalletResponse?, error: Error?) -> Void in
            guard error == nil else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let errMsg = (error?.localizedDescription)!
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: errMsg)
                return
            }
            
            guard let walletResponse = response else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let failureMsg = (error?.localizedDescription)!
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: failureMsg)
                return
            }
            
            //Handling success
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            let paymentMethodsJson = Utils.getJsonOfPaymentMethods(walletResponse.paymentMethods)
            Utils.sendSuccessBackToJavascript(cdvPlugin, cdvCommand: command, successMsg: paymentMethodsJson)
        })
    }
    
    
    class func payWithWallet(_ cdvPlugin: PaymentPlugin, command: CDVInvokedUrlCommand, theCustomerId: String,
                             theAmount:String, tokenOfUserSelectedPaymentMethod: String,
                             thePin: String, theCurrency: String, theRequestorId: String) {
        let walletSdk : WalletSDK = WalletSDK(clientId: cdvPlugin.clientId, clientSecret: cdvPlugin.clientSecret)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let request = PurchaseRequest(customerId: theCustomerId, amount: theAmount, pan: tokenOfUserSelectedPaymentMethod,
                                      pin: thePin, transactionRef: Payment.randomStringWithLength(12),
                                      currency: theCurrency, requestorId: theRequestorId)
        
        walletSdk.purchase(request, completionHandler:{(purchaseResponse: PurchaseResponse?, error: Error?) in
            guard error == nil else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let errMsg = (error?.localizedDescription)!
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: errMsg)
                return
            }
            
            guard let response = purchaseResponse else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let failureMsg = (error?.localizedDescription)!
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: failureMsg)
                return
            }
            //Success or OTP
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            Utils.sendSuccessBackToJavascript(cdvPlugin, cdvCommand: command, successMsg: Utils.getJsonOfPurchaseResponse(response))
        })
    }
    
    class func paymentStatus(_ cdvPlugin: PaymentPlugin, command: CDVInvokedUrlCommand,
                             theTransactionRef: String, theAmount:String) {
        let purchaseSdk = PaymentSDK(clientId: cdvPlugin.clientId, clientSecret: cdvPlugin.clientSecret)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        purchaseSdk.getPaymentStatus(theTransactionRef, amount: theAmount, completionHandler:{(paymentStatusResponse: PaymentStatusResponse?, error: Error?) in
            guard error == nil else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let errMsg = (error?.localizedDescription)!
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: errMsg)
                return
            }
            
            guard let response = paymentStatusResponse else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let failureMsg = (error?.localizedDescription)!
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: failureMsg)
                return
            }
            //Success
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            Utils.sendSuccessBackToJavascript(cdvPlugin, cdvCommand: command, successMsg: Utils.getJsonOfPaymentStatus(response))
        })
    }
    
    class func validateCard(_ cdvPlugin: PaymentPlugin, command: CDVInvokedUrlCommand,
                            thePan: String, theCvv:String, thePin: String, theExpiryDate: String, theCustomerId: String) {
        let purchaseSdk = PaymentSDK(clientId: cdvPlugin.clientId, clientSecret: cdvPlugin.clientSecret)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let validateCardRequest = ValidateCardRequest(customerId: theCustomerId, pan: thePan, pin: thePin, expiryDate: theExpiryDate,
                                                      cvv2: theCvv, transactionRef: Payment.randomStringWithLength(12), requestorId: "")
        
        purchaseSdk.validateCard(validateCardRequest, completionHandler:{(validateCardResponse: ValidateCardResponse?, error: Error?) in
            guard error == nil else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let errMsg = (error?.localizedDescription)!
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: errMsg)
                return
            }
            
            guard let response = validateCardResponse else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let failureMsg = (error?.localizedDescription)!
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: failureMsg)
                return
            }
            //Success
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            Utils.sendSuccessBackToJavascript(cdvPlugin, cdvCommand: command, successMsg: Utils.getJsonOfPurchaseResponse(response))
        })
    }
    
    class func authorizeOtp(_ cdvPlugin: PaymentPlugin, command: CDVInvokedUrlCommand, theOtp: String,
                            theOtpTransactionId:String, theOtpTransactionRef: String) {
        let otpRequest = AuthorizeOtpRequest(otpTransactionIdentifier: theOtpTransactionId,
                                             otp: theOtp, transactionRef: theOtpTransactionRef)
        
        let purchaseSdk = PaymentSDK(clientId: cdvPlugin.clientId, clientSecret: cdvPlugin.clientSecret)
        purchaseSdk.authorizeOtp(otpRequest, completionHandler: {(authorizeOtpResponse: AuthorizeOtpResponse?, error: Error?) in
            guard error == nil else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                let errMsg = (error?.localizedDescription)!
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: errMsg)
                return
            }
            
            guard authorizeOtpResponse != nil else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                Utils.sendErrorBackToJavascript(cdvPlugin, cdvCommand: command, errMsg: "Otp validation was NOT successful")
                return
            }
            //OTP successful
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            Utils.sendSuccessBackToJavascript(cdvPlugin, cdvCommand: command, successMsg: Utils.getJsonForAuthorizeOtpResponse(authorizeOtpResponse!))
        })
    }
}
