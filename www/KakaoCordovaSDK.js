var exec = require('cordova/exec');
var AuthConstant = require('./AuthConstant');

var KakaoCordovaSDK = {
  login: function(loginOptions, successCallback, errorCallback) {
		
		if(typeof loginOptions === 'function'){
			loginOptions = {
        'authTypes':[]
      };
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

  requestMe: function(successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'requestMe', []);
  },

  sendLinkFeed: function(template, successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'sendLinkFeed', [template]);
  },

  sendLinkList: function(template, successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'sendLinkList', [template]);
  },

  sendLinkLocation: function(template, successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'sendLinkLocation', [template]);
  },

  sendLinkCommerce: function(template, successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'sendLinkCommerce', [template]);
  },

  sendLinkText: function(template, successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'sendLinkText', [template]);
  },

  sendLinkScrap: function(template, successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'sendLinkScrap', [template]);
  },

  sendLinkCustom: function(template, successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'sendLinkCustom', [template]);
  },

  uploadImage: function(option, successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'uploadImage', [option]);
  },

  deleteUploadedImage: function(option, successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'deleteUploadedImage', [option]);
  },

  postStory: function(option, successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'postStory', [option]);
  },
};

module.exports = KakaoCordovaSDK;
