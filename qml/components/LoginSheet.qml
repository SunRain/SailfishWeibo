import QtQuick 2.0
import QtWebKit 3.0
import Sailfish.Silica 1.0

/*Component*/Item {
    id: loginSheet
    width: parent.width
    height: parent.height
    
    SilicaFlickable {
        anchors.fill: parent
        
        contentHeight: Screen.height
        contentWidth: Screen.width
        
        SilicaWebView {
            id: webView
            
            Component.onCompleted:{
                console.log("---- loginSheet webView onCompleted");
            }
            
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: navigationColumn.top
            }
            
            opacity: 0
            onLoadingChanged: {
                switch (loadRequest.status)
                {
                case WebView.LoadSucceededStatus:
                    opacity = 1
                    break
                case WebView.LoadFailedStatus:
                    opacity = 0
                    viewPlaceHolder.errorString = loadRequest.errorString
                    break
                default:
                    opacity = 0
                    break
                }
                
                console.log("==== loginSheet url: ", loadRequest.url)
                var url = loadRequest.url + ""
                var temp = url.split("code=")
                if (temp[0].indexOf("https://api.weibo.com/oauth2/default.html") == 0) {
                    console.log("final code: ", temp[1])
                    getAccessCode(temp[1])
                    // PopupUtils.close(webviewSheet)
                    //pageStack.pop();
                }
            }
            
            FadeAnimation on opacity {}
            PullDownMenu {
                MenuItem {
                    text: "Reload"
                    onClicked: webView.reload()
                }
            }
        }
        
        ViewPlaceholder {
            id: viewPlaceHolder
            property string errorString
            
            enabled: webView.opacity === 0 && !webView.loading
            text: "Web content load error: " + errorString
            hintText: "Check network connectivity and pull down to reload"
        }
        
        Column {
            id: navigationColumn
            width: parent.width
            anchors.bottom: parent.bottom
            spacing: Theme.paddingSmall
            
            Label {
                x: Theme.paddingLarge
                width: parent.width - 2 * Theme.paddingLarge
                text: qsTr("About oauth2 info");
            }
            Button {
                text: qsTr("Click to oauth")
                enabled: true
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    webView.url = "https://open.weibo.cn/oauth2/authorize?client_id=" + appData.key + "&redirect_uri=https://api.weibo.com/oauth2/default.html&display=mobile&response_type=code"
                }
            }
        }
    }
}

