import QtQuick 2.0
//import QtQuick.XmlListModel 2.0
//import Ubuntu.Components 0.1
//import Ubuntu.Components.ListItems 0.1 as ListItem
//import Ubuntu.Components.Popups 0.1
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../components"

Page {
    id: userPage

    property var uid
    property var userInfo: {"id":-1,"idstr":"","class":1,"screen_name":"","name":"","province":"","city":"","location":"","description":"","url":"","profile_image_url":"","profile_url":"","domain":"","weihao":"","gender":"","followers_count":0,"friends_count":0,"statuses_count":0,"favourites_count":0,"created_at":"Sun Jan 22 13:32:37 +0800 1999","following":false,"allow_all_act_msg":false,"geo_enabled":true,"verified":false,"verified_type":-1,"remark":"","status":{"text": "", "reposts_count": 0, "comments_count": 0, "attitudes_count": 0},"ptype":0,"allow_all_comment":true,"avatar_large":"","avatar_hd":"","verified_reason":"","follow_me":false,"online_status":0,"bi_followers_count":0,"lang":"zh-cn","star":0,"mbtype":0,"mbrank":0,"block_word":0}
    property bool isFollowing: false

    Component.onCompleted: {
        userGetInfo(Settings.getAccess_token())
    }
    
    function userGetInfo(token)
    {
        function observer() {}
        observer.prototype = {
            update: function(status, result)
            {
                if(status != "error"){
                    if(result.error) {
                        // TODO  error handler
                    }else {
                        // right result
                        userInfo = result
                        isFollowing = result.following
                    }
                }else{
                    // TODO  empty result
                }
            }
        }

        WB.userGetInfoByUid(token, uid, new observer())
    }

    function userFollowCreate()
    {
        function observer() {}
        observer.prototype = {
            update: function(status, result)
            {
                if(status != "error"){
                    if(result.error) {
                        // TODO  error handler
                    }else {
                        // right result
//                        userInfo = result
//                        userInfo.following = true
                        isFollowing = true
                    }
                }else{
                    // TODO  empty result
                }
            }
        }

        WB.userFriendshipCreate(Settings.getAccess_token(), uid, new observer())
    }

    function userFollowCancel()
    {
        function observer() {}
        observer.prototype = {
            update: function(status, result)
            {
                if(status != "error"){
                    if(result.error) {
                        // TODO  error handler
                    }else {
                        // right result
//                        userInfo = result
//                        userInfo.following = false
                        isFollowing = false
                    }
                }else{
                    // TODO  empty result
                }
            }
        }

        WB.userFriendshipdestroy(Settings.getAccess_token(), uid, new observer())
    }

    SilicaFlickable {
        id: scrollArea
        //boundsBehavior: (contentHeight > height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
        anchors.fill: parent
        //contentWidth: width
        contentHeight: innerAreaColumn.height + Theme.paddingSmall

        Column {
            id: innerAreaColumn

            spacing: Theme.paddingMedium
            anchors {
                top: parent.top;
                left: parent.left
                right: parent.right
            }
            
            PageHeader {
                id:pageHeader
                title: qsTr("About user")
            }
            
            // user
            Item {
                anchors { left: parent.left; right: parent.right }
                height: rowUser.height + Theme.paddingMedium
                //color: Qt.rgba(255, 255, 255, 0.5)

                Row {
                    id: rowUser
                    anchors { 
                        left: parent.left
                        //right: parent.right
                        top: parent.top
                        margins: Theme.paddingSmall
                    }
                    spacing: Theme.paddingMedium
                    height: Math.max(rowUserColumn.height,usAvatar.height)//usAvatar.height

                    Item {
                        id: usAvatar
                        width: 160
                        height: width
                        //radius: "medium"
                        Image {
                            width: parent.width
                            height: parent.height
                            smooth: true
                            fillMode: Image.PreserveAspectFit
                            source: userInfo.avatar_hd
                        }
                    }

                    Column {
                        id:rowUserColumn
                        //width: childrenRect.width
                        spacing: Theme.paddingSmall

                        Label {
                            id: labelUserName
                            color: Theme.primaryColor
                            font.pixelSize: Theme.fontSizeMedium
                            width: parent.width
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: userInfo.screen_name
                        }

                        Label {
                            id: labelLocation
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall 
                            width: parent.width
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: userInfo.location
                        }
                        Button {
                            text: {
                                if (isFollowing == true) {
                                    if (userInfo.follow_me == true) {
                                        return qsTr("Bilateral")
                                    }
                                    else {
                                        return qsTr("Following")
                                    }
                                } else {
                                    if (userInfo.follow_me == true) {
                                        return qsTr("Follower")
                                    }
                                    else {
                                        return qsTr("Follow")
                                    }
                                }
                            }
                            visible: userInfo.id != Settings.getUid()
                            onClicked: {
                                if (isFollowing == true) {
                                    userFollowCancel()
                                } else {
                                    userFollowCreate()
                                }
                            }
                        }
                    }
                }

            }

            // description
            Item {
                anchors { 
                    left: parent.left
                    right: parent.right
                }
                height: colDesc.height + Theme.paddingMedium
 
                Image {
                    anchors {
                        top:parent.top
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    smooth: true
                    fillMode: Image.TileHorizontally
                    source: "../graphics/mask_background_reposted.png"
                }
                
                Column {
                    id: colDesc
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        //bottom: parent.bottom
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
                        text: userInfo.description
                    }
                }

            }

            // friends
            Item {
                anchors { 
                    left: parent.left
                    right: parent.right
                } 
                height: rowFriends.height + Theme.paddingMedium

                Row {
                    id: rowFriends
                    anchors { 
                        left: parent.left
                        right: parent.right
                        margins:  Theme.paddingSmall
                    }
                   spacing: Theme.paddingSmall

                    Item {
                        width: parent.width / 4 - Theme.paddingSmall
                        height: Theme.fontSizeSmall + Theme.paddingSmall

                        Label {
                            anchors.centerIn: parent
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                            text: qsTr("Weibo: ") + userInfo.statuses_count
                        }
                    }
                    Rectangle {
                        width: 2
                        height: parent.height - Theme.paddingSmall
                        color: Theme.highlightColor
                    }
                    Item {
                        width: parent.width / 4 - Theme.paddingSmall
                        height: Theme.fontSizeSmall + Theme.paddingSmall

                        Label {
                            anchors.centerIn: parent
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                            text: qsTr("following: ") + userInfo.friends_count
                        }
                        //TODO 似乎第三方客户端无法调用除本身意外的其他用户的follower/following信息
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                pageStack.replace(Qt.resolvedUrl("FriendsPage.qml"), { mode: "following", uid: userInfo.id })
                            }
                        }
                    }
                    Rectangle {
                        width: 2//units.gu(0.1)
                        height: parent.height - Theme.paddingSmall
                        color: Theme.highlightColor
                    }
                    Item {
                        width: parent.width / 4 - Theme.paddingSmall
                        height: Theme.fontSizeSmall + Theme.paddingSmall

                        Label {
                            anchors.centerIn: parent
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                            text: qsTr("follower: ") + userInfo.followers_count
                        }
                        //TODO 似乎第三方客户端无法调用除本身意外的其他用户的follower/following信息
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                pageStack.replace(Qt.resolvedUrl("FriendsPage.qml"), { mode: "follower", uid: userInfo.id })
                            }
                        }
                    }

                }
            }

            // user weibo
           Item {
                id: usWeiboContent
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: columnWContent.height + Theme.paddingMedium

                property var status: userInfo.status

                signal clicked

                Component.onCompleted: {
                    if (status.pic_urls != undefined && status.pic_urls.count > 0) {
                        modelImages.clear()
                        for (var i=0; i<status.pic_urls.count; i++) {
                            modelImages.append( status.pic_urls.get(i) )
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        toUserWeibo(userInfo.id, userInfo.screen_name)
                    }
                }

                Image {
                    id: imageBackground
                    width: parent.width
                    height: parent.height
                    fillMode: Image.PreserveAspectCrop
                    source: "../graphics/mask_background_grid.png"
                }
                
                Column {
                    id: columnWContent
                    anchors {
                        top: parent.top
                        topMargin: Theme.paddingMedium
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.paddingMedium
                        rightMargin: Theme.paddingMedium
                    }
                    spacing: Theme.paddingSmall
                    Column {
                        id: colUser
                        anchors { 
                            left: parent.left
                            right: parent.right
                        }
                        spacing: Theme.paddingSmall

                        Label {
                            id: labelWeiboUserName
                            color: Theme.highlightColor
                            font.pixelSize: Theme.fontSizeSmall
                            text: userInfo.screen_name
                        }
                    }

                    Label {
                        id: labelWeibo
                        width: parent.width
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        text: usWeiboContent.status.text
                    }

                    Grid {
                        id: gridWeiboPics
                        columns: 3
                        spacing:Theme.paddingSmall
                        width: parent.width
                        height: childrenRect.height

                        Repeater {
                            model: ListModel { id: modelImages }
                            delegate: Component {
                                Image {
                                    fillMode: Image.PreserveAspectCrop;
                                    width: modelImages.count == 1 ? implicitWidth : columnWContent.width / 3 - 3;//units.gu(3) ;
                                    height: modelImages.count == 1 ? implicitHeight : width
                                    source: model.thumbnail_pic

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            //TODO 添加方法
                                            //mainView.toGalleryPage(modelImages, index)
                                        }
                                    }
                                }
                            }
                        }

                    }

//                    Item {
//                        id: itemRetweetContainer
//                        anchors {
//                            left: parent.left; right: parent.right
//                            leftMargin: units.gu(1); rightMargin: units.gu(1)
//                        }
//                        height: childrenRect.height

//                        DelegateRepostedWeibo{
//                            visible: usWeiboContent.status.retweeted_status != undefined
//                            retweetWeibo: usWeiboContent.status.retweeted_status

//                            onRetweetClicked: usWeiboContent.clicked()
//                        }
//                    }

                    Column {
                        width: parent.width
                        Row {
                            anchors{
                                left: parent.left
                                right: parent.right
                                margins:  Theme.paddingSmall
                            }
                            
                            spacing: Theme.paddingSmall

                            Item {
                                width: parent.width / 4 - Theme.paddingSmall
                                height: Theme.fontSizeSmall + Theme.paddingSmall

                                Label {
                                    anchors.centerIn: parent
                                    color: Theme.secondaryColor
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    text: qsTr("repost: ") + usWeiboContent.status.reposts_count
                                }

//                                MouseArea {
//                                    anchors.fill: parent
//                                    onClicked: {
//                                        mainView.toSendPage("repost", {"id": usWeiboContent.status.id})
//                                    }
//                                }
                            }
                            Rectangle {
                                width: 2
                                height: parent.height - Theme.paddingSmall
                                color: Theme.highlightColor
                            }
                            Item {
                                width: parent.width / 4 - Theme.paddingSmall
                                height: Theme.fontSizeSmall + Theme.paddingSmall

                                Label {
                                    anchors.centerIn: parent
                                    color: Theme.secondaryColor
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    text: qsTr("comment: ") + usWeiboContent.status.comments_count
                                }

//                                MouseArea {
//                                    anchors.fill: parent
//                                    onClicked: {
//                                        mainView.toSendPage("comment", {"id": usWeiboContent.status.id})
//                                    }
//                                }
                            }
                            Rectangle {
                                width: 2
                                height: parent.height - Theme.paddingSmall
                                color: Theme.highlightColor
                            }
                            Item {
                                width: parent.width / 4 - Theme.paddingSmall
                                height: Theme.fontSizeSmall + Theme.paddingSmall

                                Label {
                                    anchors.centerIn: parent
                                    color: Theme.secondaryColor
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    text: qsTr("like: ") + usWeiboContent.status.attitudes_count
                                }
                            }
                        }
                    }
                    
                    Separator {
                        width: parent.width
                        color: Theme.highlightColor
                    }

                } // column


            } // user weibo

            // user's photo album   // api only return photos which have location info // implement later
//            Button {
//                anchors {
//                    left: parent.left; right: parent.right
//                    leftMargin: units.gu(1); rightMargin: units.gu(1)
//                }
//                text: qsTr("view user's photo album")

//                onClicked: {
//                    mainView.toUserPhoto(userInfo.id)
//                }
//            }

        }
    }
}
