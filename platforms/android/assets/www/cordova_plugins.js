cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "file": "plugins/com.filfatstudios.spinnerdialog/www/SpinnerDialog.js",
        "id": "com.filfatstudios.spinnerdialog.SpinnerDialog",
        "clobbers": [
            "SpinnerDialog"
        ]
    },
    {
        "file": "plugins/com.interswitchng.sdk.payment/www/PaymentPlugin.js",
        "id": "com.interswitchng.sdk.payment.PaymentPlugin",
        "clobbers": [
            "PaymentPlugin"
        ]
    }
];
module.exports.metadata = 
// TOP OF METADATA
{
    "cordova-plugin-whitelist": "1.2.2",
    "com.filfatstudios.spinnerdialog": "1.0.2",
    "cordova-plugin-add-swift-support": "1.6.2",
    "com.interswitchng.sdk.payment": "0.0.1"
};
// BOTTOM OF METADATA
});