var exec = require('cordova/exec');
var AuthConstant = require('./AuthConstant');

var KakaoCordovaSDK = {
  login: function(loginOptions, successCallback, errorCallback) {
		
		if(loginOptions == null || !loginOptions.authTypes){
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

  updateScopes: function(targetScopes, successCallback, errorCallback) {
		
		if(targetScopes == null || !targetScopes.targetScopes){
			targetScopes = {
        'targetScopes':[]
      };
		}
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'updateScopes', [targetScopes]);
  },
  
  checkScopeStatus: function(targetScopes, successCallback, errorCallback) {
		
		if(targetScopes == null || !targetScopes.targetScopes){
			targetScopes = {
        'targetScopes':[]
      };
		}
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'checkScopeStatus', [targetScopes]);
  },

  requestSendMemo: function(builder, successCallback, errorCallback) {

		if(builder == null || !builder.templateId){
			builder = {
        'arguments':[],
        'templateId':''
      };
		}
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'requestSendMemo', [builder]);
  },

  addPlusFriend: function(params, successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'addPlusFriend', [params]);
  },

  chatPlusFriend: function(params, successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'chatPlusFriend', [params]);
  },

  chatPlusFriendUrl: function(params, successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'KakaoCordovaSDK', 'chatPlusFriendUrl', [params]);
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
