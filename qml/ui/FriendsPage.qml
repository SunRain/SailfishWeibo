import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../components"

Page {
    id: friendsPage
    //title: qsTr("Friends")

    property var uid/*: friendsPage.fuid*/
    property var modelFriend
    property var mode/*: friendsPage.fmode*/
    property string titleName: "Friends"

    Component.onCompleted: setMode(mode, uid)

    //3984244261
    //qsTr("Following"), qsTr("Follower"), qsTr("Bilateral")
    function setMode(mode, uid) {
        console.log("friendsPage == setMod " + mode + " uid " + uid);
        switch (mode) {
        case "following":
            titleName = "Following"
            
            lvLoader.sourceComponent = lvLoader.Null;
            lvLoader.sourceComponent = lvUsers0Component;
            if (modelFollowing.count == 0) {
                userGetFollowing(Settings.getAccess_token(), uid, 30, modelFollowing.cursor);
            } 
            
            break
        case "follower":
            //selectorFriend.selectedIndex = 1
            titleName = "Follower"
            
            lvLoader.sourceComponent = lvLoader.Null;
            lvLoader.sourceComponent = lvUsers1Component;
            if (modelFollower.count == 0) {
                userGetFollower(Settings.getAccess_token(), uid, 30, modelFollower.cursor)
            }
            
            break
        case "bilateral":
            //selectorFriend.selectedIndex = 2
            titleName = "Bilateral"
            
            lvLoader.sourceComponent = lvLoader.Null;
            lvLoader.sourceComponent = lvUsers2Component
            if (modelBilateral.count == 0) {
                userGetBilateral(Settings.getAccess_token(), uid, 30, modelBilateral.cursor)
            }
            
            break
        }
    }

    // get following
    function userGetFollowing(token, uid, count, cursor)
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
                       console.log("cursor: ", result.next_cursor, result.previous_cursor)
                        modelFollowing.cursor = result.next_cursor
                        if (result.next_cursor == 0) {
                            lvUsers0.footerItem.visible = false
                        }
                        for (var i=0; i<result.users.length; i++) {
                            modelFollowing.append(result.users[i])
                        }
                    }
                }else{
                    // TODO  empty result
                }
            }
        }

        WB.userGetFollowing(token, uid, count, cursor, new observer())
    }

    function addMoreFollowing() {
//        console.log("modelFollowing.cursor: ", modelFollowing.cursor)
        userGetFollowing(Settings.getAccess_token(), uid, 30, modelFollowing.cursor)
    }

    // get follower
    function userGetFollower(token, uid, count, cursor)
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
                        console.log("cursor: ", result.next_cursor, result.previous_cursor)
                        modelFollower.cursor = result.next_cursor
                        if (result.next_cursor == 0) {
                            lvUsers1.footerItem.visible = false
                        }
                        for (var i=0; i<result.users.length; i++) {
                            modelFollower.append(result.users[i])
                        }
                    }
                }else{
                    // TODO  empty result
                }
            }
        }

        WB.userGetFollower(token, uid, count, cursor, new observer())
    }

    function addMoreFollower() {
//        console.log("modelFollower.cursor: ", modelFollower.cursor)
        userGetFollower(Settings.getAccess_token(), uid, 30, modelFollower.cursor)
    }

    // get bilateral
    function userGetBilateral(token, uid, count, page)
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
//                        modelBilateral.cursor = result.next_cursor
                        for (var i=0; i<result.users.length; i++) {
                            modelBilateral.append(result.users[i])
                        }
                        if (modelBilateral.count == result.total_number) {
                            lvUsers2.footerItem.visible = false
                        }
                    }
                }else{
                    // TODO  empty result
                }
            }
        }

        WB.userGetBilateral(token, uid, count, page, new observer())
    }

    function addMoreBilateral() {
        console.log("modelBilateral.cursor: ", modelBilateral.cursor)
        modelBilateral.cursor++
        userGetBilateral(Settings.getAccess_token(), uid, 30, modelBilateral.cursor)
    }


    ListModel{
        id: modelFollowing
        property int cursor: 0
    }

    ListModel{
        id: modelFollower
        property int cursor: 0
    }

    ListModel{
        id: modelBilateral
        property int cursor: 1
    }

    Component {
        id:lvUsers0Component
        SilicaListView {
            id: lvUsers0
            header:PageHeader {
                id:pageHeader
                title: qsTr(titleName)
            }
            model: modelFollowing
            delegate: delegateUser
            footer: FooterLoadMore{
                onClicked: addMoreFollowing()
            }
             VerticalScrollDecorator { flickable: lvUsers0 }
        }
    }
    
    Component {
        id:lvUsers1Component
        SilicaListView {
            id: lvUsers1
            header:PageHeader {
                id:pageHeader
                title: qsTr(titleName)
            }
            model: modelFollower
            delegate: delegateUser
            footer: FooterLoadMore{
                onClicked: addMoreFollower()
            }
            VerticalScrollDecorator { flickable: lvUsers1 }
        }
    }
    
    Component {
        id:lvUsers2Component
        SilicaListView {
            id: lvUsers2
            header:PageHeader {
                id:pageHeader
                title: qsTr(titleName)
            }
            model: modelBilateral
            delegate: delegateUser
            footer: FooterLoadMore{
                onClicked: addMoreBilateral()
            }
            VerticalScrollDecorator { flickable: lvUsers2 }
        }
    }

    SilicaFlickable {
        id:mainFlickableView
        anchors.fill: parent

        //TODO 以下添加的菜单暂时移除，因为我们希望这个page是直接由其他页面提供参数指定调用，而不是自己更改自身内容
//        PullDownMenu {
//            MenuItem {
//                text: qsTr("Following")
//                onClicked: {
//                    modelFriend = modelFollowing;
//                    setMode("following");
////                    lvLoader.sourceComponent = lvLoader.Null;
////                    lvLoader.sourceComponent = lvUsers0Component;
////                    if (modelFollowing.count == 0) {
////                        userGetFollowing(Settings.getAccess_token(), uid, 30, modelFollowing.cursor);
////                    }                    
//                }
//            }
//            MenuItem {
//                text: qsTr("Follower")
//                onClicked: {
//                    modelFriend = modelFollower
//                    setMode("follower");
////                    lvLoader.sourceComponent = lvLoader.Null;
////                    lvLoader.sourceComponent = lvUsers1Component;
////                    if (modelFollower.count == 0) {
////                        userGetFollower(Settings.getAccess_token(), uid, 30, modelFollower.cursor)
////                    }
//                }
//            }
//            MenuItem {
//                text: qsTr("Bilateral")
//                onClicked: {
//                    modelFriend = modelBilateral
//                    setMode("bilateral");
////                    lvLoader.sourceComponent = lvLoader.Null;
////                    lvLoader.sourceComponent = lvUsers2Component
////                    if (modelBilateral.count == 0) {
////                        userGetBilateral(Settings.getAccess_token(), uid, 30, modelBilateral.cursor)
////                    }
//                }
//            }
//        }
        Loader {
            id:lvLoader
            anchors.fill: parent
        }
        

    }
    Component {
        id: delegateUser

        Item {
            width: parent.width
            height: columnWContent.height + Theme.paddingMedium 

            Column {
                id: columnWContent
                anchors {
                    top: parent.top
                    topMargin: Theme.paddingMedium//0.5//units.gu(0.5)
                    left: parent.left
                    right: parent.right
                }
                spacing: Theme.paddingMedium

                Row {
                    id: rowUser
                    anchors { 
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.paddingSmall 
                        rightMargin:Theme.paddingSmall 
                    }
                    spacing:Theme.paddingMedium 
                    height: Math.max(labelUserName.height,usAvatar.height)
                    Item {
                        id: usAvatar
                        width: 64
                        height: width
                        Image {
                            width: parent.width
                            height: parent.height
                            smooth: true
                            fillMode: Image.PreserveAspectFit
                            source: model.profile_image_url
                        }
                    }

                    Item {
                        width: parent.width - usAvatar.width - Theme.paddingMedium  *2
                        height: usAvatar.height
                        Label {
                            id: labelUserName
                            anchors.verticalCenter:  parent.verticalCenter
                            color: Theme.primaryColor
                            font.pixelSize: Theme.fontSizeMedium
                            text: model.screen_name
                        }
                    }
                }
                Separator {
                    width: parent.width
                    color: Theme.highlightColor
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    //TODO 转到UserPage
                   // mainView.toUserPage(model.id)
                    console.log("===== clicked");
                    toUserPage(model.id);
                }
            }
        }
    }
}
