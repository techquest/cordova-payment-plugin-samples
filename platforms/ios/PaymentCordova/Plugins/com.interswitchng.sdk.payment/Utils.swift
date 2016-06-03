//
//  Created by Efe Ariaroo on 10/05/2016.
//  Copyright © 2016 Interswitch Limited. All rights reserved.

import UIKit
import PaymentSDK


public class Utils {
    
    static var dateFormatter = NSDateFormatter()
    
    class func getStringFromDict (theDict: [String : AnyObject], theKey: String) -> String {
        var result : String? = ""
        
        if let theValue = theDict[theKey] as? Int {
            result = String(theValue)
        } else if let theValue = theDict[theKey] as? String {
            result = theValue
        }
        return result!
    }
    
    class func sendErrorBackToJavascript(cdvPlugin: PaymentPlugin, cdvCommand: CDVInvokedUrlCommand, errMsg: String) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAsString: errMsg)
        cdvPlugin.commandDelegate!.sendPluginResult(pluginResult, callbackId: cdvCommand.callbackId)
    }
    
    class func sendSuccessBackToJavascript(cdvPlugin: PaymentPlugin, cdvCommand: CDVInvokedUrlCommand, successMsg: String) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: successMsg)
        cdvPlugin.commandDelegate!.sendPluginResult(pluginResult, callbackId: cdvCommand.callbackId)
    }
    
    class public func getJsonOfPurchaseResponse(purchaseResObj : PurchaseResponse) -> String {
        var purchaseResponseAsDict = [String:AnyObject]()
        
        purchaseResponseAsDict["transactionIdentifier"] = purchaseResObj.transactionIdentifier
        purchaseResponseAsDict["transactionRef"] = purchaseResObj.transactionRef
        purchaseResponseAsDict["message"] = purchaseResObj.message
        
        if let theToken = purchaseResObj.token {
            if theToken.characters.count > 0 {
                purchaseResponseAsDict["token"] = theToken
            }
        }
        if let theTokenExpiry = purchaseResObj.tokenExpiryDate {
            if theTokenExpiry.characters.count > 0 {
                purchaseResponseAsDict["tokenExpiryDate"] = theTokenExpiry
            }
        }
        if let thePanLast4 = purchaseResObj.panLast4Digits {
            if thePanLast4.characters.count > 0 {
                purchaseResponseAsDict["panLast4Digits"] = thePanLast4
            }
        }
        if let theCardType = purchaseResObj.cardType {
            if theCardType.characters.count > 0 {
                purchaseResponseAsDict["cardType"] = theCardType
            }
        }
        if let theBalance = purchaseResObj.balance {
            if theBalance.characters.count > 0 {
                purchaseResponseAsDict["balance"] = theBalance
            }
        }
        if let otpTransactionIdentifier = purchaseResObj.otpTransactionIdentifier {
            if otpTransactionIdentifier.characters.count > 0 {
                purchaseResponseAsDict["otpTransactionIdentifier"] = otpTransactionIdentifier
            }
        }
        
        do {
            let jsonNSData = try NSJSONSerialization.dataWithJSONObject(purchaseResponseAsDict, options: NSJSONWritingOptions(rawValue: 0))
            return String(data: jsonNSData, encoding: NSUTF8StringEncoding)!
        } catch _ {
        }
        return ""
    }
    
    class func getJsonOfPaymentMethods(thePaymentMethods: [PaymentMethod]) -> String {
        var result : String = ""
        do {
            let listOfDicts : [Dictionary] = thePaymentMethods.map { return getDictOfPayment($0) }
            let jsonNSData = try NSJSONSerialization.dataWithJSONObject(listOfDicts, options: NSJSONWritingOptions(rawValue: 0))
            result = String(data: jsonNSData, encoding: NSUTF8StringEncoding)!
            
            result = "{\"paymentMethods\": \(result)}"
        } catch _ {
        }
        return result
    }
    
    class func getJsonOfPaymentStatus(thePaymentStatus: PaymentStatusResponse) -> String {
        var paymentStatusAsDict = [String:AnyObject]()
        
        paymentStatusAsDict["message"] = thePaymentStatus.message
        paymentStatusAsDict["transactionRef"] = thePaymentStatus.transactionRef
        paymentStatusAsDict["amount"] = thePaymentStatus.amount
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let transactionDateAsString = dateFormatter.stringFromDate(thePaymentStatus.transactionDate)
        
        paymentStatusAsDict["transactionDate"] = transactionDateAsString
        paymentStatusAsDict["panLast4Digits"] = thePaymentStatus.panLast4Digits
        
        do {
            let jsonNSData = try NSJSONSerialization.dataWithJSONObject(paymentStatusAsDict, options: NSJSONWritingOptions(rawValue: 0))
            return String(data: jsonNSData, encoding: NSUTF8StringEncoding)!
        } catch _ {
        }
        return ""
    }
    
    class func getJsonForAuthorizeOtpResponse(theOtpAuthorizeResponse: AuthorizeOtpResponse) -> String {
        return "{\"transactionRef\": \"\(theOtpAuthorizeResponse.transactionRef)\"}"
    }
    
    class private func getDictOfPayment(thePaymentMethod: PaymentMethod) -> Dictionary<String, AnyObject> {
        var paymentMethodAsDict = [String:AnyObject]()
        
        paymentMethodAsDict["cardProduct"] = thePaymentMethod.cardProduct
        paymentMethodAsDict["panLast4Digits"] = thePaymentMethod.panLast4Digits
        paymentMethodAsDict["token"] = thePaymentMethod.token
        
        return paymentMethodAsDict
    }

    class func showError(cdvPlugin: PaymentPlugin, message: String) {
        let alertVc = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertVc.addAction(action)
        
        cdvPlugin.viewController?.presentViewController(alertVc, animated: true, completion: nil)
    }
}
