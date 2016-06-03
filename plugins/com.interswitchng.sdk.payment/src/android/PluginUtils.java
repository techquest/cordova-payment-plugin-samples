import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.PluginResult;
import com.google.gson.Gson;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class PluginUtils extends CordovaPlugin{

    public PluginUtils(){

    }
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
    }
    public static <T> PluginResult getPluginResult(CallbackContext callbackContext, T response){
        Gson gson = new Gson();
        PluginResult result = null;
        result = new PluginResult(PluginResult.Status.OK, gson.toJson(response));
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);
        return result;
    }
}