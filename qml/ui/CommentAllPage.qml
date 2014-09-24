import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../js/getURL.js" as GetURL
import "../components"

Page {
    id: commentAllPage

    property var uid
    property string userName: ""
    property int pageNum: 1

    property var commentInfo
    property var weiboTmp

    function refresh() {
        modelComment.clear()

        pageNum = 1
//        isRefresh = true
        commentAll(Settings.getAccess_token(), pageNum)
    }

    function addMore() {
        pageNum++
        commentAll(Settings.getAccess_token(), pageNum)
    }

    //////////////////////////////////////////////////////////////////         get all comment
    function commentAll(token, page)
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
//                        console.log("all comment: ", JSON.stringify(result))
                        for (var i=0; i<result.comments.length; i++) {
                            modelComment.append( result.comments[i] )
                        }
                    }
                }else{
                    // TODO  empty result
                }
            }
        }

        WB.messageGetAllComment(token, page, new observer())
    }
    Component.onCompleted: {
        refresh();
    }

    SilicaListView {
        anchors.fill: parent
        model: ListModel { id: modelComment }
        delegate: delegateComment
        cacheBuffer: 9999
        header:PageHeader {
            id:pageHeader
            title: qsTr("All comments")
        }
    }


    Component {
        id: delegateComment

        ListItem {
            width: parent.width
            contentHeight: columnWContent.height + Theme.paddingMedium 

            menu: contextMenu

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
                    spacing:Theme.paddingSmall 
                    height: Math.max(rowUserColumn.height,usAvatar.height)//owUserColumn.height > 64 ? rowUserColumn.height : usAvatar.height//usAvatar.height

                    Item{
                        id: usAvatar
                        width: 64//units.gu(4.5)
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
                            text:{
                                return DateUtils.formatRelativeTime(DateUtils.parseDate(appData.dateParse(model.created_at)))
                                + qsTr(" From ") + GetURL.linkToStr(model.source)
                            }
                        }
                    }
                }

                Label {
                    id: labelComment
                    anchors { 
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.paddingSmall 
                        rightMargin: Theme.paddingSmall 
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
                        leftMargin: Theme.paddingSmall 
                        rightMargin: Theme.paddingSmall 
                    }
                    height: colWeibo.height + Theme.paddingSmall //1.5//units.gu(1.5)
                    // use reply_comment if reply_comment exist
                    property var status: model.reply_comment == undefined ? model.status : model.reply_comment

                    signal clicked

                    Image {
                        id: background
                        source: "../graphics/mask_background_reposted.png"
                        fillMode: Image.PreserveAspectCrop
                    }
                    
                    Column {
                        id: colWeibo
                        anchors {
                            top: parent.top
                            topMargin:Theme.paddingSmall 
                            left: parent.left
                            right: parent.right
                            leftMargin: Theme.paddingSmall 
                            rightMargin: Theme.paddingSmall 
                        }
                        spacing:Theme.paddingSmall 
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

            //TODO 使用ApplicationWindow定义的方法切换qml会出错，需要使用更好的全局方法来替代冗余的pageStack.push
            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: qsTr("Reply comment")
                        onClicked: {
                                        /////////// Ugly code
                            commentAllPage.commentInfo = { "id": model.status.id, "cid": model.id}
                            commentAllPage.weiboTmp = model.status
                           //toSendPage("reply", commentAllPage.commentInfo)
                            pageStack.push(Qt.resolvedUrl("SendPage.qml"),
                                           {"mode":"reply",
                                               "info":commentAllPage.commentInfo})
                        }
                    }
                    MenuItem {
                        text: qsTr("View weibo")
                        onClicked: {
                                        /////////// Ugly code
                            commentAllPage.commentInfo = { "id": model.status.id, "cid": model.id}
                            commentAllPage.weiboTmp = model.status
                            
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
