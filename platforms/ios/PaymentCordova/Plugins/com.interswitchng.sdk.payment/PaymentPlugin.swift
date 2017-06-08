//
//  Created by Efe Ariaroo on 10/05/2016.
//  Copyright © 2016 Interswitch Limited. All rights reserved.

import UIKit
import PaymentSDK
import SwiftyJSON


@objc(PaymentPlugin) class PaymentPlugin : CDVPlugin {
    internal var clientId : String = ""
    internal var clientSecret : String = ""
    
    
    func Init (_ command: CDVInvokedUrlCommand) {
        let firstArg = command.arguments[0] as? [String:AnyObject]
        
        let theClientId = Utils.getStringFromDict(firstArg!, theKey: "clientId")
        let theClientSecret = Utils.getStringFromDict(firstArg!, theKey: "clientSecret")
        let paymentApi = Utils.getStringFromDict(firstArg!, theKey: "paymentApi")
        let passportApi = Utils.getStringFromDict(firstArg!, theKey: "passportApi")
        
        if paymentApi.length > 0 && passportApi.length > 0 {
            Payment.overrideApiBase(paymentApi)
            Passport.overrideApiBase(passportApi)
        }
        if theClientId.length > 0 && theClientSecret.length > 0 {
            self.clientId = theClientId
            self.clientSecret = theClientSecret
        }
    }
    
    
    //---------- With SDK UI
    
    func Pay(_ cdvCommand: CDVInvokedUrlCommand) {
        let firstArg = cdvCommand.arguments[0] as? [String:AnyObject]
        
        let customerIdAsString = Utils.getStringFromDict(firstArg!, theKey: "customerId")
        let amountAsString = Utils.getStringFromDict(firstArg!, theKey: "amount")
        //--
        let theCurrency = firstArg?["currency"] as? String
        let theDescription = firstArg?["description"] as? String
        
        PayWithUI.payWithCardOrWallet(self, command: cdvCommand, theCustomerId: customerIdAsString, theCurrency: theCurrency!,
                                      theDescription: theDescription!, theAmount: amountAsString)
    }
    
    func PayWithCard(_ cdvCommand: CDVInvokedUrlCommand) {
        let firstArg = cdvCommand.arguments[0] as? [String:AnyObject]
        
        let customerIdAsString = Utils.getStringFromDict(firstArg!, theKey: "customerId")
        let amountAsString = Utils.getStringFromDict(firstArg!, theKey: "amount")
        //--
        let theCurrency = firstArg?["currency"] as? String
        let theDescription = firstArg?["description"] as? String
        
        PayWithUI.payWithCard(self, command: cdvCommand, theCustomerId: customerIdAsString, theCurrency: theCurrency!,
                              theDescription: theDescription!, theAmount: amountAsString)
    }
    
    func PayWithWallet(_ cdvCommand: CDVInvokedUrlCommand) {
        let firstArg = cdvCommand.arguments[0] as? [String:AnyObject]
        
        let customerIdAsString = Utils.getStringFromDict(firstArg!, theKey: "customerId")
        let amountAsString = Utils.getStringFromDict(firstArg!, theKey: "amount")
        //--
        let theCurrency = firstArg?["currency"] as? String
        let theDescription = firstArg?["description"] as? String
        
        PayWithUI.payWithWallet(self, command: cdvCommand, theCustomerId: customerIdAsString, theCurrency: theCurrency!,
                                theDescription: theDescription!, theAmount: amountAsString)
    }
    
    func PayWithToken(_ cdvCommand: CDVInvokedUrlCommand) {
        let firstArg = cdvCommand.arguments[0] as? [String:AnyObject]
        
        let customerIdAsString = Utils.getStringFromDict(firstArg!, theKey: "customerId")
        let amountAsString = Utils.getStringFromDict(firstArg!, theKey: "amount")
        let tokenAsString = Utils.getStringFromDict(firstArg!, theKey: "pan")
        let panLast4DigitsAsString = Utils.getStringFromDict(firstArg!, theKey: "panLast4Digits")
        let expiryDateAsString = Utils.getStringFromDict(firstArg!, theKey: "expiryDate")
        //--
        let theCurrency = firstArg?["currency"] as? String
        let theDescription = firstArg?["description"] as? String
        let theCardType = firstArg?["cardtype"] as? String
        
        PayWithUI.payWithToken(self, command: cdvCommand, theCustomerId: customerIdAsString, paymentDescription: theDescription!,
                               theToken: tokenAsString, theAmount: amountAsString, theCurrency:theCurrency!,
                               theExpiryDate: expiryDateAsString, theCardType: theCardType!, thePanLast4Digits: panLast4DigitsAsString)
    }
    
