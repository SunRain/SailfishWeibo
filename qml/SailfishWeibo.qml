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

import "js/Settings.js" as Settings

import com.sunrain.sinaweibo 1.0

ApplicationWindow
{
    id:applicationWindow
    allowedOrientations: Orientation.Portrait
    property Page currentPage: pageStack.currentPage

    property bool tokenValid: false
    property bool reminderRefreshed: false
//    property /*Dialog*/var _loginDialog

    //cover: Qt.resolvedUrl("cover/CoverPage.qml")
    initialPage: Component {
        id: indexPageComponent
        FirstPage {
            id: indexPage
            property bool withPanelView: true
            property bool _settingsInitialized: false
            property bool _dataInitialized: false
            Binding {
                target: indexPage.contentItem
                property: "parent"
                value: indexPage.status === PageStatus.Active
                       ? (panelView .closed ? panelView : indexPage)
                       : indexPage
            }
            Component.onCompleted: {
                if (!_settingsInitialized) {
                    Settings.initialize();
                    _settingsInitialized = true;
                }
            }
            onStatusChanged: {
//                if (indexPage.status === PageStatus.Activating) {
////                    if (!_settingsInitialized) {
////                        Settings.initialize();
////                        _settingsInitialized = true;
////                    }
////                    if (_firstUiLaunchTime) {
////                        reset();
////                        _firstUiLaunchTime = false;
////                    }
//                }
                if (indexPage.status === PageStatus.Active) {
                    if (!tokenValid) {
                        startLogin();
                    } else {
                        if (!_dataInitialized) {
                            indexPage.refresh();
                            panelView.initUserAvatar();
                            _dataInitialized = true;
                        }
                    }
                }
            }
        }
    }

    //Dirty hack
    //Use a Timer to fix Warning: cannot pop while transition is in progress
    function startLogin() {
        pageStack.completeAnimation();
        loginDelay.restart();
    }
    Timer {
        id: loginDelay
        interval: 500
        onTriggered: {
            _startLogin();
        }
    }

    function _startLogin() {
        var dialog = pageStack.push(Qt.resolvedUrl("ui/LoginDialog.qml"),{ token: Settings.getAccess_token()});
        dialog.accepted.connect(function() {
            tokenValid = true;

        })
        dialog.rejected.connect(function() {
            startLogin();
        })
    }

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

        leftPanel: NavigationPanel {
            id: leftPanel
            busy: false //panelView.closed /*&& !!BufferModel.connections && BufferModel.connections.some(function (c) { return c.active && !c.connected })*/
//            highlighted: MessageStorage.activeHighlights > 0
            onClicked: {
                panelView.hidePanel()
            }
            Component.onCompleted: {
                panelView.hidePanel();
            }
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
    
    function attachSecondPage() {
        if (pageStack.depth == 1) {
            pageStack.pushAttached("pages/SecondPage.qml");
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
    
    function toIndexPage() {
        popAttachedPages();
        pageStack.replace(indexPageComponent)
    }

    //////////////////////////////////////////////////////////////////         go to weibo page
    function toWeiboPage(jsonContent) {
        //console.log("toWeiboPage  index " + index + " model " + model);
        popAttachedPages();
        pageStack.push(Qt.resolvedUrl("ui/WeiboPage.qml"),
                        {"userWeiboJSONContent":jsonContent})
    }
    
    //////////////////////////////////////////////////////////////////         go to send page
    function toSendPage(mode, userInfo, placeHoldText, shouldPopAttachedPages) {
        //sendPage.setMode(mode, info)
        //mainStack.push(sendPage)
        if(shouldPopAttachedPages == true)
            popAttachedPages();

        pageStack.push(Qt.resolvedUrl("ui/SendPage.qml"),
                        {"mode":mode,
                           "placeHoldText":placeHoldText,
                           "userInfo":userInfo})
    }
    
    function toUserPage(uid) {
        pageStack.push(Qt.resolvedUrl("ui/UserPage.qml"), { uid: uid/*, title: qsTr("About user")*/ })
    }
    
    function toFriendsPage(mode, uid) {
        pageStack.push(Qt.resolvedUrl("ui/FriendsPage.qml"), { mode: mode, uid: uid })
    }
    
    function toUserWeibo(uid, name) {
        pageStack.push(Qt.resolvedUrl("ui/UserWeibo.qml"), { uid: uid, userName: name })
        //mainStack.currentPage.refresh()
    }
    
    function toGalleryPage(model, index) {
        pageStack.push(Qt.resolvedUrl("ui/Gallery.qml"), { "modelGallery": model, "index": index })
    }
    
    function weiboLogout() {
        Settings.setAccess_token("");
    }

    MyType {
        id: appData
    }
    
    WeiboApi {
        id:api
    }
}


