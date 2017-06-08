import android.app.Activity;
import android.content.Context;
import android.widget.Button;

import com.interswitchng.sdk.auth.Passport;
import com.interswitchng.sdk.model.RequestOptions;
import com.interswitchng.sdk.model.User;
import com.interswitchng.sdk.model.UserInfoRequest;
import com.interswitchng.sdk.payment.IswCallback;
import com.interswitchng.sdk.payment.Payment;
import com.interswitchng.sdk.payment.android.PassportSDK;
import com.interswitchng.sdk.payment.android.inapp.LoginCredentials;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Bundle;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;

/**
 * @author Babajide.Apata
 * @description Expose the Payment to Cordova JavaScript Applications
 */

public class PaymentPlugin extends CordovaPlugin  {
    public PaymentPlugin() {
    }
    private String clientId;
    private String clientSecret;

    private Activity activity;
    private Context context;
    private Button payWithCard;
    private static RequestOptions options;
    private IswCallback<LoginCredentials> callback;


    //final RequestOptions options = RequestOptions.builder().setClientId(this.clientId).setClientSecret(this.clientSecret).build();

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        activity =  cordova.getActivity();
        try{
            ApplicationInfo applicationInfo = activity.getPackageManager().getApplicationInfo(activity.getPackageName(), PackageManager.GET_META_DATA);
            Bundle bundle = applicationInfo.metaData;
            clientId = bundle.getString("clientId");
            clientSecret = bundle.getString("clientSecret");
        }catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
    }
    public boolean execute(final String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        final PayWithOutUI payWithOutUI = new PayWithOutUI(activity,clientId,clientSecret);
        final PayWithUI payWithUI = new PayWithUI(activity,clientId,clientSecret);
        if (action.equals("Init")) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        init(args, callbackContext);
                    } catch (Exception ex) {
                        callbackContext.error(ex.toString());
                    }
                }
            });
            return true;
        }
        else if(action.equals("AuthorizePurchase")){
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        payWithOutUI.authorizePurchase(action, args, callbackContext); //asyncronous call
                    } catch (Exception error) {
                        callbackContext.error(error.toString());
                    }
                    // Call the success function of the .js file
                }
            });
            return true;
        }
        else if(action.equals("AuthorizeCard")){
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        payWithOutUI.authorizeCard(action, args, callbackContext); //asyncronous call
                    } catch (Exception error) {
                        callbackContext.error(error.toString());
                    }
                    // Call the success function of the .js file
                }
            });
            return true;
        }
        else if(action.equals("MakePayment")){
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        payWithOutUI.makePayment(action, args, callbackContext); //asyncronous call
                    } catch (Exception error) {
                        callbackContext.error(error.toString());
                    }
                    // Call the success function of the .js file
                }
            });
            return true;
        }

        else if(action.equals("LoadWallet")){
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        payWithOutUI.loadWallet(action, callbackContext); //asyncronous call
                    }
                    catch (Exception error){
                        callbackContext.error(error.toString());
                    }
                    // Call the success function of the .js file
                }
            });
            return true;
        }
        else if(action.equals("ValidatePaymentCard")){
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        payWithUI.validatePaymentCard(action, args, callbackContext); //asyncronous call
                    }
                    catch (Exception error){
                        callbackContext.error(error.toString());
                    }
                    // Call the success function of the .js file
                }
            });
            return true;
        }
        else if(action.equals("ValidateCard")){
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        payWithOutUI.validateCard(action, args, callbackContext); //asyncronous call
                    }
                    catch (Exception error){
                        callbackContext.error(error.toString());
                    }
                    // Call the success function of the .js file
                }
            });
            return true;
        }
        else if(action.equals("Pay")){
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        payWithUI.pay(action, args, callbackContext); //asyncronous call
                    }
                    catch (Exception error){
                        callbackContext.error(error.toString());
                    }
                    // Call the success function of the .js file
                }
            });
            return true;
        }
        else if(action.equals("PayWithToken")){
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        payWithUI.payWithToken(action, args, callbackContext); //asyncronous call
                    }
                    catch (Exception error){
                        callbackContext.error(error.toString());
                    }
                    // Call the success function of the .js file
                }
            });
            return true;
        }
        else if(action.equals("PayWithCard")){
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        payWithUI.payWithCard(action, args, callbackContext); //asyncronous call
                    }
                    catch (Exception error){
                        callbackContext.error(error.toString());
                    }
                    // Call the success function of the .js file
                }
            });
            return true;
        }
        else if(action.equals("PayWithWallet")){
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        payWithUI.payWithWallet(action, args, callbackContext); //asyncronous call
                    }
                    catch (Exception error){
                        callbackContext.error(error.toString());
                    }
                    // Call the success function of the .js file
                }
            });
            return true;
        }
        else if(action.equals("PayWithWalletSDK")){
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        payWithOutUI.payWithWalletSDK(action, args, callbackContext); //asyncronous call
                    }
                    catch (Exception error){
                        callbackContext.error(error.toString());
                    }
                    // Call the success function of the .js file
                }
            });
            return true;
        }
        else if(action.equals("PaymentStatus")){
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        payWithOutUI.paymentStatus(action, args, callbackContext); //asyncronous call
                    }
                    catch (Exception error){
                        callbackContext.error(error.toString());
                    }
                    // Call the success function of the .js file
                }
            });
            return true;
        }
        else if(action.equals("UserInformation")){
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        userInformation(action, args, callbackContext); //asyncronous call
                    }
                    catch (Exception error){
                        callbackContext.error(error.toString());
                    }
                    // Call the success function of the .js file
                }
            });
            return true;
        }
        return false;
    }
    public void userInformation(final String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException{
        activity = this.cordova.getActivity();
        activity.runOnUiThread(new Runnable() {
            public void run() {
                try {
                    options = RequestOptions.builder().setClientId(clientId).setClientSecret(clientSecret).build();
                    final LoginCredentials loginCredentials = new LoginCredentials();
                    JSONObject params = args.getJSONObject(0);
                    loginCredentials.setUsername(params.getString("username"));
                    loginCredentials.setPassword(params.getString("password"));
                    UserInfoRequest userInfoRequest = new UserInfoRequest();
                    userInfoRequest.setUsername(loginCredentials.getUsername());
                    new PassportSDK(activity, options).getUserInfo(userInfoRequest, new IswCallback<User>() {

                        @Override
                        public void onError(Exception error) {
                            callbackContext.error(error.getMessage());
                        }

                        @Override
                        public void onSuccess(final User response) {
                            if (response.getVerifiedMobileNo() == null) {
                                //Send OTP
                                new PassportSDK(activity, options).sendMobileOtp(response, new IswCallback<Object>() {
                                    @Override
                                    public void onError(Exception error) {
                                        callbackContext.error(error.getMessage());
                                    }

                                    @Override
                                    public void onSuccess(Object otpResponse) {
                                        PluginUtils.getPluginResult(callbackContext, otpResponse);
                                    }
                                });
                            } else {
                                PluginUtils.getPluginResult(callbackContext, response);
                            }
                        }
                    });
                } catch (Exception error) {
                    callbackContext.error(error.toString());
                }
            }
        });
    }
    private void init(JSONArray args, CallbackContext callbackContext) {
        try{
            if (args != null && args.length() > 0) {
                JSONObject params = args.getJSONObject(0);
                String paymentApi = params.getString("paymentApi");
                String passportApi = params.getString("passportApi");
                if( (paymentApi != null && paymentApi.length()>0) && (passportApi != null && passportApi.length()>0)){
                    Payment.overrideApiBase(params.getString("paymentApi")); // used to override the payment api base url.
                    Passport.overrideApiBase(params.getString("passportApi"));
                }
                if((clientId !=null && clientSecret != null) && (clientId !="" && clientSecret !="")){
                    options = RequestOptions.builder().setClientId(this.clientId).setClientSecret(this.clientSecret).build();
                    //callbackContext.success("Initialization was successfull");
                }
            }
        }
        catch (JSONException jsonException){
            callbackContext.error(jsonException.toString());
        }
    }

}