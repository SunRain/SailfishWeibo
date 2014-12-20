import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../components"

import com.sunrain.sinaweibo 1.0

Page {
    id: userPage
    
    property var uid
//    property var userInfo: {"id":-1,"idstr":"","class":1,"screen_name":"","name":"","province":"","city":"","location":"","description":"","url":"","profile_image_url":"","profile_url":"","domain":"","weihao":"","gender":"","followers_count":0,"friends_count":0,"statuses_count":0,"favourites_count":0,"created_at":"Sun Jan 22 13:32:37 +0800 1999","following":false,"allow_all_act_msg":false,"geo_enabled":true,"verified":false,"verified_type":-1,"remark":"","status":{"text": "", "reposts_count": 0, "comments_count": 0, "attitudes_count": 0},"ptype":0,"allow_all_comment":true,"avatar_large":"","avatar_hd":"","verified_reason":"","follow_me":false,"online_status":0,"bi_followers_count":0,"lang":"zh-cn","star":0,"mbtype":0,"mbrank":0,"block_word":0}
    property bool isFollowing: false

    UserInfoObject {
        id: userInfoObject
    }

    Component.onCompleted: {
        //userGetInfo(Settings.getAccess_token())
        var method = WeiboMethod.WBOPT_GET_USERS_SHOW;
        api.setWeiboAction(method, {'uid':uid});
    }
    
    //    function userGetInfo(token)
    //    {
    //        function observer() {}
    //        observer.prototype = {
    //            update: function(status, result)
    //            {
    //                if(status != "error"){
    //                    if(result.error) {
    //                        // TODO  error handler
    //                    }else {
    //                        // right result
    //                        userInfo = result
    //                        isFollowing = result.following
    //                    }
    //                }else{
    //                    // TODO  empty result
    //                }
    //            }
    //        }
    
    //        WB.userGetInfoByUid(token, uid, new observer())
    //    }
    
    Connections {
        target: api
        //void weiboPutSucceed(QWeiboMethod::WeiboAction action, const QString& replyData);
        onWeiboPutSucceed: {
            if (action == WeiboMethod.WBOPT_GET_USERS_SHOW) {
                userInfoObject.usrInfo = JSON.parse(replyData);
                isFollowing = userInfoObject.usrInfo.following;
            }
            if (action == WeiboMethod.WBOPT_POST_FRIENDSHIPS_CREATE) {
                isFollowing = true;
            }
            if (action == WeiboMethod.WBOPT_POST_FRIENDSHIPS_DESTROY) {
                isFollowing = false;
            }
        }
    }
    
    function userFollowCreate()
    {
        //        function observer() {}
        //        observer.prototype = {
        //            update: function(status, result)
        //            {
        //                if(status != "error"){
        //                    if(result.error) {
        //                        // TODO  error handler
        //                    }else {
        //                        // right result
        ////                        userInfo = result
        ////                        userInfoObject.usrInfo.following = true
        //                        isFollowing = true
        //                    }
        //                }else{
        //                    // TODO  empty result
        //                }
        //            }
        //        }
        
        //        WB.userFriendshipCreate(Settings.getAccess_token(), uid, new observer())
        
        var method = WeiboMethod.WBOPT_POST_FRIENDSHIPS_CREATE;
        api.setWeiboAction(method, {'uid':uid});
    }
    
    function userFollowCancel()
    {
        //        function observer() {}
        //        observer.prototype = {
        //            update: function(status, result)
        //            {
        //                if(status != "error"){
        //                    if(result.error) {
        //                        // TODO  error handler
        //                    }else {
        //                        // right result
        ////                        userInfo = result
        ////                        userInfoObject.usrInfo.following = false
        //                        isFollowing = false
        //                    }
        //                }else{
        //                    // TODO  empty result
        //                }
        //            }
        //        }
        
        //        WB.userFriendshipdestroy(Settings.getAccess_token(), uid, new observer())
        
        var method = WeiboMethod.WBOPT_POST_FRIENDSHIPS_DESTROY;
        api.setWeiboAction(method, {'uid':uid});
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
                            width:rowUser.width - usAvatar.width - Theme.paddingMedium// parent.width
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
                            width: rowUserColumn.width
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
                                        if (isFollowing == true) {
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
                                        if (isFollowing == true) {
                                            return qsTr("CancelFollowing");
                                        } else {
                                            return qsTr("Follow");
                                        }
                                    }
                                    onClicked: {
                                        if (isFollowing == true) {
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
                anchors { 
                    left: parent.left
                    right: parent.right
                }
                height: colDesc.height + Theme.paddingMedium
                
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
                        text: userInfoObject.usrInfo.description
                    }
                }
                
            }
            
            // friends
            Column {
                anchors { 
                    left: parent.left
                    right: parent.right
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
            
            // user weibo
            Item {
                id: usWeiboContent
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: childrenRect.height //columnWContent.height + Theme.paddingMedium
                
                property var status: userInfoObject.usrInfo.status
                
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
                        toUserWeibo(userInfoObject.usrInfo.id, userInfoObject.usrInfo.screen_name)
                    }
                }
                
                Label {
                    id:title
                    anchors.horizontalCenter: usWeiboContent.horizontalCenter
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium
                    text: userInfoObject.usrInfo.screen_name + qsTr("'s RecentWeibo")
                }
                
                Image {
                    id: imageBackground
                    anchors{
                        left: parent.left
                        right: parent.right
                        top:columnWContent.top
                        bottom: columnWContent.bottom
                    }
                    fillMode: Image.PreserveAspectCrop
                    source: "../graphics/mask_background_reposted.png"
                }
                
                Column {
                    id: columnWContent
                    anchors {
                        top: title.bottom
                        topMargin: Theme.paddingMedium
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.paddingMedium
                        rightMargin: Theme.paddingMedium
                    }
                    spacing: Theme.paddingSmall
                    
                    Label {
                        id: labelWeibo
                        width: parent.width
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        textFormat: Text.StyledText
                        font.pixelSize: Theme.fontSizeSmall
                        text: util.parseWeiboContent(usWeiboContent.status.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
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
                                            toGalleryPage(modelImages, index)
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
                        anchors { 
                            left: parent.left
                            right: parent.right
                        } 
                        spacing: Theme.paddingSmall
                        
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Item {
                                width: innerAreaColumn.width/3 - Theme.paddingSmall
                                height: Theme.fontSizeSmall
                                
                                Label {
                                    anchors.centerIn: parent
                                    color: Theme.secondaryColor
                                    font.pixelSize: Theme.fontSizeTiny 
                                    text: qsTr("repost: ") + usWeiboContent.status.reposts_count
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
                                    font.pixelSize: Theme.fontSizeTiny
                                    text: qsTr("comment: ") + usWeiboContent.status.comments_count
                                }
                            }
                            Rectangle {
                                width: 1
                                height: parent.height - 2
                                color: Theme.highlightColor
                            }
                            Item {
                                width: innerAreaColumn.width/3 - Theme.paddingSmall
                                height: Theme.fontSizeSmall
                                
                                Label {
                                    anchors.centerIn: parent
                                    color: Theme.secondaryColor
                                    font.pixelSize: Theme.fontSizeTiny
                                    text: qsTr("like: ") + usWeiboContent.status.attitudes_count
                                }
                            }
                        }
                    } // column
                } //columnWContent
            } // user weibo
            
            // user's photo album   // api only return photos which have location info // implement later
            //            Button {
            //                anchors {
            //                    left: parent.left; right: parent.right
            //                    leftMargin: units.gu(1); rightMargin: units.gu(1)
            //                }
            //                text: qsTr("view user's photo album")
            
            //                onClicked: {
            //                    mainView.toUserPhoto(userInfoObject.usrInfo.id)
            //                }
            //            }
            
        }
    }
}
