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

import "js/Settings.js" as Settings

import com.sunrain.sinaweibo 1.0

ApplicationWindow
{
    initialPage: /*Qt.resolvedUrl("pages/FirstPage.qml")*/Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

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
                // bottomMargin: Theme.paddingMedium
                //verticalCenter: parent.verticalCenter
            }

            spacing: Theme.paddingMedium

            move: Transition { NumberAnimation { properties: "y" } }
        }
    }

    Item{
        id:busyIndicatorItem
        width: Screen.width
        height:Screen.height
        z: 10
        BusyIndicator {
            id:busyIndicator
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
        }
    }
    function showBusyIndicator() {
        busyIndicator.running = true;
    }
    function stopBusyIndicator() {
        busyIndicator.running = false;
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
    
    //////////////////////////////////////////////////////////////////         go to weibo page
    function toWeiboPage(model, index) {
        //console.log("toWeiboPage  index " + index + " model " + model);
        popAttachedPages();
        pageStack.push(Qt.resolvedUrl("ui/WeiboPage.qml"),
                        {"weiboModel":model,
                           "newIndex":index})
    }
    
    //////////////////////////////////////////////////////////////////         go to send page
    function toSendPage(mode, info) {
        //sendPage.setMode(mode, info)
        //mainStack.push(sendPage)
        popAttachedPages();
        pageStack.push(Qt.resolvedUrl("ui/SendPage.qml"),
                        {"mode":mode,
                           "info":info})
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


