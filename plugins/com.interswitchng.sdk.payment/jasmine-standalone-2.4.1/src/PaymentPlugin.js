//var exec = require('cordova/exec');
function PaymentPlugin() {
 //console.log('Payment plugin working');
}
PaymentPlugin.prototype.makePayment = function(args){
   return execPromise("MakePayment",args);
}

function execPromise(action, args){
    if (!Array.isArray(args)) {
		args = [args];
	}
    var defer = new $.Deferred();
     exec(function success(successMessage){
              defer.resolve(successMessage);
    },
    function error(errorMessage){
        defer.reject(errorMessage);
    },
    "PaymentPlugin",
    action,
    args);
    return defer.promise();
}
PaymentPlugin.prototype.init = function(args){
      return execPromise("Init",args);
 }
 PaymentPlugin.prototype.authorizeOtp = function(args){
       return execPromise("AuthorizeOTP",args);
 }
PaymentPlugin.prototype.loadWallet  = function(){
    return execPromise("LoadWallet");
}

PaymentPlugin.prototype.payWithWallet  = function(args){
    return execPromise("PayWithWallet",args);
}
PaymentPlugin.prototype.payWithWalletSDK  = function(args){
    return execPromise("PayWithWalletSDK",args);
}

PaymentPlugin.prototype.paymentStatus  = function(args){
    return execPromise("PaymentStatus",args);
}

PaymentPlugin.prototype.payWithToken  = function(args){
    return execPromise("PayWithToken",args);
}

PaymentPlugin.prototype.validatePaymentCard  = function(args){
    return execPromise("ValidatePaymentCard",args);
}
PaymentPlugin.prototype.userInformation = function(args){
    return execPromise("UserInformation",args);
}

PaymentPlugin.prototype.validateCard  = function(args){
    return execPromise("ValidateCard",args);
}

PaymentPlugin.prototype.pay = function(args){
    return execPromise("Pay",args);
}

PaymentPlugin.prototype.payWithCard = function(args){
      return execPromise("PayWithCard",args);
 }
var paymentPlugin = new PaymentPlugin();
module.exports = new PaymentPlugin();