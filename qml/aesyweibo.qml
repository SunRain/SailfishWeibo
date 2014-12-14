import QtQuick 2.0
//import Ubuntu.Components 0.1
//import Ubuntu.Components.Popups 0.1
//import aesyweibo 1.0
import "ui"
import "components"
import "js"

/*!
    \brief MainView with Tabs element.
           First Tab has a single Label and
           second Tab has a single ToolbarAction.
*/

MainView {
    id: mainView
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "com.ubuntu.developer.qqworini.aesyweibo"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    width: units.gu(50)
    height: units.gu(84)

    headerColor: "#68B7DE"
    backgroundColor: "#ADD5EF"
    footerColor: "#BDE0F4"

    Component.onCompleted: {
//        addNotification("config writable path: " + appData.path, 99)
//        addNotification("img writable path: " + networkHelper.imgFolder, 99)
//        addNotification("is arm? " + appData.isARM, 99)
        console.log("is arm? ", appData.isARM)
        reset()
    }

    function reset() {
        if (settings.getAccess_token() == "") {
            startLogin()
        }
        else {
            weiboApiHandler.checkToken(settings.getAccess_token())
        }
    }

    //////////////////////////////////////////////////////////////////         main PageStack
    PageStack {
        id: mainStack
        anchors.fill: parent

        Component.onCompleted: {
            push(tabsWeibo)
        }

        onCurrentPageChanged: {
            if (currentPage != null) {
                // TODO: do sth when page changed
//                if (currentPage.reloadPageContent)
//                    currentPage.reloadPageContent()
            }
        }

        Tabs {
            id: tabsWeibo
            visible: false
            anchors.fill: parent

            WeiboTab {
                id: weiboTab
                onSendNewWeibo: { toSendPage("", {}) }
            }

            MessageTab {
                id: messageTab
            }

            UserTab {
                id: userTab
            }

            SettingTab {
                id: settingTab
            }
        }

        SendPage {
            id: sendPage
            visible: false
        }

        WeiboPage {
            id: weiboPage
            visible: false
        }

        Gallery {
            id: galleryPage
            visible: false
        }

        FriendsPage {
            id: friendsPage
            visible: false
        }
    }

    //////////////////////////////////////////////////////////////////         functions for weiboTab
    function refreshHome(result) {
        weiboTab.refresh(result)
    }

    //////////////////////////////////////////////////////////////////         go to weibo page
    function toWeiboPage(model, index) {
        weiboPage.setFeed(model, index)
        mainStack.push(weiboPage)
    }

    //////////////////////////////////////////////////////////////////         go to gallery page
    function toGalleryPage(model, index) {
        galleryPage.setModel(model, index)
        mainStack.push(galleryPage)
    }

    //////////////////////////////////////////////////////////////////         go to send page
    function toSendPage(mode, info) {
        sendPage.setMode(mode, info)
        mainStack.push(sendPage)
    }

    //////////////////////////////////////////////////////////////////         go to friends page
    function toFriendsPage(mode, uid) {
//        friendsPage.setMode(mode, uid)
//        mainStack.push(friendsPage)
        mainStack.push(Qt.resolvedUrl("./ui/FriendsPage.qml"), { mode: mode, uid: uid })
    }

    //////////////////////////////////////////////////////////////////         go to personal info page
    function toUserPage(uid) {
        mainStack.push(Qt.resolvedUrl("./ui/UserPage.qml"), { uid: uid, title: i18n.tr("About user") })
        mainStack.currentPage.userGetInfo(settings.getAccess_token())
    }

    //////////////////////////////////////////////////////////////////         go to personal weibo page
    function toUserWeibo(uid, name) {
        mainStack.push(Qt.resolvedUrl("./ui/UserWeibo.qml"), { uid: uid, userName: name })
        mainStack.currentPage.refresh()
    }

    //////////////////////////////////////////////////////////////////         go to personal photo page
    function toUserPhoto(uid) {
        mainStack.push(Qt.resolvedUrl("./ui/UserPhoto.qml"), { uid: uid })
        mainStack.currentPage.refresh()
    }

    //////////////////////////////////////////////////////////////////         notificationBar
    Column {
        id: notificationBar
        anchors {
            fill: parent
            topMargin: units.gu(10); leftMargin: parent.width / 2; rightMargin: units.gu(2); bottomMargin: units.gu(2)
        }
        z: 9999
        spacing: units.gu(1)

        move: Transition { UbuntuNumberAnimation { properties: "y" } }
    }

    // pls use this function to add notification: mainView.addNotification(string, int)
    function addNotification(inText, inTime) {
        var text = inText == undefined ? "" : inText
        var time = inTime == undefined ? 3 : inTime
        var noti = Qt.createComponent("./components/Notification.qml")
        var notiItem = noti.createObject(notificationBar, { "text": text, "time": time })
    }

    //////////////////////////////////////////////////////////////////         Login webview
    function startLogin() {
        PopupUtils.open(loginSheet)
    }

    LoginSheet {
        id: loginSheet
    }

    //////////////////////////////////////////////////////////////////         api handlers
    function getAccessCode(code) {
        weiboApiHandler.login(appData.key, appData.secret, code)
    }

    MyType {
        id: appData
    }

    WeiboApiHandler {
        id: weiboApiHandler

        function initialData() {
            addNotification(i18n.tr("Welcome"), 3)
            weiboTab.refresh()
            messageTab.refresh()
            userTab.getInfo()
            tabsWeibo.selectedTabIndex = 0
        }

        onLogined: {
//            weiboTab.refresh()
            initialData()
        }

        onTokenExpired: {
            if (isExpired) {
                startLogin()
            }
            else {
//                weiboTab.refresh()
                initialData()
            }
        }

        onSendedWeibo: { mainStack.pop() }
    }

    //////////////////////////////////////////////////////////////////         settings
    Settings {
        id: settings
    }

    //////////////////////////////////////////////////////////////////         settings
    NetworkHelper {
        id: networkHelper
    }
}
