
import QtQuick 2.0
import Sailfish.Silica 1.0

import harbour.sailfish_sinaweibo.sunrain 1.0

import "../ui"
import "../components"
import "../js"

WBPage {
    id: mainView
    
    property bool _dockOpened: false
    property var _title: qsTr("Sailfish Weibo")

    function refresh() {
        weiboTab.refresh();
    }
    WeiboTab {
        id: weiboTab
//        anchors {
//            top: parent.top
//            bottom: toolBar.top
//        }
        property int yIndex: 0
        anchors.fill: parent
//        pressDelay: 200
        header:  PageHeader {
            id:pageHeader
            title: _title
        }
        PullDownMenu {
            id:weiboTabPullDownMenu
            MenuItem {
                text: qsTr("Logout")
                onClicked: {
                    weiboLogout();
                }
            }
        }
        onMovementStarted: {
            yIndex = weiboTab.contentY;
            toolBar.hidePopup();
        }
        onContentYChanged: {
            if (contentY - yIndex > 0)
                toolBar.opacity = 0;
            else
                toolBar.opacity = 1;
        }

        onFetchPending: {
            weiboTabPullDownMenu.busy = true;
        }
        onFetchFinished: {
            weiboTabPullDownMenu.busy = false;
        }
    }

    BottomPopupToolBar {
        id: toolBar
        anchors.bottom: parent.bottom
        enableToolbarMenu: false
        onPopupReady: {
            groupItem.fetchGroups();
        }
        Behavior on opacity {
            NumberAnimation {
                id: animation
                duration: 400
                easing.type: Easing.InOutCubic
            }
        }
        Rectangle {
            anchors.fill: parent
            z: parent.z - 1
            color: Theme.highlightDimmerColor
        }

        popupContent: GroupItem {
            id: groupItem
            anchors.fill: parent
            header:  PageHeader {
                id:groupHeader
                title: qsTr("Close")
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        toolBar.hidePopup();
                    }
                }
            }
            onClickItem: {
                if (idstr == "" || idstr == undefined) {
                    weiboTab.showAllWeibo();
                    _title = qsTr("Sailfish Weibo");
                } else {
                    weiboTab.showGroupWeibo(idstr);
                    _title = name;
                }
                toolBar.hidePopup();
            }
        }
        toolBarContent: Item {
            id: tools
            width: parent.width - Theme.paddingMedium * 2
            anchors.horizontalCenter: parent.horizontalCenter
            height: Theme.itemSizeMedium
            Row {
                anchors.centerIn: parent
                BackgroundItem {
                    width: tools.width/3 -2
                    Label {
                        anchors.centerIn: parent
                        text: qsTr("Groups")
                        color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }
                    onClicked: {
                        if (!toolBar.popuped)
                            toolBar.showPopup();
                    }
                }
                Rectangle {
                    width: 1
                    height: parent.height
                    color: Theme.highlightColor
                }
                BackgroundItem {
                    width: tools.width/3 -2
                    Label {
                        anchors.centerIn: parent
                        text: qsTr("New")
                        color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }
                    onClicked: {
                        toSendPage("", {});
                    }
                }
                Rectangle {
                    width: 1
                    height: parent.height
                    color: Theme.highlightColor
                }
                BackgroundItem {
                    width: tools.width/3 -2
                    Label {
                        anchors.centerIn: parent
                        text: qsTr("Refresh")
                        color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }
                    onClicked: {
                        weiboTab.refresh();
                    }
                }
            }
        }
    }

    //////////////////////////////////////////////////////////////////         settings
    NetworkHelper {
        id: networkHelper
    }
}


