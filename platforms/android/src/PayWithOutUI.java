import android.app.Activity;
import android.content.Context;
import android.webkit.WebView;
import android.app.Dialog;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.Display;
import android.view.LayoutInflater;
import android.graphics.Point;

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
import com.interswitchng.sdk.payment.model.AuthorizePurchaseRequest;
import com.interswitchng.sdk.payment.model.AuthorizePurchaseResponse;
import com.interswitchng.sdk.payment.model.AuthorizeCardRequest;
import com.interswitchng.sdk.payment.model.AuthorizeCardResponse;
import com.interswitchng.sdk.payment.android.AuthorizeWebView;

import com.interswitchng.sdk.util.RandomString;
import com.interswitchng.sdk.util.StringUtils;
import com.interswitchng.sdk.payment.model.Card;
import org.apache.cordova.PluginResult;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.google.gson.Gson;

public class PayWithOutUI extends CordovaPlugin{
    private String clientId;
    private String clientSecret;
    private WalletSDK sdk;
    private Activity activity;
    private Context context;
    protected WebView webView;

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
                    final PurchaseRequest request = new PurchaseRequest(); // Setup request parameters
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
                            if (StringUtils.hasText(response.getResponseCode())) {
                                if (PaymentSDK.SAFE_TOKEN_RESPONSE_CODE.equals(response.getResponseCode())){
                                    PluginResult result = null;
                                    result = new PluginResult(PluginResult.Status.OK, getJsonObject(response,request));
                                    result.setKeepCallback(true);
                                    callbackContext.sendPluginResult(result);
                                }
                                else if(PaymentSDK.CARDINAL_RESPONSE_CODE.equals(response.getResponseCode())){
                                    handleCardinal(response);
                                }
                            } else {
                                PluginUtils.getPluginResult(callbackContext, response);
                            }
                        }
                        private void handleCardinal(final PurchaseResponse response) {
                            final Context context = activity;
                            final Dialog cardinalDialog;
                            cardinalDialog = new Dialog(activity) {
                                @Override
                                public void onBackPressed() {
                                    super.onBackPressed();
                                    PluginUtils.getPluginResult(callbackContext, new RuntimeException("User cancelled operation"));
                                }
                            };
                            webView = new AuthorizeWebView(context, response) {
                                public void onPageDone() {
                                    cardinalDialog.dismiss();
                                    Util.showProgressDialog(context, "Processing...");
                                    AuthorizePurchaseRequest cardinalRequest = new AuthorizePurchaseRequest();
                                    cardinalRequest.setAuthData(request.getAuthData());
                                    cardinalRequest.setPaymentId(response.getPaymentId());
                                    cardinalRequest.setTransactionId(response.getTransactionId());
                                    cardinalRequest.setEciFlag(response.getEciFlag());
                                    new PaymentSDK(context, options).authorizePurchase(cardinalRequest, new IswCallback<AuthorizePurchaseResponse>() {
                                        @Override
                                        public void onError(Exception error) {
                                            Util.hideProgressDialog();
                                            PluginUtils.getPluginResult(callbackContext, error.getMessage());
                                        }

                                        @Override
                                        public void onSuccess(AuthorizePurchaseResponse response) {
                                            Util.hideProgressDialog();
                                            PluginUtils.getPluginResult(callbackContext, response);
                                        }
                                    });
                                }

                                public void onPageError(Exception error) {
                                   // finish();
                                    Util.hideProgressDialog();
                                    cardinalDialog.dismiss();
                                    PluginUtils.getPluginResult(callbackContext,error.getMessage());
                                    //Util.notify(context, "Error", error.getMessage(), "Close", false);
                                }

                            };
                            cardinalDialog.setContentView(webView);
                            cardinalDialog.show();
                            cardinalDialog.setCancelable(true);
                            webView.requestFocus(View.FOCUS_DOWN);
                            webView.getSettings().setJavaScriptEnabled(true);
                            webView.setVerticalScrollBarEnabled(true);
                            WindowManager wm = (WindowManager) activity.getSystemService(Context.WINDOW_SERVICE);
                            Display display = wm.getDefaultDisplay();
                            Point size = new Point();
                            display.getSize(size);
                            int width = size.x;
                            int height = size.y;
                            Window window = cardinalDialog.getWindow();
                            window.setLayout(width, height);
                        }
                    });
                } catch (Exception ex) {
                    PluginUtils.getPluginResult(callbackContext,ex.getMessage());
                }
            }
        });
    }

    private JSONObject getJsonObject(PurchaseResponse response, PurchaseRequest request) {
        Gson gson = new Gson();
        JSONObject jsonObject = null;
        try{
            jsonObject = new JSONObject(gson.toJson(response));
            jsonObject.put("paymentId", response.getPaymentId());
            jsonObject.put("authData",request.getAuthData());
        }catch (JSONException jsonException){
            jsonException.printStackTrace();
        }
        return jsonObject;
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
                                //String otpTransactionIdentifier = response.getOtpTransactionIdentifier();
                                PluginUtils.getPluginResult(callbackContext, response);
                                /*String otpTransactionIdentifier = response.getOtpTransactionIdentifier();
                                Util.prompt(activity, "OTP", response.getMessage(), "Close", "Continue", true, 1L);*/
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
                    final ValidateCardRequest request = new ValidateCardRequest(); // Setup request parameters
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
                            response.setCardType(type);
                            if (StringUtils.hasText(response.getResponseCode())) {
                                if (PaymentSDK.SAFE_TOKEN_RESPONSE_CODE.equals(response.getResponseCode())){
                                    PluginResult result = null;
                                    result = new PluginResult(PluginResult.Status.OK, getJsonObject(response,request));
                                    result.setKeepCallback(true);
                                    callbackContext.sendPluginResult(result);
                                }
                                else if(PaymentSDK.CARDINAL_RESPONSE_CODE.equals(response.getResponseCode())){
                                    handleCardinal(response);
                                }
                            } else {
                                PluginUtils.getPluginResult(callbackContext, response);
                            }
                        }
                        private void handleCardinal(final ValidateCardResponse response) {
                            final Context context = activity;
                            final Dialog cardinalDialog;
                            cardinalDialog = new Dialog(activity) {
                                @Override
                                public void onBackPressed() {
                                    super.onBackPressed();
                                    PluginUtils.getPluginResult(callbackContext, new RuntimeException("User cancelled operation"));
                                }
                            };
                            webView = new AuthorizeWebView(context, response) {
                                public void onPageDone() {
                                    cardinalDialog.dismiss();
                                    Util.showProgressDialog(context, "Processing...");
                                    AuthorizeCardRequest cardinalRequest = new AuthorizeCardRequest();
                                    cardinalRequest.setAuthData(request.getAuthData());
                                    cardinalRequest.setTransactionRef(response.getTransactionRef());
                                    cardinalRequest.setTransactionId(response.getTransactionId());
                                    cardinalRequest.setEciFlag(response.getEciFlag());
                                    new PaymentSDK(context, options).authorizeCard(cardinalRequest, new IswCallback<AuthorizeCardResponse>() {
                                        @Override
                                        public void onError(Exception error) {
                                            Util.hideProgressDialog();
                                            PluginUtils.getPluginResult(callbackContext, error.getMessage());
                                        }

                                        @Override
                                        public void onSuccess(AuthorizeCardResponse response) {
                                            Util.hideProgressDialog();
                                            PluginUtils.getPluginResult(callbackContext, response);
                                        }
                                    });
                                }

                                public void onPageError(Exception error) {
                                    // finish();
                                    Util.hideProgressDialog();
                                    cardinalDialog.dismiss();
                                    PluginUtils.getPluginResult(callbackContext, error.getMessage());
                                    //Util.notify(context, "Error", error.getMessage(), "Close", false);
                                }

                            };
                            cardinalDialog.setContentView(webView);
                            cardinalDialog.show();
                            cardinalDialog.setCancelable(true);
                            webView.requestFocus(View.FOCUS_DOWN);
                            webView.getSettings().setJavaScriptEnabled(true);
                            webView.setVerticalScrollBarEnabled(true);
                            WindowManager wm = (WindowManager) activity.getSystemService(Context.WINDOW_SERVICE);
                            Display display = wm.getDefaultDisplay();
                            Point size = new Point();
                            display.getSize(size);
                            int width = size.x;
                            int height = size.y;
                            Window window = cardinalDialog.getWindow();
                            window.setLayout(width, height);
                        }
                    });
                }
                catch (Exception ex){
                    PluginUtils.getPluginResult(callbackContext, ex.toString());
                }
            }
        });
    }
    public void authorizePurchase(final String action, final JSONArray args, final CallbackContext callbackContext){
        context = activity.getApplicationContext();
        activity.runOnUiThread(new Runnable() {
            public void run() {
                try {
                    options = RequestOptions.builder().setClientId(clientId).setClientSecret(clientSecret).build();
                    JSONObject params = args.getJSONObject(0);
                    AuthorizePurchaseRequest request = new AuthorizePurchaseRequest();
                    request.setPaymentId(params.getString("paymentId")); // Set the unique transaction reference.
                    request.setAuthData(params.getString("authData")); // Set the OTP identifier for the request
                    request.setOtp(params.getString("otp")); // Accept OTP from user
                    new PaymentSDK(context, options).authorizePurchase(request, new IswCallback<AuthorizePurchaseResponse>() {
                        @Override
                        public void onError(Exception error) {
                            callbackContext.error(error.getMessage());
                        }

                        @Override
                        public void onSuccess(AuthorizePurchaseResponse authorizePurchaseResponse) {
                            PluginUtils.getPluginResult(callbackContext, authorizePurchaseResponse);
                        }
                    });
                } catch (Exception error) {
                    PluginUtils.getPluginResult(callbackContext, error.toString());
                }
            }
        });
    }
    public void authorizeCard(final String action, final JSONArray args, final CallbackContext callbackContext){
        context = activity.getApplicationContext();
        activity.runOnUiThread(new Runnable() {
            public void run() {
                try {
                    options = RequestOptions.builder().setClientId(clientId).setClientSecret(clientSecret).build();
                    JSONObject params = args.getJSONObject(0);
                    AuthorizeCardRequest request = new AuthorizeCardRequest();
                    request.setTransactionRef(params.getString("transactionRef"));
                    request.setAuthData(params.getString("authData")); // Set the OTP identifier for the request
                    request.setOtp(params.getString("otp")); // Accept OTP from user
                    new PaymentSDK(context, options).authorizeCard(request, new IswCallback<AuthorizeCardResponse>() {
                        @Override
                        public void onError(Exception error) {
                            callbackContext.error(error.getMessage());
                        }

                        @Override
                        public void onSuccess(AuthorizeCardResponse authorizeCardResponse) {
                            PluginUtils.getPluginResult(callbackContext, authorizeCardResponse);
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