
import QtQuick 2.0
import Sailfish.Silica 1.0

import harbour.sailfish_sinaweibo.sunrain 1.0

import "../ui"
import "../components"
import "../js"
//import "../js/Settings.js" as Settings


Page {
    id: mainView
    
    property alias contentItem: drawer//weiboTab
    property bool _dockOpened: false
    property var _title: qsTr("Sailfish Weibo")

    function refresh() {
        weiboTab.refresh();
    }

    Drawer {
        id: drawer
        anchors.fill: parent
        background: GroupItem {
            id: groupItem
            anchors.fill: parent

            header:  PageHeader {
                id:groupHeader
                title: qsTr("Groups")
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (drawer.opened) {
                            drawer.open = false;
                        }
                    }
                }
            }
            PullDownMenu {
                id:groupPullDownMenu
//                MenuItem {
//                    text: qsTr("newGroup")
//                }
            }
            onFetchPending: {groupPullDownMenu.busy = true;}
            onFetchFinished: {groupPullDownMenu.busy = false;}
            onClickItem: {
                if (idstr == "" || idstr == undefined) {
                    weiboTab.showAllWeibo();
                    _title = qsTr("Sailfish Weibo");
                } else {
                    weiboTab.showGroupWeibo(idstr);
                    _title = name;
                }
                drawer.open = false;
            }
        }

        foreground: WeiboTab {
            id: weiboTab
            anchors.fill: parent

            header:  PageHeader {
                id:pageHeader
                title: _title
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (drawer.opened) {
                            drawer.open = false;
                        }
                    }
                }
            }

            PullDownMenu {
                id:weiboTabPullDownMenu
                MenuItem {
                    text: qsTr("Logout")
                    onClicked: {
                        weiboLogout();
//                        pageStack.popAttached(undefined, PageStackAction.Animated);
//                        reset();
                    }
                }
                MenuItem {
                    text: qsTr("Refresh")
                    onClicked: {weiboTab.refresh();}
                }
                MenuItem {
                    text: qsTr("Groups")
                    onClicked: {
                        if (!drawer.opened) {
                            drawer.open = true;
                            groupItem.fetchGroups();
                        }
                    }
                }
                MenuItem {
                    text: qsTr("New")
                    onClicked: {
                        toSendPage("", {});
                    }
                }
            }
            onFetchPending: {
                weiboTabPullDownMenu.busy = true;
            }
            onFetchFinished: {
                weiboTabPullDownMenu.busy = false;
            }
        }
    }

    //////////////////////////////////////////////////////////////////         settings
    NetworkHelper {
        id: networkHelper
    }
}


