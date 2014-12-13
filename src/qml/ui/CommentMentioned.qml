import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../js/getURL.js" as GetURL
import "../components"

import com.sunrain.sinaweibo 1.0

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
        commentMentioned(pageNum)
    }

    function addMore() {
        pageNum++
        commentMentioned(pageNum)
    }

    //////////////////////////////////////////////////////////////////         get all comment mentioned me
    function commentMentioned(page) {
//        // 2/comments/mentions: 获取@到我的评论
//        REQUEST_API_BEGIN(comments_mentions, "2/comments/mentions")
//                ("source", "")  //采用OAuth授权方式不需要此参数，其他授权方式为必填参数，数值为应用的AppKey。
//                ("access_token", "")  //采用OAuth授权方式为必填参数，其他授权方式不需要此参数，OAuth授权后获得。
//                ("since_id", 0)  //若指定此参数，则返回ID比since_id大的评论（即比since_id时间晚的评论），默认为0。
//                ("max_id", 0)  //若指定此参数，则返回ID小于或等于max_id的评论，默认为0。
//                ("count", 50)  //单页返回的记录条数，默认为50。
//                ("page", 1)  //返回结果的页码，默认为1。
//                ("filter_by_author", 0)  //作者筛选类型，0：全部、1：我关注的人、2：陌生人，默认为0。
//                ("filter_by_source", 0)  //来源筛选类型，0：全部、1：来自微博的评论、2：来自微群的评论，默认为0。
//        REQUEST_API_END()
        // WBOPT_GET_COMMENTS_MENTIONS,//@到我的评论
        var method = WeiboMethod.WBOPT_GET_COMMENTS_MENTIONS;
        api.setWeiboAction(method, {'page':pageNum});
    }
    
    
    Connections {
        target: api
        //void weiboPutSucceed(QWeiboMethod::WeiboAction action, const QString& replyData);
        onWeiboPutSucceed: {
            if (action == WeiboMethod.WBOPT_GET_COMMENTS_MENTIONS) {
                var result = JSON.parse(replyData);
                for (var i=0; i<result.comments.length; i++) {
                    modelComment.append( result.comments[i] )
                }
            }
        }
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
        model: ListModel { id: modelComment }
        delegate: delegateComment
        cacheBuffer: 9999
        header:PageHeader {
            id:pageHeader
            title: qsTr("Comments mentioned me")
        }
        footer: FooterLoadMore {
            visible: modelComment.count != 0
            onClicked: {addMore()}
        }
    }


    Component {
        id: delegateComment

        OptionItem {
            width: parent.width
            contentHeight: columnWContent.height + Theme.paddingMedium

            menu: contextMenu
            
            Column {
                id: columnWContent
                anchors {
                    top: parent.top
                    topMargin: Theme.paddingMedium
                    left: parent.left
                    right: parent.right
                }
                spacing: Theme.paddingMedium
                
                UserAvatarHeader {
                    id:avaterHeader
                    width: parent.width *7/10
                    height:Theme.itemSizeSmall
                    
                    userName: model.user.screen_name
                    userNameFontSize: Theme.fontSizeExtraSmall
                    userAvatar: model.user.profile_image_url
                    weiboTime: DateUtils.formatRelativeTime(DateUtils.parseDate(appData.dateParse(model.created_at)))
                               + qsTr(" From ") + GetURL.linkToStr(model.source)
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
                                               "userInfo":commentMentionedPage.commentInfo})
                        }
                    }
                    MenuItem {
                        text: qsTr("View weibo")
                        onClicked: {
                            /////////// Ugly code
//                            commentMentionedPage.commentInfo = { "id": model.status.id, "cid": model.id}
//                            commentMentionedPage.weiboTmp = model.status
                            
//                            modelWeiboTemp.clear()
//                            modelWeiboTemp.append(weiboTmp)
//                            //toWeiboPage(modelWeiboTemp, 0)
                            pageStack.push(Qt.resolvedUrl("WeiboPage.qml"),
                                           {"userWeiboJSONContent":model.status})
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
