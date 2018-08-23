// This file contains the source for the Javascript side of the
// WebViewJavascriptBridge. It is plaintext, but converted to an NSString
// via some preprocessor tricks.
//
// Previous implementations of WebViewJavascriptBridge loaded the javascript source
// from a resource. This worked fine for app developers, but library developers who
// included the bridge into their library, awkwardly had to ask consumers of their
// library to include the resource, violating their encapsulation. By including the
// Javascript as a string resource, the encapsulation of the library is maintained.

#import "WebViewJavascriptBridge_JS.h"

NSString * WebViewJavascriptBridge_js() {
	#define __wvjb_js_func__(x) #x
	
	// BEGIN preprocessorJSCode
	static NSString * preprocessorJSCode = @__wvjb_js_func__(
;(function() {
	if (window.SNNativeClient) {
		return;
	}

	if (!window.onerror) {
		window.onerror = function(msg, url, line) {
			console.log("SNNativeClient: ERROR:" + msg + "@" + url + ":" + line);
		}
	}

	var messagingIframe;
	var sendMessageQueue = [];
    var receiveMessageQueue = [];
	var messageHandlers = {};
	
	var CUSTOM_PROTOCOL_SCHEME = 'suningwvjbscheme';
	var QUEUE_HAS_MESSAGE = '__WVJB_QUEUE_MESSAGE__';
	
	var responseCallbacks = {};
	var uniqueId = 1;
	var dispatchMessagesWithTimeoutSafety = true;

    var navButtonCallBacks = {};
    var navButtonId = 1;
        
    function init(messageHandler) {
        if (SNNativeClient._messageHandler) { throw new Error('SNNativeClient.init called twice') }
        SNNativeClient._messageHandler = messageHandler;
        var receivedMessages = receiveMessageQueue;
        receiveMessageQueue = null;
        for (var i=0; i<receivedMessages.length; i++) {
            _dispatchMessageFromObjC(receivedMessages[i])
        }
    }
        
    function send(data, responseCallback) {
        _doSend({ data:data }, responseCallback)
    }
        
	function registerHandler(handlerName, handler) {
		messageHandlers[handlerName] = handler;
	}
	
	function callHandler(handlerName, data, responseCallback) {
		if (arguments.length == 2 && typeof data == 'function') {
			responseCallback = data;
			data = null;
		}
		_doSend({ handlerName:handlerName, data:data }, responseCallback);
	}
        
	function disableJavscriptAlertBoxSafetyTimeout() {
		dispatchMessagesWithTimeoutSafety = false;
	}
	
	function _doSend(message, responseCallback) {
		if (responseCallback) {
			var callbackId = 'cb_'+(uniqueId++)+'_'+new Date().getTime();
			responseCallbacks[callbackId] = responseCallback;
			message['callbackId'] = callbackId;
		}
		sendMessageQueue.push(message);
		messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;
	}

	function _fetchQueue() {
		var messageQueueString = JSON.stringify(sendMessageQueue);
		sendMessageQueue = [];
		return messageQueueString;
	}

	function _dispatchMessageFromObjC(messageJSON) {
		if (dispatchMessagesWithTimeoutSafety) {
			setTimeout(_doDispatchMessageFromObjC);
		} else {
			 _doDispatchMessageFromObjC();
		}
		
		function _doDispatchMessageFromObjC() {
			var message = JSON.parse(messageJSON);
			var messageHandler;
			var responseCallback;

			if (message.responseId) {
				responseCallback = responseCallbacks[message.responseId];
				if (!responseCallback) {
					return;
				}
				responseCallback(message.responseData);
				delete responseCallbacks[message.responseId];
			} else {
				if (message.callbackId) {
					var callbackResponseId = message.callbackId;
					responseCallback = function(responseData) {
						_doSend({ handlerName:message.handlerName, responseId:callbackResponseId, responseData:responseData });
					};
				}
				
				var handler = messageHandlers[message.handlerName];
				if (!handler) {
					console.log("SNNativeClient: WARNING: no handler for message from ObjC:", message);
				} else {
					handler(message.data, responseCallback);
				}
			}
		}
	}
	
    function _handleMessageFromObjC(messageJSON) {
        if (receiveMessageQueue) {
            receiveMessageQueue.push(messageJSON)
        } else {
            _dispatchMessageFromObjC(messageJSON)
        }
    }
        
    function copyToClipboard(text, responseCallback) {
        SNNativeClient.callHandler("copyToClipboard", {"text": text}, responseCallback);
    }

    //添加miniProgramPath miniProgramUserName参数 小程序分享
    //添加channelType 分享圈子所需参数
    function callNativeShare(title, content, targetUrl, iconUrl, shareWays, miniProgramPath, miniProgramUserName, channelType) {
        var data = {"title": title, "content": content, "targetUrl": targetUrl, "iconUrl":iconUrl, "shareWays":shareWays, "miniProgramPath":miniProgramPath, "miniProgramUserName":miniProgramUserName, "channelType":channelType};
        SNNativeClient.callHandler("callNativeShare", data, null);
    }

    //iphoneX开放全屏
    function callOpenWebViewFullScreen(isOpen) {
        
        var data = {"isOpen" : isOpen};
        SNNativeClient.callHandler("callOpenWebViewFullScreen", data, null);
    }
    
    //返回操作
    function popViewControllerIfCanGoBack() {
            
        var data = {};
        SNNativeClient.callHandler("popViewControllerIfCanGoBack", data, null);
    }
    
    //购买SuperVip支付成功
    function superVipPaySuccess() {
        SNNativeClient.callHandler("superVipPaySuccess", null, null);
    }
        
    //直接分享
    function callDirectShare(title, content, targetUrl, iconUrl, shareWay, miniProgramPath, miniProgramUserName) {
        var data = {"title": title, "content": content, "targetUrl": targetUrl, "iconUrl":iconUrl, "shareWay":shareWay, "miniProgramPath":miniProgramPath, "miniProgramUserName":miniProgramUserName};
        SNNativeClient.callHandler("callDirectShare", data, null);
    }

    //直接分享二维码组合图片到朋友圈，微信好友 0 朋友圈 1微信好友
    function callDirectQRCodePlentifulShare(title , price, targetUrl, iconUrl, appIconUrl ,productPicUrl ,shareWay) {
        var data = {"title": title,"price": price, "targetUrl": targetUrl, "iconUrl":iconUrl,  "appIconUrl": appIconUrl, "productPicUrl":productPicUrl,"shareWay":shareWay };
        SNNativeClient.callHandler("callDirectQRCodePlentifulShare", data, null);
    }
        
    //机型是否支持指纹
    function yfbIsDeviceSupportTouchID(responseCallback) {
        SNNativeClient.callHandler("yfbIsDeviceSupportTouchID",null,responseCallback);
    }
    
    //易付宝账号是否支持指纹
    function yfbIsUserSupportTouchID(responseCallback) {
        SNNativeClient.callHandler("yfbIsUserSupportTouchID",null,responseCallback);
    }
    
    //开通易付宝指纹支付
    function yfbOpenTouchIDPay(responseCallback) {
        SNNativeClient.callHandler("yfbOpenTouchIDPay",null,responseCallback);
    }
    
    function callGetLastDeepLinkUrl(responseCallback) {
        SNNativeClient.callHandler("callGetLastDeepLinkUrl", null, responseCallback);
    }

    //  function hasAddedLocalNotification(id, title, startTime, responseCallback) {
        //      var data = {"id":id, "title":title, "startTime": startTime};
        //      SNNativeClient.callHandler("hasAddedLocalNotification", data, responseCallback);
    //  }
    
    function addLocalNotification(id, title, startTime, responseCallback) {
        var data = {"id":id, "title":title, "startTime": startTime};
        SNNativeClient.callHandler("addLocalNotification", data, responseCallback);
    }
    
    //  function cancelLocalNotification(id, title, startTime, responseCallback) {
        //        var data = {"id":id, "title":title, "startTime": startTime};
        //        SNNativeClient.callHandler("cancelLocalNotification", data, responseCallback);
    //  }
    
    //云信与js交互透传
    function invokeYunXin(id, type, value, responseCallback) {
        var data = {"id":id, "type": type, "value":value};
        SNNativeClient.callHandler("invokeYunXin", data, responseCallback);
    }

    function goToProductDetail(productCode, shopCode) {
        var data = {"productCode": productCode, "shopCode": shopCode};
        SNNativeClient.callHandler("goToProductDetail", data, null);
    }

    function goToRushProductDetail(productCode, shopCode, rushPurId, rushChannel) {
        var data = {"productCode": productCode, "shopCode": shopCode, "rushPurId": rushPurId, "rushPurChannel": rushChannel, "promotionType": "1"};
        SNNativeClient.callHandler("goToProductDetail", data, null);
    }

    function goToGroupProductDetail(productCode, shopCode, groupPurId) {
        var data = {"productCode": productCode, "shopCode": shopCode, "groupPurId": groupPurId, "promotionType": "2"};
        SNNativeClient.callHandler("goToProductDetail", data, null);
    }

    function goToJuhuiProductDetail(productCode, shopCode) {
        var data = {"productCode": productCode, "shopCode": shopCode, "promotionType": "3"};
        SNNativeClient.callHandler("goToProductDetail", data, null);
    };

    function goToFamousBrandProductDetail(productCode, shopCode) {
        var data = {"productCode": productCode, "shopCode": shopCode, "promotionType": "6"};
        SNNativeClient.callHandler("goToProductDetail", data, null);
    }

    function goToTreatyProductDetail(productCode, shopCode,promotionType,buyTypeCode,treatyTypeCode) {
        var data = {"productCode": productCode, "shopCode": shopCode, "promotionType": promotionType, "buyTypeCode": buyTypeCode, "treatyTypeCode": treatyTypeCode};
        SNNativeClient.callHandler("goToProductDetail", data, null);
    }

    function goBackFreeNessPay(status) {
        var data = {"status": status};
        SNNativeClient.callHandler("goBackFreeNessPay", data, null);
    }

    function closeWapPage(responseCallback) {
        SNNativeClient.callHandler("closeWapPage", null, responseCallback);
    }

    function getClientInfo(responseCallback) {
        SNNativeClient.callHandler("getClientInfo", null, responseCallback);
    }

    function getIdentifier(responseCallback) {
        SNNativeClient.callHandler("getIdentifier", null, responseCallback);
    }

    function getCityInfo(responseCallback){
        SNNativeClient.callHandler("getCityInfo", null, responseCallback);
    }

    //定位省市区code
    function getLocatedAddressInfo(responseCallback){
        SNNativeClient.callHandler("getLocatedAddressInfo", null, responseCallback);
    }

    function changeCity(cityId){
        var data = {"cityId": cityId};
        SNNativeClient.callHandler("changeCity", data, null);
    }

    function changeCityByLes(cityId){
        var data = {"cityId": cityId};
        SNNativeClient.callHandler("changeCityByLes", data, null);
    }

    function gotoCustom(shopCode,shopName) {
        var data = {"shopCode": shopCode,"shopName": shopName};
        SNNativeClient.callHandler("gotoCustom", data, null);
    }

    function gotoB2CShop(catentryIds,thirdCategoryId,brandId,channel) {
        var data = {"catentryIds":catentryIds, "thirdCategoryId":thirdCategoryId, "brandId":brandId, "channel":channel};
        SNNativeClient.callHandler("gotoB2CShop", data, null);
    }

    function gotoCPA(){
        SNNativeClient.callHandler("gotoCPA", null);
    }

    function gotoActive(){
        SNNativeClient.callHandler("gotoActive", null);
    }

    function goToSearchResultWithKeyword(keyword) {
        SNNativeClient.callHandler("goToSearchResultWithKeyword", {"keyword": keyword});
    }

    function pushToNextPage(url) {
        SNNativeClient.callHandler("pushToNextPage", {"url": url});
    }

    //wap页通过页面路由跳转原生页
    function routeToClientPage(adTypeCode, adId) {
        SNNativeClient.callHandler("routeToClientPage", {"adTypeCode": adTypeCode, "adId": adId});
    }

    function showAlert(message, buttons, touchCallBack) {
        SNNativeClient.callHandler("showAlert", {"message": message, "buttons": buttons}, function (response) {
            touchCallBack(response["clickIndex"]);
        })
    }

    function showTip(message) {
        SNNativeClient.callHandler("showTip", {"message": message});
    }

    function openImageChooser(pictureUrl){
        SNNativeClient.callHandler("openImageChooser", {"pictureUrl": pictureUrl});
        
    }

    function showRightButtons(buttons, touchCallBack) {
        var navId = "nav_button_"+(navButtonId++);
        if (touchCallBack) {
            navButtonCallBacks[navId] = touchCallBack;
        }
        
        SNNativeClient.callHandler("showRightButtons", {"buttons": buttons, "id": navId});
        
        if (messageHandlers["navRightButtonClicked"] == null) {
            SNNativeClient.registerHandler("navRightButtonClicked", function (response) {
                var navbuttonresponseId = response["id"];
                block = navButtonCallBacks[navbuttonresponseId];
                if (block) {
                    block(response["buttonIndex"]);
                }
            });
        }
    }

    function addProductToShopCart(productId, shopCode, quantity, cityCode, completionCallback) {
        var data = {"productId": productId, "shopCode": shopCode, "quantity": quantity, "cityCode":cityCode};
        SNNativeClient.callHandler("addProductToShopCart", data, completionCallback);
    }


    function addNewProductToShopCart(productCode, quantity, supplierCode, isDJH, actType, actId, provinceId, cityId, districtId, completionCallback) {
        var data = {"productCode": productCode, "quantity": quantity ,"supplierCode" :supplierCode , "isDJH": isDJH, "actType":actType , "actId" :actId, "provinceId":provinceId , "cityId":cityId , "districtId":districtId};
        SNNativeClient.callHandler("addNewProductToShopCart", data, completionCallback);
    }


    function addSpecailProductToShopCart(productId, shopCode, quantity, cityCode, special, promotionId, completionCallback) {
        var data = {"productId": productId, "shopCode": shopCode, "quantity": quantity, "cityCode":cityCode, "special":special, "promotionId":promotionId};
        SNNativeClient.callHandler("addSpecailProductToShopCart", data, completionCallback);
    }

    function setBarColor(color) {
        SNNativeClient.callHandler("setBarColor", {"color": color});
    }

    function openLinkInSafari(url) {
        SNNativeClient.callHandler("openLinkInSafari", {"url": url});
    }

    function openPhoneSettings(){
        SNNativeClient.callHandler("openPhoneSettings", null);
    }

    function gotoHomePage() {
        SNNativeClient.callHandler("gotoHomePage", null);
    }

    function openBestieFileChooser(descText,choosedCount,images) {
        SNNativeClient.callHandler("openBestieFileChooser",{"choosedCount":choosedCount,"descText":descText,"images":images});
    }

    /*wap店铺数据采集，add by xingxianping,2015-3-4*/
    function setSATitle(shopCode,shopType){
        var data = {"shopCode": shopCode, "shopType": shopType,};
        SNNativeClient.callHandler("setSATitle",data);
    }

    /*苏宁wap店铺数据采集，add by wb,2016-1-28*/
    function setSNSATitle(title){
        var data = {"title": title};
        SNNativeClient.callHandler("setSNSATitle",data);
    }

    //获取定位信息 （不含城市id）
    function getGeoPosition(responseCallback) {
        SNNativeClient.callHandler("getGeoPosition", null, responseCallback);
    }

    //获取定位信息 （包含城市id）
    function getLesPosition(responseCallback) {
        SNNativeClient.callHandler("getLesPosition", null, responseCallback);
    }

    function preparePayWithSDK(orderId, orderPrice, prepareType, date, productCode) {
        var data = {"orderId": orderId, "orderPrice": orderPrice, "prepareType": prepareType, "date": date, "productCode": productCode};
        SNNativeClient.callHandler("preparePayWithSDK", data);
    }

    //    function seckillPayWithSDK(orderId, orderPrice, productCode) {
    //        var data = {"orderId": orderId, "orderPrice": orderPrice, "productCode": productCode}
    //        SNNativeClient.callHandler("seckillPayWithSDK", data)
    //    }

    //进定制的云购物车
    function gotoCustomizedCloudCart2(cart2No,type) {
        var data = {"cart2No": cart2No,"type": type};
        SNNativeClient.callHandler("gotoCustomizedCloudCart2", data, null);
    }

    function setTempCartId(tempCartId)
    {
        var data = {"tempCartId":tempCartId};
        SNNativeClient.callHandler("setTempCartId", data,null);
    }

    function gotoCloudCart2(cart2No) {
        var data = {"cart2No": cart2No};
        SNNativeClient.callHandler("gotoCloudCart2", data, null);
    }

    function gotoCloudCart2V2(cart2No,codeType,productType) {
        var data = {"cart2No": cart2No,"codeType":codeType,"productType":productType};
        SNNativeClient.callHandler("gotoCloudCart2V2", data, null);
    }

    function coffeePayWithSDK(orderId, orderPrice, productCode) {
        var data = {"orderId": orderId, "orderPrice": orderPrice, "productCode": productCode};
        SNNativeClient.callHandler("coffeePayWithSDK", data);
    }

    //点击去扫一扫页面
    function gotoScan(operationWay){
        var data ={"operationWay":operationWay};
        SNNativeClient.callHandler("gotoScan", data);
    }

    //点击选择地址
    function selectAddress(addressType){
        var data ={"addressType":addressType};
        SNNativeClient.callHandler("selectAddress", data);
    }

    //上传多张图片
    function uploadMultiplePictures(pictureUrl){
        SNNativeClient.callHandler("uploadMultiplePictures", {"pictureUrl": pictureUrl});
    }

    function enableLoading(status) {
        var data = {"status":status};
        SNNativeClient.callHandler("enableLoading", data);
    }

    //支付js(此方法由h5调用支付前检查接口)
    //orderInfo 支付报文
    //version SDK版本，1.0 或者 2.0
    //直接返回的报文
    function payWithOrderInfo(orderInfo, version) {
        var data = {"orderInfo": orderInfo, "version": version};
        SNNativeClient.callHandler("payWithOrderInfo", data);
    }

    //客户端通知是否开启，未开启弹框
    //norificateType   页面类型 1-到货通知
    function appNotificationStatus(norificateType) {
        var data = {"norificateType": norificateType};
        SNNativeClient.callHandler("appNotificationStatus", data);
    }

    function addressBook() {
        SNNativeClient.callHandler("addressBook", null);
    }

    function setNavigationHiden(hasNavigation) {
        var data = {"hasNavigation": hasNavigation};
        SNNativeClient.callHandler("setNavigationHiden", data);
    }

    function useShake(status) {
        var data = {"status":status};
        SNNativeClient.callHandler("useShake", data);
    }

    function addDesktopShortcut(name,url,routeCode){
        var data = {"name": name, "url": url,"routeCode":routeCode};
        SNNativeClient.callHandler("addDesktopShortcut", data);
    }

    //点击去拍照页面
    function takePhoto(picUrl, title, picSize){
        var data ={"picUrl":picUrl, "title":title, "picSize":picSize};
        SNNativeClient.callHandler("takePhoto", data);
    }

    /*jsonDic
     orderId 订单号
     orderItemsId 订单行id
     productCode 商品编码
     payType 支付方式描述（易付宝支付）
     shipType 配送方式（"配送" or "自提"）
     userAddress 收货地址
     orderPayMode 支付方式（11601）
     invoiceType 发票类型（电子发票）
     productPrice 商品价格
     */
    function gotoNativeReturn(jsonDic) {
        var data = {"jsonDic": jsonDic};
        SNNativeClient.callHandler("gotoNativeReturn", data);
    }

    function enablePullRefresh() {
        SNNativeClient.callHandler("enablePullRefresh", null);
    }

    function updateTitle(title) {
        SNNativeClient.callHandler("updateTitle", {"title": title});
    }

    // @xzoscar 2015/12/14
    function documentNavStyle() {
        if (document) {
            var dTitle     = document.title;
            var eTitle,eImage,eFontSize,eFontColor,eBakground,eBakgIos6,eBakImage,eIconStyle;
            var div =  document.getElementById("ebuyNavigation");
            if (div) {
                eTitle      = div.getAttribute("title");
                eImage      = div.getAttribute("image");
                eFontSize   = div.getAttribute("fontSize");
                eFontColor  = div.getAttribute("fontColor");
                eBakground  = div.getAttribute("background");
                eBakgIos6   = div.getAttribute("backgImgIos6");
                eBakImage   = div.getAttribute("backgImg");
                eIconStyle = div.getAttribute("iconStyle"); //    0黑色 1白色
            };
            
            var data = {"dTitle":(dTitle?dTitle:""),
                "eTitle":(eTitle?eTitle:""),
                "eImage":(eImage?eImage:""),
                "eFontSize":(eFontSize?eFontSize:""),
                "eFontColor":(eFontColor?eFontColor:""),
                "eBakground":(eBakground?eBakground:""),
                "eBakgIos6":(eBakgIos6?eBakgIos6:""),
                "eBakImage":(eBakImage?eBakImage:""),
                "eIconStyle":(eIconStyle?eIconStyle:"")};
            SNNativeClient.callHandler("documentNavStyle", data);
        }
    }

    function httpGet(url, responseCallback) {
        SNNativeClient.callHandler("httpGet", url, responseCallback);
    }

    function getNetworkInfo(responseCallback) {
        SNNativeClient.callHandler("getNetworkInfo", null, responseCallback);
    }

    function commonPayWithSDK(orderId, orderPrice, productCode, successType) {
        var data = {"orderId": orderId, "orderPrice": orderPrice, "productCode": productCode, "successType": successType};
        SNNativeClient.callHandler("commonPayWithSDK", data);
    }

    function payWithJsonStr(jsonStr) {
        var data = {"jsonStr": jsonStr};
        SNNativeClient.callHandler("payWithJsonStr", data);
    }

    function jumpToOrderCenter() {
        SNNativeClient.callHandler("jumpToOrderCenter", null);
    }

    //4.0新增获取三种citycode
    function getCityCode(responseCallback){
        SNNativeClient.callHandler("getCityCode", null, responseCallback);
    }

    //4.2新增搜索搜趣js方法
    function getSearchFunInfo(responseCallback) {
        SNNativeClient.callHandler("getSearchFunInfo", null, responseCallback);
    }

    //4.2新增保存图片
    function saveImage(imageUrl) {
        SNNativeClient.callHandler("saveImage", imageUrl, null);
    }

    //4.3新增添加日历事件
    function addEKEvent(title, url, startDate, endDate, alarmDate, responseCallback) {
        var data = {"title":title, "url":url, "startDate":startDate, "endDate":endDate, "alarmDate":alarmDate};
        SNNativeClient.callHandler("addEKEvent", data, responseCallback);
    }

    //4.2新增保存图片
    function gotoRegist(url) {
        SNNativeClient.callHandler("gotoRegist", url, null);
    }

    //4.4新增领券md5加密
    function couponMD5Encrypt(string, responseCallback) {
        SNNativeClient.callHandler("couponMD5Encrypt", string, responseCallback);
    }

    //4.4新增获取会员等级
    function getUserLevel(responseCallback) {
        SNNativeClient.callHandler("getUserLevel", null, responseCallback);
    }

    function getMemberInfo(responseCallback) {
        SNNativeClient.callHandler("getMemberInfo", null, responseCallback);
    }

    //4.4设置pageTitle
    function setPageTitle(title) {
        SNNativeClient.callHandler("setPageTitle", title, null);
    }

    //5.6.2 设置newPageTitle
    function setNewPageTitle(title,newTitle) {
        var data = {"title":title, "newTitle":newTitle};
        SNNativeClient.callHandler("setNewPageTitle", data, null);
    }

    //4.4调用自定义block
    function callCustomBlock(string) {
        SNNativeClient.callHandler("callCustomBlock", string, null);
    }

    //4.5点击埋点
    function setClickId(clickId) {
        SNNativeClient.callHandler("setClickId", clickId, null);
    }

    //4.5.6设备指纹
    function getDeviceToken(responseCallback) {
        SNNativeClient.callHandler("getDeviceToken", null, responseCallback);
    }

    //4.5.6人机
    function getHumanMachine(responseCallback) {
        SNNativeClient.callHandler("getHumanMachine", null, responseCallback);
    }

    //4.4设置pageTitle
    function saveCipher(newCipher, responseCallback) {
        SNNativeClient.callHandler("saveCipher", newCipher, responseCallback);
    }

    //4.7销售来源统计
    //sourceArray ex: @[@[二级销售来源,商品编码,价格,订单号],@[二级销售来源,商品编码,价格,订单号]]  内部数组里面对象必须是4个,否则不统计,顺序不要乱
    function sellSourceForH5(sourceArray) {
        SNNativeClient.callHandler("sellSourceForH5", sourceArray, null);
    }

    //旋转屏幕 0不旋转 1旋转
    function neesWebViewScreenRotation(hasRotate) {
        var data = {"hasRotate": hasRotate};
        SNNativeClient.callHandler("neesWebViewScreenRotation", data);
    }

    //4.9.1获取相机权限
    function SNGetCameraPermission(responseCallback) {
        SNNativeClient.callHandler("SNGetCameraPermission", null, responseCallback);
    }

    //4.9.1初级实名认证
    function SNCallRealName(responseCallback) {
        SNNativeClient.callHandler("SNCallRealName", null, responseCallback);
    }

    //4.9.1高级实名认证
    function SNAdvancedAuth (responseCallback) {
        SNNativeClient.callHandler("SNAdvancedAuth", null, responseCallback);
    }

    //4.9.1单独的人脸验证接口
    function SNFaceIdcheck (channelCode,responseCallback) {
        SNNativeClient.callHandler("SNFaceIdcheck", channelCode, responseCallback);
    }

    //5.0 增加前端获取网络状态改变
    function SNOpenNetNotificationCenter (callBackName,responseCallback) {
        SNNativeClient.callHandler("SNOpenNetNotificationCenter", callBackName, responseCallback);
    }

    //5.2 截屏分享
    function takeScreenshotShare(url, title, desc) {
        var data = {"url": url, "title": title, "desc": desc};
        SNNativeClient.callHandler("takeScreenshotShare", data, null);
    }

    //图片分享(6.3.0添加分享圈子)
    function callMediaShare(picUrl, shareWay, title, content, targetUrl, channelType, responseCallback) {
        var data = {
            "picUrl": picUrl,
            "shareWay":shareWay,
            "title":title,
            "content":content,
            "targetUrl":targetUrl,
            "channelType":channelType};
        SNNativeClient.callHandler("callMediaShare", data, responseCallback);
    }
        
    //分享圈子(6.3.0)
    function callMediaShareCircle(picUrl, title, content, targetUrl, channelType, responseCallback) {
        var data = {
            "picUrl": picUrl,
            "title":title,
            "content":content,
            "targetUrl":targetUrl,
            "channelType":channelType };
        SNNativeClient.callHandler("callMediaShareCircle", data, responseCallback);
    }
        
    //5.5跳转拼购分享页面
    function goPinGouShareVC(itemName, snPrice, pgPrice, commission, commissionPrice, imgList, targetUrl, vendorName, actId, productCode, vendorCode) {
        var data = {
            "itemName": itemName,
            "snPrice":snPrice,
            "pgPrice":pgPrice,
            "commission":commission,
            "commissionPrice":commissionPrice,
            "imgList":imgList,
            "targetUrl":targetUrl,
            "vendorName":vendorName,
            "actId":actId,
            "productCode":productCode,
            "vendorCode":vendorCode
        };
        SNNativeClient.callHandler("goPinGouShareVC", data, null);
    }

    //5.5显示导航栏购物车
    function showRightShopCarBtn(showRightShopCarBtn) {
        var data = {"showRightShopCarBtn": showRightShopCarBtn};
        SNNativeClient.callHandler("showRightShopCarBtn", data, null);
    }

    //6.2返回到首页A
    function backToHomeA(){
            
        SNNativeClient.callHandler("backToHomeA",null,null);
    }
    //5.6显示push提示
    function showPushAlertView() {
        SNNativeClient.callHandler("showPushAlertView", null, null);
    }

    //5.6获取用户通讯录信息
    function getContactInfo(responseCallback) {
        SNNativeClient.callHandler("getContactInfo", null, responseCallback);
    }

    //5.8扫条形码
    function goToScanBarCode(responseCallback) {
        SNNativeClient.callHandler("goToScanBarCode", null, responseCallback);
    }

    //5.9 wap调用阿里支付,传订单信息
    function aliPayWithOrderInfo(orderInfo,isShowPayLoading){
        var data = {"orderInfo": orderInfo,
            "isShowPayLoading":isShowPayLoading
        };
        SNNativeClient.callHandler("aliPayWithOrderInfo", data, null);
    }
    //6.3 微信支付 ,订单信息
    function wxPayWithOrderInfo(orderInfo) {

        SNNativeClient.callHandler("wxPayWithOrderInfo", orderInfo, null);
    }
    //6.4 微信支付 , 订单
    function wxPayWap(data) {
        
        SNNativeClient.callHandler("wxPayWap", data, null);
    }
        
    //6.2导航栏右侧显示分享
    function showRightShareBtn(showRightShareBtn) {
        var data = {"showRightShareBtn":showRightShareBtn};
        SNNativeClient.callHandler("showRightShareBtn", data, null);
    }
        
    //6.3选择圈子区域
    function selectCircleRange(responseCallback) {
        SNNativeClient.callHandler("selectCircleRange", null, responseCallback);
    }
    
    window.SNNativeClient = {
        registerHandler: registerHandler,
        callHandler: callHandler,
        disableJavscriptAlertBoxSafetyTimeout: disableJavscriptAlertBoxSafetyTimeout,
        _fetchQueue: _fetchQueue,
        _handleMessageFromObjC: _handleMessageFromObjC,
        send: send,
        init: init,
        addEventListener: addEventListener,
        copyToClipboard: copyToClipboard,
        callNativeShare: callNativeShare,
        callDirectShare: callDirectShare,
        callOpenWebViewFullScreen: callOpenWebViewFullScreen,
        superVipPaySuccess: superVipPaySuccess,
        pppaysuccess: superVipPaySuccess,
        popViewControllerIfCanGoBack:popViewControllerIfCanGoBack,
        callDirectQRCodePlentifulShare: callDirectQRCodePlentifulShare,
        yfbIsDeviceSupportTouchID: yfbIsDeviceSupportTouchID,
        yfbIsUserSupportTouchID: yfbIsUserSupportTouchID,
        yfbOpenTouchIDPay: yfbOpenTouchIDPay,
        callGetLastDeepLinkUrl: callGetLastDeepLinkUrl,
        addLocalNotification: addLocalNotification,
        invokeYunXin: invokeYunXin,
        goToProductDetail: goToProductDetail,
        goToRushProductDetail: goToRushProductDetail,
        goToFamousBrandProductDetail:goToFamousBrandProductDetail,
        goToTreatyProductDetail:goToTreatyProductDetail,
        goToGroupProductDetail: goToGroupProductDetail,
        goToJuhuiProductDetail: goToJuhuiProductDetail,
        goBackFreeNessPay: goBackFreeNessPay,
        closeWapPage: closeWapPage,
        getClientInfo: getClientInfo,
        getIdentifier:getIdentifier,
        changeCity: changeCity,
        changeCityByLes: changeCityByLes,
        getCityInfo:getCityInfo,
        gotoCustom:gotoCustom,
        gotoB2CShop:gotoB2CShop,
        gotoCPA:gotoCPA,
        gotoActive:gotoActive,
        goToSearchResultWithKeyword: goToSearchResultWithKeyword,
        pushToNextPage: pushToNextPage,
        routeToClientPage: routeToClientPage,
        showAlert: showAlert,
        showTip: showTip,
        updateTitle:updateTitle,
        showRightButtons: showRightButtons,
        addProductToShopCart: addProductToShopCart,
        addNewProductToShopCart: addNewProductToShopCart,
        addSpecailProductToShopCart: addSpecailProductToShopCart,
        setBarColor: setBarColor,
        openLinkInSafari: openLinkInSafari,
        openPhoneSettings: openPhoneSettings,
        gotoHomePage:gotoHomePage,
        openBestieFileChooser:openBestieFileChooser,
        setSATitle: setSATitle,
        openImageChooser:openImageChooser,
        getGeoPosition: getGeoPosition,
        getLesPosition: getLesPosition,
        preparePayWithSDK: preparePayWithSDK,
        setTempCartId: setTempCartId,
        gotoCloudCart2: gotoCloudCart2,
        gotoCloudCart2V2: gotoCloudCart2V2,
        getLocatedAddressInfo: getLocatedAddressInfo,
        coffeePayWithSDK: coffeePayWithSDK,
        gotoScan:gotoScan,
        selectAddress:selectAddress,
        uploadMultiplePictures:uploadMultiplePictures,
        enableLoading:enableLoading,
        payWithOrderInfo:payWithOrderInfo,
        appNotificationStatus:appNotificationStatus,
        addressBook:addressBook,
        setNavigationHiden:setNavigationHiden,
        useShake:useShake,
        gotoNativeReturn:gotoNativeReturn,
        addDesktopShortcut:addDesktopShortcut,
        enablePullRefresh:enablePullRefresh,
        documentNavStyle:documentNavStyle,
        gotoCustomizedCloudCart2:gotoCustomizedCloudCart2,
        takePhoto:takePhoto,
        httpGet:httpGet,
        getNetworkInfo:getNetworkInfo,
        commonPayWithSDK:commonPayWithSDK,
        payWithJsonStr:payWithJsonStr,
        jumpToOrderCenter:jumpToOrderCenter,
        setSNSATitle:setSNSATitle,
        getCityCode:getCityCode,
        getSearchFunInfo:getSearchFunInfo,
        saveImage:saveImage,
        addEKEvent:addEKEvent,
        gotoRegist:gotoRegist,
        couponMD5Encrypt:couponMD5Encrypt,
        getUserLevel:getUserLevel,
        getMemberInfo:getMemberInfo,
        setPageTitle:setPageTitle,
        setNewPageTitle:setNewPageTitle,
        callCustomBlock:callCustomBlock,
        setClickId:setClickId,
        getDeviceToken:getDeviceToken,
        getHumanMachine:getHumanMachine,
        saveCipher: saveCipher,
        sellSourceForH5:sellSourceForH5,
        neesWebViewScreenRotation:neesWebViewScreenRotation,
        SNGetCameraPermission:SNGetCameraPermission,
        SNCallRealName:SNCallRealName,
        SNAdvancedAuth:SNAdvancedAuth,
        SNFaceIdcheck:SNFaceIdcheck,
        SNOpenNetNotificationCenter:SNOpenNetNotificationCenter,
        takeScreenshotShare:takeScreenshotShare,
        callMediaShare:callMediaShare,
        callMediaShareCircle:callMediaShareCircle,
        goPinGouShareVC:goPinGouShareVC,
        showRightShopCarBtn:showRightShopCarBtn,
        showPushAlertView:showPushAlertView,
        getContactInfo:getContactInfo,
        goToScanBarCode:goToScanBarCode,
        backToHomeA:backToHomeA,
        aliPayWithOrderInfo:aliPayWithOrderInfo,
        wxPayWithOrderInfo:wxPayWithOrderInfo,
        showRightShareBtn:showRightShareBtn,
        selectCircleRange:selectCircleRange,
        wxPayWap:wxPayWap
    };

	messagingIframe = document.createElement('iframe');
	messagingIframe.style.display = 'none';
	messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;
	document.documentElement.appendChild(messagingIframe);

	registerHandler("_disableJavascriptAlertBoxSafetyTimeout", disableJavscriptAlertBoxSafetyTimeout);
        
    function setupWebViewJavascriptBridge() {
        var WVJBIframe = document.createElement('iframe');
        WVJBIframe.style.display = 'none';
        WVJBIframe.src = 'suningwvjbscheme://__BRIDGE_LOADED__';
        document.documentElement.appendChild(WVJBIframe);
        setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
    }

    setupWebViewJavascriptBridge();
    var doc = document;
    var readyEvent = doc.createEvent('Events');
    readyEvent.initEvent('SNNativeClientReady');
    readyEvent.bridge = SNNativeClient;
    doc.dispatchEvent(readyEvent);
    SNNativeClient.init();
})();
	); // END preprocessorJSCode

	#undef __wvjb_js_func__
	return preprocessorJSCode;
};
