function init() {
  var userDetails = {
//    clientId: "IKIAF8F70479A6902D4BFF4E443EBF15D1D6CB19E232",
//    clientSecret: "ugsmiXPXOOvks9MR7+IFHSQSdk8ZzvwQMGvd0GJva30=",
    paymentApi: "https://qa.interswitchng.com",
    passportApi: "https://qa.interswitchng.com/passport"
  };
    
  var initial = PaymentPlugin.init(userDetails);
}

(function () {
  var App = angular.module('app', ['onsen'])
 
  App.controller('uiController', function($scope,$timeout){             
  
  });
 
  App.controller('Paycontroller', function ($scope, $timeout) {
    $scope.input = {
      transactionRef: null,
      amount: null,
      cardPan: null,
      cvv: null,
      pin: null,
      expiryDate: null,
      customerId: null,
      requestorId: null,
      currency: null
    };

    $scope.payCardOrWallet = function() {
      var payRequest = {
        amount: "10", // Amount in Naira
        customerId: "1234567890", // Optional email, mobile no, BVN etc to uniquely identify the customer.
        currency: "NGN", // ISO Currency code
        description: "Purchase Phone" // Description of product to purchase
      };
      var paySuccess = function(response) {
        var purchaseResponse = JSON.parse(response);
        
        alert(purchaseResponse.message);
      }
      var payFail = function(response) {
        alert(response);
      }
      PaymentPlugin.pay(payRequest, paySuccess, payFail);
    }

    $scope.payWithCard = function() {
      var payWithCardRequest = {
        amount: "200", // Amount in Naira
        customerId: "1234567890", // Optional email, mobile no, BVN etc to uniquely identify the customer.
        currency: "NGN", // ISO Currency code
        description: "Purchase Phone" // Description of product to purchase
      };
      var payWithCardSuccess = function(response) {
        var purchaseResponse = JSON.parse(response);
        
       alert(purchaseResponse.message);
      }
      var payWithCardFail = function(response) {
       alert(response);
      }
      PaymentPlugin.payWithCard(payWithCardRequest, payWithCardSuccess, payWithCardFail);
    }
                
    $scope.payWithWallet = function () {
      var payWithWalletRequest = {
        amount: "1000", // Amount in Naira
        customerId: "1234567890", // Optional email, mobile no, BVN etc to uniquely identify the customer.
        currency: "NGN", // ISO Currency code
        description: "Purchase Phone" // Description of product to purchase
      };
 
      var payWithWalletSuccess = function(response) {
        var purchaseResponse = JSON.parse(response);
        
        alert(purchaseResponse.message);
      }

      var payWithWalletFail = function(response) {
        alert(response);
      }

      PaymentPlugin.payWithWallet(payWithWalletRequest, payWithWalletSuccess, payWithWalletFail);
    }
    
    $scope.payWithToken = function(){
      var payWithTokenRequest = {
        pan : "5123459987670669364",      // Token
        amount : "100",                   // Amount in Naira
        currency : "NGN",                 // ISO Currency code
        cardtype : "Verve",               // Card Type
        expiryDate : "2004",              // Card or Token expiry date in YYMM format
        customerId : "1234567890",        // Optional email, mobile no, BVN etc to uniquely identify the customer.
        panLast4Digits : "7499",          // Last 4digit of the pan card
        description : "Pay for gown"
      };
      var payWithTokenSuccess = function(response) {
        var purchaseResponse = JSON.parse(response);
        
        alert("Payment success\n" + purchaseResponse.message);
      }

      var payWithTokenFail = function(response) {
        alert(response);
      }
      
      PaymentPlugin.payWithToken(payWithTokenRequest, payWithTokenSuccess, payWithTokenFail);
    }
    
    $scope.validatePaymentCard = function() {
      var validateCardRequest = {
        customerId: "1234567890"
      };

      var validatePaymentCardSuccess = function(response) {
        var validateCardResponse = JSON.parse(response);
        var token = validateCardResponse.token;
        var tokenExpiryDate = validateCardResponse.tokenExpiryDate;
        var balance = validateCardResponse.balance;
        var panLast4Digits = validateCardResponse.panLast4Digits;
        var cardType = validateCardResponse.cardType;
        
        alert("Validating your card was successful");
      }
    
      var validatePaymentCardFail = function(response) {
        alert(response);
      }
      PaymentPlugin.validatePaymentCard(validateCardRequest, validatePaymentCardSuccess, validatePaymentCardFail);
    }
                                    
    //Pay without SDK ui features

    $scope.list = {
      tokens : []
    };
    
    $scope.getPaymentMethods = function() {
		SpinnerDialog.show();      
        var loadWalletSuccess = function(response) {        
        //alert("Wallet loaded successfully");        
        var responseObject = JSON.parse(response);
        // The responseObject here contains cardProduct, panLast4Digits and token        
        $scope.$apply($scope.list.tokens = responseObject.paymentMethods);
		SpinnerDialog.hide();
      }
      var loadWalletFail = function(response) {
        SpinnerDialog.hide();
        alert(response);
      }
      
      PaymentPlugin.loadWallet(null, loadWalletSuccess, loadWalletFail);                
    }

    $scope.payWithWalletNoUI = function () {
      SpinnerDialog.show("", "Please wait ...", null);
      
      var walletRequest = {
        pan:$scope.tokens,  //Token from the wallet
        amount : $scope.input.amount, // Amount in Naira
        cvv : $scope.input.cvv, // Card CVV
        pin : $scope.input.pin, // Optional Card PIN for card payment
        currency : $scope.input.currency, // ISO Currency code
        expiryDate : $scope.input.expiryDate, // Card or Token expiry date in YYMM format
        requestorId : $scope.input.requestorId,
        customerId : $scope.input.customerId // Optional email, mobile no, BVN etc to uniquely identify the customer.
      };

      var payWithWalletSuccess = function(response) {
        SpinnerDialog.hide();
        var responseObject = JSON.parse(response);

        if(responseObject.otpTransactionIdentifier){
          ons.notification.prompt(responseObject.message).then(
            function(otp) {
              responseObject.otpValue = otp;
              
              authorizeOtp(responseObject);
            });
        } else {
          alert(responseObject.message);
        }
      }

      var payWithWalletFail = function(response) {
        SpinnerDialog.hide();
        alert(response);
      }
      
      PaymentPlugin.payWithWalletSDK(walletRequest, payWithWalletSuccess, payWithWalletFail);
    }

    $scope.makePayment = function(){
      if ($scope.input.cardPan === null || $scope.input.amount === null || $scope.input.pin === null 
          || $scope.input.cvv === null || $scope.input.expiryDate === null || $scope.input.customerId === null 
          || $scope.input.currency === null) {
        alert("Field(s) cannot be empty");
        return false;
      }
                
      var purchaseRequest = {
        pan: $scope.input.cardPan,
        amount : $scope.input.amount,
        cvv : $scope.input.cvv,
        pin : $scope.input.pin,
        currency : $scope.input.currency,
        expiryDate : $scope.input.expiryDate,
        customerId : $scope.input.customerId
      };
      SpinnerDialog.show("", "Please wait ...", null);
      
      var makePaymentSuccess = function(response) {
        SpinnerDialog.hide();
        var responseObject = JSON.parse(response);

        if(responseObject.otpTransactionIdentifier) {
          var transactionIdentifier = responseObject.transactionIdentifier;
          
          ons.notification.prompt(responseObject.message).then(
            function(otp) {
              responseObject.otpValue = otp;
              authorizeOtp(responseObject);
            }
          );
        } else {
          alert(responseObject.message);
        }
      }
      var makePaymentFail = function(response) {
        SpinnerDialog.hide();
       
        alert(response);
      }
        
      PaymentPlugin.makePayment(purchaseRequest, makePaymentSuccess, makePaymentFail);
    }
    
    $scope.paymentStatus = function(){
      if ($scope.input.transactionRef === null || $scope.input.amount === null 
          || $scope.input.transactionRef === undefined || $scope.input.amount === undefined) {
        alert("Fields(s) cannot be empty");
        return false;
      }
      SpinnerDialog.show("", "Payment status enquiry ...", null);

      var paymentStatusRequest = {
        transactionRef : $scope.input.transactionRef,
        amount : $scope.input.amount
      };
      
      var paymentStatusSuccess = function(response) {
        SpinnerDialog.hide();
        var responseObject = JSON.parse(response);
        
        alert(responseObject.message);
      }
      
      var paymentStatusFail = function(response) {
        SpinnerDialog.hide();
        
        alert(response);
      }
      
      PaymentPlugin.paymentStatus(paymentStatusRequest, paymentStatusSuccess, paymentStatusFail);
    }       
    
    $scope.validateCard = function () {
      SpinnerDialog.show("", "Validating Payment Card ... ");
      
      var validateCardRequest = {
        pan: $scope.input.cardPan,
        cvv : $scope.input.cvv,
        pin : $scope.input.pin,
        expiryDate : $scope.input.expiryDate,
        customerId : $scope.input.customerId
      };
        
      var validateCardSuccess = function(response) {
        SpinnerDialog.hide();
        var validateCardResponse = JSON.parse(response);

        var token = validateCardResponse.token;
        var tokenExpiryDate = validateCardResponse.tokenExpiryDate;
        var balance = validateCardResponse.balance;
        var panLast4Digits = validateCardResponse.panLast4Digits;
        var cardType = validateCardResponse.cardType;
        
        alert("Card Validation was successful");
      }
                 
      var validateCardFail = function(response) {
        SpinnerDialog.hide();
        alert(response);
      }

      PaymentPlugin.validateCard(validateCardRequest, validateCardSuccess, validateCardFail);
    }

    
    function authorizeOtp(results) {
      if(results !== null && results.otpValue && results.otpValue.length > 0){
        SpinnerDialog.show("", "Verifying One Time Password ...", null);
        
        var authorizeOtpRequest = {
          otp : results.otpValue,
          otpTransactionIdentifier: results.otpTransactionIdentifier,
          transactionRef: results.transactionRef
        }

        var authorizeOtpSuccess = function(response) {
          SpinnerDialog.hide();
          
          var responseObject = JSON.parse(response);
          var theTransactionRef = responseObject.transactionRef;
          
          alert("Success: Approved by Financial Institution");
        }

        var authorizeOtpFail = function(response) {
          SpinnerDialog.hide();          
          alert("Payment failed");
        }
        
        PaymentPlugin.authorizeOtp(authorizeOtpRequest, authorizeOtpSuccess, authorizeOtpFail);        
      } else {
        alert("Invalid OTP value!");
      }
    }
    
  });
})();
