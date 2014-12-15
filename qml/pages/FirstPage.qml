
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
    
    property alias contentItem: loader

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
            } /*else {
                attachSecondPage();
            }*/

            //addNotification("hello", 3);
            console.log("====================== page depth is "+ pageStack.depth);

        }
    }
    
    function reset() {
        runningBusyIndicator = 0;
        if (Settings.getAccess_token() == "") {
            startLogin()
        } else {
            console.log("FirstPage === checkToken " + Settings.getAccess_token());
            
           // weiboApiHandler.checkToken(Settings.getAccess_token())
            api.accessToken = Settings.getAccess_token();
            api.uid = Settings.getUid();
            api.checkToken(Settings.getAccess_token());
        }
    }
    
    function startLogin() {
        console.log("=== startLogin()");
        //PopupUtils.open(loginSheet)
        loader.sourceComponent = loader.Null;
        loader.sourceComponent = loginSheet;      
    }

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

//            header: PageHeader {
//                id:pageHeader
//                title: qsTr("Sailfish Weibo")
//            }
//            menus {
//                MenuItem {
//                    text: qsTr("Logout")
//                    onClicked: {
//                        weiboLogout();
//                        pageStack.popAttached(undefined, PageStackAction.Animated);
//                        reset();
//                    }
//                }
//                MenuItem {
//                    text: qsTr("Refresh")
//                    onClicked: {
//                        weiboTab.refresh();
//                    }
//                }
//                MenuItem {
//                    text: qsTr("New")
//                    onClicked: {
//                        weiboTab.gotoSendNewWeibo();
//                    }
//                }
//            }
            
            onSendNewWeibo: {
                //TODO 添加相关功能//代码太复杂，需要重构
                console.log("MainView == WeiboTab onSendNewWeibo");
                toSendPage("", {});
            }
            
            Component.onCompleted: {
                weiboTab.refresh();
//                attachSecondPage();
            }
        }
    }

    //////////////////////////////////////////////////////////////
    
    Component {
        id: loginSheet
        LoginComponent {
            id:loginView
            anchors.fill: parent
            onLoginSucceed: {
                loader.sourceComponent = loader.Null;
                loader.sourceComponent = mainComponent;
            }
        }
    }
    
    /////////////////////////////////////////////////////////
    

    Connections {
        target: api
        onWeiboPutSucceed: {
//            console.log("====== FirstPage onWeiboPutSucceed action is "+ action);
        }
        onTokenExpired: {
            if (tokenExpired == true) {
                startLogin();
            } else {
                loader.sourceComponent = loader.Null;
                loader.sourceComponent = mainComponent;
            }
        }
    }

//    function getAccessCode(code) {
//        weiboApiHandler.login(appData.key, appData.secret, code)
//    }
    
//    WeiboApiHandler {
//        id: weiboApiHandler

//        function initialData() {
//            console.log("===== we got token succeed, here we go ^_^");
            
//            //remove the loginSheet
//            loader.sourceComponent = loader.Null;
//            loader.sourceComponent = mainComponent;
            
//           //console.log("===== addNotification");
//           //addNotification(qsTr("Welcome"), 3)
            
//            //weiboTab.refresh()
//            //messageTab.refresh()
//            //userTab.getInfo()
//            //tabsWeibo.selectedTabIndex = 0
            
//             //weiboTab.refresh();
//        }

//        onLogined: {
//            initialData()
//        }

//        onTokenExpired: {
//            loader.sourceComponent = loader.Null;
            
//            if (isExpired) {
//                startLogin()
//            } else {
//                initialData()
//            }
//        }

//        onSendedWeibo: {
//            //loader.sourceComponent = loader.Null;
//            //TODO: what is this for ????
//            //mainStack.pop() 
//        }
//    }
    
    //////////////////////////////////////////////////////////////////         settings
    /*Settings {
        id: settings
    }*/

    //////////////////////////////////////////////////////////////////         settings
    NetworkHelper {
        id: networkHelper
    }
    
    
}


