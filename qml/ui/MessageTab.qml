import QtQuick 2.0
//import QtQuick.XmlListModel 2.0
//import Ubuntu.Components 0.1
//import Ubuntu.Components.ListItems 0.1 as ListItem
//import Ubuntu.Components.Popups 0.1
import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../components"

Tab {
    id: messageTab
    title: i18n.tr("Message")

    property var remind: {"status":0,"follower":0,"cmt":0,"dm":0,"mention_status":0,"mention_cmt":0,"group":0,"notice":0,"invite":0,"badge":0,"photo":0}

    function refresh() {
        messageGetRemind(settings.getAccess_token(), settings.getUid())
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
//                        console.log("remind: ", JSON.stringify(result))
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
                            mainView.addNotification(i18n.tr("You have " + mCount + " new messages"), 3)
                        }
                        else if (mCount > 0) {
                            mainView.addNotification(i18n.tr("You have " + mCount + " new message"), 3)
                        }
                        else {
                            mainView.addNotification(i18n.tr("You have no new message"), 3)
                        }
                    }
                }else{
                    // TODO  empty result
                }
            }
        }

        WB.messageGetRemind(token, uid, new observer())
    }

    page: Page {

        tools: ToolbarItems {
            id: toolbarWeibo

            back: ToolbarButton {
                action: Action {
                    text:  i18n.tr("Refresh")
                    iconSource: Qt.resolvedUrl("../graphics/reload.svg")
                    onTriggered:
                    {
                        // TODO: refresh
                        refresh()
                    }
                }
            }

//            ToolbarButton {
//                action: Action {
//                    text:  i18n.tr("New")
//                    iconSource: Qt.resolvedUrl("../graphics/edit.svg")
//                    onTriggered: {
//                        // TODO: send weibo
//                        sendNewWeibo()
//                    } // onTriggered
//                }
//            }
        }

        Flickable {
            id: scrollArea
            boundsBehavior: (contentHeight > height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
            anchors.fill: parent
            contentWidth: width
            contentHeight: innerAreaColumn.height + units.gu(1)

            Column {
                id: innerAreaColumn

                spacing: units.gu(1)
                anchors {
                    top: parent.top;
                    topMargin: units.gu(1)
                    //                margins: units.gu(1)
                    left: parent.left; right: parent.right
                    //                leftMargin: units.gu(1); rightMargin: units.gu(1)
                }
                height: childrenRect.height

                // New comment
                Item {
                    anchors { left: parent.left; right: parent.right }
                    height: childrenRect.height

                    Column {
                        anchors { left: parent.left; right: parent.right }
                        height: childrenRect.height
                        spacing: units.gu(1)

                        Row {
                            anchors { left: parent.left; right: parent.right; leftMargin: units.gu(2) }
                            height: childrenRect.height
                            spacing: units.gu(1)

                            UbuntuShape {
                                id: us0
                                width: units.gu(7)
                                height: width
                                radius: "medium"
                            }

                            Label {
                                color: "black"
                                fontSize: "large"
                                anchors.verticalCenter: us0.verticalCenter
                                width: parent.width / 1.4
                                text: i18n.tr("New comment")
                            }

                            Label {
                                color: "black"
                                fontSize: "large"
                                anchors.verticalCenter: us0.verticalCenter
                                text: remind.cmt
                            }

                        }

                        ListItem.ThinDivider{}
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            mainStack.push(Qt.resolvedUrl("./CommentAllPage.qml"))
                            mainStack.currentPage.refresh()
                        }
                    }
                }

                // New mentioned comment
                Item {
                    anchors { left: parent.left; right: parent.right }
                    height: childrenRect.height

                    Column {
                        anchors { left: parent.left; right: parent.right }
                        height: childrenRect.height
                        spacing: units.gu(1)

                        Row {
                            anchors { left: parent.left; right: parent.right; leftMargin: units.gu(2) }
                            height: childrenRect.height
                            spacing: units.gu(1)

                            UbuntuShape {
                                id: us1
                                width: units.gu(7)
                                height: width
                                radius: "medium"
                            }

                            Label {
                                color: "black"
                                fontSize: "large"
                                anchors.verticalCenter: us1.verticalCenter
                                width: parent.width / 1.4
                                text: i18n.tr("New mentioned comment")
                            }

                            Label {
                                color: "black"
                                fontSize: "large"
                                anchors.verticalCenter: us1.verticalCenter
                                text: remind.mention_cmt
                            }

                        }

                        ListItem.ThinDivider{}
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            mainStack.push(Qt.resolvedUrl("./CommentMentioned.qml"))
                            mainStack.currentPage.refresh()
                        }
                    }
                }

                // New mentioned weibo
                Item {
                    anchors { left: parent.left; right: parent.right }
                    height: childrenRect.height

                    Column {
                        anchors { left: parent.left; right: parent.right }
                        height: childrenRect.height
                        spacing: units.gu(1)

                        Row {
                            anchors { left: parent.left; right: parent.right; leftMargin: units.gu(2) }
                            height: childrenRect.height
                            spacing: units.gu(1)

                            UbuntuShape {
                                id: us2
                                width: units.gu(7)
                                height: width
                                radius: "medium"
                            }

                            Label {
                                color: "black"
                                fontSize: "large"
                                anchors.verticalCenter: us2.verticalCenter
                                width: parent.width / 1.4
                                text: i18n.tr("New mentioned weibo")
                            }

                            Label {
                                color: "black"
                                fontSize: "large"
                                anchors.verticalCenter: us2.verticalCenter
                                text: remind.mention_status
                            }

                        }

                        ListItem.ThinDivider{}
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            mainStack.push(Qt.resolvedUrl("./WeiboMentioned.qml"))
                            mainStack.currentPage.refresh()
                        }
                    }
                }

                // New follower
                Item {
                    anchors { left: parent.left; right: parent.right }
                    height: childrenRect.height

                    Column {
                        anchors { left: parent.left; right: parent.right }
                        height: childrenRect.height
                        spacing: units.gu(1)

                        Row {
                            anchors { left: parent.left; right: parent.right; leftMargin: units.gu(2) }
                            height: childrenRect.height
                            spacing: units.gu(1)

                            UbuntuShape {
                                id: us3
                                width: units.gu(7)
                                height: width
                                radius: "medium"
                            }

                            Label {
                                color: "black"
                                fontSize: "large"
                                anchors.verticalCenter: us3.verticalCenter
                                width: parent.width / 1.4
                                text: i18n.tr("New follower")
                            }

                            Label {
                                color: "black"
                                fontSize: "large"
                                anchors.verticalCenter: us3.verticalCenter
                                text: remind.follower
                            }

                        }

                        ListItem.ThinDivider{}
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            mainView.toFriendsPage("follower", settings.getUid())
                        }
                    }
                }



            }
        }//Flickable
    }
}
