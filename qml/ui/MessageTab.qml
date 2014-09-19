import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../components"

Page {
    id: messageTab
    //title: qsTr("Message")
    
    property var remind: {"status":0,"follower":0,"cmt":0,"dm":0,"mention_status":0,"mention_cmt":0,"group":0,"notice":0,"invite":0,"badge":0,"photo":0}
    
    function refresh() {
        messageGetRemind(Settings.getAccess_token(), Settings.getUid())
    }
    
    Component.onCompleted: {
        console.log("MessageTab === Component.onCompleted");
        refresh();
    }

    function messageGetRemind(token, uid)
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
                        console.log("remind: ", JSON.stringify(result))
                        //{"status":0,"follower":0,"cmt":0,"dm":0,"mention_status":0,"mention_cmt":0,"group":0,"notice":0,"invite":0,"badge":0,"photo":0}
                        //                        status	int	新微博未读数
                        //                        follower	int	新粉丝数
                        //                        cmt	int	新评论数
                        //                        dm	int	新私信数
                        //                        mention_status	int	新提及我的微博数
                        //                        mention_cmt	int	新提及我的评论数
                        remind = result
                        var mCount = result.follower + result.cmt + result.mention_status + result.mention_cmt
                        if (mCount > 1) {
                            addNotification(qsTr("You have " + mCount + " new messages"), 3)
                        }
                        else if (mCount > 0) {
                            addNotification(qsTr("You have " + mCount + " new message"), 3)
                        }
                        else {
                            addNotification(qsTr("You have no new message"), 3)
                        }
                        
                        listModel.append({"title":"New comment", "text":remind.cmt, "page":"CommentAllPage.qml", "toFunction":"0"});
                        listModel.append({"title":"New mentioned comment", "text":remind.mention_cmt, "page":"CommentMentioned.qml","toFunction":"0"});
                        listModel.append({"title":"New mentioned weibo", "text":remind.mention_status, "page":"WeiboMentioned.qml", "toFunction":"0"});
                        listModel.append({"title":"New follower", "text":remind.follower, "page":"follower", "toFunction":"1"});
                    }
                }else{
                    // TODO  empty result
                }
            }
        }
        
        WB.messageGetRemind(token, uid, new observer())
    }
    
    ListModel {
        id:listModel
    }

//    SilicaFlickable {
//        id: scrollArea
//        //boundsBehavior: (contentHeight > height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
//        anchors.fill: parent
//        //contentWidth: width
//        contentHeight: innerAreaColumn.height// + units.gu(1)
        
        /*Column*/ SilicaListView{
            id: innerAreaColumn
            anchors.fill: parent
            //spacing: Theme.paddingMedium
            
            header:PageHeader {
                id:pageHeader
                title: qsTr("Message")
            }
            
            model: listModel
            
            delegate: Item {
                width: parent.width
                height: Theme.iconSizeMedium/*64*/
                
                Label {
                    id: title
                    anchors{
                        left: parent.left
                        leftMargin: Theme.paddingLarge
                        right: right.left
                        verticalCenter: parent.verticalCenter
                    }
                    text: qsTr("model.title")
                    font.pixelSize: Theme.fontSizeMedium
                }
                Item {
                    id:right
                    anchors{
                        right: parent.right
                        rightMargin: Theme.paddingLarge
                        verticalCenter: parent.verticalCenter
                        horizontalCenter: parent.horizontalRight
                    }
                    Loader {
                        id:rightLoader
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalRight
                    }
                    Component.onCompleted: {
                        if (model.text == "0") {
                            rightLoader.sourceComponent = imageComponent
                        } else {
                            rightLoader.sourceComponent = numberComponent
                        }
                    }

                    Component {
                        id:imageComponent
                        Image {
                            source: "image://theme/icon-m-right"
                       }
                    }
                    
                    Component {
                        id:numberComponent
                        Label {
                            text:model.text
                            font.pixelSize: Theme.fontSizeMedium
                        }
                    }
                    
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (model.toFunction === "1") {
                            //TODO 转到Friends page
                            //oFriendsPage("follower", Settings.getUid())
                        } else {
                            //page
                            pageStack.push(Qt.resolvedUrl(model.page));
                        }
                    }
                }
            }
        }
    }
//}

            // New comment
//            Item {
//                anchors { left: parent.left; right: parent.right }
//                height: childrenRect.height
                
//                Column {
//                    //anchors { left: parent.left; right: parent.right }
//                    height: childrenRect.height
//                    spacing: Theme.paddingSmall 
                    
////                    Row {
////                        anchors { 
////                            left: parent.left
////                            right: parent.right
////                            leftMargin: Theme.paddingSmall 
////                        }
////                        height: childrenRect.height
////                        spacing: Theme.paddingSmall 
                        
////                        Rectangle {
////                            id: us0
////                            width: Theme.iconSizeSmall 
////                            height: width
////                            color: Theme.highlightColor
////                        }
                        
