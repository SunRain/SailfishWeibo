import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

import "../components"
//import "../js/Settings.js" as Settings

Panel {
    id: panel

//    property var _usrInfo: {"id":-1,"idstr":"","class":1,"screen_name":"","name":"","province":"","city":"","location":"","description":"","url":"","cover_image_phone":"","profile_image_url":"","profile_url":"","domain":"","weihao":"","gender":"","followers_count":0,"friends_count":0,"statuses_count":0,"favourites_count":0,"created_at":"Sun Jan 22 13:32:37 +0800 1999","following":false,"allow_all_act_msg":false,"geo_enabled":true,"verified":false,"verified_type":-1,"remark":"","status":{"text": "", "reposts_count": 0, "comments_count": 0, "attitudes_count": 0},"ptype":0,"allow_all_comment":true,"avatar_large":"","avatar_hd":"","verified_reason":"","follow_me":false,"online_status":0,"bi_followers_count":0,"lang":"zh-cn","star":0,"mbtype":0,"mbrank":0,"block_word":0}

    property bool _userAvatarLock: false

    signal clicked
    signal userAvatarClicked

    UsersShow {
        id: usersShow
        onRequestAbort: {
            console.log("== usersShow onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== usersShow onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            console.log("== usersShow onRequestSuccess ["+replyData+"]")

            if (!panel._userAvatarLock) {
                userInfoObject.usrInfo = JSON.parse(replyData)
                panel._userAvatarLock = !panel._userAvatarLock;
            }
        }
    }

    RemindUnreadCount {
        id: remindUnreadCount
        onRequestAbort: {
            console.log("== remindUnreadCount onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== remindUnreadCount onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            console.log("== remindUnreadCount onRequestSuccess ["+replyData+"]")

            remindObject.remind = JSON.parse(replyData);
        }
    }

    function initUserAvatar() {
        console.log("=== panel initUserAvatar");
        usersShow.getRequest();
    }

    function messageGetRemind() {
        console.log("=== panel messageGetRemind");
        remindUnreadCount.getRequest();
    }


    RemindObject {
        id: remindObject
    }
    UserInfoObject {
        id: userInfoObject
    }

    Column {
        id: column
        spacing: Theme.paddingMedium
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        Item {
            id: userAvatar
            width: column.width
            height: cover.height
            BusyIndicator {
                id: avatarLoading
                anchors.centerIn: parent
                parent: userAvatar
                size: BusyIndicatorSize.Small
                opacity: avatarLoading.running ? 1 : 0
                running: cover.status != Image.Ready && profile.status != Image.Ready
            }
            Image {
                id: cover
                width: parent.width
                height: cover.width *2/3
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                source: util.parseImageUrl(userInfoObject.usrInfo.cover_image_phone)
                onStatusChanged: {
                    if (cover.status == Image.Ready) {
                        util.saveRemoteImage(userInfoObject.usrInfo.cover_image_phone)
                    }
                }
            }
            Image {
                id: profile
                width: userAvatar.width/4
                height: width
                anchors.centerIn: cover
                asynchronous: true
                source: util.parseImageUrl(userInfoObject.usrInfo.profile_image_url)
                onStatusChanged: {
                    if (profile.status == Image.Ready) {
                        util.saveRemoteImage(userInfoObject.usrInfo.profile_image_url)
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        userAvatarClicked();
                    }
                }
            }
            Label {
                id: screenName
                text: userInfoObject.usrInfo.screen_name
                anchors {
                    top: profile.bottom
                    topMargin: Theme.paddingSmall
                    horizontalCenter: profile.horizontalCenter
                }
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
            }
        }
        HorizontalIconTextButton {
            width: column.width - Theme.paddingLarge *2
            height: Theme.itemSizeExtraSmall
            anchors.horizontalCenter: column.horizontalCenter
            text: qsTr("Home")
            fontSize: Theme.itemSizeExtraSmall *0.8
            color: Theme.secondaryColor
            spacing: Theme.paddingMedium
            icon: util.pathTo("qml/graphics/panel_home.png")
            iconSize: Theme.itemSizeExtraSmall *0.6
            onClicked: {
                toIndexPage();
            }
        }
        HorizontalIconTextButton {
            id: atMeWeibo
            width: column.width - Theme.paddingLarge *2
            height: Theme.itemSizeExtraSmall
            anchors.horizontalCenter: column.horizontalCenter
            fontSize: Theme.itemSizeExtraSmall *0.8
            text: qsTr("AtMeWeibo")
            color: Theme.secondaryColor
            spacing: Theme.paddingMedium
            icon: util.pathTo("qml/graphics/panel_at.png")
            iconSize: Theme.itemSizeExtraSmall *0.6
            onClicked: {
                toWeiboMentionedPage();
            }
            Rectangle {
                radius: 90
                anchors {
                    left: atMeWeibo.left
                    leftMargin: atMeWeibo.iconSize
                    top: atMeWeibo.top
                    topMargin: atMeWeibo.height - atMeWeibo.fontSize
                }
                width: atMeWeibo.height - atMeWeibo.fontSize
                height: width
                z: parent.z + 1
                color: Theme.highlightColor
                opacity: remindObject.remind.mention_status == "0" ? 0 : 1
            }
        }
        HorizontalIconTextButton {
            id: atMeComment
            width: column.width - Theme.paddingLarge *2
            height: Theme.itemSizeExtraSmall
            anchors.horizontalCenter: column.horizontalCenter
            fontSize: Theme.itemSizeExtraSmall *0.8
            text: qsTr("AtMeComment")
            color: Theme.secondaryColor
            spacing: Theme.paddingMedium
            icon: util.pathTo("qml/graphics/panel_at.png")
            iconSize: Theme.itemSizeExtraSmall *0.6
            onClicked: {
                toCommentMentionedPage();
            }
            Rectangle {
                radius: 90
                anchors {
                    left: atMeComment.left
                    leftMargin: atMeComment.iconSize
                    top: atMeComment.top
                    topMargin: atMeComment.height - atMeComment.fontSize
                }
                width: atMeComment.height - atMeComment.fontSize
                height: width
                z: parent.z + 1
                color: Theme.highlightColor
                opacity: remindObject.remind.mention_cmt == "0" ? 0 : 1
            }
        }
        HorizontalIconTextButton {
            id: comment
            width: column.width - Theme.paddingLarge *2
            height: Theme.itemSizeExtraSmall
            anchors.horizontalCenter: column.horizontalCenter
            fontSize: Theme.itemSizeExtraSmall *0.8
            text: qsTr("Comment")
            color: Theme.secondaryColor
            spacing: Theme.paddingMedium
            icon: util.pathTo("qml/graphics/panel_comment.png")
            iconSize: Theme.itemSizeExtraSmall *0.6
            onClicked: {
                toCommentAllPage();
            }
            Rectangle {
                radius: 90
                anchors {
                    left: comment.left
                    leftMargin: comment.iconSize
                    top: comment.top
                    topMargin: comment.height - comment.fontSize
                }
                width: comment.height - comment.fontSize
                height: width
                z: parent.z + 1
                color: Theme.highlightColor
                opacity: remindObject.remind.cmt == "0" ? 0 : 1
            }
        }
        HorizontalIconTextButton {
            id: pm
            width: column.width - Theme.paddingLarge *2
            height: Theme.itemSizeExtraSmall
            anchors.horizontalCenter: column.horizontalCenter
            fontSize: Theme.itemSizeExtraSmall *0.8
            text: qsTr("PM")
            color: Theme.secondaryColor
            spacing: Theme.paddingMedium
            icon: util.pathTo("qml/graphics/panel_pm.png")
            iconSize: Theme.itemSizeExtraSmall *0.6
            onClicked: {
                toDummyDialog();
            }
            Rectangle {
                radius: 90
                anchors {
                    left: pm.left
                    leftMargin: pm.iconSize
                    top: pm.top
                    topMargin: pm.height - pm.fontSize
                }
                width: pm.height - pm.fontSize
                height: width
                z: parent.z + 1
                color: Theme.highlightColor
                opacity: remindObject.remind.cmt == "0" ? 0 : 1
            }
        }
        HorizontalIconTextButton {
            width: column.width - Theme.paddingLarge *2
            height: Theme.itemSizeExtraSmall
            anchors.horizontalCenter: column.horizontalCenter
            fontSize: Theme.itemSizeExtraSmall *0.8
            text: qsTr("Favourite")
            color: Theme.secondaryColor
            spacing: Theme.paddingMedium
            icon: util.pathTo("qml/graphics/panel_fav.png")
            iconSize: Theme.itemSizeExtraSmall *0.6
            onClicked: {
                toFavoritesPage();
            }
        }
        HorizontalIconTextButton {
            width: column.width - Theme.paddingLarge *2
            height: Theme.itemSizeExtraSmall
            anchors.horizontalCenter: column.horizontalCenter
            fontSize: Theme.itemSizeExtraSmall *0.8
            text: qsTr("Settings")
            color: Theme.secondaryColor
            spacing: Theme.paddingMedium
            icon: util.pathTo("qml/graphics/panel_set.png")
            iconSize: Theme.itemSizeExtraSmall *0.6
            onClicked: {
                toSettingsPage();
            }
        }
    }
}
