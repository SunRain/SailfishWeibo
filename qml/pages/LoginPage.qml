import QtQuick 2.0
import Sailfish.Silica 1.0
import QtWebKit 3.0
import QtWebKit.experimental 1.0

import "../ui"
import "../js/AutheticatorToken.js" as AutheticatorUrl
Page {
    id: loginPage

    signal logined

//    property var _warning_url//: appUtility.pathTo("qml/warning.html")

//    onStatusChanged:  {
//        if (status == PageStatus.Active)
//            loginPage._warning_url = appUtility.pathTo("qml/warning.html");
//    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: parent.height
        contentWidth: parent.width
        Loader {
            id: loader
            anchors.fill: parent
            sourceComponent: helpView
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("Login")
                onClicked: {
                    loader.sourceComponent = loginComponent;
                }
            }
            MenuItem {
                text: qsTr("Help")
                onClicked: {
                    loader.sourceComponent = helpView;
                }
            }
        }
    }

    Component {
        id: loginComponent
        LoginComponent {
            onLoginSucceed: {
                loginPage.logined()
            }
        }
    }

    Component {
        id: helpView
        SilicaWebView {
            id: webView
            anchors.fill: parent
//            PullDownMenu {
//                id: pdMenu
//                MenuItem {
//                    id: manualBtn
//                    text: qsTr("Manual Autheticator")
//                    onClicked: {
//                        console.log("=== to url ", AutheticatorUrl.getWeicoAuthorizeUrl());
//                        webView.url = AutheticatorUrl.getWeicoAuthorizeUrl();
//                    }
//                }
//                MenuItem {
//                    text: qsTr("User Password Autheticator")
//                    onClicked: {
//                        pageStack.replace(Qt.resolvedUrl("file:///usr/share/harbour-sailfish_sinaweibo/qml/pages/LoginComponent.qml"));
//                    }
//                }
//                MenuItem {
//                    text: qsTr("Help")
//                    onClicked: {
//                        webView.url = loginPage._warning_url
//                    }
//                }
//            }
            header: PageHeader {
                title: qsTr("Help")
            }
            ScrollDecorator{}
            url: appUtility.pathTo("qml/warning.html")//loginPage._warning_url
//            onLoadingChanged: {
//                if (loadRequest.status == WebView.LoadStartedStatus
//                        && webView.url != loginPage._warning_url) {
//                    pdMenu.busy = true;
//                }
//                if ((loadRequest.status == WebView.LoadSucceededStatus
//                     ||loadRequest.status == WebView.LoadFailedStatus)
//                        && webView.url != loginPage._warning_url) {
//                    pdMenu.busy = false;
//                }
//                if (appUtility.parseOauthTokenUrl(loadRequest.url)) {
//                    console.log("=== parseOauthTokenUrl ok");
//                    logined();
//                }
//            }
        }
    }
}
