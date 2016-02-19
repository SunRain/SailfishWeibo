import QtQuick 2.0
//import QtQuick 2.2
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
//import "../js/Settings.js" as Settings
import "../components"

import harbour.sailfish_sinaweibo.sunrain 1.0

Page {
    id: userPage
    
    property var uid: undefined
    property bool _isFollowing: false

    property int _pageNum: 1

    property bool _showUserWeibo: false
    property bool _refreshUserWeiboLock: false
    property bool _refreshUserInfoLock: false
    property bool _pageActive: false
    property var _userWeiboCache: undefined

    UserInfoObject {
        id: userInfoObject
    }

    onStatusChanged: {
        if (userPage.status == PageStatus.Active || userPage.status == PageStatus.Activating) {
            userPage._pageActive = true;
        } else {
            userPage._pageActive = false;
        }
    }

    function refreshUserWeibo() {
        showBusyIndicator();
        _pageNum = 1;
        statusesUserTimeline.setParameters("page", _pageNum)
        statusesUserTimeline.setParameters("uid", userInfoObject.userInfo.id);
        statusesUserTimeline.getRequest();
    }
    function showUserWeibo() {
        modelWeibo.clear();
        if (userPage._refreshUserWeiboLock) {
            for (var i=0; i<userPage._userWeiboCache.statuses.length; i++) {
                modelWeibo.append(userPage._userWeiboCache.statuses[i])
            }
            if (lvUserWeibo.model == undefined) {
                lvUserWeibo.model = modelWeibo;
            }
        } else {
            userPage._refreshUserWeiboLock = !userPage._refreshUserWeiboLock;
            refreshUserWeibo();
        }
    }

    function refreshUserInfo() {
        showBusyIndicator();
        usersShow.setParameters("uid", uid);
        usersShow.getRequest();
    }

    function showUserInfo() {
        modelWeibo.clear();
        if (userPage._refreshUserInfoLock) {
            modelWeibo.append(userInfoObject.userInfo.status);
            if (lvUserWeibo.model == undefined) {
                lvUserWeibo.model = modelWeibo;
            }
        } else {
            userPage._refreshUserInfoLock = !userPage._refreshUserInfoLock;
            refreshUserInfo();
        }
    }

    function userWeiboAddMore() {
        showBusyIndicator();
        _pageNum++
        statusesUserTimeline.setParameters("page", _pageNum);
        statusesUserTimeline.setParameters("uid", userInfoObject.userInfo.id);
        statusesUserTimeline.getRequest();
    }
    StatusesUserTimeline {
        id: statusesUserTimeline
        onRequestAbort: {
            console.log("== statusesUserTimeline onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== statusesUserTimeline onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            userPage._userWeiboCache = JSON.parse(replyData);
            for (var i=0; i<userPage._userWeiboCache.statuses.length; i++) {
                modelWeibo.append(userPage._userWeiboCache.statuses[i])
            }
            if (lvUserWeibo.model == undefined) {
                lvUserWeibo.model = modelWeibo;
            }
            stopBusyIndicator();
        }
    }

    UsersShow {
        id: usersShow
        onRequestAbort: {
            console.log("== usersShow onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== usersShow onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            if (!userPage._pageActive) {
                return;
            }
            userInfoObject.userInfo = JSON.parse(replyData);

            console.log("==== == usersShow object value "+ userInfoObject.userInfo)

            console.log(">>>>> usersShow object value "+ JSON.stringify(userInfoObject.userInfo))

            _isFollowing = userInfoObject.userInfo.following;
            modelWeibo.append(userInfoObject.userInfo.status);

            if (lvUserWeibo.model == undefined) {
                lvUserWeibo.model = modelWeibo;
            }
            stopBusyIndicator();
        }
    }

    FriendshipsCreate {
        id: friendshipsCreate
        onRequestAbort: {
            console.log("== friendshipsCreate onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== friendshipsCreate onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            if (!userPage._pageActive) {
                return;
            }
            _isFollowing = true;
        }
    }
    FriendshipsDestroy {
        id: friendshipsDestroy
        onRequestAbort: {
            console.log("== FriendshipsDestroy onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== FriendshipsDestroy onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            if (!userPage._pageActive) {
                return;
            }
            _isFollowing = false;
        }
    }

    function userFollowCreate() {
        friendshipsCreate.setParameters("uid", uid);
        friendshipsCreate.postRequest();
    }
    
    function userFollowCancel() {
        friendshipsDestroy.setParameters("uid", uid);
        friendshipsDestroy.postRequest();
    }
    
    ListModel {
        id: modelWeibo
    }

    SilicaFlickable {
        id: scrollArea
        boundsBehavior: (contentHeight > height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
        anchors.fill: parent
        contentHeight: userPage._showUserWeibo ? Screen.height : innerAreaColumn.height + Theme.paddingSmall
        clip: true
        ScrollDecorator{
//            flickable: userPage._showUserWeibo ? lvUserWeibo : scrollArea
        }
        Column {
            id: innerAreaColumn
            spacing: Theme.paddingMedium
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            Item {
                id:pageHeader
                width: parent.width
                height: childrenRect.height//Math.max(Theme.itemSizeLarge, childrenRect.height)
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onClicked: {
                        userPage._showUserWeibo = !userPage._showUserWeibo;
                        if(userPage._showUserWeibo) {
                            userPage.showUserWeibo();
                        } /*else {
                            userPage.showuserInfo();
                        }*/
                    }
                }
                Rectangle {
                    z: -1
                    width: pageHeader.width
                    height: pageHeader.height
                    color: Theme.highlightDimmerColor
                    opacity: scrollArea.moving || lvUserWeibo.moving || userPage._showUserWeibo ? 0.5 : 0.0
                    Behavior on opacity { FadeAnimation { } }
                }
                Row {
                    height: Math.max(label.height, image.height) + Theme.paddingMedium
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    spacing: Theme.paddingMedium
                    Label {
                        id: label
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: Theme.fontSizeLarge
                        color: mouseArea.pressed ? Theme.highlightColor : Theme.primaryColor
                        text: qsTr("About user")
                    }
                    Image {
                        id: image
                        anchors.verticalCenter: parent.verticalCenter
                        width: implicitWidth
                        height: implicitHeight
                        source: userPage._showUserWeibo
                                ? util.pathTo("qml/graphics/action_collapse.png")
                                : util.pathTo("qml/graphics/action_open.png")
                        //                    RotationAnimator on rotation {
                        //                        id: animation
                        //                        from: userPage._showUserWeibo ? 0 : 180
                        //                        to: userPage._showUserWeibo ? 180 : 360
                        //                    }

                    }
                }
            }
            Loader {
                id: loader
                anchors {
                    left: parent.left
                    right: parent.right
                }
                visible: !userPage._showUserWeibo
                enabled: !userPage._showUserWeibo
                height: userPage._showUserWeibo ? 0 : implicitHeight
                sourceComponent: userPage._showUserWeibo ? loader.Null : userInfoComponent
                onStatusChanged: {
                    if (loader.status == Loader.Ready) {
                        userPage.showUserInfo();
                    }
                }
            }
            SilicaListView{
                id: lvUserWeibo
                width: parent.width
                height: userPage._showUserWeibo
                        ? userPage.height - pageHeader.height
                          - Theme.itemSizeMedium //the FooterLoadMore Component height
                        : lvUserWeibo.contentHeight
                parent: userPage._showUserWeibo ? userPage : innerAreaColumn
                anchors{
                    top: userPage._showUserWeibo ? pageHeader.bottom : undefined
                    topMargin: userPage._showUserWeibo ? pageHeader.height : undefined
                }
                clip: true
                cacheBuffer: 9999
                delegate: delegateWeibo
                footer: userPage._showUserWeibo
                        ? footerLoadMore
                        : null
                Behavior on height {
                    FadeAnimation{}
                }
            }
        }
    }

    Component {
        id: footerLoadMore
        FooterLoadMore {
            onClicked: {
                userPage.userWeiboAddMore();
            }
        }
    }

    Component {
        id: delegateWeibo
        Column {
            width: parent.width
            spacing: Theme.paddingMedium
            WeiboCard {
                id:weiboCard
                width: parent.width - Theme.paddingMedium * 2
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingMedium
                }
                weiboJSONContent: modelWeibo.get(index)//.JSON
                optionMenu: options
                onRepostedWeiboClicked: {
                    toWeiboPage(modelWeibo.get(index).retweeted_status);
                }
                onUsWeiboClicked: {
                    toWeiboPage(modelWeibo.get(index)/*.JSON*/);
                }
                onAvatarHeaderClicked: {
                    toUserPage(userId);
                }
                onLabelLinkClicked: {
                    Qt.openUrlExternally(link);
                }
                onLabelImageClicked: {
                    toGalleryPage(modelImages, index);
                }
                ContextMenu {
                    id:options
                    MenuItem {
                        text: qsTr("Repost")
                        onClicked: {
                            toSendPage("repost", {"id": model.id},
                                       (model.retweeted_status == undefined || model.retweeted_status == "") == true ?
                                           "" :
                                           "//@"+model.user.name +": " + model.text ,
                                           true)
                        }
                    }
                    MenuItem {
                        text: qsTr("Comment")
                        onClicked: {
                            toSendPage("comment", {"id": model.id}, "", true)
                        }
                    }
                }
            }
            Separator {
                width: parent.width
                color: Theme.highlightColor
            }
            Item {
                width: parent.width
                height: Theme.paddingSmall
            }
        }
    }

    Component {
        id: userInfoComponent
        Column {
            id: wrapper
            width: implicitWidth
            spacing: Theme.paddingMedium
            Item {
                id: topItem
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: childrenRect.height
                // user
                Item {
                    id: userArea
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
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
                            source: userInfoObject.userInfo.avatar_hd
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
                                text: userInfoObject.userInfo.screen_name
                            }

                            Label {
                                id: labelLocation
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeSmall
                                width: labelUserName.width
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: userInfoObject.userInfo.location
                            }
                            OptionItem {
                                id:optionItem
                                width: parent.width
                                visible: userInfoObject.userInfo.id != tokenProvider.uid
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
                                        if (_isFollowing == true) {
                                            if (userInfoObject.userInfo.follow_me == true) {
                                                return qsTr("Bilateral")
                                            } else {
                                                return qsTr("Following")
                                            }
                                        } else {
                                            if (userInfoObject.userInfo.follow_me == true) {
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
                                            if (_isFollowing == true) {
                                                return qsTr("CancelFollowing");
                                            } else {
                                                return qsTr("Follow");
                                            }
                                        }
                                        onClicked: {
                                            if (_isFollowing == true) {
                                                userFollowCancel();
                                            } else {
                                                userFollowCreate();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                }
                // description
                Item {
                    id: description
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: userArea.bottom
                    }
                    height: colDesc.height + Theme.paddingMedium

                    Column {
                        id: colDesc
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins:Theme.paddingSmall
                        }
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
                            text: userInfoObject.userInfo.description
                        }
                    }

                }

                // friends
                Column {
                    id: infoBar
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: description.bottom
                    }
                    spacing: Theme.paddingSmall
                    Row {
                        id: rowFriends
                        anchors.horizontalCenter: parent.horizontalCenter
                        Item {
                            width: innerAreaColumn.width/3 - Theme.paddingSmall
                            height: Theme.fontSizeSmall
                            Label {
                                anchors.centerIn: parent
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeTiny
                                text: qsTr("Weibo: ") + userInfoObject.userInfo.statuses_count
                            }
                        }
                        Rectangle {
                            width: 1
                            height: Theme.fontSizeSmall -2
                            color: Theme.highlightColor
                        }
                        Item {
                            width: innerAreaColumn.width/3 - Theme.paddingSmall
                            height: Theme.fontSizeSmall
                            Label {
                                anchors.centerIn: parent
                                color: Theme.secondaryColor
                                font.pixelSize:Theme.fontSizeTiny
                                text: qsTr("following: ") + userInfoObject.userInfo.friends_count
                            }
                            //TODO 似乎第三方客户端无法调用除本身意外的其他用户的follower/following信息
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    //pageStack.replace(Qt.resolvedUrl("FriendsPage.qml"), { mode: "following", uid: userInfoObject.userInfo.id })
                                    toFriendsPage("following", userInfoObject.userInfo.id);
                                }
                            }
                        }
                        Rectangle {
                            width: 1
                            height: Theme.fontSizeSmall - 2
                            color: Theme.highlightColor
                        }
                        Item {
                            width: innerAreaColumn.width/3 - Theme.paddingSmall
                            height: Theme.fontSizeSmall
                            Label {
                                anchors.centerIn: parent
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeTiny
                                text: qsTr("follower: ") + userInfoObject.userInfo.followers_count
                            }
                            //TODO 似乎第三方客户端无法调用除本身意外的其他用户的follower/following信息
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
//                                    pageStack.replace(Qt.resolvedUrl("FriendsPage.qml"), { mode: "follower", uid: userInfoObject.userInfo.id })
                                    toFriendsPage("follower", userInfoObject.userInfo.id);
                                }
                            }
                        }

                    }

                    Separator {
                        width: parent.width
                        color: Theme.highlightColor
                    }
                }
            } //topItem
            ///////////////////////////////
            Label {
                id:title
                anchors.horizontalCenter: parent.horizontalCenter
                //            opacity: userPage._showUserWeibo ? 0 : 1
                height: /*userPage._showUserWeibo ? 0 : */implicitHeight
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium
                text: userInfoObject.userInfo.screen_name + qsTr("'s RecentWeibo")
//                Behavior on opacity {
//                    FadeAnimation{}
//                }
//                Behavior on height {
//                    FadeAnimation{}
//                }
            }
        }
    }
}
