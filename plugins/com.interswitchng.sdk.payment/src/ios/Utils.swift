//
//  Created by Efe Ariaroo on 10/05/2016.
//  Copyright © 2016 Interswitch Limited. All rights reserved.

import UIKit
import PaymentSDK


open class Utils {
    
    static var dateFormatter = DateFormatter()
    
    class func getStringFromDict (_ theDict: [String : AnyObject], theKey: String) -> String {
        var result : String? = ""
        
        if let theValue = theDict[theKey] as? Int {
            result = String(theValue)
        } else if let theValue = theDict[theKey] as? String {
            result = theValue
        }
        return result!
    }
    
    class func sendErrorBackToJavascript(_ cdvPlugin: PaymentPlugin, cdvCommand: CDVInvokedUrlCommand, errMsg: String) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: errMsg)
        cdvPlugin.commandDelegate!.send(pluginResult, callbackId: cdvCommand.callbackId)
    }
    
    class func sendSuccessBackToJavascript(_ cdvPlugin: PaymentPlugin, cdvCommand: CDVInvokedUrlCommand, successMsg: String) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: successMsg)
        cdvPlugin.commandDelegate!.send(pluginResult, callbackId: cdvCommand.callbackId)
    }
    
    class open func getJsonOfPurchaseResponse(_ purchaseResObj : PurchaseResponse) -> String {
        var purchaseResponseAsDict = [String:AnyObject]()
        
        purchaseResponseAsDict["transactionIdentifier"] = purchaseResObj.transactionIdentifier as AnyObject
        purchaseResponseAsDict["transactionRef"] = purchaseResObj.transactionRef as AnyObject
        purchaseResponseAsDict["message"] = purchaseResObj.message as AnyObject
        
        if let theToken = purchaseResObj.token {
            if theToken.characters.count > 0 {
                purchaseResponseAsDict["token"] = theToken as AnyObject
            }
        }
        if let theTokenExpiry = purchaseResObj.tokenExpiryDate {
            if theTokenExpiry.characters.count > 0 {
                purchaseResponseAsDict["tokenExpiryDate"] = theTokenExpiry as AnyObject
            }
        }
        if let thePanLast4 = purchaseResObj.panLast4Digits {
            if thePanLast4.characters.count > 0 {
                purchaseResponseAsDict["panLast4Digits"] = thePanLast4 as AnyObject
            }
        }
        if let theCardType = purchaseResObj.cardType {
            if theCardType.characters.count > 0 {
                purchaseResponseAsDict["cardType"] = theCardType as AnyObject
            }
        }
        if let otpTransactionIdentifier = purchaseResObj.otpTransactionIdentifier {
            if otpTransactionIdentifier.characters.count > 0 {
                purchaseResponseAsDict["otpTransactionIdentifier"] = otpTransactionIdentifier as AnyObject
            }
        }
        
        do {
            let jsonNSData = try JSONSerialization.data(withJSONObject: purchaseResponseAsDict, options: JSONSerialization.WritingOptions(rawValue: 0))
            return String(data: jsonNSData, encoding: String.Encoding.utf8)!
        } catch _ {
        }
        return ""
    }
    
    class func getJsonOfPaymentMethods(_ thePaymentMethods: [PaymentMethod]) -> String {
        var result : String = ""
        do {
            let listOfDicts : [Dictionary] = thePaymentMethods.map { return getDictOfPayment($0) }
            let jsonNSData = try JSONSerialization.data(withJSONObject: listOfDicts, options: JSONSerialization.WritingOptions(rawValue: 0))
            result = String(data: jsonNSData, encoding: String.Encoding.utf8)!
            
            result = "{\"paymentMethods\": \(result)}"
        } catch _ {
        }
        return result
    }
    
    class func getJsonOfPaymentStatus(_ thePaymentStatus: PaymentStatusResponse) -> String {
        var paymentStatusAsDict = [String:AnyObject]()
        
        paymentStatusAsDict["message"] = thePaymentStatus.message as AnyObject
        paymentStatusAsDict["transactionRef"] = thePaymentStatus.transactionRef as AnyObject
        paymentStatusAsDict["amount"] = thePaymentStatus.amount as AnyObject
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let transactionDateAsString = dateFormatter.string(from: thePaymentStatus.transactionDate)
        
        paymentStatusAsDict["transactionDate"] = transactionDateAsString as AnyObject
        paymentStatusAsDict["panLast4Digits"] = thePaymentStatus.panLast4Digits as AnyObject
        
        do {
            let jsonNSData = try JSONSerialization.data(withJSONObject: paymentStatusAsDict, options: JSONSerialization.WritingOptions(rawValue: 0))
            return String(data: jsonNSData, encoding: String.Encoding.utf8)!
        } catch _ {
        }
        return ""
    }
    
    class func getJsonForAuthorizeOtpResponse(_ theOtpAuthorizeResponse: AuthorizeOtpResponse) -> String {
        return "{\"transactionRef\": \"\(theOtpAuthorizeResponse.transactionRef)\"}"
    }
    
    class fileprivate func getDictOfPayment(_ thePaymentMethod: PaymentMethod) -> Dictionary<String, AnyObject> {
        var paymentMethodAsDict = [String:AnyObject]()
        
        paymentMethodAsDict["cardProduct"] = thePaymentMethod.cardProduct as AnyObject
        paymentMethodAsDict["panLast4Digits"] = thePaymentMethod.panLast4Digits as AnyObject
        paymentMethodAsDict["token"] = thePaymentMethod.token as AnyObject
        
        return paymentMethodAsDict
    }
    
    class func showError(_ cdvPlugin: PaymentPlugin, message: String) {
        let alertVc = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertVc.addAction(action)
        
        cdvPlugin.viewController?.present(alertVc, animated: true, completion: nil)
    }
}
