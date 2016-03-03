import QtQuick 2.0
import Sailfish.Silica 1.0

//import "./WeiboFunctions.js" as Func

QtObject {
    id: wbFunctions
    objectName: "WeiboFunctions"

    function showBusyIndicator() {
        busyIndicatorTimeout.restart();
        busyIndicator.runningBusyIndicator = true
    }

    function stopBusyIndicator() {
        busyIndicatorTimeout.stop();
        busyIndicator.runningBusyIndicator = false
    }

    function addNotification(inText, inTime) {
        var text = inText == undefined ? "" : inText
        var time = inTime == undefined ? 3 : inTime
        var noti = Qt.createComponent("components/Notification.qml")
        if (noti.status == Component.Ready) {
            var notiItem = noti.createObject(notificationBar, { "text": text, "time": time })
        }
    }

    function popAttachedPages() {
        // find the first page
        var firstPage = pageStack.previousPage();
        if (!firstPage) {
            return;
        }
        while (pageStack.previousPage(firstPage)) {
            firstPage = pageStack.previousPage(firstPage);
        }
        // pop to first page
        pageStack.pop(firstPage);
    }
    ///////////// 登陆页面
    function toLoginPage() {
        console.log("===== toLoginPage ===== ")
        popAttachedPages();
        pageStack.replace(loginPageComponent);
    }

    ///////////// 主页（微博列表显示页面）
    function toIndexPage() {
        popAttachedPages();
        console.log("===== toIndexPage ===== ")
        pageStack.replace(indexPageComponent)
    }

    function weiboLogout() {
        tokenProvider.accessToken = "";
        tokenProvider.uid = "";
        toLoginPage();
    }

    function toCommentAllPage() {
        popAttachedPages();
        pageStack.replace(commentAllComponent);
    }

    function toCommentMentionedPage() {
        popAttachedPages();
        pageStack.replace(commentMentionedComponent);
    }

    function toWeiboMentionedPage() {
        popAttachedPages();
        pageStack.replace(weiboMentionedComponent);
    }

    function toFavoritesPage() {
        pageStack.push(weiboFavoritesComponent);
    }

    //////////////////////////////////////////////////////////////////         go to weibo page
    function toWeiboPage(jsonContent) {
        //console.log("toWeiboPage  index " + index + " model " + model);
        var content = jsonContent;
//        popAttachedPages();
        pageStack.push(Qt.resolvedUrl("pages/WeiboPage.qml"),
                        {"userWeiboJSONContent":content})
    }

    //////////////////////////////////////////////////////////////////         go to send page
    function toSendPage(mode, userInfo, placeHoldText, shouldPopAttachedPages) {
        var m = mode;
        var info = userInfo;
        var pht = placeHoldText;
        pageStack.push(Qt.resolvedUrl("pages/SendPage.qml"),
                        {"mode":m,
                           "placeHoldText":pht,
                           "userInfo":info})
    }

    function toUserPage(uid, uname) {
        pageStack.push(Qt.resolvedUrl("pages/UserPage.qml"), { "uid":uid, "uname":uname })
    }

    function toFriendsPage(mode, uid) {
        pageStack.push(Qt.resolvedUrl("pages/FriendsPage.qml"), { "mode": mode, "uid": uid })
    }

    function toUserWeibo(uid, name) {
        pageStack.push(Qt.resolvedUrl("ui/UserWeibo.qml"), { "uid": uid, "userName": name })
        //mainStack.currentPage.refresh()
    }

    function toGalleryPage(model, index) {
        pageStack.push(Qt.resolvedUrl("pages/Gallery.qml"), { "modelGallery": model, "index": index })
    }

    function toSettingsPage() {
        pageStack.push(Qt.resolvedUrl("pages/AboutPage.qml"));
    }

    function toDummyDialog() {
        pageStack.push(Qt.resolvedUrl("pages/Dummy.qml"));
    }
}
