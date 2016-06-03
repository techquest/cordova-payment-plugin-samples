cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "file": "plugins/com.filfatstudios.spinnerdialog/www/SpinnerDialog.js",
        "id": "com.filfatstudios.spinnerdialog.SpinnerDialog",
        "pluginId": "com.filfatstudios.spinnerdialog",
        "clobbers": [
            "SpinnerDialog"
        ]
    },
    {
        "file": "plugins/com.interswitchng.sdk.payment/www/PaymentPlugin.js",
        "id": "com.interswitchng.sdk.payment.PaymentPlugin",
        "pluginId": "com.interswitchng.sdk.payment",
        "clobbers": [
            "PaymentPlugin"
        ]
    },
    {
        "file": "plugins/cordova-plugin-test-framework/www/tests.js",
        "id": "cordova-plugin-test-framework.cdvtests",
        "pluginId": "cordova-plugin-test-framework"
    },
    {
        "file": "plugins/cordova-plugin-test-framework/www/jasmine_helpers.js",
        "id": "cordova-plugin-test-framework.jasmine_helpers",
        "pluginId": "cordova-plugin-test-framework"
    },
    {
        "file": "plugins/cordova-plugin-test-framework/www/medic.js",
        "id": "cordova-plugin-test-framework.medic",
        "pluginId": "cordova-plugin-test-framework"
    },
    {
        "file": "plugins/cordova-plugin-test-framework/www/main.js",
        "id": "cordova-plugin-test-framework.main",
        "pluginId": "cordova-plugin-test-framework"
    }
];
module.exports.metadata = 
// TOP OF METADATA
{
    "com.filfatstudios.spinnerdialog": "1.0.2",
    "cordova-plugin-add-swift-support": "1.0.4",
    "com.interswitchng.sdk.payment": "0.0.1",
    "cordova-plugin-test-framework": "1.1.3-dev",
    "cordova-plugin-whitelist": "1.2.2"
}
// BOTTOM OF METADATA
});