
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
    
    property alias contentItem: weiboTab

    function refresh() {
        weiboTab.refresh();
    }
    WeiboTab {
        id: weiboTab
        anchors.fill: parent

        onSendNewWeibo: {
            //TODO 添加相关功能//代码太复杂，需要重构
            console.log("MainView == WeiboTab onSendNewWeibo");
            toSendPage("", {});
        }
    }

    //////////////////////////////////////////////////////////////////         settings
    NetworkHelper {
        id: networkHelper
    }
}


