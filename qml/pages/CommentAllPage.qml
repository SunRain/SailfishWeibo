import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../js/getURL.js" as GetURL
import "../components"

import harbour.sailfish_sinaweibo.sunrain 1.0

Page {
    id: commentAllPage

    property var uid
    property string userName: ""
    property int _pageNum: 1

    property var _commentInfo
    property var _weiboTmp

    property alias contentItem: commentListView

    function refresh() {
        modelComment.clear()

        _pageNum = 1
        _commentAll(_pageNum)
    }

    function _addMore() {
        _pageNum++
        _commentAll(_pageNum)
    }

    //////////////////////////////////////////////////////////////////         get all comment
    function _commentAll(page) {
        showBusyIndicator();
//        // 2/comments/timeline: 获取用户发送及收到的评论列表
//        REQUEST_API_BEGIN(comments_timeline, "2/comments/timeline")
//                ("source", "")  //采用OAuth授权方式不需要此参数，其他授权方式为必填参数，数值为应用的AppKey。
//                ("access_token", "")  //采用OAuth授权方式为必填参数，其他授权方式不需要此参数，OAuth授权后获得。
//                ("since_id", 0)  //若指定此参数，则返回ID比since_id大的评论（即比since_id时间晚的评论），默认为0。
//                ("max_id", 0)  //若指定此参数，则返回ID小于或等于max_id的评论，默认为0。
//                ("count", 50)  //单页返回的记录条数，默认为50。
//                ("page", 1)  //返回结果的页码，默认为1。
//                ("trim_user", 0)  //返回值中user字段开关，0：返回完整user字段、1：user字段仅返回user_id，默认为0。
//        REQUEST_API_END()
        //WBOPT_GET_COMMENTS_TIMELINE,//获取当前用户发送及收到的评论列表
        
        var method = WeiboMethod.WBOPT_GET_COMMENTS_TIMELINE;
        api.setWeiboAction(method, {'page':_pageNum});
    }
    
    Connections {
        target: api
        //void weiboPutSucceed(QWeiboMethod::WeiboAction action, const QString& replyData);
        onWeiboPutSucceed: {
            if (action == WeiboMethod.WBOPT_GET_COMMENTS_TIMELINE) {
                var result = JSON.parse(replyData);
                for (var i=0; i<result.comments.length; i++) {
                    modelComment.append( result.comments[i] )
                }
                stopBusyIndicator();
            }
        }
    }
    
//    Component.onCompleted: {
//        refresh();
//    }

    SilicaListView {
        id: commentListView
        anchors.fill: parent
        model: ListModel { id: modelComment }
        delegate: delegateComment
        cacheBuffer: 9999
        header:PageHeader {
            id:pageHeader
            title: qsTr("All comments")
        }
        footer: FooterLoadMore {
            visible: modelComment.count != 0
            onClicked: {_addMore()}
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    commentAllPage.refresh();
                }
            }
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
                        leftMargin: Theme.paddingSmall 
                        rightMargin: Theme.paddingSmall 
                    }
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    text: util.parseWeiboContent(model.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
                    //model.text
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
                    height: colWeibo.height + Theme.paddingSmall
                    // use reply_comment if reply_comment exist
                    property var _status: model.reply_comment == undefined ? model.status : model.reply_comment

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

                        Column {
                            id: colUser
                            anchors { left: parent.left; right: parent.right }
                            spacing: Theme.paddingSmall 
                            height: childrenRect.height

                            Label {
                                id: labelWeiboUserName
                                color: Theme.secondaryHighlightColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                                text: usWeiboContent._status.user.screen_name
                            }
                        }

                        Label {
                            id: labelWeibo
                            width: parent.width
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            text: util.parseWeiboContent(usWeiboContent._status.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
                            //usWeiboContent._status.text
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
                            commentAllPage._commentInfo = { "id": model.status.id, "cid": model.id}
                            commentAllPage._weiboTmp = model.status
                           //toSendPage("reply", commentAllPage.commentInfo)
                            pageStack.push(Qt.resolvedUrl("SendPage.qml"),
                                           {"mode":"reply",
                                               "userInfo":commentAllPage._commentInfo})
                        }
                    }
                    MenuItem {
                        text: qsTr("View weibo")
                        onClicked: {
                                        /////////// Ugly code
//                            commentAllPage.commentInfo = { "id": model.status.id, "cid": model.id}
//                            commentAllPage.weiboTmp = model.status
                            
//                            modelWeiboTemp.clear()
//                            modelWeiboTemp.append(weiboTmp)
                            //toWeiboPage(modelWeiboTemp, 0)
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