    func ValidatePaymentCard(_ cdvCommand: CDVInvokedUrlCommand) {
        let firstArg = cdvCommand.arguments[0] as? [String:AnyObject]
        
        let customerIdAsString = Utils.getStringFromDict(firstArg!, theKey: "customerId")
        
        PayWithUI.validatePaymentCard(self, command: cdvCommand, theCustomerId: customerIdAsString)
    }
    
    
    //---------- Without SDK UI
    
    
    func MakePayment(_ cdvCommand: CDVInvokedUrlCommand) {
        let firstArg = cdvCommand.arguments[0] as? [String:AnyObject]
        
        let customerId = Utils.getStringFromDict(firstArg!, theKey: "customerId")
        let pan = Utils.getStringFromDict(firstArg!, theKey: "pan")
        let amount = Utils.getStringFromDict(firstArg!, theKey: "amount")
        let cvv = Utils.getStringFromDict(firstArg!, theKey: "cvv")
        let pin = Utils.getStringFromDict(firstArg!, theKey: "pin")
        let expiryDate = Utils.getStringFromDict(firstArg!, theKey: "expiryDate")
        //--
        let currency = firstArg?["currency"] as? String
        
        PayWithoutUI.makePayment(self, command: cdvCommand, thePan: pan, theAmount: amount, theCvv: cvv,
                                 thePin: pin, theExpiryDate: expiryDate, theCustomerId: customerId, theCurrency: currency!)
    }
    
    func LoadWallet(_ cdvCommand: CDVInvokedUrlCommand) {
        PayWithoutUI.loadWallet(self, command: cdvCommand)
    }
    
    func PayWithWalletSDK(_ cdvCommand: CDVInvokedUrlCommand) {
        let firstArg = cdvCommand.arguments[0] as? [String:AnyObject]
        
        let customerId = Utils.getStringFromDict(firstArg!, theKey: "customerId")
        let theTokenOfPaymentMethod = Utils.getStringFromDict(firstArg!, theKey: "pan")
        let amount = Utils.getStringFromDict(firstArg!, theKey: "amount")
        let requestorId = Utils.getStringFromDict(firstArg!, theKey: "requestorId")
        let pin = Utils.getStringFromDict(firstArg!, theKey: "pin")
        let currency = Utils.getStringFromDict(firstArg!, theKey: "currency")
        
        PayWithoutUI.payWithWallet(self, command: cdvCommand, theCustomerId: customerId, theAmount: amount,
                                   tokenOfUserSelectedPaymentMethod: theTokenOfPaymentMethod, thePin: pin,
                                   theCurrency: currency, theRequestorId: requestorId)
    }
    
    func PaymentStatus(_ cdvCommand: CDVInvokedUrlCommand) {
        let firstArg = cdvCommand.arguments[0] as? [String:AnyObject]
        
        let transactionRef = Utils.getStringFromDict(firstArg!, theKey: "transactionRef")
        let amount = Utils.getStringFromDict(firstArg!, theKey: "amount")
        
        PayWithoutUI.paymentStatus(self, command: cdvCommand, theTransactionRef: transactionRef, theAmount: amount)
    }
    
    func ValidateCard(_ cdvCommand: CDVInvokedUrlCommand) {
        let firstArg = cdvCommand.arguments[0] as? [String:AnyObject]
        
        let customerId = Utils.getStringFromDict(firstArg!, theKey: "customerId")
        let pan = Utils.getStringFromDict(firstArg!, theKey: "pan")
        let cvv = Utils.getStringFromDict(firstArg!, theKey: "cvv")
        let pin = Utils.getStringFromDict(firstArg!, theKey: "pin")
        let expiryDate = Utils.getStringFromDict(firstArg!, theKey: "expiryDate")
        
        PayWithoutUI.validateCard(self, command: cdvCommand, thePan: pan, theCvv: cvv,
                                  thePin: pin, theExpiryDate: expiryDate, theCustomerId: customerId)
    }
    
    func AuthorizeOTP(_ cdvCommand: CDVInvokedUrlCommand) {
        let firstArg = cdvCommand.arguments[0] as? [String:AnyObject]
        
        let otp = Utils.getStringFromDict(firstArg!, theKey: "otp")
        let otpTransId = Utils.getStringFromDict(firstArg!, theKey: "otpTransactionIdentifier")
        let otpTransRef = Utils.getStringFromDict(firstArg!, theKey: "transactionRef")
        
        PayWithoutUI.authorizeOtp(self, command: cdvCommand, theOtp: otp, theOtpTransactionId: otpTransId,
                                  theOtpTransactionRef: otpTransRef)
    }
}

extension String {
    var length: Int {
        return (self as NSString).length
    }
}
