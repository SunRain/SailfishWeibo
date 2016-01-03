import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
//import "../js/Settings.js" as Settings
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

    CommentsTimeline {
        id: commentsTimeline
        onRequestAbort: {
            console.log("== commentsTimeline onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== commentsTimeline onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            //            console.log("== commentsTimeline onRequestSuccess ")//["+replyData+"]")
            var result = JSON.parse(replyData);
            for (var i=0; i<result.comments.length; ++i) {
                modelComment.append(result.comments[i])
            }
            if (commentListView.model == undefined)
                commentListView.model = modelComment;
            stopBusyIndicator();
        }
    }

    //////////////////////////////////////////////////////////////////         get all comment
    function _commentAll(page) {
        showBusyIndicator();
        commentsTimeline.setParameters("page", _pageNum);
        commentsTimeline.getRequest();
    }

    ListModel { id: modelComment }

    SilicaListView {
        id: commentListView
        anchors.fill: parent
        spacing: Theme.paddingLarge
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

        Column {
            width: parent.width
            spacing: Theme.paddingSmall

            BaseWeiboCard {
                id: commentCard
                avatarHeaderHeight: Theme.itemSizeSmall
                avaterHeaderFontSize: Theme.fontSizeExtraSmall
                avaterHeaderUserName: model.user.screen_name
                avaterHeaderAvaterImage: model.user.profile_image_url
                avaterHeaderWeiboTime: DateUtils.parseDate(appData.dateParse(model.created_at))
                                       + qsTr(" From ") + GetURL.linkToStr(model.source)
                labelFontSize: Theme.fontSizeMedium
                labelContent: util.parseWeiboContent(model.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
                picURLs: model.pic_urls
                onUserAvatarHeaderClicked: {
                    console.log("==== commentCard onUserAvatarHeaderClicked")
                }
                onLabelLinkClicked: {
                    console.log("==== commentCard onLabelLinkClicked")
                }
                onBaseWeiboCardClicked: {
                    console.log("==== commentCard onBaseWeiboCardClicked")
                }
                onLabelImageClicked: {
                    console.log("==== commentCard onLabelImageClicked")
                }
                optionMenu:menu
                ContextMenu {
                    id: menu
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
                            pageStack.push(Qt.resolvedUrl("WeiboPage.qml"),
                                           {"userWeiboJSONContent":model.status})
                        }
                    }
                }
            }
            BaseWeiboCard {
                id: statusCard
                // use reply_comment if reply_comment exist
                property var _status: model.reply_comment == undefined ? model.status : model.reply_comment

                avatarHeaderHeight: Theme.itemSizeSmall
                avaterHeaderFontSize: Theme.fontSizeExtraSmall
                avaterHeaderUserName: _status.user.screen_name//weiboJSONContent.user.screen_name
                avaterHeaderAvaterImage: _status.user.profile_image_url//weiboJSONContent.user.profile_image_url
                avaterHeaderWeiboTime: DateUtils.parseDate(appData.dateParse(_status.created_at))
                                       + qsTr(" From ") + GetURL.linkToStr(_status.source)
                labelFontSize: Theme.fontSizeMedium
                labelContent: util.parseWeiboContent(_status.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
                picURLs: _status.pic_urls
                onUserAvatarHeaderClicked: {
                    console.log("==== statusCard onUserAvatarHeaderClicked")
                }
                onLabelLinkClicked: {
                    console.log("==== statusCard onLabelLinkClicked")
                }
                onBaseWeiboCardClicked: {
                    console.log("==== statusCard onBaseWeiboCardClicked")
                }
                onLabelImageClicked: {
                    console.log("==== statusCard onLabelImageClicked")
                }
                Image {
                    id: background
                    anchors.fill: parent
                    source: util.pathTo("qml/graphics/mask_background_reposted.png")
                    fillMode: Image.PreserveAspectCrop
                }
            }
            Separator {
                width: parent.width
                color: Theme.highlightColor
            }
        }
    }// component

    ListModel {
        id: modelWeiboTemp
    }

}
