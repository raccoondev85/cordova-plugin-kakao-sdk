var exec = require('cordova/exec');
var AuthConstant = require('./AuthConstant');

var KakaoCordovaSDK = {
  login: function(loginOptions, successCallback, errorCallback) {
		
		if(typeof loginOptions === 'function'){
			loginOptions = {};
		}
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'login', [loginOptions]);
	},
	
  logout: function(successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'logout', []);
  },

  unlinkApp: function(successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'unlinkApp', []);
	},
	
  getAccessToken: function(successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'getAccessToken', []);
  },
};

module.exports = KakaoCordovaSDK;
