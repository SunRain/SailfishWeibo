import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../components"

Page{
    id: commentMentionedPage
    //title: qsTr("Comments mentioned me")

    property var uid
    property string userName: ""
    property int pageNum: 1

    property var commentInfo
    property var weiboTmp

    function refresh() {
        modelComment.clear()

        pageNum = 1
//        isRefresh = true
        commentMentioned(Settings.getAccess_token(), pageNum)
    }

    function addMore() {
        pageNum++
        commentMentioned(Settings.getAccess_token(), pageNum)
    }

    //////////////////////////////////////////////////////////////////         get all comment mentioned me
    function commentMentioned(token, page)
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
//                        console.log("all comment: ", JSON.stringify(result.comments[0]))
                        for (var i=0; i<result.comments.length; i++) {
                            modelComment.append( result.comments[i] )
                        }
                    }
                }else{
                    // TODO  empty result
                }
            }
        }

        WB.messageGetCommentMentioned(token, page, new observer())
    }
    Component.onCompleted: {
        commentMentionedPage.refresh();
    }

//    Component {
//        id: dialog
//        Dialog {
//            id: dialogue
//            title: qsTr("Comment options")
//            text: qsTr("Please choose one of the following options")

//            Button {
//                text: qsTr("Reply")
//                onClicked: {
//                    console.log("comment info: ", JSON.stringify(commentMentionedPage.commentInfo))
//                    PopupUtils.close(dialogue)
//                    mainView.toSendPage("reply", commentMentionedPage.commentInfo)
//                }
//            }
//            Button {
//                text: qsTr("View weibo")
//                onClicked: {
//                    modelWeiboTemp.clear()
//                    modelWeiboTemp.append(weiboTmp)
//                    mainView.toWeiboPage(modelWeiboTemp, 0)
//                    PopupUtils.close(dialogue)
//                }
//            }
//            Button{
//                gradient: UbuntuColors.greyGradient
//                text: qsTr("Cancel")
//                onClicked: PopupUtils.close(dialogue)
//            }
//        }
//    }

    SilicaListView {
        anchors.fill: parent
        //width: parent.width
        //height: contentItem.childrenRect.height
        //spacing: units.gu(1)
        model: ListModel { id: modelComment }
        delegate: delegateComment
        cacheBuffer: 9999
        header:PageHeader {
            id:pageHeader
            title: qsTr("Comments mentioned me")
        }
    }


    Component {
        id: delegateComment

        ListItem {
            width: parent.width
            contentHeight: columnWContent.height + Theme.paddingMedium //childrenRect.height

            menu: contextMenu
            
            Column {
                id: columnWContent
                anchors {
                    top: parent.top
                    topMargin: Theme.paddingMedium//units.gu(0.5)
                    left: parent.left
                    right: parent.right
                }
                spacing: Theme.paddingMedium//units.gu(0.5)
                //height: childrenRect.height

                Row {
                    id: rowUser
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.paddingSmall 
                        rightMargin: Theme.paddingSmall 
                    }
                    spacing: Theme.paddingSmall 
                    height: Math.max(rowUserColumn.height,usAvatar.height)//usAvatar.height

                    Item {
                        id: usAvatar
                        width: 64
                        height: width
                        Image {
                            width: parent.width
                            height: parent.height
                            smooth: true
                            fillMode: Image.PreserveAspectFit
                            source: model.user.profile_image_url
                        }
                    }

                    Column {
                        id:rowUserColumn
                        spacing: Theme.paddingSmall

                        Label {
                            id: labelUserName
                            color: Theme.primaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                            text: model.user.screen_name
                        }

                        Label {
                            id: labelCommentTime
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                            text: "Weibo Time" /*{
                                return DateUtils.formatRelativeTime(i18n, DateUtils.parseDate(appData.dateParse(model.created_at)))
                            }*/
                        }
                    }
                }

                Label {
                    id: labelComment
                    anchors { 
                        left: parent.left
                        right: parent.right
                        leftMargin:  Theme.paddingSmall 
                        rightMargin:  Theme.paddingSmall 
                    }
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    text: model.text
                }

                // user weibo
                Item {
                    id: usWeiboContent
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin:  Theme.paddingSmall 
                        rightMargin:  Theme.paddingSmall 
                    }
                    height: colWeibo.height + Theme.paddingSmall 
                    
                    // use reply_comment if reply_comment exist
                    property var status: model.status

                    signal clicked

                    Image {
                        id: background
                        source: "../graphics/mask_background_reposted.png"
                        fillMode: Image.PreserveAspectCrop
                    }
                    
                    Column {
                        id: colWeibo
                        anchors {
                            top: parent.top; topMargin: Theme.paddingSmall 
                            left: parent.left; right: parent.right
                            leftMargin: Theme.paddingSmall 
                            rightMargin: Theme.paddingSmall 
                        }
                        spacing: Theme.paddingSmall 
                        //height: childrenRect.height

                        Column {
                            id: colUser
                            anchors { left: parent.left; right: parent.right }
                            spacing: Theme.paddingSmall 
                            height: childrenRect.height

                            Label {
                                id: labelWeiboUserName
                                color: Theme.secondaryHighlightColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                                text: usWeiboContent.status.user.screen_name
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

                    } // column
                } // user weibo

                Separator {
                    width: parent.width
                    color: Theme.highlightColor
                }
            }

//            MouseArea {
//                anchors.fill: parent
//                onClicked: {
////                    console.log("reply comment: ", JSON.stringify(model.reply_comment))
//                    commentMentionedPage.commentInfo = { "id": model.status.id, "cid": model.id}
//                    commentMentionedPage.weiboTmp = model.status
//                    PopupUtils.open(dialog)
//                }
//            }
            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text:  qsTr("Reply")
                        onClicked: {
                            /////////// Ugly code
                            commentMentionedPage.commentInfo = { "id": model.status.id, "cid": model.id}
                            commentMentionedPage.weiboTmp = model.status
                            //toSendPage("reply", commentMentionedPage.commentInfo)
                            pageStack.push(Qt.resolvedUrl("SendPage.qml"),
                                           {"mode":"reply",
                                               "info":commentMentionedPage.commentInfo})
                        }
                    }
                    MenuItem {
                        text: qsTr("View weibo")
                        onClicked: {
                            /////////// Ugly code
                            commentMentionedPage.commentInfo = { "id": model.status.id, "cid": model.id}
                            commentMentionedPage.weiboTmp = model.status
                            
                            modelWeiboTemp.clear()
                            modelWeiboTemp.append(weiboTmp)
                            //toWeiboPage(modelWeiboTemp, 0)
                            pageStack.push(Qt.resolvedUrl("WeiboPage.qml"),
                                           {"weiboModel":modelWeiboTemp,
                                               "newIndex":"0"})
                        }
                    }
                }
            }
        }
    }// component

    ListModel {
        id: modelWeiboTemp
    }

}
