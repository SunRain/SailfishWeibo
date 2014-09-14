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
import QtWebKit 3.0
import Sailfish.Silica 1.0

import com.sunrain.sinaweibo 1.0

//import "../js/Settings.js" as settings

import "../ui"
import "../components"
import "../js"
import "../js/Settings.js" as Settings


Page {
    id: mainView
    
    property bool settingsInitialized: false
    property bool firstUiLaunchTime: true
    property int runningBusyIndicator: 1
    
    Loader{
        id:loader
        anchors.fill: parent
    }
    
    onStatusChanged: {
        if (mainView.status === PageStatus.Active) {
            console.log("=== PageStatus.Active");
            
            if (!settingsInitialized) {
                Settings.initialize();
                settingsInitialized = true;
            }
            if (firstUiLaunchTime) {
                reset();
                firstUiLaunchTime = false;
            }
            
            console.log("====================== page depth is "+ pageStack.depth);
           // loader.sourceComponent = mainComponent;
        }
    }
    
    //FIXME:这个column是起什么作用？
//    Column {
//        id: notificationBar
//        anchors {
//            fill: parent
//            topMargin: 10//units.gu(10)
//            leftMargin: parent.width / 2
//            rightMargin: 2//units.gu(2)
//            bottomMargin: 2//units.gu(2)
//        }
//        z: 9999
//        spacing: 1//units.gu(1)
        
//        move: Transition { /*UbuntuNumberAnimation*/NumberAnimation { properties: "y" } }
//    }
    
    function reset() {
        runningBusyIndicator = 0;
        if (Settings.getAccess_token() == "") {
            startLogin()
        }
        else {
            weiboApiHandler.checkToken(Settings.getAccess_token())
        }
    }
    
    function startLogin() {
        console.log("=== startLogin()");
        //PopupUtils.open(loginSheet)
        loader.sourceComponent = loader.Null;
        loader.sourceComponent = loginSheet;
        
        //pageStack.push(Qt.resolvedUrl("../components/LoginSheet.qml"));        
    }
    
    
    Component{
        id:mainComponent
        WeiboTab {
            id: weiboTab
            
            Component.onCompleted: {
                weiboTab.refresh();
            }
        }
    }

    //////////////////////////////////////////////////////////////
    
    Component {
        id: loginSheet
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
    
    /////////////////////////////////////////////////////////
    
    MyType {
        id: appData
    }
    
    //////////////////////////////////////////////////////////////////         go to weibo page
    function toWeiboPage(model, index) {
        console.log("toWeiboPage  index " + index);
        //weiboPage.setFeed(model, index)
        //mainStack.push(weiboPage)
        pageStack.push(Qt.resolvedUrl("../ui/WeiboPage.qml"),
                        {"weiboModel":model,
                           "newIndex":index})
    }
    
    //////////////////////////////////////////////////////////////////         notificationBar
    //FIXME:这个column是起什么作用？
//    Column {
//        id: notificationBar
//        anchors {
//            fill: parent
//            topMargin: 10//units.gu(10)
//            leftMargin: parent.width / 2
//            rightMargin: 2//units.gu(2)
//            bottomMargin: 2//units.gu(2)
//        }
//        z: 9999
//        spacing: 1//units.gu(1)

//        move: Transition { /*UbuntuNumberAnimation*/NumberAnimation { properties: "y" } }
//    }
    
    //TODO:Need a better way to add Notification
    
    // pls use this function to add notification: mainView.addNotification(string, int)
    function addNotification(obj, inText, inTime) {
//        var text = inText == undefined ? "" : inText
//        var time = inTime == undefined ? 3 : inTime
//        var noti = Qt.createComponent("../components/Notification.qml")
//        var notiItem = noti.createObject(/*notificationBar*/obj, { "text": text, "time": time })
    }

    
    //////////////////////////////////////////////////////////////////
    //api handlers
    ////////////////
    function getAccessCode(code) {
        weiboApiHandler.login(appData.key, appData.secret, code)
    }
    
    WeiboApiHandler {
        id: weiboApiHandler

        function initialData() {
            console.log("===== we got token succeed, here we go ^_^");
            
            //remove the loginSheet
            loader.sourceComponent = loader.Null;
            loader.sourceComponent = mainComponent;
            
            //console.log("===== addNotification");
           // addNotification(qsTr("Welcome"), 3)
            
            //weiboTab.refresh()
            //messageTab.refresh()
            //userTab.getInfo()
            //tabsWeibo.selectedTabIndex = 0
            
             //weiboTab.refresh();
        }

        onLogined: {
//            weiboTab.refresh()
            initialData()
        }

        onTokenExpired: {
            loader.sourceComponent = loader.Null;
            
            if (isExpired) {
                startLogin()
            }
            else {
//                weiboTab.refresh()
                initialData()
            }
        }

        onSendedWeibo: {
            loader.sourceComponent = loader.Null;
            //TODO: what is this for ????
            //mainStack.pop() 
        }
    }
    
    //////////////////////////////////////////////////////////////////         settings
    /*Settings {
        id: settings
    }*/

    //////////////////////////////////////////////////////////////////         settings
    NetworkHelper {
        id: networkHelper
    }
    
    
}


