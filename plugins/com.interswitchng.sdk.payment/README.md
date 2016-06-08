# Table of Contents
1. [Cordova Payment Plugin](#CordovaPayment)

2. [First steps](#FirstSteps)

3. [Install instructions for Android](#InstallationInstructionsForAndroid)

4. [Install instructions for iOS](#InstallationInstructionsForIos)

5. [Using The Plugin in Sandbox Mode](#SandBoxMode) 

6. [Using the Plugin with UI (In PCI-DSS Scope: No )](#SDKWithUI)   
   * [Pay with Card/Wallet](#Pay)
   * [Pay with Card](#PayWithCard)
   * [Pay with Wallet](#PayWithWallet)
   * [Validate Card](#ValidateCard)
   * [Pay With Token](#PayWithToken)
   
7. [Using the Plugin without UI (In PCI-DSS Scope: Yes)](#SDKWithOutUI)
   * [Pay with Card/Token](#PayWithCardToken)
   * [Pay with Wallet](#PayWithWalletNoUI)
   * [Validate Card and Get Token](#ValidateCardNoUI)
   * [Authorize Transaction With OTP](#AuthorizeOTP)
   * [Checking Payment Status](#PaymentStatus)
  

## <a name='CordovaPayment'></a> Cordova Payment Plugin
Interswitch cordova payment plugin allows you to accept payments from customers within your cordova mobile application.

**Please Note: *The current supported currency is naira (NGN), support for other currencies would be added later***

The first step to ​using the plugin is to register as a merchant. This is described [here] (merchantxuat.interswitchng.com)

## <a name='FirstSteps'></a> First steps
* Create a new cordova project. To do so refer to the documentation [here](https://cordova.apache.org/docs/en/latest/guide/cli/index.html)

## <a name='InstallationInstructionsForAndroid'></a> Plugin installation instructions for Android
* **cd** to the directory of your cordova project. 

* Add the cordova-payment-plugin from CLI, using this command
```terminal
cordova plugin add https://github.com/techquest/cordova-payment-plugin.git
```
* Add ```android``` platform. Make sure to add the platform **after** adding the plugin.
```terminal
cordova platform add android
```
* **NOTE: *To use the inapp change your manifest theme to android:theme="@style/Theme.AppCompat.Light"***

**Please Note:** Ensure your cordova.js file is the first Javascript file to be included in your index.html


## <a name='InstallationInstructionsForIos'></a>Plugin installation instructions for iOS
* You'll need to have **Xcode 7.3** or later installed.

* **cd** to the directory of your cordova project. 

* Add cordova payment plugin
```
cordova plugin add https://github.com/techquest/cordova-payment-plugin.git
```
* Add ```ios``` platform. Make sure to add the platform **after** adding the plugin.
```terminal
cordova platform add ios
```

* In ```Finder```, go to the **YourCordovaApp/platforms/ios** directory. Open the .xcodeproj file in XCode. A dialog may appear asking: Convert to latest Swift Syntax? Click the **Cancel** button.

* In ```Finder```, go to the ```/platforms/ios/<NameOfApp>/Plugins/com.interswitchng.sdk.payment``` directory. You should see a **PaymentSDK.framework** file.

* Drag the ​ **PaymentSDK.framework** file from ```Finder``` to XCode's **Embedded Binaries** section for your app's **TARGETS** settings.

* In the dialog that appears, make sure ```Copy items if needed``` is unchecked.

* **Important**: With ```XCode``` still open, click the project to view its settings. Under the **info** tab find the **Configurations** section and change all the values for ```Debug``` and ```Release``` to **None**. You can change it back once our setups are done.

The **PaymentSDK.framework** needs some [Cocoapods](https://cocoapods.org/) dependencies so we'll need to install them.

* Close Xcode. **cd** into ```platforms/ios``` directory

* Run: 
```terminal
pod init
```

* Open the **Podfile** created and replace ```#``` commented parts with the following.
```terminal
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, "8.0"
use_frameworks!
```

* Add the following to the **Podfile**, inside the first ```target``` block.
```
pod 'CryptoSwift'
pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git'
pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
pod 'OpenSSL'
```

* Now run:
```terminal
pod install
```

* After the pods are installed successfully you can go to the directory ```platforms/ios``` and open the ```<NameOfApp>.xcworkspace``` file in XCode. 


### <a name='SandBoxMode'></a> Using The Plugin in Sandbox Mode

During development of your app, you should use the Plugin in sandbox mode to enable testing. Different Client Id and Client Secret are provided for Production and Sandbox mode. The procedure to use the Plugin on sandbox mode is just as easy:

* Use Sandbox Client Id and Client Secret got from the Sandbox Tab of the Developer Console after signup (usually you have to wait for 5 minutes after signup for you to see the Sandbox details) everywhere you are required to supply Client Id and Client Secret in the remainder of this documentation              
* In your code, override the api base as follows
```javascript
    function init(){
        var userDetails = {
            clientId: "IKIAF8F70479A6902D4BFF4E443EBF15D1D6CB19E232",
            clientSecret: "ugsmiXPXOOvks9MR7+IFHSQSdk8ZzvwQMGvd0GJva30=",
            paymentApi : "https://sandbox.interswitchng.com",
            passportApi : "https://sandbox.interswitchng.com/passport"
        };
        var initial = PaymentPlugin.init(userDetails);
    }
```

* Follow the remaining steps in the documentation.
* call the init function inside the onDeviceReady function of your cordova app
* NOTE: When going into Production mode, use the Client Id and the Client Secret got from the Production Tab of Developer Console instead.

## <a name='SDKWithUI'></a>Using the Plugin with UI (In PCI-DSS Scope: No )

### <a name='Pay'>Pay with Card/Wallet

* To allow for Payment with Card or Wallet
* Create a Pay button
* In the onclick event of the Pay button, use this code
1. Set up payment request like this: 
```javascript
    var payRequest = {			
        amount : 100, // Amount in Naira
        customerId : 1234567890, // Optional email, mobile no, BVN etc to uniquely identify the customer.
        currency : "NGN", // ISO Currency code
        description : "Purchase Phone" // Description of product to purchase
    }
```
2. Create a button to make payment and use this code in the onclick event of the button
```javascript
    var paySuccess = function(response) {
        var purchaseResponse = JSON.parse(response); // transaction success reponse
        alert(purchaseResponse.message); 
    }
    var payFail = function(response) {
        alert(response); // transaction failure reponse
    }
    PaymentPlugin.pay(payRequest, paySuccess, payFail);
```

### <a name='PayWithCard'>Pay with Card

* To allow for Payment with Card only
* Create a Pay button and set the payment request
*Set up payment request like this: 
```javascript
    var payWithCardRequest = {			
        amount : 100, // Amount in Naira
        customerId : 1234567890, // Optional email, mobile no, BVN etc to uniquely identify the customer.
        currency : "NGN", // ISO Currency code
        description : "Purchase Phone" // Description of product to purchase
    }
```
* In the onclick event of the Pay button, use this code.
```javascript
  var payWithCardSuccess = function(response) {
    var purchaseResponse = JSON.parse(response); // transaction success reponse
    alert(purchaseResponse.message);
  }
  var payWithCardFail = function(response) {
    alert(response); // transaction failure reponse
  }

  PaymentPlugin.payWithCard(payWithCardRequest, payWithCardSuccess, payWithCardFail);
```

### <a name='PayWithWallet'>Pay With Wallet

* To allow for Payment with Wallet only
* Create a Pay button and set the payment request
* Set up payment request like this: 
```javascript
    var payWithWalletRequest = {			
        amount : 100, // Amount in Naira
        customerId : 1234567890, // Optional email, mobile no, BVN etc to uniquely identify the customer.
        currency : "NGN", // ISO Currency code
        description : "Purchase Phone" // Description of product to purchase
    }
```
* In the onclick event of the Pay button, use this code.
```javascript
    var payWithWalletSuccess = function(response) {
        var purchaseResponse = JSON.parse(response); // transaction success reponse
        alert(purchaseResponse.message); 
    }
    var payWithWalletFail = function(response) {
        alert(response); // transaction failure reponse
    }

    PaymentPlugin.payWithWallet(payWithWalletRequest, payWithWalletSuccess, payWithWalletFail);
```

### <a name='ValidateCard'></a>Validate Card

* Validate card is used to check if a card is a valid card, it returns the card balance and token
* Set up payment request like this: 
```javascript
    var validateCardRequest = {
        customerId : 1234567890 // Optional email, mobile no, BVN etc to uniquely identify the customer
    }
```
* To call validate card, use this code.
```javascript
  var validatePaymentCardSuccess = function(response) {
    var validateCardResponse = JSON.parse(resposne);
    var token = validateCardResponse.token;
    var tokenExpiryDate = validateCardResponse.tokenExpiryDate;
    var balance = validateCardResponse.balance;
    var panLast4Digits = validateCardResponse.panLast4Digits;
    var cardType = validateCardResponse.cardType;
 
    alert("Validating your card was successful");
  }

  var validatePaymentCardFail = function(response) {
    alert(response); // transaction failure reponse
  }
  PaymentPlugin.validatePaymentCard(validateCardRequest, validatePaymentCardSuccess, validatePaymentCardFail);
```

### <a name='PayWithToken'></a> Pay with Token

* To allow for Payment with Token only
* Create a Pay button
* Set up payment request like this: 
```javascript
    var payWithTokenRequest = {
        pan : 5123459987670669364, //Token
        amount : 100, // Amount in Naira
        currency : "NGN", // ISO Currency code		
        cardtype : "Verve", // Card Type	
        expiryDate : 2004, // Card or Token expiry date in YYMM format
        customerId : 1234567890,	// Optional email, mobile no, BVN etc to uniquely identify the customer.	
        panLast4Digits : 7499,		//Last 4digit of the pan card
        description : "Pay for gown"
    }
```
* In the onclick event of the Pay button, use this code.
```javascript
  var payWithTokenSuccess = function(response) {
    var purchaseResponse = JSON.parse(response); // transaction success reponse
    alert(purchaseResponse.message);
  }
  var payWithTokenFail = function(response) {
    alert(response); // transaction failure reponse
  }

  PaymentPlugin.payWithToken(payWithTokenRequest, payWithTokenSuccess, payWithTokenFail);    
```

## <a name='SDKWithOutUI'></a>Using the Plugin without UI (In PCI-DSS Scope: Yes)

### <a name='PayWithCardToken'></a>Pay with Card/Token

* To allow for Payment with Card or Token
* Create a UI to collect amount and card details
* Create a Pay button
* Set up payment request like this:

```javascript
    var purchaseRequest = {
        pan:5060990580000217499,  //Card No or Token
        amount : 100, // Amount in Naira
        cvv : 111, // Card CVV
        pin : 1111, // Optional Card PIN for card payment
        currency : "NGN", // ISO Currency code
        expiryDate : 2004, // Card or Token expiry date in YYMM format
        customerId : 1234567890 // Optional email, mobile no, BVN etc to uniquely identify the customer.
    }
```


```javascript
    var makePaymentSuccess = function(response) {
        var responseObject = JSON.parse(response);
        //the response object here contains amount, message, transactionIdentifier and transactionRef       
        alert(responseObject.message);
    }
    var makePaymentFail = function(response) {
        alert(response);
    }    
    PaymentPlugin.makePayment(purchaseRequest, makePaymentSuccess, makePaymentFail);
```

### <a name='PayWithWalletNoUI'></a>Pay with Wallet
* To allow for Payment with Wallet only
* Create a UI to collect amount, CVV, expiry date and PIN and to display user's Payment Method(s). Use the code below to load the Payment Method(s)
```javascript
    var loadWalletSuccess = function(response) {
        alert("Wallet loaded successfully");

        var responseObject = JSON.parse(response);
        // The responseObject here contains cardProduct, panLast4Digits and token, the token is used for making payment
        // Load the cardProduct on a dropdown list and use the token in making payment with wallet 

        for(var i = 0; i < response.length; i++){
            console.log(responseObject.paymentMethods[i].token);
            console.log(responseObject.paymentMethods[i].panLast4Digits);
            console.log(responseObject.paymentMethods[i].cardProduct);
        }
    }
    var loadWalletFail = function(response) {
        alert(response);
    }
    PaymentPlugin.loadWallet(null, loadWalletSuccess, loadWalletFail);  
```

* Create a Pay button
* Set up payment request like this:

```javascript
    var walletRequest = {
        pan:ADA4C1FFE6DE40C584ABD3CBAFDA0D08,  //Token from the wallet
        amount : 100, // Amount in Naira
        cvv : 111, // Card CVV
        pin : 1111, // Optional Card PIN for card payment
        currency : "NGN", // ISO Currency code
        expiryDate : 2004, // Card or Token expiry date in YYMM format
        requestorId : 1234567890,
        customerId : 1234567890 // Optional email, mobile no, BVN etc to uniquely identify the customer.
    }
```
* In the onclick event of the Pay button, use this code.
```javascript
    var payWithWalletSuccess = function(response) {
        var responseObject = JSON.parse(response);

        if(responseObject.otpTransactionIdentifier){
          // handle OTP
        } else {
          alert("Payment success\n" + responseObject.message);
        }
    }
    var payWithWalletFail = function(response) {
        alert(response);
    }
    PaymentPlugin.payWithWalletSDK(walletRequest, payWithWalletSuccess, payWithWalletFail);    
```


### <a name='ValidateCardNoUI'></a> Validate Card and Get Token
* To check if a card is valid and get a token
* Create a UI to collect card details
* Create a Validate/Add Card button
* Set up validate card request using this code

```javascript
    var validateCardRequest = {
        pan : 5060990580000217499,  //Token from the wallet				
        cvv : 111, // Card CVV
        pin : 1111, // Optional Card PIN for card payment
        expiryDate : 2004, // Card or Token expiry date in YYMM format
        customerId : 1234567890 // Optional email, mobile no, BVN etc to uniquely identify the customer.
    }
```

* In the onclick event of the Validate/Add Card button, use this code.

```javascript
    var validateCardSuccess = function(response) {
        var validateCardResponse = JSON.parse(response);  // transaction success reponse
        // The response object contains fields transactionIdentifier, transactionRef,
        // message, balance, token, tokenExpiryDate, panLast4Digits and cardType. 

        var token = validateCardResponse.token;
        var tokenExpiryDate = validateCardResponse.tokenExpiryDate;
        var balance = validateCardResponse.balance;
        var panLast4Digits = validateCardResponse.panLast4Digits;
        var cardType = validateCardResponse.cardType;

        // Save the token, tokenExpiryDate, cardType and panLast4Digits 
        // in order to pay with the token in the future.

        alert("Card Validation was successful");
    }
         
    var validateCardFail = function(response) {
        alert(response);// transaction failure reponse
    }

    PaymentPlugin.validateCard(validateCardRequest, validateCardSuccess, validateCardFail);
```

## <a name='AuthorizeOTP'></a>Authorize Transaction With OTP

* To authorize transaction with OTP
* Create a UI to collect OTP
* Create authorize otp button
* Set up otp request using this code
```javascript
    var authorizeOtpRequest = {		
        otp : 123456, // Accept OTP from user
        otpTransactionIdentifier: "2121324", // Set the OTP identifier for the request
        transactionRef: "13324444"	// Set the unique transaction reference.	
    }
```

* In the onclick event of the authorize otp button, use this code.

```javascript
    var authorizeOtpSuccess = function(response) {      
      var responseObject = JSON.parse(response);              // transaction success reponse
      var theTransactionRef = responseObject.transactionRef;
      
      alert("Success: Approved by Financial Institution");
    }

    var authorizeOtpFail = function(response) {      
      alert("Payment failed");                                // transaction failure reponse
    }

    PaymentPlugin.authorizeOtp(authorizeOtpRequest, authorizeOtpSuccess, authorizeOtpFail);  
```

### <a name='PaymentStatus'></a>Checking Payment Status
* To check payment status
* Create a UI to collect transaction identifier
* Create payment status button
* Set up payment status request using this code

```javascript
    var paymentStatusRequest = {
        transactionRef : 117499114589, // The transaction unique reference.
        amount : 100                   // The transaction amount
    }
```

* To check the status of a payment made, use the code below
```javascript
    var paymentStatusSuccess = function(response) {
        var responseObject = JSON.parse(response);
        alert(responseObject.message);
    }

    var paymentStatusFail = function(response) {
        alert(response);
    }

    PaymentPlugin.paymentStatus(paymentStatusRequest, paymentStatusSuccess, paymentStatusFail);
```