import android.app.Activity;
import android.content.Context;

import com.interswitchng.sdk.model.RequestOptions;
import com.interswitchng.sdk.payment.IswCallback;
import com.interswitchng.sdk.payment.android.PaymentSDK;
import com.interswitchng.sdk.payment.android.WalletSDK;
import com.interswitchng.sdk.payment.android.util.Util;
import com.interswitchng.sdk.payment.model.AuthorizeOtpRequest;
import com.interswitchng.sdk.payment.model.AuthorizeOtpResponse;
import com.interswitchng.sdk.payment.model.Card;
import com.interswitchng.sdk.payment.model.PaymentStatusRequest;
import com.interswitchng.sdk.payment.model.PaymentStatusResponse;
import com.interswitchng.sdk.payment.model.PurchaseRequest;
import com.interswitchng.sdk.payment.model.PurchaseResponse;
import com.interswitchng.sdk.payment.model.ValidateCardRequest;
import com.interswitchng.sdk.payment.model.ValidateCardResponse;
import com.interswitchng.sdk.payment.model.WalletRequest;
import com.interswitchng.sdk.payment.model.WalletResponse;
import com.interswitchng.sdk.util.RandomString;
import com.interswitchng.sdk.util.StringUtils;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class PayWithOutUI extends CordovaPlugin{
    private String clientId;
    private String clientSecret;
    private WalletSDK sdk;
    private Activity activity;
    private Context context;

    private static RequestOptions options;
    public PayWithOutUI(Activity activity, String clientId, String clientSecret ){
        this.activity = activity;
        this.clientId = clientId;
        this.clientSecret = clientSecret;
    }
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        activity =  cordova.getActivity();
    }
    public  void makePayment(final String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException{
        context = activity.getApplicationContext();
        activity.runOnUiThread(new Runnable() {
            public void run() {
                try {
                    options = RequestOptions.builder().setClientId(clientId).setClientSecret(clientSecret).build();
                    JSONObject params = args.getJSONObject(0);
                    PurchaseRequest request = new PurchaseRequest(); // Setup request parameters
                    request.setPan(params.getString("pan")); //Card No or Token
                    request.setAmount(params.getString("amount")); // Amount in Naira
                    request.setCvv2(params.getString("cvv"));
                    request.setPinData(params.getString("pin")); // Optional Card PIN for card payment
                    request.setTransactionRef(RandomString.numeric(12));
                    request.setExpiryDate(params.getString("expiryDate"));
                    request.setCustomerId(params.getString("customerId"));
                    request.setCurrency(params.getString("currency"));
                    final Card card = new Card(request.getPan(), null, null, null);
                    final String type = card.getType();
                    new PaymentSDK(context, options).purchase(request, new IswCallback<PurchaseResponse>() {
                        @Override
                        public void onError(Exception error) {
                            callbackContext.error(error.getMessage());
                        }

                        @Override
                        public void onSuccess(PurchaseResponse response) {

                            response.setCardType(type);
                            if (StringUtils.hasText(response.getOtpTransactionIdentifier())) {

                                PluginUtils.getPluginResult(callbackContext, response);

                            } else {
                                PluginUtils.getPluginResult(callbackContext, response);
                            }
                        }
                    });
                } catch (Exception ex) {
                    callbackContext.error(ex.toString());
                }
            }
        });
    }
    public  void loadWallet(final String action, final CallbackContext callbackContext) throws JSONException {
        context = activity;
        activity.runOnUiThread(new Runnable() {
            public void run() {
                final WalletRequest request = new WalletRequest();
                if(Util.isNetworkAvailable(context)){
                    try {
                        options = RequestOptions.builder().setClientId(clientId).setClientSecret(clientSecret).build();
                        request.setTransactionRef(RandomString.numeric(12));
                        new WalletSDK(context, options).getPaymentMethods(request, new IswCallback<WalletResponse>() {
                            @Override
                            public void onError(Exception error) {
                                Util.hideProgressDialog();
                                callbackContext.error(error.getMessage());
                            }

                            @Override
                            public void onSuccess(WalletResponse response) {
                                Util.hideProgressDialog();
                                PluginUtils.getPluginResult(callbackContext, response);
                            }
                        });
                    } catch (Exception ex) {
                        callbackContext.error(ex.toString());
                    }
                }else{
                    Util.notifyNoNetwork(context);
                }
            }
        });
    }
    public void payWithWalletSDK(final String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException{
        context = activity.getApplicationContext();
        activity.runOnUiThread(new Runnable() {
            public void run() {
                try {
                    options = RequestOptions.builder().setClientId(clientId).setClientSecret(clientSecret).build();
                    final PurchaseRequest request = new PurchaseRequest();
                    JSONObject params = args.getJSONObject(0);
                    request.setCustomerId(params.getString("customerId"));
                    request.setAmount(params.getString("amount"));
                    if (params.getString("pan") == null) {
                        callbackContext.error("Error : No wallet item selected");
                        return;
                    }

                    request.setPan(params.getString("pan"));
                    request.setPinData(params.getString("pin"));
                    request.setRequestorId(params.getString("requestorId"));
                    request.setCurrency(params.getString("currency"));
                    request.setTransactionRef(RandomString.numeric(12));

                    new WalletSDK(context, options).purchase(request, new IswCallback<PurchaseResponse>() {

                        @Override
                        public void onError(Exception error) {
                            callbackContext.error(error.getMessage());
                        }

                        @Override
                        public void onSuccess(PurchaseResponse response) {
                            String transactionIdentifier = response.getTransactionIdentifier();
                            if (StringUtils.hasText(response.getOtpTransactionIdentifier())) {
                                PluginUtils.getPluginResult(callbackContext, response);
                            } else {
                                PluginUtils.getPluginResult(callbackContext, response);
                            }
                        }
                    });
                } catch (Exception ex) {
                    callbackContext.error(ex.toString());
                }
            }
        });
    }
    public void validateCard(final String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException{
        context = activity.getApplicationContext();
        activity.runOnUiThread(new Runnable() {
            public void run() {
                try{
                    options = RequestOptions.builder().setClientId(clientId).setClientSecret(clientSecret).build();
                    JSONObject params = args.getJSONObject(0);
                    ValidateCardRequest request = new ValidateCardRequest(); // Setup request parameters
                    request.setPan(params.getString("pan")); //Card No or Token
                    request.setPinData(params.getString("pin")); // Optional Card PIN for card payment
                    request.setCvv2(params.getString("cvv"));
                    request.setTransactionRef(RandomString.numeric(12));
                    request.setExpiryDate(params.getString("expiryDate"));
                    request.setCustomerId(params.getString("customerId"));
                    final Card card = new Card(request.getPan(), null, null, null);
                    final String type = card.getType();
                    new PaymentSDK(context, options).validateCard(request, new IswCallback<ValidateCardResponse>() {
                        @Override
                        public void onError(Exception error) {
                            callbackContext.error(error.getMessage());
                        }
                        @Override
                        public void onSuccess(ValidateCardResponse response) {
                            // Check if OTP is required.
                            response.setCardType(type);
                            try {
                                if (StringUtils.hasText(response.getOtpTransactionIdentifier())) {
                                    PluginUtils.getPluginResult(callbackContext, response);
                                }
                                else {
                                    PluginUtils.getPluginResult(callbackContext, response);
                                }
                            } catch (Exception ex) {
                                callbackContext.error(ex.getMessage());
                            }
                        }
                    });
                }
                catch (Exception ex){
                    callbackContext.error(ex.toString());
                }
            }
        });
    }
    public void authorizeOtp(final String action, final JSONArray args, final CallbackContext callbackContext){
        context = activity.getApplicationContext();
        activity.runOnUiThread(new Runnable() {
            public void run() {
                try {
                    options = RequestOptions.builder().setClientId(clientId).setClientSecret(clientSecret).build();
                    JSONObject params = args.getJSONObject(0);
                    AuthorizeOtpRequest otpRequest = new AuthorizeOtpRequest();
                    otpRequest.setOtp(params.getString("otp")); // Accept OTP from user
                    otpRequest.setOtpTransactionIdentifier(params.getString("otpTransactionIdentifier")); // Set the OTP identifier for the request
                    otpRequest.setTransactionRef(params.getString("transactionRef")); // Set the unique transaction reference.
                    new PaymentSDK(context, options).authorizeOtp(otpRequest, new IswCallback<AuthorizeOtpResponse>() {
                        @Override
                        public void onError(Exception error) {
                            callbackContext.error(error.getMessage());
                        }

                        @Override
                        public void onSuccess(AuthorizeOtpResponse otpResponse) {
                            PluginUtils.getPluginResult(callbackContext, otpResponse);
                        }
                    });
                } catch (Exception error) {
                    PluginUtils.getPluginResult(callbackContext, error.toString());
                }
            }
        });
    }
    public void paymentStatus(final String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException{
        context = activity.getApplicationContext();
        activity.runOnUiThread(new Runnable() {
            public void run() {
                try {
                    final PaymentStatusRequest request = new PaymentStatusRequest();
                    JSONObject params = args.getJSONObject(0);
                    String transactionRef = params.getString("transactionRef");
                    String amount = params.getString("amount");
                    request.setTransactionRef(transactionRef);
                    request.setAmount(amount);
                    options = RequestOptions.builder().setClientId(clientId).setClientSecret(clientSecret).build();
                    new PaymentSDK(context, options).paymentStatus(request, new IswCallback<PaymentStatusResponse>() {
                        @Override
                        public void onError(Exception error) {
                            callbackContext.error(error.getMessage()); // Handle and notify user of error
                        }

                        @Override
                        public void onSuccess(PaymentStatusResponse response) {
                            PluginUtils.getPluginResult(callbackContext, response);// Update Payment Status
                        }
                    });
                } catch (Exception error) {
                    callbackContext.error(error.toString());
                }
            }
        });
    }
}