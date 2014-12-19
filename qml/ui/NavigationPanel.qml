import QtQuick 2.0
import Sailfish.Silica 1.0
import com.sunrain.sinaweibo 1.0

import "../components"
import "../js/Settings.js" as Settings

Panel {
    id: panel

    property var _usrInfo: {"id":-1,"idstr":"","class":1,"screen_name":"","name":"","province":"","city":"","location":"","description":"","url":"","cover_image_phone":"","profile_image_url":"","profile_url":"","domain":"","weihao":"","gender":"","followers_count":0,"friends_count":0,"statuses_count":0,"favourites_count":0,"created_at":"Sun Jan 22 13:32:37 +0800 1999","following":false,"allow_all_act_msg":false,"geo_enabled":true,"verified":false,"verified_type":-1,"remark":"","status":{"text": "", "reposts_count": 0, "comments_count": 0, "attitudes_count": 0},"ptype":0,"allow_all_comment":true,"avatar_large":"","avatar_hd":"","verified_reason":"","follow_me":false,"online_status":0,"bi_followers_count":0,"lang":"zh-cn","star":0,"mbtype":0,"mbrank":0,"block_word":0}

    signal clicked

    function initUserAvatar() {
        //userGetInfo(Settings.getAccess_token())
        var method = WeiboMethod.WBOPT_GET_USERS_SHOW;
        api.setWeiboAction(method, {'uid':Settings.getUid()});
    }

//    Component.onCompleted: {
//        //userGetInfo(Settings.getAccess_token())
//        var method = WeiboMethod.WBOPT_GET_USERS_SHOW;
//        api.setWeiboAction(method, {'uid':Settings.getUid()});
//    }

    Connections {
        target: api
        //void weiboPutSucceed(QWeiboMethod::WeiboAction action, const QString& replyData);
        onWeiboPutSucceed: {
            if (action == WeiboMethod.WBOPT_GET_USERS_SHOW) {
                _usrInfo = JSON.parse(replyData)
            }
        }
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
//            color: "#c41782"
//            border.color: "#d11313"
//            anchors {
//                left: parent.left
//                right: parent.right
//                //top: cover.top
//                //topMargin: 10
//                bottom: cover.bottom
//                //bottomMargin: 10
//            }
            width: column.width
            height: cover.height //Theme.itemSizeExtraSmall +10
            BusyIndicator {
                id: avatarLoading
                anchors.centerIn: parent
                parent: userAvatar
                size: BusyIndicatorSize.Smal
                opacity: avatarLoading.running ? 1 : 0
                running: cover.status != Image.Ready && profile.status != Image.Ready
            }
            Image {
                id: cover
                width: parent.width
                height: cover.width *2/3
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                source: util.parseImageUrl(_usrInfo.cover_image_phone)
                onStatusChanged: {
                    if (cover.status == Image.Ready) {
                        util.saveRemoteImage(_usrInfo.cover_image_phone)
                    }
                }
            }
            Image {
                id: profile
                width: userAvatar.width/4
                height: width
                anchors.centerIn: cover
                asynchronous: true
                source: util.parseImageUrl(_usrInfo.profile_image_url)
                onStatusChanged: {
                    if (profile.status == Image.Ready) {
                        util.saveRemoteImage(_usrInfo.profile_image_url)
                    }
                }
            }
            Label {
                id: screenName
                text: _usrInfo.screen_name
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
//                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.horizontalCenterOffset:-column.width/5
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: qsTr("Home")
                color: Theme.secondaryColor
                spacing: Theme.paddingLarge *2
                icon: "../graphics/panel_home.png"
                iconSize: Theme.itemSizeExtraSmall *2/3
                onClicked: {

                }
            }
        }
        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalIconTextButton {
//                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.horizontalCenterOffset: -column.width/5
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: qsTr("AtMe")
                color: Theme.secondaryColor
                spacing: Theme.paddingLarge*2
                icon: "../graphics/panel_at.png"
                iconSize: Theme.itemSizeExtraSmall *2/3
                onClicked: {

                }
            }
        }
        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalIconTextButton {
//                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.horizontalCenterOffset: -column.width/5
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: qsTr("Comment")
                color: Theme.secondaryColor
                spacing: Theme.paddingLarge*2
                icon: "../graphics/panel_comment.png"
                iconSize: Theme.itemSizeExtraSmall *2/3
                onClicked: {

                }
            }
        }
        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalIconTextButton {
//                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.horizontalCenterOffset: -column.width/5
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: qsTr("PM")
                color: Theme.secondaryColor
                spacing: Theme.paddingLarge*2
                icon: "../graphics/panel_pm.png"
                iconSize: Theme.itemSizeExtraSmall *2/3
                onClicked: {

                }
            }
        }
        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalIconTextButton {
//                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.horizontalCenterOffset: -column.width/5
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: qsTr("Favourite")
                color: Theme.secondaryColor
                spacing: Theme.paddingLarge*2
                icon: "../graphics/panel_fav.png"
                iconSize: Theme.itemSizeExtraSmall *2/3
                onClicked: {

                }
            }
        }
        Item {
            width: column.width
            height: Theme.itemSizeExtraSmall
            HorizontalIconTextButton {
//                anchors.horizontalCenter: parent.horizontalCenter
//                anchors.horizontalCenterOffset: -column.width/5
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: qsTr("Settings")
                color: Theme.secondaryColor
                spacing: Theme.paddingLarge*2
                icon: "../graphics/panel_set.png"
                iconSize: Theme.itemSizeExtraSmall *2/3
                onClicked: {

                }
            }
        }
    }
}
