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

    function initUserAvatar() {
        //userGetInfo(Settings.getAccess_token())
        var method = WeiboMethod.WBOPT_GET_USERS_SHOW;
        api.setWeiboAction(method, {'uid':settings.uid/*Settings.getUid()*/});
    }

    function messageGetRemind() {
        var method = WeiboMethod.WBOPT_GET_REMIND_UNREAD_COUNT;
        api.setWeiboAction(method, "");
    }

    RemindObject {
        id: remindObject
    }
    UserInfoObject {
        id: userInfoObject
    }

//    Connections {
//        target: api
//        //void weiboPutSucceed(QWeiboMethod::WeiboAction action, const QString& replyData);
//        onWeiboPutSucceed: {
//            if (action == WeiboMethod.WBOPT_GET_USERS_SHOW) {
//                if (!panel._userAvatarLock) {
//                    userInfoObject.usrInfo = JSON.parse(replyData)
//                    panel._userAvatarLock = !panel._userAvatarLock;
//                }
//            }
//            if (action == WeiboMethod.WBOPT_GET_REMIND_UNREAD_COUNT) {
//                remindObject.remind = JSON.parse(replyData);
//            }
//        }
//    }

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
        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalIconTextButton {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: qsTr("Home")
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                icon: "../graphics/panel_home.png"
                iconSize: Theme.itemSizeExtraSmall *2/3
                onClicked: {
                    toIndexPage();
                }
            }
        }
        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalIconTextButton {
                id: atMeWeibo
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: qsTr("AtMeWeibo")
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                icon: "../graphics/panel_at.png"
                iconSize: Theme.itemSizeExtraSmall *2/3
                onClicked: {
                    toWeiboMentionedPage();
                }
            }
            Label {
                anchors {
                    left: atMeWeibo.left
                    leftMargin: atMeWeibo.iconSize -2
                    top: atMeWeibo.top
                    topMargin: -3
                }
                opacity: remindObject.remind.mention_status == "0" ? 0 : 1
                text: remindObject.remind.mention_status
                font.pixelSize: atMeWeibo.iconSize/2
                color: Theme.secondaryHighlightColor
            }
        }
        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalIconTextButton {
                id: atMeComment
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: qsTr("AtMeComment")
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                icon: "../graphics/panel_at.png"
                iconSize: Theme.itemSizeExtraSmall *2/3
                onClicked: {
                    toCommentMentionedPage();
                }
            }
            Label {
                anchors {
                    left: atMeComment.left
                    leftMargin: atMeComment.iconSize -2
                    top: atMeComment.top
                    topMargin: -3
                }
                opacity: remindObject.remind.mention_cmt == "0" ? 0 : 1
                text: remindObject.remind.mention_cmt
                font.pixelSize: atMeComment.iconSize/2
                color: Theme.secondaryHighlightColor
            }
        }
        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalIconTextButton {
                id: comment
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: qsTr("Comment")
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                icon: "../graphics/panel_comment.png"
                iconSize: Theme.itemSizeExtraSmall *2/3
                onClicked: {
                    toCommentAllPage();
                }
            }
            Label {
                anchors {
                    left: comment.left
                    leftMargin: comment.iconSize -2
                    top: comment.top
                    topMargin: -3
                }
                opacity: remindObject.remind.cmt == "0" ? 0 : 1
                text: remindObject.remind.cmt
                font.pixelSize: comment.iconSize/2
                color: Theme.secondaryHighlightColor
            }
        }
        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalIconTextButton {
                id: pm
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: qsTr("PM")
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                icon: "../graphics/panel_pm.png"
                iconSize: Theme.itemSizeExtraSmall *2/3
                onClicked: {
                    toDummyDialog();
                }
            }
//            Label {
//                anchors {
//                    left: pm.left
//                    leftMargin: pm.iconSize -2
//                    top: pm.top
//                    topMargin: -3
//                }
//                opacity: remindObject.remind.cmt == "0" ? 0 : 1
//                text: remindObject.remind.cmt
//                font.pixelSize: comment.iconSize/2
//                color: Theme.secondaryHighlightColor
//            }
        }
        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalIconTextButton {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: qsTr("Favourite")
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                icon: "../graphics/panel_fav.png"
                iconSize: Theme.itemSizeExtraSmall *2/3
                onClicked: {
                    toFavoritesPage();
                }
            }
        }
        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalIconTextButton {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: qsTr("Settings")
                color: Theme.secondaryColor
                spacing: Theme.paddingMedium
                icon: "../graphics/panel_set.png"
                iconSize: Theme.itemSizeExtraSmall *2/3
                onClicked: {
                    toSettingsPage();
                }
            }
        }
    }
}
