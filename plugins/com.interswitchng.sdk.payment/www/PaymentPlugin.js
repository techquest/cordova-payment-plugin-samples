var exec = require('cordova/exec');
  
function paymentAction (action) {
  return function (arg, successCallback, failCallback) {
    var argsArray =  (Array.isArray(arg)) ? arg : [arg];
    
    if(successCallback) {
      exec(successCallback, failCallback, "PaymentPlugin", action, argsArray);
    } else {
      exec(function(response) {}, failCallback, "PaymentPlugin", action, argsArray);
    }
  }
}

var PaymentPlugin = {};
PaymentPlugin.SAFE_TOKEN_RESPONSE_CODE = "T0";
PaymentPlugin.CARDINAL_RESPONSE_CODE = "S0";
PaymentPlugin.init = paymentAction("Init");

// Using Payment SDK UI
PaymentPlugin.pay = paymentAction("Pay");
PaymentPlugin.payWithCard = paymentAction("PayWithCard");
PaymentPlugin.payWithWallet = paymentAction("PayWithWallet");
PaymentPlugin.payWithToken = paymentAction("PayWithToken");
PaymentPlugin.validatePaymentCard = paymentAction("ValidatePaymentCard");

// Without using Payment SDK UI
PaymentPlugin.makePayment = paymentAction("MakePayment");
PaymentPlugin.loadWallet = paymentAction("LoadWallet");
PaymentPlugin.payWithWalletSDK = paymentAction("PayWithWalletSDK");
PaymentPlugin.validateCard = paymentAction("ValidateCard");
PaymentPlugin.authorizePurchase = paymentAction("AuthorizePurchase");
PaymentPlugin.authorizeCard = paymentAction("AuthorizeCard");
PaymentPlugin.paymentStatus = paymentAction("PaymentStatus");

module.exports = PaymentPlugin;
