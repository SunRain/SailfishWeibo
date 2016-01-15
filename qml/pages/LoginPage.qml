import QtQuick 2.0
import Sailfish.Silica 1.0
import QtWebKit 3.0
import QtWebKit.experimental 1.0

import "../components"
import "../js/AutheticatorToken.js" as AutheticatorUrl
Page {
    id: loginPage

    signal logined

    property var _warning_url: util.pathTo("qml/warning.html")

    SilicaWebView {
        id: webView
        anchors.fill: parent
        PullDownMenu {
            id: pdMenu
            MenuItem {
                id: manualBtn
                text: qsTr("Manual Autheticator")
                onClicked: {
                    webView.url = AutheticatorUrl.getWeicoAuthorizeUrl();
                }
            }
            MenuItem {
                text: qsTr("User Password Autheticator")
                onClicked: {
			pageStack.replace(Qt.resolvedUrl("file:///usr/share/harbour-sailfish_sinaweibo/qml/pages/LoginComponent.qml"));
                }
            }
            MenuItem {
                text: qsTr("Help")
                onClicked: {
                    webView.url = loginPage._warning_url
                }
            }
        }
        header: PageHeader {
            title: qsTr("Login Autheticator")
        }
        url: loginPage._warning_url

        onLoadingChanged: {
            if (loadRequest.status == WebView.LoadStartedStatus
                    && webView.url != loginPage._warning_url) {
                pdMenu.busy = true;
            }
            if ((loadRequest.status == WebView.LoadSucceededStatus
                 ||loadRequest.status == WebView.LoadFailedStatus)
                    && webView.url != loginPage._warning_url) {
                pdMenu.busy = false;
            }
            if (util.parseOauthTokenUrl(loadRequest.url)) {
                console.log("=== parseOauthTokenUrl ok");
                logined();
            }
        }
    }
}
