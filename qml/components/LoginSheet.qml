import QtQuick 2.0
import QtWebKit 3.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Component {
    id: loginSheet

    DefaultSheet {
        id: webviewSheet
        title: i18n.tr("Login")
        doneButton: false
        contentsHeight: parent.height

        onCloseClicked: { PopupUtils.close(webviewSheet) }

        WebView {
            id: web
            anchors.fill: parent

            Component.onCompleted: {
                url = "https://open.weibo.cn/oauth2/authorize?client_id=" + appData.key + "&redirect_uri=https://api.weibo.com/oauth2/default.html&display=mobile&response_type=code"
            }

            onLoadingChanged: {
                console.log("url: ", loadRequest.url)
                var url = loadRequest.url + ""
                var temp = url.split("code=")
                if (temp[0].indexOf("https://api.weibo.com/oauth2/default.html") == 0) {
                    console.log("final code: ", temp[1])
                    mainView.getAccessCode(temp[1])
                    PopupUtils.close(webviewSheet)
                }
            }
        }
    }
}
