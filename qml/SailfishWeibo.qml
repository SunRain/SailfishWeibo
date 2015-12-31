/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.
  
  You may use this file under the terms of BSD license as follows:
  
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.
      
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR 
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "components"
import "ui"

//import "js/Settings.js" as Settings

import harbour.sailfish_sinaweibo.sunrain 1.0

ApplicationWindow
{
    id:applicationWindow
    allowedOrientations: Orientation.Portrait
    property Page currentPage: pageStack.currentPage

    property bool tokenValid: false
    property bool reminderRefreshed: false

    initialPage: Component {
        SplashesPage { //SplashesPage，同时用于初始化数据库和检测token值
            id: splashes
//            property bool _settingsInitialized: false
            property int _delayType: -1; // 0 ==> start login page
                                        // 1 ==> start index page
            onStatusChanged: {
                if (splashes.status === PageStatus.Active) {
//                    if (!_settingsInitialized) {
//                        Settings.initialize();
//                        _settingsInitialized = true;
//                    }
                    var token = tokenProvider.accessToken;

                    console.log("===== main view token is " + token);
                    if (token == "" || token == undefined) {
                        _delayType = 0;
                        delay.restart();
                    } else {
//                        api.checkToken(token);
                        tokenProvider.checkToken(token);
                    }
                }
            }
            Timer {
                id: delay
                interval: 1000
                onTriggered: {
                    if (splashes._delayType == 0) {
                        toLoginPage();
                    }
                    if (splashes._delayType == 1) {
                        toIndexPage();
                    }
                }
            }
            Connections {
                target: tokenProvider
                onTokenExpired: {
                    if (!tokenExpired) {
                        console.log("==== !tokenExpired")
//                        api.accessToken = settings.accessToken;//Settings.getAccess_token();
//                        api.uid = settings.uid//Settings.getUid();
                        _delayType = 1;
                        delay.restart();
                    } else {
                        _delayType = 0;
                        delay.restart()
                    }
                }
            }
        }
    }

    //主页微博列表显示
    Component {
        id: indexPageComponent
        FirstPage {
            id: indexPage
//            property bool _settingsInitialized: false
            property bool _dataInitialized: false
            property bool withPanelView: true
            Binding {
                target: indexPage.contentItem
                property: "parent"
                value: indexPage.status === PageStatus.Active
                       ? (panelView .closed ? panelView : indexPage) //修正listview焦点
                       : indexPage
            }
//            Component.onCompleted: {
//                if (!_settingsInitialized) {
//                    Settings.initialize();
//                    _settingsInitialized = true;
//                }
//            }
            onStatusChanged: {
                if (indexPage.status === PageStatus.Active) {
//                    if (!tokenValid) {
//                        startLogin();
//                    } else {
                        if (!_dataInitialized) {
                            indexPage.refresh();
                            panelView.initUserAvatar();
                            panelView.initRemind();
                            _dataInitialized = true;
//                        }
                    }
                }
            }
        }
    }

//    //Dirty hack
//    //Use a Timer to fix Warning: cannot pop while transition is in progress
//    function startLogin() {
//        pageStack.completeAnimation();
//        loginDelay.restart();
//    }
//    Timer {
//        id: loginDelay
//        interval: 500
//        onTriggered: {
//            _startLogin();
//        }
//    }

//    function _startLogin() {
//        var dialog = pageStack.push(Qt.resolvedUrl("ui/LoginDialog.qml"),{ token: Settings.getAccess_token()});
//        dialog.accepted.connect(function() {
//            tokenValid = true;

//        })
//        dialog.rejected.connect(function() {
//            startLogin();
//        })
//    }

    Item{
        id:notiItem
        width: parent.width
        height:Screen.height/5
        z: 20
        Column {
            id: notificationBar
            anchors {
                top:parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins:Theme.paddingMedium
            }
            spacing: Theme.paddingMedium
            move: Transition { NumberAnimation { properties: "y" } }
        }
    }

    BusyIndicator {
        id:busyIndicator
        property bool runningBusyIndicator: false

        parent: applicationWindow.currentPage
        anchors.centerIn: parent
        z: 10
        size: BusyIndicatorSize.Large
        running: runningBusyIndicator
        opacity: busyIndicator.running ? 1: 0
    }

    PanelView {
        id: panelView
        // a workaround to avoid TextAutoScroller picking up PanelView as an "outer"
        // flickable and doing undesired contentX adjustments (the right side panel
        // slides partially in) meanwhile typing/scrolling long TextEntry content
        property bool maximumFlickVelocity: false

        width: pageStack.currentPage.width
        panelWidth: Screen.width / 3 * 2
        panelHeight: pageStack.currentPage.height
        height: currentPage && currentPage.contentHeight || pageStack.currentPage.height
        visible:  (!!currentPage && !!currentPage.withPanelView) || !panelView.closed
        anchors.centerIn: parent
        //anchors.verticalCenterOffset:  -(panelHeight - height) / 2

        anchors.horizontalCenterOffset:  0

        Connections {
            target: pageStack
            onCurrentPageChanged: panelView.hidePanel()
        }

        function initUserAvatar() {
            leftPanel.initUserAvatar();
        }
        function initRemind() {
            leftPanel.messageGetRemind();
        }

        leftPanel: NavigationPanel {
            id: leftPanel
            busy: false //panelView.closed /*&& !!BufferModel.connections && BufferModel.connections.some(function (c) { return c.active && !c.connected })*/
//            highlighted: MessageStorage.activeHighlights > 0
            onClicked: {
                panelView.hidePanel();
            }
            onUserAvatarClicked: {
                toUserPage(settings.uid/*Settings.getUid()*/);
            }

            Component.onCompleted: {
                panelView.hidePanel();
            }
        }
    }

    Component {
        id: commentAllComponent
        CommentAllPage {
            id: commentAllPage
            property bool withPanelView: true
            property bool _refreshed: false
            Binding {
                target: commentAllPage.contentItem
                property: "parent"
                value: commentAllPage.status === PageStatus.Active
                       ? (panelView .closed ? panelView : commentAllPage)
                       : commentAllPage
            }
            onStatusChanged: {
                if (commentAllPage.status == PageStatus.Active) {
                    if (!commentAllPage._refreshed) {
                        commentAllPage.refresh();
                        commentAllPage._refreshed = true;
                    }
                }
            }
        }
    }

    Component {
        id: commentMentionedComponent
        CommentMentioned {
            id: commentMentionedPage
            property bool withPanelView: true
            property bool _refreshed: false
            Binding {
                target: commentMentionedPage.contentItem
                property: "parent"
                value: commentMentionedPage.status === PageStatus.Active
                       ? (panelView .closed ? panelView : commentMentionedPage)
                       : commentMentionedPage
            }
            onStatusChanged: {
                if (commentMentionedPage.status == PageStatus.Active) {
                    if (!commentMentionedPage._refreshed) {
                        commentMentionedPage.refresh();
                        commentMentionedPage._refreshed = true;
                    }
                }
            }
        }
    }

    Component {
        id: weiboMentionedComponent
        WeiboMentioned {
            id: weiboMentionedPage
            property bool withPanelView: true
            property bool _refreshed: false
            Binding {
                target: weiboMentionedPage.contentItem
                property: "parent"
                value: weiboMentionedPage.status === PageStatus.Active
                       ? (panelView .closed ? panelView : weiboMentionedPage)
                       : weiboMentionedPage
            }
            onStatusChanged: {
                if (weiboMentionedPage.status == PageStatus.Active) {
                    if (!weiboMentionedPage._refreshed) {
                        weiboMentionedPage.refresh();
                        weiboMentionedPage._refreshed = true;
                    }
                }
            }
        }
    }

    Component {
        id: weiboFavoritesComponent
        WeiboFavorites {
            id: weiboFavoritesPage
            property bool withPanelView: true
            property bool _refreshed: false
            Binding {
                target: weiboFavoritesPage.contentItem
                property: "parent"
                value: weiboFavoritesPage.status === PageStatus.Active
                       ? (panelView .closed ? panelView : weiboFavoritesPage)
                       : weiboFavoritesPage
            }
            onStatusChanged: {
                if (weiboFavoritesPage.status == PageStatus.Active) {
                    if (!weiboFavoritesPage._refreshed) {
                        weiboFavoritesPage.refresh();
                        weiboFavoritesPage._refreshed = true;
                    }
                }
            }
        }
    }

    Component {
        id: loginPageComponent
        LoginPage {
            onLogined: {toIndexPage();}
        }
    }

    function showBusyIndicator() {
        busyIndicator.runningBusyIndicator = true
    }
    function stopBusyIndicator() {
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
    
//    function attachSecondPage() {
//        if (pageStack.depth == 1) {
//            pageStack.pushAttached("pages/SecondPage.qml");
//        }
//    }

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
        popAttachedPages();
        pageStack.replace(loginPageComponent);
    }
    
    ///////////// 主页（微博列表显示页面）
    function toIndexPage() {
        popAttachedPages();
        pageStack.replace(indexPageComponent)
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
        //sendPage.setMode(mode, info)
        //mainStack.push(sendPage)
        var m = mode;
        var info = userInfo;
        var pht = placeHoldText;

//        if(shouldPopAttachedPages)
//            popAttachedPages();

        pageStack.push(Qt.resolvedUrl("pages/SendPage.qml"),
                        {"mode":m,
                           "placeHoldText":pht,
                           "userInfo":info})
    }
    
    function toUserPage(uid) {
        pageStack.push(Qt.resolvedUrl("pages/UserPage.qml"), { "uid": uid/*, title: qsTr("About user")*/ })
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
    
//    function toFriendsPage(model, uid) {
//        pageStack.push(Qt.resolvedUrl("pages/FriendsPage.qml"), { "mode": model, "uid": uid })
//    }

    function weiboLogout() {
//        Settings.setAccess_token("");
        settings.accessToken = "";
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

    function toSettingsPage() {
        pageStack.push(Qt.resolvedUrl("pages/AboutPage.qml"));
    }

    function toFavoritesPage() {
        pageStack.push(weiboFavoritesComponent);
    }

    function toDummyDialog() {
        pageStack.push(Qt.resolvedUrl("pages/Dummy.qml"));
    }

    MyType {
        id: appData
    }
    
//    WeiboApi {
//        id:api
//    }
}


