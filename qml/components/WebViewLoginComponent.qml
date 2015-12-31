import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/AutheticatorToken.js" as AutheticatorUrl

SilicaWebView {
    id:webViewLoginComponent
    signal loginSucceed()

    anchors.fill: parent
    url: AutheticatorUrl.getWeicoAuthorizeUrl()

    Component.onCompleted: {
        console.log("==== url is " + AutheticatorUrl.getWeicoAuthorizeUrl());
    }

    onLoadingChanged: {
        webViewLoginComponent.focus = true;
        console.log("=== onLoadingChanged " + loadRequest.status);
        console.log("=== onLoadingChanged  ret " + loadRequest.url);

        if (util.parseOauthTokenUrl(loadRequest.url)) {
//            api.accessToken = weiboSettings.accessToken;
//            api.uid = weiboSettings.uid;
            console.log("=== parseOauthTokenUrl ok");
            loginSucceed();
        }
//        switch (loadRequest.status)
//        {
//        case webViewLoginComponent.LoadSucceededStatus:
////            opacity = 1
//            var ret = loadRequest.url + ""
//            console.log("===== " + ret);
////            var temp = url.split("code=")
////            if (temp[0].indexOf("https://api.weibo.com/oauth2/default.html") == 0) {
////                console.log("final code: ", temp[1])
////                loginComponent.loginSucceed(temp[1]);
////            }
//            break
//        case webViewLoginComponent.LoadFailedStatus:
//            console.log(" onLoadingChanged LoadFailedStatus" + loadRequest.status);
////            opacity = 0
////            loginComponent.loginFailed(errorString);
//            break
//        default:
////            opacity = 0
////            loginComponent.loginFailed("");
//            break
//        }
    }

//    property alias menus: viewPullDownMenu._content
//    //property alias header: webView.header
//    property alias placeholderText: viewPlaceHolder.text
//    property alias placeholderHintText: viewPlaceHolder.hintText

//    signal loginSucceed(var code)
//    signal loginFailed(var code)

//    function loadLoginView() {
//        webView.url = "https://open.weibo.cn/oauth2/authorize?client_id=" + appData.key + "&redirect_uri=https://api.weibo.com/oauth2/default.html&display=mobile&response_type=code"
//    }

//    function refreshLoginView() {
//        webView.reload()
//    }

//    SilicaFlickable {
//        id:flickable

//        anchors.fill: parent

//        PullDownMenu {
//            id:viewPullDownMenu
//        }
//        contentHeight: column.height

//        Column {
//            id:column
//            spacing: Theme.paddingMedium

//            Label {
//                id:infoLabel
//                anchors {
//                    left: parent.left
//                    leftMargin: Theme.paddingLarge
//                    right: parent.right
//                    rightMargin: Theme.paddingLarge
//                }

//                color: Theme.highlightColor
//                width: loginComponent.width
//                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

//                font.pixelSize: Theme.fontSizeMedium
//                text: webView.opacity === 1 ? qsTr("click the enter key if the webview login icon not work") : ""
//            }

//            SilicaWebView {
//                id: webView
//                width:loginComponent.width
//                height: loginComponent.height - Theme.paddingMedium -infoLabel.height

//                opacity: 0
//                onLoadingChanged: {
//                    webView.focus = true;
//                    switch (loadRequest.status)
//                    {
//                    case WebView.LoadSucceededStatus:
//                        opacity = 1
//                        var url = loadRequest.url + ""
//                        var temp = url.split("code=")
//                        if (temp[0].indexOf("https://api.weibo.com/oauth2/default.html") == 0) {
//                            console.log("final code: ", temp[1])
//                            loginComponent.loginSucceed(temp[1]);
//                        }
//                        break
//                    case WebView.LoadFailedStatus:
//                        console.log(" onLoadingChanged LoadFailedStatus" + loadRequest.status);
//                        opacity = 0
//                        loginComponent.loginFailed(errorString);
//                        break
//                    default:
//                        opacity = 0
//                        loginComponent.loginFailed("");
//                        break
//                    }
//                }

//                FadeAnimation on opacity {}
//            }
//        }

//        ViewPlaceholder {
//            id: viewPlaceHolder
//            enabled: webView.opacity === 0 && !webView.loading
//        }
//    }
}

