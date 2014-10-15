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
            console.log("FirstPage === PageStatus.Active");
            
            if (!settingsInitialized) {
                Settings.initialize();
                settingsInitialized = true;
            }
            if (firstUiLaunchTime) {
                reset();
                firstUiLaunchTime = false;
            } else {
                attachSecondPage();
            }

            //addNotification("hello", 3);
            console.log("====================== page depth is "+ pageStack.depth);

        }
    }
    
    function reset() {
        runningBusyIndicator = 0;
        if (Settings.getAccess_token() == "") {
            startLogin()
        } else {
            weiboApiHandler.checkToken(Settings.getAccess_token())
        }
    }
    
    function startLogin() {
        console.log("=== startLogin()");
        //PopupUtils.open(loginSheet)
        loader.sourceComponent = loader.Null;
        loader.sourceComponent = loginSheet;      
    }
    
//    function attachSecondPage() {
//        if (pageStack.depth == 1) {
//            pageStack.pushAttached("SecondPage.qml");
//        }
//    }

//    function popAttachedPages() {
//        // find the first page
//        var firstPage = pageStack.previousPage();
//        if (!firstPage) {
//            return;
//        }
//        while (pageStack.previousPage(firstPage)) {
//            firstPage = pageStack.previousPage(firstPage);
//        }
//        // pop to first page
//        pageStack.pop(firstPage);
//    }

    Component{
        id:mainComponent
        
        WeiboTab {
            id: weiboTab
            anchors{
                top:parent.top
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            header: PageHeader {
                id:pageHeader
                title: qsTr("Sailfish Weibo")
            }
            menus {
                MenuItem {
                    text: qsTr("Logout")
                    onClicked: {
                        weiboLogout();
                        pageStack.popAttached(undefined, PageStackAction.Animated);
                        reset();
                    }
                }
                MenuItem {
                    text: qsTr("Refresh")
                    onClicked: {
                        weiboTab.refresh();
                    }
                }
                MenuItem {
                    text: qsTr("New")
                    onClicked: {
                        weiboTab.gotoSendNewWeibo();
                    }
                }
            }
            
            onSendNewWeibo: {
                //TODO 添加相关功能//代码太复杂，需要重构
                console.log("MainView == WeiboTab onSendNewWeibo");
                toSendPage("", {});
            }
            
            Component.onCompleted: {
                weiboTab.refresh();
                attachSecondPage();
            }
        }
    }

    //////////////////////////////////////////////////////////////
    
    Component {
        id: loginSheet
        LoginComponent {
            id:loginView
            anchors.fill: parent
//            placeholderText: qsTr("pull down menu to start oauth login")
//            menus {
//                MenuItem {
//                    text: qsTr("Reload")
//                    onClicked: loginView.refreshLoginView();
//                }
//                MenuItem {
//                    text: qsTr("Login")
//                    onClicked: {
//                        loginView.loadLoginView();
//                    }
//                }
//            }
            onLoginSucceed: {
                 getAccessCode(code);
            }
            onLoginFailed: {
                loginView.placeholderText = qsTr("Web content load error: ") + code;
                loginView.placeholderHintText = qsTr("Check network connectivity and pull down to reload");
            }
        }
    }
    
    /////////////////////////////////////////////////////////
    
//    MyType {
//        id: appData
//    }
 
//    //////////////////////////////////////////////////////////////////         go to weibo page
//    function toWeiboPage(model, index) {
//        console.log("toWeiboPage  index " + index);
//        popAttachedPages();
//        pageStack.push(Qt.resolvedUrl("../ui/WeiboPage.qml"),
//                        {"weiboModel":model,
//                           "newIndex":index})
//    }
    
//    //////////////////////////////////////////////////////////////////         go to send page
//    function toSendPage(mode, info) {
//        //sendPage.setMode(mode, info)
//        //mainStack.push(sendPage)
//        popAttachedPages();
//        pageStack.push(Qt.resolvedUrl("../ui/SendPage.qml"),
//                        {"mode":mode,
//                           "info":info})
//    }
    
    
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
           //addNotification(qsTr("Welcome"), 3)
            
            //weiboTab.refresh()
            //messageTab.refresh()
            //userTab.getInfo()
            //tabsWeibo.selectedTabIndex = 0
            
             //weiboTab.refresh();
        }

        onLogined: {
            initialData()
        }

        onTokenExpired: {
            loader.sourceComponent = loader.Null;
            
            if (isExpired) {
                startLogin()
            } else {
                initialData()
            }
        }

        onSendedWeibo: {
            //loader.sourceComponent = loader.Null;
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


