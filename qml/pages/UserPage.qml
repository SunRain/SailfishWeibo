import QtQuick 2.0
//import QtQuick 2.2
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../components"

import com.sunrain.sinaweibo 1.0

Page {
    id: userPage
    
    property var uid
    property bool _isFollowing: false

    property int _pageNum: 1

    property bool _showUserWeibo: false
    property bool _refreshUserWeiboLock: false
    property bool _refreshUserInfoLock: false
    property var _userWeiboCache

    UserInfoObject {
        id: userInfoObject
    }

    Component.onCompleted: {
//        //userGetInfo(Settings.getAccess_token())
//        var method = WeiboMethod.WBOPT_GET_USERS_SHOW;
//        api.setWeiboAction(method, {'uid':uid});
        showuserInfo();
    }

    function refreshUserWeibo() {
        showBusyIndicator();
        _pageNum = 1;
        var method = WeiboMethod.WBOPT_GET_STATUSES_USER_TIMELINE;
        api.setWeiboAction(method, {'page':_pageNum,
                               'uid':userInfoObject.usrInfo.id});
    }

    function showUserWeibo() {
        modelWeibo.clear();
        if (userPage._refreshUserWeiboLock) {
            for (var i=0; i<userPage._userWeiboCache.statuses.length; i++) {
                modelWeibo.append({"JSON":userPage._userWeiboCache.statuses[i] } )
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
        var method = WeiboMethod.WBOPT_GET_USERS_SHOW;
        api.setWeiboAction(method, {'uid':uid});
    }

    function showuserInfo() {
        modelWeibo.clear();
        if (userPage._refreshUserInfoLock) {
            modelWeibo.append({"JSON":userInfoObject.usrInfo.status});
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
        var method = WeiboMethod.WBOPT_GET_STATUSES_USER_TIMELINE;
        api.setWeiboAction(method, {'page':_pageNum,
                               'uid':userInfoObject.usrInfo.id
                               /*,'access_token':Settings.getAccess_token()*/});
    }

    Connections {
        target: api
        //void weiboPutSucceed(QWeiboMethod::WeiboAction action, const QString& replyData);
        onWeiboPutSucceed: {
            if (action == WeiboMethod.WBOPT_GET_USERS_SHOW) {
                userInfoObject.usrInfo = JSON.parse(replyData);
                _isFollowing = userInfoObject.usrInfo.following;
                modelWeibo.append({"JSON":userInfoObject.usrInfo.status});
                if (lvUserWeibo.model == undefined) {
                    lvUserWeibo.model = modelWeibo;
                }
            }
            if (action == WeiboMethod.WBOPT_POST_FRIENDSHIPS_CREATE) {
                _isFollowing = true;
            }
            if (action == WeiboMethod.WBOPT_POST_FRIENDSHIPS_DESTROY) {
                _isFollowing = false;
            }
            if (action == WeiboMethod.WBOPT_GET_STATUSES_USER_TIMELINE) {
                userPage._userWeiboCache = JSON.parse(replyData);
                for (var i=0; i<userPage._userWeiboCache.statuses.length; i++) {
                    modelWeibo.append({"JSON":userPage._userWeiboCache.statuses[i] } )
                }
                if (lvUserWeibo.model == undefined) {
                    lvUserWeibo.model = modelWeibo;
                }
                stopBusyIndicator();
            }
        }
    }
    
    function userFollowCreate() {
        var method = WeiboMethod.WBOPT_POST_FRIENDSHIPS_CREATE;
        api.setWeiboAction(method, {'uid':uid});
    }
    
    function userFollowCancel() {
        var method = WeiboMethod.WBOPT_POST_FRIENDSHIPS_DESTROY;
        api.setWeiboAction(method, {'uid':uid});
    }
    
    ListModel {
        id: modelWeibo
    }

    SilicaFlickable {
        id: scrollArea
        boundsBehavior: (contentHeight > height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
        anchors.fill: parent
        contentHeight: userPage._showUserWeibo ? Screen.height : innerAreaColumn.height + Theme.paddingSmall
        
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
                height: Math.max(Theme.itemSizeLarge, childrenRect.height)

                Rectangle {
                    z: -1
                    width: pageHeader.width
                    height: pageHeader.height
                    color: Theme.highlightDimmerColor
                    opacity: scrollArea.moving || lvUserWeibo.moving || userPage._showUserWeibo ? 0.5 : 0.0
                    Behavior on opacity { FadeAnimation { } }
                }
                Label {
                    id: label
                    anchors {
                        right: image.left
                        margins: Theme.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                    font.pixelSize: Theme.fontSizeLarge
                    color: mouseArea.pressed ? Theme.highlightColor : Theme.primaryColor
                    text: qsTr("About user")
                }
                Image {
                    id: image
                    anchors {
                        right: parent.right
                        margins: Theme.paddingMedium
                        verticalCenter: label.verticalCenter
                    }
                    width: implicitWidth
                    height: implicitHeight
                    source: userPage._showUserWeibo
                            ? "../graphics/action_collapse.png"
                            : "../graphics/action_open.png"
//                    RotationAnimator on rotation {
//                        id: animation
//                        from: userPage._showUserWeibo ? 0 : 180
//                        to: userPage._showUserWeibo ? 180 : 360
//                    }

                }
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onClicked: {
//                        animation.running = true;
                        userPage._showUserWeibo = !userPage._showUserWeibo;
                        if(userPage._showUserWeibo) {
                            userPage.showUserWeibo();
                        } else {
                            userPage.showuserInfo();
                        }
                    }
                }

            }
            Item {
                id: topItem
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: userPage._showUserWeibo ? 0 : childrenRect.height
                opacity: userPage._showUserWeibo ? 0 : 1
                Behavior on opacity {
                    FadeAnimation{}
                }
                Behavior on height {
                    FadeAnimation{}
                }

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
                            source: userInfoObject.usrInfo.avatar_hd
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
                                text: userInfoObject.usrInfo.screen_name
                            }

                            Label {
                                id: labelLocation
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeSmall
                                width: labelUserName.width
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: userInfoObject.usrInfo.location
                            }
                            OptionItem {
                                id:optionItem
                                //width: rowUserColumn.width
                                anchors{
                                    left: parent.left
                                    right: parent.right
                                }
                                visible: userInfoObject.usrInfo.id != Settings.getUid()
                                Rectangle {
                                    width: parent.width
                                    height: parent.height
                                    border.color:Theme.highlightColor
                                    color:"#00000000"
                                    radius: 15
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
                                                if (userInfoObject.usrInfo.follow_me == true) {
                                                    return qsTr("Bilateral")
                                                } else {
                                                    return qsTr("Following")
                                                }
                                            } else {
                                                if (userInfoObject.usrInfo.follow_me == true) {
                                                    return qsTr("Follower")
                                                } else {
                                                    return qsTr("Follow")
                                                }
                                            }
                                        }
                                    }
                                    Image {
                                        anchors{
                                            top:parent.top
                                            bottom: parent.bottom
                                            right: parent.right
                                        }
                                        width: Theme.iconSizeMedium
                                        height: width
                                        source: optionItem.menuOpen ?
                                                    "../graphics/action_collapse.png" :
                                                    "../graphics/action_open.png"
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
                            text: userInfoObject.usrInfo.description
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
                                text: qsTr("Weibo: ") + userInfoObject.usrInfo.statuses_count
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
                                text: qsTr("following: ") + userInfoObject.usrInfo.friends_count
                            }
                            //TODO 似乎第三方客户端无法调用除本身意外的其他用户的follower/following信息
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    pageStack.replace(Qt.resolvedUrl("FriendsPage.qml"), { mode: "following", uid: userInfoObject.usrInfo.id })
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
                                text: qsTr("follower: ") + userInfoObject.usrInfo.followers_count
                            }
                            //TODO 似乎第三方客户端无法调用除本身意外的其他用户的follower/following信息
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    pageStack.replace(Qt.resolvedUrl("FriendsPage.qml"), { mode: "follower", uid: userInfoObject.usrInfo.id })
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
                opacity: userPage._showUserWeibo ? 0 : 1
                height: userPage._showUserWeibo ? 0 : implicitHeight
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium
                text: userInfoObject.usrInfo.screen_name + qsTr("'s RecentWeibo")
                Behavior on opacity {
                    FadeAnimation{}
                }
                Behavior on height {
                    FadeAnimation{}
                }
            }

            SilicaListView{
                id: lvUserWeibo
                width: parent.width
                height: userPage._showUserWeibo
                        ? userPage.height - pageHeader.height
                          - Theme.itemSizeMedium //the FooterLoadMore height
                        : lvUserWeibo.contentHeight
                parent: userPage._showUserWeibo ? userPage : innerAreaColumn
                anchors{
                    top: userPage._showUserWeibo ? pageHeader.bottom : undefined
                    topMargin: userPage._showUserWeibo ? pageHeader.height : undefined
                }

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
            anchors{left:parent.left; right:parent.right }
            spacing: Theme.paddingMedium

            Item {
                anchors{left:parent.left; right:parent.right; }
                height: childrenRect.height
                WeiboCard {
                    id:weiboCard
                    weiboJSONContent: modelWeibo.get(index).JSON
                    optionMenu: options
                    onRepostedWeiboClicked: {
                        toWeiboPage(modelWeibo.get(index).JSON.retweeted_status);
                    }
                    onUsWeiboClicked: {
                        toWeiboPage(modelWeibo.get(index).JSON);
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
                                           (model.JSON.retweeted_status == undefined || model.JSON.retweeted_status == "") == true ?
                                               "" :
                                               "//@"+model.JSON.user.name +": " + model.JSON.text ,
                                               true)
                            }
                        }
                        MenuItem {
                            text: qsTr("Comment")
                            onClicked: {
                                toSendPage("comment", {"id": model.JSON.id}, "", true)
                            }
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
}
