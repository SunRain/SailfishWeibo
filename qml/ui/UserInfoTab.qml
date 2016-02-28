import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

import "../WeiboFunctions.js" as WBLoader
import "../js/Utility.js" as Utility
import "../components"

Column {
    id: userInfoTab
    width: parent ? parent.width : Screen.width
    spacing: Theme.paddingMedium
    property var userInfoObject: undefined
    signal followStateChanged
    Item {
        id: userArea
        width: parent.width
        height: rowUser.height + Theme.paddingMedium
        Row {
            id: rowUser
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.paddingSmall
            }
            spacing: Theme.paddingMedium
            Image {
                id: usAvatar
                width: 160
                height: width
                anchors.verticalCenter: rowUserColumn.verticalCenter
                smooth: true
                fillMode: Image.PreserveAspectFit
                source: userInfoObject.avatar_hd
            }

            Column {
                id:rowUserColumn
                spacing: Theme.paddingSmall

                Label {
                    id: labelUserName
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    width:rowUser.width - usAvatar.width - Theme.paddingMedium
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: userInfoObject.screen_name
                }

                Label {
                    id: labelLocation
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    width: labelUserName.width
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: userInfoObject.location
                }
                OptionItem {
                    id:optionItem
                    width: parent.width
                    //TODO fit hacklogin
                    visible: userInfoObject.id != tokenProvider.uid
                             || userInfoObject.id != tokenProvider.hackLoginUid
                    enabled: userInfoObject.id != tokenProvider.uid
                             || userInfoObject.id != tokenProvider.hackLoginUid
                    Rectangle {
                        z: optionItem.z - 1
                        width: optionItem.width
                        height: optionItem.height
                        anchors.left: optionItem.left
                        anchors.top: optionItem.top
                        border.color:Theme.highlightColor
                        color:"#00000000"
                        radius: 15
                    }
                    Label {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: Theme.paddingSmall
                        }
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                        text: {
                            if (userInfoObject.following) {
                                if (userInfoObject.follow_me == true) {
                                    return qsTr("Bilateral")
                                } else {
                                    return qsTr("Following")
                                }
                            } else {
                                if (userInfoObject.follow_me) {
                                    return qsTr("Follower")
                                } else {
                                    return qsTr("Follow")
                                }
                            }
                        }
                    }
                    menu: optionMenu
                    ContextMenu {
                        id:optionMenu
                        MenuItem {
                            text: {
                                if (userInfoObject.following) {
                                    return qsTr("CancelFollowing");
                                } else {
                                    return qsTr("Follow");
                                }
                            }
                            onClicked: {
                                userInfoTab.followStateChanged();
                            }
                        }
                    }
                }
            }
        }
    }
    Column {
        id: colDesc
        width: parent.width
        spacing: Theme.paddingSmall
        Label {
            id: labelDesc
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeMedium
            text: qsTr("Description: ")
        }

        Label {
            id: labelDescription
            color: Theme.primaryColor
            width: parent.width
            font.pixelSize: Theme.fontSizeMedium
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: userInfoObject.description
        }
    }
    Row {
        id: rowFriends
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        Item {
            width: parent.width/3 - Theme.paddingSmall
            height: Theme.fontSizeSmall
            Label {
                anchors.centerIn: parent
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeTiny
                text: qsTr("Weibo:") + " " + userInfoObject.statuses_count
            }
        }
        Rectangle {
            width: 1
            height: Theme.fontSizeSmall -2
            color: Theme.highlightColor
        }
        Item {
            width: parent.width/3 - Theme.paddingSmall
            height: Theme.fontSizeSmall
            Label {
                anchors.centerIn: parent
                color: Theme.secondaryColor
                font.pixelSize:Theme.fontSizeTiny
                text: qsTr("following:") + " " +userInfoObject.friends_count
            }
            //TODO 似乎第三方客户端无法调用除本身意外的其他用户的follower/following信息
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    wbFunc.toFriendsPage("following", userInfoObject.id);
                }
            }
        }
        Rectangle {
            width: 1
            height: Theme.fontSizeSmall - 2
            color: Theme.highlightColor
        }
        Item {
            width: parent.width/3 - Theme.paddingSmall
            height: Theme.fontSizeSmall
            Label {
                anchors.centerIn: parent
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeTiny
                text: qsTr("follower:")+" " + userInfoObject.followers_count
            }
            //TODO 似乎第三方客户端无法调用除本身意外的其他用户的follower/following信息
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    wbFunc.toFriendsPage("follower", userInfoObject.id);
                }
            }
        }
    }
}

