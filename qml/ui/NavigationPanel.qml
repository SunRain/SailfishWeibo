import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

import "../WeiboFunctions.js" as WBLoader
import "../js/Utility.js" as Utility

import "../components"

Panel {
    id: panel

    signal clicked
    signal userAvatarClicked

    Connections {
        target: tokenProvider
        onUseHackLoginChanged: { //useHackLogin
            if (inner.remindUnreadCountExist()) {
                WBLoader.cleanup(inner.rc_object, inner.rc_component, inner.rc_incubator);
                panel.messageGetRemind();
            }
        }
    }

    QtObject {
        id: inner
        property bool userAvatarLock: false
        //////////////////////// UsersShow
        property var us_component: null
        property var us_object: null
        property var us_incubator: null
        function usersShowExist() {
            if (us_component || us_object || us_incubator)
                return true;
            return false;
        }
        function initUserInfo(callback) {
            if (tokenProvider.useHackLogin) {
                WBLoader.create("../requests/hack/HackUsersInfoMe.qml", panel,
                    function(object, component, incubator) {
                        inner.us_component = component;
                        inner.us_incubator = incubator;
                        inner.us_object = object;
                        if (inner.us_object) {
                            inner.us_object.requestResult.connect(function(ret, replyData) {
                                console.log("=== HackUsersInfoMe connect ===");
                                if (ret == BaseRequest.RET_ABORT) {
                                    console.log("== HackUsersInfoMe onRequestAbort");
                                } else if (ret == BaseRequest.RET_FAILURE) {
                                    console.log("== HackUsersInfoMe onRequestFailure ["+replyData+"]")
                                } else {
                                    console.log("== HackUsersInfoMe onRequestSuccess ["+replyData+"]")
                                    //create remindObject if not created
                                    if (!globalInner.userInfoObject) {
                                        WBLoader.create("../components/UserInfoObject.qml", panel,
                                            function(object, component, incubator){
                                                if (object)
                                                    globalInner.userInfoObject = object;
                                                Utility.parserUserInfoMe(globalInner.userInfoObject, JSON.parse(replyData));
                                            });
                                    } else {
                                        Utility.parserUserInfoMe(globalInner.userInfoObject, JSON.parse(replyData));
                                    }
                                }
                                });
                            callback.call(this, inner.us_object);
                        } else {
                            callback.call(this, inner.us_object);
                        }
                    });
            } else {
                WBLoader.create("../requests/oauth/UsersShow.qml", panel,
                    function(object, component, incubator) {
                        inner.us_component = component;
                        inner.us_incubator = incubator;
                        inner.us_object = object;
                        if (inner.us_object) {
                            inner.us_object.requestResult.connect(
                                function(ret, replyData) {
                                    console.log("=== usersShow connect ===");
                                    if (ret == BaseRequest.RET_ABORT) {
                                        console.log("== usersShow onRequestAbort");
                                    } else if (ret == BaseRequest.RET_FAILURE) {
                                        console.log("== usersShow onRequestFailure ["+replyData+"]")
                                    } else {
                                        console.log("== usersShow onRequestSuccess ["+replyData+"]")

                                        //create userInfoObject if not created
                                        if (!globalInner.userInfoObject) {
                                            WBLoader.create("../components/UserInfoObject.qml", panel,
                                                function(object, component, incubator){
                                                    if (object)
                                                        globalInner.userInfoObject = object;
                                                    if (!inner.userAvatarLock) {
                                                        globalInner.userInfoObject.userInfo = JSON.parse(replyData)
                                                        inner.userAvatarLock = !inner.userAvatarLock;
                                                    }
                                                });
                                        } else if (!inner.userAvatarLock) {
                                            globalInner.userInfoObject.userInfo = JSON.parse(replyData)
                                            inner.userAvatarLock = !inner.userAvatarLock;
                                        }
                                    }
                                });
                            callback.call(this, inner.us_object);
                        } else {
                            callback.call(this, inner.us_object);
                        }
                    });
            }
        }

        //////////////////////////RemindUnreadCount
        property var rc_component: null
        property var rc_object: null
        property var rc_incubator: null
        function remindUnreadCountExist() {
            if (rc_component || us_object || rc_incubator)
                return true;
            return false;
        }
        function messageGetRemind(callback) {
            if (tokenProvider.useHackLogin) {
                WBLoader.create("../requests/hack/HackRemindUnreadCount.qml", panel,
                    function(object, component, incubator) {
                        inner.rc_component = component;
                        inner.rc_incubator = incubator;
                        inner.rc_object = object;
                        if (inner.rc_object) {
                            inner.rc_object.requestResult.connect(function(ret, replyData) {
                                console.log("=== HackRemindUnreadCount connect ===");
                                if (ret == BaseRequest.RET_ABORT) {
                                    console.log("== HackRemindUnreadCount onRequestAbort");
                                } else if (ret == BaseRequest.RET_FAILURE) {
                                    console.log("== HackRemindUnreadCount onRequestFailure ["+replyData+"]")
                                } else {
                                    console.log("== HackRemindUnreadCount onRequestSuccess ["+replyData+"]")
                                    //create remindObject if not created
                                    if (!globalInner.remindObject) {
                                        WBLoader.create("../components/RemindObject.qml", panel,
                                            function(object, component, incubator){
                                                if (object)
                                                    globalInner.remindObject = object;
//                                                parserRemind(JSON.parse(replyData));
                                                Utility.parserRemind(globalInner.remindObject, JSON.parse(replyData));
                                            });
                                    } else {
//                                        parserRemind(JSON.parse(replyData));
                                        Utility.parserRemind(globalInner.remindObject, JSON.parse(replyData));
                                    }
                                }
                                });
                            callback.call(this, inner.rc_object);
                        } else {
                            callback.call(this, inner.rc_object);
                        }
                    });
            } else {
                WBLoader.create("../requests/oauth/RemindUnreadCount.qml", panel,
                    function(object, component, incubator) {
                        inner.rc_component = component;
                        inner.rc_incubator = incubator;
                        inner.rc_object = object;
                        if (inner.rc_object) {
                            inner.rc_object.requestResult.connect(function(ret, replyData) {
                                console.log("=== remindUnreadCount connect ===");
                                if (ret == BaseRequest.RET_ABORT) {
                                    console.log("== remindUnreadCount onRequestAbort");
                                } else if (ret == BaseRequest.RET_FAILURE) {
                                    console.log("== remindUnreadCount onRequestFailure ["+replyData+"]")
                                } else {
                                    console.log("== remindUnreadCount onRequestSuccess ["+replyData+"]")
                                    //create remindObject if not created
                                    if (!globalInner.remindObject) {
                                        WBLoader.create("../components/RemindObject.qml", panel,
                                            function(object, component, incubator){
                                                if (object)
                                                    globalInner.remindObject = object;
                                                globalInner.remindObject.remind = JSON.parse(replyData);
                                            });
                                    } else {
                                        globalInner.remindObject.remind = JSON.parse(replyData);
                                    }
                                }
                                });
                            callback.call(this, inner.rc_object);
                        } else {
                            callback.call(this, inner.rc_object);
                        }
                    });
            }
        }
    }

    function initUserInfo() {
        console.log("=== panel initUserInfo");
        if (!inner.us_object) {
            inner.initUserInfo(function(obj) {
                if (obj)
                    obj.getRequest();
            });
        } else {
            inner.us_object.getRequest();
        }
    }

    function messageGetRemind() {
        console.log("=== panel messageGetRemind");
        if (!inner.rc_object) {
            inner.messageGetRemind(function(obj) {
                if (obj)
                    obj.getRequest();
            });
        } else {
            inner.rc_object.getRequest();
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
                source: util.parseImageUrl(globalInner.userInfoObject.cover_image_phone)
            }
            Image {
                id: profile
                width: userAvatar.width/4
                height: width
                anchors.centerIn: cover
                asynchronous: true
                source: util.parseImageUrl(globalInner.userInfoObject.profile_image_url)
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        userAvatarClicked();
                    }
                }
            }
            Label {
                id: screenName
                text: globalInner.userInfoObject.screen_name
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
                wbFunc.toIndexPage();
            }
            dotOpacity: globalInner.remindObject.status == 0 ? 0 : 1
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
                wbFunc.toWeiboMentionedPage();
            }
            dotOpacity: globalInner.remindObject.mention_status == "0" ? 0 : 1
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
                wbFunc.toCommentMentionedPage();
            }
            dotOpacity: globalInner.remindObject.mention_cmt == "0" ? 0 : 1
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
                wbFunc.toCommentAllPage();
            }
            dotOpacity: globalInner.remindObject.cmt == "0" ? 0 : 1
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
                wbFunc.toDummyDialog();
            }
            dotOpacity: globalInner.remindObject.dm == "0" ? 0 : 1
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
                wbFunc.toFavoritesPage();
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
                wbFunc.toSettingsPage();
            }
        }
    }
}