//                        Label {
//                            anchors.verticalCenter: us0.verticalCenter
//                            color: Theme.primaryColor
//                            font.pixelSize: Theme.fontSizeMedium
//                            //width: parent.width / 1.4
//                            text: qsTr("New comment")
//                        }
                        
//                        Label {
//                            anchors.verticalCenter: us0.verticalCenter
//                            color: Theme.secondaryHighlightColor
//                            font.pixelSize: Theme.fontSizeMedium
//                            text: remind.cmt
//                        }
                        
////                    }
                    
//                    //ListItem.ThinDivider{}
//                }
                
//                MouseArea {
//                    anchors.fill: parent
//                    onClicked: {
//                        //mainStack.push(Qt.resolvedUrl("./CommentAllPage.qml"))
//                        //mainStack.currentPage.refresh()
//                    }
//                }
//            }
            
//            // New mentioned comment
//            Item {
//                anchors { left: parent.left; right: parent.right }
//                height: childrenRect.height
                
//                Column {
//                    anchors { left: parent.left; right: parent.right }
//                    height: childrenRect.height
//                    spacing: 1//units.gu(1)
                    
//                    Row {
//                        anchors { left: parent.left; right: parent.right; leftMargin: 2/*units.gu(2)*/ }
//                        height: childrenRect.height
//                        spacing: 1// units.gu(1)
                        
//                        /*UbuntuShape*/ Rectangle{
//                            id: us1
//                            width: 1//units.gu(7)
//                            height: width
//                            //radius: "medium"
//                        }
                        
//                        Label {
//                            color: "black"
//                            //fontSize: "large"
//                            anchors.verticalCenter: us1.verticalCenter
//                            width: parent.width / 1.4
//                            text: qsTr("New mentioned comment")
//                        }
                        
//                        Label {
//                            color: "black"
//                            // fontSize: "large"
//                            anchors.verticalCenter: us1.verticalCenter
//                            text: remind.mention_cmt
//                        }
                        
//                    }
                    
//                    // ListItem.ThinDivider{}
//                }
                
//                MouseArea {
//                    anchors.fill: parent
//                    onClicked: {
//                        //mainStack.push(Qt.resolvedUrl("./CommentMentioned.qml"))
//                        //mainStack.currentPage.refresh()
//                    }
//                }
//            }
            
//            // New mentioned weibo
//            Item {
//                anchors { left: parent.left; right: parent.right }
//                height: childrenRect.height
                
//                Column {
//                    anchors { left: parent.left; right: parent.right }
//                    height: childrenRect.height
//                    spacing: 1//units.gu(1)
                    
//                    Row {
//                        anchors { left: parent.left; right: parent.right; leftMargin: /*units.gu(2)*/ 2}
//                        height: childrenRect.height
//                        spacing: 1//units.gu(1)
                        
//                        /*UbuntuShape*/Rectangle {
//                            id: us2
//                            width: 7//units.gu(7)
//                            height: width
//                            //radius: "medium"
//                        }
                        
//                        Label {
//                            color: "black"
//                            //fontSize: "large"
//                            anchors.verticalCenter: us2.verticalCenter
//                            width: parent.width / 1.4
//                            text: qsTr("New mentioned weibo")
//                        }
                        
//                        Label {
//                            color: "black"
//                            //fontSize: "large"
//                            anchors.verticalCenter: us2.verticalCenter
//                            text: remind.mention_status
//                        }
                        
//                    }
                    
//                    //ListItem.ThinDivider{}
//                }
                
//                MouseArea {
//                    anchors.fill: parent
//                    onClicked: {
//                        //mainStack.push(Qt.resolvedUrl("./WeiboMentioned.qml"))
//                        // mainStack.currentPage.refresh()
//                    }
//                }
//            }
            
//            // New follower
//            Item {
//                anchors { left: parent.left; right: parent.right }
//                height: childrenRect.height
                
//                Column {
//                    anchors { left: parent.left; right: parent.right }
//                    height: childrenRect.height
//                    spacing: 1//units.gu(1)
                    
//                    Row {
//                        anchors { left: parent.left; right: parent.right; leftMargin: /*units.gu(2)*/2 }
//                        height: childrenRect.height
//                        spacing: 1//units.gu(1)
                        
//                        /*UbuntuShape*/Rectangle {
//                            id: us3
//                            width: 7//units.gu(7)
//                            height: width
//                            //radius: "medium"
//                        }
                        
//                        Label {
//                            color: "black"
//                            //fontSize: "large"
//                            anchors.verticalCenter: us3.verticalCenter
//                            width: parent.width / 1.4
//                            text: qsTr("New follower")
//                        }
                        
//                        Label {
//                            color: "black"
//                            //fontSize: "large"
//                            anchors.verticalCenter: us3.verticalCenter
//                            text: remind.follower
//                        }
                        
//                    }
                    
//                    //ListItem.ThinDivider{}
//                }
                
//                MouseArea {
//                    anchors.fill: parent
//                    onClicked: {
//                        //mainView.toFriendsPage("follower", Settings.getUid())
//                    }
//                }
//            }
            
            
            
//        }
//    }//Flickable
//}
//}
