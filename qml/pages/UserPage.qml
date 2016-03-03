import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

import "../WeiboFunctions.js" as WBLoader
import "../js/Utility.js" as Utility
import "../components"
import "../ui"

Page {
    id: userPage
    
    property var uid: undefined
    property var uname: undefined

    property bool _isFollowing: false

    property int _pageNum: 1

    property bool _showUserWeibo: false
    property bool _refreshUserWeiboLock: false
    property bool _refreshUserInfoLock: false
    property bool _pageActive: false

    QtObject {
        id: inner
        property var userInfoObject: null
        property var requestUsersShow: null
        property var userWeiboListScheme

        function refreshUserInfo() {
            wbFunc.showBusyIndicator();
            if (tokenProvider.useHackLogin && tokenProvider.hackLoginUid != userPage.uid) {
                if (userPage.uid) {
                    var path = "u/"+userPage.uid;
                } else if (userPage.uname) {
                    path = userPage.uname;
                }
                requestUsersShow.resetUrlPath(path);
            }
            requestUsersShow.setParameters("uid", uid);
            requestUsersShow.getRequest();
        }

        function parseUsersShowData(replyData) {
            if (tokenProvider.useHackLogin) {
                Utility.parserOthersUserInfo(inner.userInfoObject, JSON.parse(replyData));
                if (uname && !uid)
                    uid = inner.userInfoObject.id;
                inner.userWeiboListScheme = inner.userInfoObject.userWeiboListScheme;
            } else {
                inner.userInfoObject.userInfo = JSON.parse(replyData);
            }
            _isFollowing = inner.userInfoObject.following;
            modelWeibo.append(inner.userInfoObject.userInfo.status);
            wbFunc.stopBusyIndicator();
        }

        function createUsersShow(callback) {
            if (tokenProvider.useHackLogin) {
                console.log("====== UserPage show other users info =====");
                if (inner.requestUsersShow)
                    WBLoader.cleanup(inner.requestUsersShow, null, null);
                WBLoader.create("../requests/RQHackUsersInfo.qml", userPage, function(object, component, incubator) {
                    inner.requestUsersShow = object;
                    if (inner.requestUsersShow) {
                        inner.requestUsersShow.requestResult.connect(function(ret, replyData) {
                            console.log("=== HackUsersInfo connect ===");
                            if (ret == BaseRequest.RET_ABORT) {
                                console.log("== HackUsersInfo onRequestAbort");
                            } else if (ret == BaseRequest.RET_FAILURE) {
                                console.log("== HackUsersInfo onRequestFailure ["+replyData+"]")
                            } else {
                                console.log("== HackUsersInfo onRequestSuccess ["+replyData+"]")
                                //create UserInfoObject if not created
                                if (!inner.userInfoObject) {
                                    WBLoader.create("../components/UserInfoObject.qml", userPage,
                                                    function(object, component, incubator){
                                                        if (object)
                                                            inner.userInfoObject = object;
                                                        parseUsersShowData(replyData)
                                                    });
                                } else {
                                    parseUsersShowData(replyData);
                                }
                            }
                        });
                        callback.call(this, inner.requestUsersShow);
                    } else {
                        callback.call(this, inner.requestUsersShow);
                    }
                });
            } else {
                WBLoader.create("../requests/OauthUsersShow.qml", userPage, function(object, component, incubator) {
                    inner.requestUsersShow = object;
                    if (inner.requestUsersShow) {
                        inner.requestUsersShow.requestResult.connect(function(ret, replyData) {
                            console.log("=== UsersShow connect ===");
                            if (ret == BaseRequest.RET_ABORT) {
                                console.log("== UsersShow onRequestAbort");
                            } else if (ret == BaseRequest.RET_FAILURE) {
                                console.log("== UsersShow onRequestFailure ["+replyData+"]")
                            } else {
                                console.log("== HackUsersInfoMe onRequestSuccess ["+replyData+"]")
                                //create UserInfoObject if not created
                                if (!inner.userInfoObject) {
                                    WBLoader.create("../components/UserInfoObject.qml", userPage,
                                                    function(object, component, incubator){
                                                        if (object)
                                                            inner.userInfoObject = object;
                                                        parseUsersShowData(replyData)
                                                    });
                                } else {
                                    parseUsersShowData(replyData);
                                }
                            }
                        });
                        callback.call(this, inner.requestUsersShow);
                    } else {
                        callback.call(this, inner.requestUsersShow);
                    }
                });
            }
        }
    }

    onStatusChanged: {
        if (userPage.status == PageStatus.Active || userPage.status == PageStatus.Activating) {
            userPage._pageActive = true;
        } else {
            userPage._pageActive = false;
        }
    }

    function refreshUserWeibo() {
        wbFunc.showBusyIndicator();
        _pageNum = 1;
        statusesUserTimeline.setParameters("page", _pageNum)
        statusesUserTimeline.setParameters("uid", userPage.uid);
        if (tokenProvider.useHackLogin)
            statusesUserTimeline.setParameters("containerid", inner.userWeiboListScheme);
        statusesUserTimeline.getRequest();
    }
    function showUserWeibo() {
        modelWeibo.clear();
        refreshUserWeibo();
    }


    function showUserInfo() {
        if (tokenProvider.useHackLogin && tokenProvider.hackLoginUid == userPage.uid) {
            inner.userInfoObject = userMeObject;
            inner.userWeiboListScheme = userMeObject.userWeiboListScheme;
        } else {
            modelWeibo.clear();
            if (!inner.requestUsersShow) {
                inner.createUsersShow(function(obj) {
                    if (obj)
                        inner.requestUsersShow = obj;
                    inner.refreshUserInfo();
                });
            } else {
                inner.refreshUserInfo();
            }
        }
    }

    function userWeiboAddMore() {
        wbFunc.showBusyIndicator();
        _pageNum++
        statusesUserTimeline.setParameters("page", _pageNum);
        statusesUserTimeline.setParameters("uid", userPage.uid);
        if (tokenProvider.useHackLogin)
            statusesUserTimeline.setParameters("containerid", inner.userWeiboListScheme);
        statusesUserTimeline.getRequest();
    }
    WrapperStatusesUserTimeline {
        id: statusesUserTimeline
        onRequestAbort: {
            console.log("== statusesUserTimeline onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== statusesUserTimeline onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            console.log("== statusesUserTimeline onRequestSuccess ["+replyData+"]")

            var data = JSON.parse(replyData);
            for (var i=0; i<data.statuses.length; i++) {
                modelWeibo.append(data.statuses[i])
            }
            wbFunc.stopBusyIndicator();
        }
    }

    WrapperFriendshipsCreate {
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
    WrapperFriendshipsDestroy {
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
    Loader {
        id: mainLoader
        anchors {
            top: parent.top
            bottom: toolBar.top
        }
        width: parent.width
        sourceComponent: userPage._showUserWeibo ? webiboListComponent : userInfoTabComponent
        onStatusChanged: {
            if (mainLoader.status == Loader.Ready) {
                if (userPage._showUserWeibo)
                    userPage.showUserWeibo();
                else
                    userPage.showUserInfo();
            }
        }
    }

    Rectangle {
        id: toolBar
        width: parent.width
        height: Theme.itemSizeMedium
        anchors.bottom: parent.bottom
        color: Theme.highlightDimmerColor
        property int index: userPage._showUserWeibo ? 1 : 0
        Rectangle {
            id: indicator
            anchors.top: toolBar.top
            height: Theme.paddingSmall
            color: Theme.highlightColor
            width: toolBar.width/2
            x: toolBar.width * toolBar.index/2
            Behavior on x {
                NumberAnimation {duration: 200}
            }
        }
        Row {
            anchors.centerIn: parent
            BackgroundItem {
                width: toolBar.width/2
                Label {
                    anchors.centerIn: parent
                    text: qsTr("UserInfo")
                    color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                onClicked: {
                    userPage._showUserWeibo = false;
                }
            }
            BackgroundItem {
                width: toolBar.width/2
                Label {
                    anchors.centerIn: parent
                    text: qsTr("UserWeibo")
                    color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                onClicked: {
                    userPage._showUserWeibo = true;
                }
            }
        }
    }

    Component {
        id: userInfoTabComponent
        Flickable {
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Theme.horizontalPageMargin
                rightMargin: Theme.horizontalPageMargin
            }
            height: parent.height
            contentHeight: column.height
            boundsBehavior: (contentHeight > height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
            Column {
                id: column
                width: parent.width
                spacing: Theme.paddingMedium
                PageHeader {
                    title: qsTr("User Info")
                }
                UserInfoTab {
                    id: userInfoTab
                    userInfoObject: inner.userInfoObject
                    onFollowStateChanged: {
                        if (_isFollowing)
                            userFollowCancel();
                        else
                            userFollowCreate();
                    }
                }
                ////////// hack login does not support below
                Column {
                    width: parent.width
                    spacing: Theme.paddingMedium
                    visible: !tokenProvider.useHackLogin
                    enabled: !tokenProvider.useHackLogin
                    Separator {
                        width: parent.width
                        color: Theme.highlightColor
                    }
                    Label {
                        id:title
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: implicitHeight
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeMedium
                        text: inner.userInfoObject.screen_name + qsTr("'s RecentWeibo")
                    }
                    WeiboCard {
                        id:weiboCard
                        width: parent.width - Theme.paddingMedium * 2
                        anchors {
                            left: parent.left
                            leftMargin: Theme.paddingMedium
                        }
                        weiboJSONContent: inner.userInfoObject.userInfo.status[0]
                        onRepostedWeiboClicked: {
                            wbFunc.toWeiboPage(inner.userInfoObject.userInfo.status[0].retweeted_status);
                        }
                        onUsWeiboClicked: {
                            wbFunc.toWeiboPage(inner.userInfoObject.userInfo.status[0]);
                        }
                        onAvatarHeaderClicked: {
                            wbFunc.toUserPage(userId);
                        }
                        onLabelLinkClicked: {
                            Qt.openUrlExternally(link);
                        }
                        onLabelImageClicked: {
                            wbFunc.toGalleryPage(modelImages, index);
                        }
                    }
                }
            }
        }
    }
    Component {
        id: webiboListComponent
        SilicaListView{
            id: lvUserWeibo
            anchors.fill: parent
            header: PageHeader {
                title: inner.userInfoObject.screen_name + qsTr("'s Weibo")
            }
            clip: true
            cacheBuffer: 9999
            model: modelWeibo
            delegate: delegateWeibo
            footer: FooterLoadMore {
                onClicked: {
                    userPage.userWeiboAddMore();
                }
            }
            Behavior on height {
                FadeAnimation{}
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
                weiboJSONContent: modelWeibo.get(index)
                optionMenu: options
                onRepostedWeiboClicked: {
                    wbFunc.toWeiboPage(modelWeibo.get(index).retweeted_status);
                }
                onUsWeiboClicked: {
                    wbFunc.toWeiboPage(modelWeibo.get(index));
                }
                onAvatarHeaderClicked: {
                    wbFunc.toUserPage(userId);
                }
                onLabelLinkClicked: {
                }
                onLinkAtClicked: {
                    wbFunc.toUserPage("", link.replace(/\//, ""))
                }
                onLinkTopicClicked: {
                    console.log("==== onLinkTopicClicked "+ link)
                    Qt.openUrlExternally(link);
                }
                onLinkUnknowClicked: {
                    Qt.openUrlExternally(link);
                }
                onLinkWebOrVideoClicked: {
                    console.log("==== onLinkWebOrVideoClicked "+ link)
                    Qt.openUrlExternally(link);
                }
                onLabelImageClicked: {
                    wbFunc.toGalleryPage(modelImages, index);
                }
                ContextMenu {
                    id:options
                    MenuItem {
                        text: qsTr("Repost")
                        onClicked: {
                            wbFunc.toSendPage("repost", {"id": model.id},
                                       (model.retweeted_status == undefined || model.retweeted_status == "") == true ?
                                           "" :
                                           "//@"+model.user.name +": " + model.text ,
                                           true)
                        }
                    }
                    MenuItem {
                        text: qsTr("Comment")
                        onClicked: {
                            wbFunc.toSendPage("comment", {"id": model.id}, "", true)
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

//    Component {
//        id: userInfoComponent
//        Column {
//            id: wrapper
//            width: implicitWidth
//            spacing: Theme.paddingMedium
//            Item {
//                id: topItem
//                anchors {
//                    left: parent.left
//                    right: parent.right
//                }
//                height: childrenRect.height
//                // user
//                Item {
//                    id: userArea
//                    anchors {
//                        left: parent.left
//                        right: parent.right
//                    }
//                    height: rowUser.height + Theme.paddingMedium

//                    Row {
//                        id: rowUser
//                        anchors {
//                            left: parent.left
//                            right: parent.right
//                            top: parent.top
//                            margins: Theme.paddingSmall
//                        }
//                        spacing: Theme.paddingMedium
//                        Image {
//                            id: usAvatar
//                            width: 160
//                            height: width
//                            anchors.verticalCenter: rowUserColumn.verticalCenter
//                            smooth: true
//                            fillMode: Image.PreserveAspectFit
//                            source: userInfoObject.userInfo.avatar_hd
//                        }

//                        Column {
//                            id:rowUserColumn
//                            spacing: Theme.paddingSmall

//                            Label {
//                                id: labelUserName
//                                color: Theme.primaryColor
//                                font.pixelSize: Theme.fontSizeMedium
//                                width:rowUser.width - usAvatar.width - Theme.paddingMedium
//                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
//                                text: userInfoObject.userInfo.screen_name
//                            }

//                            Label {
//                                id: labelLocation
//                                color: Theme.secondaryColor
//                                font.pixelSize: Theme.fontSizeSmall
//                                width: labelUserName.width
//                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
//                                text: userInfoObject.userInfo.location
//                            }
//                            OptionItem {
//                                id:optionItem
//                                width: parent.width
//                                visible: userInfoObject.userInfo.id != tokenProvider.uid
//                                Rectangle {
//                                    z: optionItem.z - 1
//                                    width: optionItem.width
//                                    height: optionItem.height
//                                    anchors.left: optionItem.left
//                                    anchors.top: optionItem.top
//                                    border.color:Theme.highlightColor
//                                    color:"#00000000"
//                                    radius: 15
//                                }
//                                Label {
//                                    anchors {
//                                        verticalCenter: parent.verticalCenter
//                                        left: parent.left
//                                        leftMargin: Theme.paddingSmall
//                                    }
//                                    color: Theme.primaryColor
//                                    font.pixelSize: Theme.fontSizeMedium
//                                    text: {
//                                        if (_isFollowing == true) {
//                                            if (userInfoObject.userInfo.follow_me == true) {
//                                                return qsTr("Bilateral")
//                                            } else {
//                                                return qsTr("Following")
//                                            }
//                                        } else {
//                                            if (userInfoObject.userInfo.follow_me == true) {
//                                                return qsTr("Follower")
//                                            } else {
//                                                return qsTr("Follow")
//                                            }
//                                        }
//                                    }
//                                }
//                                menu: optionMenu
//                                ContextMenu {
//                                    id:optionMenu
//                                    MenuItem {
//                                        text: {
//                                            if (_isFollowing == true) {
//                                                return qsTr("CancelFollowing");
//                                            } else {
//                                                return qsTr("Follow");
//                                            }
//                                        }
//                                        onClicked: {
//                                            if (_isFollowing == true) {
//                                                userFollowCancel();
//                                            } else {
//                                                userFollowCreate();
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }

//                }
//                // description
//                Item {
//                    id: description
//                    anchors {
//                        left: parent.left
//                        right: parent.right
//                        top: userArea.bottom
//                    }
//                    height: colDesc.height + Theme.paddingMedium

//                    Column {
//                        id: colDesc
//                        anchors {
//                            left: parent.left
//                            right: parent.right
//                            top: parent.top
//                            margins:Theme.paddingSmall
//                        }
//                        spacing: Theme.paddingSmall

//                        Label {
//                            id: labelDesc
//                            color: Theme.highlightColor
//                            font.pixelSize: Theme.fontSizeMedium
//                            text: qsTr("Description: ")
//                        }

//                        Label {
//                            id: labelDescription
//                            color: Theme.primaryColor
//                            width: parent.width
//                            font.pixelSize: Theme.fontSizeMedium
//                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
//                            text: userInfoObject.userInfo.description
//                        }
//                    }

//                }

//                // friends
//                Column {
//                    id: infoBar
//                    anchors {
//                        left: parent.left
//                        right: parent.right
//                        top: description.bottom
//                    }
//                    spacing: Theme.paddingSmall
//                    Row {
//                        id: rowFriends
//                        anchors.horizontalCenter: parent.horizontalCenter
//                        Item {
//                            width: innerAreaColumn.width/3 - Theme.paddingSmall
//                            height: Theme.fontSizeSmall
//                            Label {
//                                anchors.centerIn: parent
//                                color: Theme.secondaryColor
//                                font.pixelSize: Theme.fontSizeTiny
//                                text: qsTr("Weibo: ") + userInfoObject.userInfo.statuses_count
//                            }
//                        }
//                        Rectangle {
//                            width: 1
//                            height: Theme.fontSizeSmall -2
//                            color: Theme.highlightColor
//                        }
//                        Item {
//                            width: innerAreaColumn.width/3 - Theme.paddingSmall
//                            height: Theme.fontSizeSmall
//                            Label {
//                                anchors.centerIn: parent
//                                color: Theme.secondaryColor
//                                font.pixelSize:Theme.fontSizeTiny
//                                text: qsTr("following: ") + userInfoObject.userInfo.friends_count
//                            }
//                            //TODO 似乎第三方客户端无法调用除本身意外的其他用户的follower/following信息
//                            MouseArea {
//                                anchors.fill: parent
//                                onClicked: {
//                                    //pageStack.replace(Qt.resolvedUrl("FriendsPage.qml"), { mode: "following", uid: userInfoObject.userInfo.id })
//                                    wbFunc.toFriendsPage("following", userInfoObject.userInfo.id);
//                                }
//                            }
//                        }
//                        Rectangle {
//                            width: 1
//                            height: Theme.fontSizeSmall - 2
//                            color: Theme.highlightColor
//                        }
//                        Item {
//                            width: innerAreaColumn.width/3 - Theme.paddingSmall
//                            height: Theme.fontSizeSmall
//                            Label {
//                                anchors.centerIn: parent
//                                color: Theme.secondaryColor
//                                font.pixelSize: Theme.fontSizeTiny
//                                text: qsTr("follower: ") + userInfoObject.userInfo.followers_count
//                            }
//                            //TODO 似乎第三方客户端无法调用除本身意外的其他用户的follower/following信息
//                            MouseArea {
//                                anchors.fill: parent
//                                onClicked: {
////                                    pageStack.replace(Qt.resolvedUrl("FriendsPage.qml"), { mode: "follower", uid: userInfoObject.userInfo.id })
//                                    wbFunc.toFriendsPage("follower", userInfoObject.userInfo.id);
//                                }
//                            }
//                        }

//                    }

//                    Separator {
//                        width: parent.width
//                        color: Theme.highlightColor
//                    }
//                }
//            } //topItem
//            ///////////////////////////////
//            Label {
//                id:title
//                anchors.horizontalCenter: parent.horizontalCenter
//                //            opacity: userPage._showUserWeibo ? 0 : 1
//                height: /*userPage._showUserWeibo ? 0 : */implicitHeight
//                color: Theme.highlightColor
//                font.pixelSize: Theme.fontSizeMedium
//                text: userInfoObject.userInfo.screen_name + qsTr("'s RecentWeibo")
////                Behavior on opacity {
////                    FadeAnimation{}
////                }
////                Behavior on height {
////                    FadeAnimation{}
////                }
//            }
//        }
//    }
}
