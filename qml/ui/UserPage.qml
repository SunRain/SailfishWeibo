import QtQuick 2.0
//import QtQuick.XmlListModel 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../components"

Page {
    id: userPage

    property var uid
    property var userInfo: {"id":-1,"idstr":"","class":1,"screen_name":"","name":"","province":"","city":"","location":"","description":"","url":"","profile_image_url":"","profile_url":"","domain":"","weihao":"","gender":"","followers_count":0,"friends_count":0,"statuses_count":0,"favourites_count":0,"created_at":"Sun Jan 22 13:32:37 +0800 1999","following":false,"allow_all_act_msg":false,"geo_enabled":true,"verified":false,"verified_type":-1,"remark":"","status":{"text": "", "reposts_count": 0, "comments_count": 0, "attitudes_count": 0},"ptype":0,"allow_all_comment":true,"avatar_large":"","avatar_hd":"","verified_reason":"","follow_me":false,"online_status":0,"bi_followers_count":0,"lang":"zh-cn","star":0,"mbtype":0,"mbrank":0,"block_word":0}
    property bool isFollowing: false

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

        WB.userFriendshipCreate(settings.getAccess_token(), uid, new observer())
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

        WB.userFriendshipdestroy(settings.getAccess_token(), uid, new observer())
    }

    Flickable {
        id: scrollArea
        boundsBehavior: (contentHeight > height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
        anchors.fill: parent
        contentWidth: width
        contentHeight: innerAreaColumn.height + units.gu(2)

        Column {
            id: innerAreaColumn

            spacing: units.gu(1)
            anchors {
                top: parent.top;
                //                topMargin: units.gu(1)
                //                margins: units.gu(1)
                left: parent.left; right: parent.right
                //                leftMargin: units.gu(1); rightMargin: units.gu(1)
            }
            height: childrenRect.height

            // user
            Rectangle {
                anchors { left: parent.left; right: parent.right }
                height: rowUser.height + units.gu(2)
                color: Qt.rgba(255, 255, 255, 0.5)

                Row {
                    id: rowUser
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
                    spacing: units.gu(1)
                    height: usAvatar.height

                    UbuntuShape {
                        id: usAvatar
                        width: units.gu(9)
                        height: width
                        radius: "medium"
                        image: Image {
                            source: userInfo.avatar_hd
                        }
                    }

                    Column {
                        width: childrenRect.width
                        spacing: units.gu(1)

                        Label {
                            id: labelUserName
                            color: "black"
                            fontSize: "large"
                            text: userInfo.screen_name
                        }

                        Label {
                            id: labelLocation
                            color: "grey"
                            text: userInfo.location
                        }
                    }


                }

                Button {
                    anchors {
                        top: parent.top; topMargin: units.gu(1)
                        right: parent.right; rightMargin: units.gu(1)
                    }
                    text: {
                        if (isFollowing == true) {
                            if (userInfo.follow_me == true) {
                                return i18n.tr("Bilateral")
                            }
                            else {
                                return i18n.tr("Following")
                            }
                        }
                        else {
                            if (userInfo.follow_me == true) {
                                return i18n.tr("Follower")
                            }
                            else {
                                return i18n.tr("Follow")
                            }
                        }
                    }
                        //i18n.tr("following")
                    height: units.gu(4)
                    gradient: isFollowing == true ? UbuntuColors.greyGradient : UbuntuColors.orangeGradient
                    visible: userInfo.id != settings.getUid()
//                        style: Component {
//                            UbuntuShape {}
//                        }
                    onClicked: {
                        if (isFollowing == true) {
                            userFollowCancel()
                        }
                        else {
                            userFollowCreate()
                        }
                    }
                }
            }

            // description
            Rectangle {
                anchors { left: parent.left; right: parent.right }
                height: colDesc.height + units.gu(2)
                color: Qt.rgba(255, 255, 255, 0.5)

                Column {
                    id: colDesc
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
                    height: childrenRect.height
                    spacing: units.gu(0.5)

                    Label {
                        id: labelDesc
                        color: "grey"
                        text: i18n.tr("Description: ")
                    }

                    Label {
                        id: labelDescription
                        color: "black"
                        text: userInfo.description
                    }
                }

            }

            // friends
            Rectangle {
                anchors { left: parent.left; right: parent.right }
                height: rowFriends.height + units.gu(2)
                color: Qt.rgba(255, 255, 255, 0.5)

                Row {
                    id: rowFriends
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: units.gu(1) }
                    height: childrenRect.height
//                    spacing: units.gu(0.5)

                    Item {
                        width: parent.width / 3 - units.gu(0.1);  height: units.gu(4)

                        Label {
                            anchors.centerIn: parent
                            color: "black"
                            text: i18n.tr("Weibo: ") + userInfo.statuses_count
                        }
                    }
                    Rectangle {y: units.gu(0.2); width: units.gu(0.1); height: units.gu(3.5); color: "grey"}
                    Item {
                        width: parent.width / 3 - units.gu(0.1);  height: units.gu(4)

                        Label {
                            anchors.centerIn: parent
                            color: "black"
                            text: i18n.tr("following: ") + userInfo.friends_count
                        }
                    }
                    Rectangle {y: units.gu(0.2); width: units.gu(0.1); height: units.gu(3.5); color: "grey"}
                    Item {
                        width: parent.width / 3 - units.gu(0.1);  height: units.gu(4)

                        Label {
                            anchors.centerIn: parent
                            color: "black"
                            text: i18n.tr("follower: ") + userInfo.followers_count
                        }
                    }

                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        mainView.toFriendsPage("following", userInfo.id)
                    }
                }
            }

            // user weibo
            UbuntuShape {
                id: usWeiboContent
                anchors {
                    left: parent.left; right: parent.right
            //                    leftMargin: units.gu(1); rightMargin: units.gu(1)
                }
                height: columnWContent.height + units.gu(1.5)
                radius: "medium"
                color: Qt.rgba(255, 255, 255, 0.3)

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
                        mainView.toUserWeibo(userInfo.id, userInfo.screen_name)
                    }
                }

                Column {
                    id: columnWContent
                    anchors {
                        top: parent.top; topMargin: units.gu(1)
                        left: parent.left; right: parent.right
                        leftMargin: units.gu(1); rightMargin: units.gu(1)
                    }
                    spacing: units.gu(1)
                    height: childrenRect.height

                    Column {
                        id: colUser
                        anchors { left: parent.left; right: parent.right }
                        spacing: units.gu(0.5)
                        height: childrenRect.height

                        Label {
                            id: labelWeiboUserName
                            color: "black"
                            text: userInfo.screen_name
                        }
                    }

                    Label {
                        id: labelWeibo
                        width: parent.width
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: "black"
                        text: usWeiboContent.status.text
                    }

                    Grid {
                        id: gridWeiboPics
                        columns: 3; spacing: units.gu(0.5); /*visible: status.pic_urls == undefined ? false : status.pic_urls.count != 0*/
                        width: parent.width; height: childrenRect.height

                        Repeater {
                            model: ListModel { id: modelImages }
                            delegate: Component {
                                Image {
                                    fillMode: Image.PreserveAspectCrop;
                                    width: modelImages.count == 1 ? implicitWidth : columnWContent.width / 3 - units.gu(3) ;
                                    height: modelImages.count == 1 ? implicitHeight : width
                                    source: model.thumbnail_pic

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: mainView.toGalleryPage(modelImages, index)
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
                        width: parent.width; height: childrenRect.height
                        ListItem.ThinDivider { }

                        Row {
                            width: childrenRect.width; height: childrenRect.height
                            anchors.horizontalCenter: parent.horizontalCenter

                            Item {
                                width: columnWContent.width / 3 - units.gu(0.5);  height: units.gu(4)

                                Label {
                                    anchors.centerIn: parent
                                    color: "black"
                                    text: i18n.tr("repost: ") + usWeiboContent.status.reposts_count
                                }

//                                MouseArea {
//                                    anchors.fill: parent
//                                    onClicked: {
//                                        mainView.toSendPage("repost", {"id": usWeiboContent.status.id})
//                                    }
//                                }
                            }
                            Rectangle {y: units.gu(0.2); width: units.gu(0.1); height: units.gu(3.5); color: "grey"}
                            Item {
                                width: columnWContent.width / 3 - units.gu(0.5);  height: units.gu(4)

                                Label {
                                    anchors.centerIn: parent
                                    color: "black"
                                    text: i18n.tr("comment: ") + usWeiboContent.status.comments_count
                                }

//                                MouseArea {
//                                    anchors.fill: parent
//                                    onClicked: {
//                                        mainView.toSendPage("comment", {"id": usWeiboContent.status.id})
//                                    }
//                                }
                            }
                            Rectangle {y: units.gu(0.2); width: units.gu(0.1); height: units.gu(3.5); color: "grey"}
                            Item {
                                width: columnWContent.width / 3 - units.gu(0.5);  height: units.gu(4)

                                Label {
                                    anchors.centerIn: parent
                                    color: "black"
                                    text: i18n.tr("like: ") + usWeiboContent.status.attitudes_count
                                }
                            }
                        }
                    }


                } // column


            } // user weibo

            // user's photo album   // api only return photos which have location info // implement later
//            Button {
//                anchors {
//                    left: parent.left; right: parent.right
//                    leftMargin: units.gu(1); rightMargin: units.gu(1)
//                }
//                text: i18n.tr("view user's photo album")

//                onClicked: {
//                    mainView.toUserPhoto(userInfo.id)
//                }
//            }

        }
    }
}
