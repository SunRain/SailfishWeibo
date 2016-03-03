import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/getURL.js" as GetURL
Item {
    id:weiboCard
    
    width: parent ? parent.width : Screen.width
    height: columnWContent.height

    property var weiboJSONContent: undefined
    onWeiboJSONContentChanged: {
        if (weiboJSONContent != undefined && weiboJSONContent != "") {
            inner.attitudes_count = weiboJSONContent.attitudes_count;
            inner.comments_count = weiboJSONContent.comments_count;
            inner.reposts_count = weiboJSONContent.reposts_count;
            if (inner.attitudes_count == undefined
                    || inner.comments_count == undefined
                    || inner.reposts_count == undefined) {
                inner.showFooterBar = false;
                //set value to "" to avoid qml warning
                inner.attitudes_count = "";
                inner.comments_count  = "";
                inner.reposts_count = "";
            } else {
                inner.showFooterBar = true;
            }

            inner.subValue = weiboJSONContent.retweeted_status;
            if (inner.subValue == undefined || inner.subValue == "")
                inner.subValue = weiboJSONContent.status;
            if (inner.subValue == undefined || inner.subValue == "")
                inner.subValue = weiboJSONContent.reply_comment;
            if (inner.subValue == undefined || inner.subValue == "") {
                inner.subValue = weiboJSONContent.card;
                if (inner.subValue != undefined && inner.subValue != "")
                    inner.useSimpleSubView = true;
            }
        }
    }

    property alias optionMenu: usWeibo.optionMenu
    
    property var repostButtonColor
    property var commentButtonColor
    property var likeButtonColor
    
    signal repostedWeiboClicked
    signal usWeiboClicked
    signal avatarHeaderClicked(string userId)
    signal labelLinkClicked(string link)
    signal linkTopicClicked(string link)
    signal linkUnknowClicked(string link)
    signal linkWebOrVideoClicked(string link)
    signal linkAtClicked(string link)
    signal labelImageClicked(var modelImages, string index)
    signal commentButtonClicked
    signal repostButtonClicked
    signal likeButtonClicked

    QtObject {
        id: inner
        property var subValue: undefined
        property var reposts_count: undefined
        property var comments_count: undefined
        property var attitudes_count: undefined
        property bool showFooterBar: false
        property bool useSimpleSubView: false
    }

    Column {
        id: columnWContent
        width: parent.width
        anchors {
            top: parent.top
            left: parent.left
        }
        spacing: Theme.paddingMedium
        BaseWeiboCard {
            id:usWeibo
            isInvalid: false
            avatarHeaderHeight: Theme.itemSizeSmall
            avaterHeaderFontSize: Theme.fontSizeExtraSmall
            avaterHeaderUserName: weiboJSONContent.user.screen_name
            avaterHeaderAvaterImage: weiboJSONContent.user.profile_image_url
            avaterHeaderWeiboTime:tokenProvider.useHackLogin
                                  ? weiboJSONContent.created_at + " " + qsTr("From") + " " + weiboJSONContent.source
                                  : DateUtils.parseDate(appUtility.dateParse(weiboJSONContent.created_at))
                                        + qsTr(" From ") + GetURL.linkToStr(weiboJSONContent.source)

            labelFontSize: Theme.fontSizeMedium
            labelContent: wbParser.parseWeiboContent(weiboJSONContent.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
            picURLs: tokenProvider.useHackLogin
                     ? weiboJSONContent.pics
                     : weiboJSONContent.pic_urls

            onUserAvatarHeaderClicked: {
                console.log("===== weiboCard.avatarHeaderClicked " + weiboJSONContent.user.id);
                weiboCard.avatarHeaderClicked(weiboJSONContent.user.id);
            }
            onLabelLinkClicked: { //link
                var data = link.split("||");
                if (data[0] == "LinkTopic")
                    weiboCard.linkTopicClicked(data[1]);
                else if (data[0] == "LinkUnknow")
                    weiboCard.linkUnknowClicked(data[1])
                else if (data[0] == "LinkWebOrVideo")
                    weiboCard.linkWebOrVideoClicked(data[1])
                else if (data[0] == "LinkAt")
                    weiboCard.linkAtClicked(data[1])
                else
                    weiboCard.labelLinkClicked(data[0]);
            }
            onBaseWeiboCardClicked: {
                weiboCard.usWeiboClicked();
            }
            onLabelImageClicked: {
                weiboCard.labelImageClicked(modelImages, index);
            }
        }
        
        Loader{
            id:repostedLoader
            width: parent.width
            height: childrenRect.height
            sourceComponent: inner.subValue == undefined
                             ? repostedLoader.Null
                             : inner.useSimpleSubView ? simpleSubViewComponent : repostedBaseWeiboCard
        }

        Component {
            id: simpleSubViewComponent
            BackgroundItem {
                id: svMain
                width: parent.width
                height: Math.max(svImage.height, svColumn.height)
                onClicked: {
                    weiboCard.repostedWeiboClicked();
                }
                Image {
                    id: background
                    anchors.fill: parent
                    source: appUtility.pathTo("qml/graphics/mask_background_reposted.png")
                    fillMode:Image.TileHorizontally
                }
                Image {
                    id: svImage
                    width: Theme.itemSizeMedium
                    height: width
                    anchors {
                        left: parent.left
                        leftMargin: Theme.paddingSmal
                        verticalCenter: parent.verticalCenter
                    }
                    source: inner.subValue.page_pic
                    fillMode: Image.PreserveAspectFit
                }
                Column {
                    id: svColumn
                    anchors {
                        left: svImage.right
                        leftMargin: Theme.paddingSmal
                        right: parent.right
                        rightMargin: Theme.paddingSmal
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: Theme.paddingSmall
                    Label {
                        width: parent.width
                        text: inner.subValue.page_title
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        textFormat: Text.StyledText
                        font.bold: true
                    }
                    Label {
                        width: parent.width
                        text: inner.subValue.page_desc
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        textFormat: Text.StyledText
                    }
                }
            }
        }

        Component {
            id:repostedBaseWeiboCard
            Item {
                width: parent.width
                height: repostedWeibo.height
                BaseWeiboCard {
                    id: repostedWeibo
                    width: parent.width - Theme.paddingSmall * 2
                    anchors {
                        left: parent.left
                        leftMargin: Theme.paddingSmall
                    }
                    isInvalid: inner.subValue == undefined
                    avatarHeaderHeight: Theme.itemSizeSmall
                    avaterHeaderFontSize: Theme.fontSizeExtraSmall
                    avaterHeaderUserName: inner.subValue.user.screen_name
                    avaterHeaderAvaterImage: inner.subValue.user.profile_image_url
                    avaterHeaderWeiboTime: tokenProvider.useHackLogin
                            ? inner.subValue.created_at + " " + qsTr("From") + " " + inner.subValue.source
                            : DateUtils.parseDate(appUtility.dateParse(inner.subValue.created_at))
                                + qsTr("From") + GetURL.linkToStr(inner.subValue.source)

                    labelFontSize: Theme.fontSizeMedium
                    labelContent: wbParser.parseWeiboContent(inner.subValue.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
                    picURLs: tokenProvider.useHackLogin
                            ? inner.subValue.pics
                            : inner.subValue.pic_urls

                    onUserAvatarHeaderClicked: {
                        weiboCard.avatarHeaderClicked(inner.subValue.user.id);
                    }
                    onLabelLinkClicked: {
                        var data = link.split("||");
                        if (data[0] == "LinkTopic")
                            weiboCard.linkTopicClicked(data[1]);
                        else if (data[0] == "LinkUnknow")
                            weiboCard.linkUnknowClicked(data[1])
                        else if (data[0] == "LinkWebOrVideo")
                            weiboCard.linkWebOrVideoClicked(data[1])
                        else if (data[0] == "LinkAt")
                            weiboCard.linkAtClicked(data[1])
                        else
                            weiboCard.labelLinkClicked(data[0]);
                    }
                    onBaseWeiboCardClicked: {
                        weiboCard.repostedWeiboClicked();
                    }
                    onLabelImageClicked: {
                        weiboCard.labelImageClicked(modelImages, index);
                    }
                }
                Image {
                    id: background
                    anchors.fill: parent
                    source: appUtility.pathTo("qml/graphics/mask_background_reposted.png")
                    fillMode:Image.TileHorizontally
                }
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            height: Theme.itemSizeExtraSmall /2
            spacing: Theme.paddingLarge *2
            enabled: inner.showFooterBar
            visible: inner.showFooterBar

            MouseArea {
                id: repostMouse
                height: parent.height
                width: childrenRect.width
                property bool _press: repostMouse.pressed && repostMouse.containsMouse
                Row {
                    height: parent.height
                    spacing: Theme.paddingSmall/2
                    Image {
                        source: appUtility.pathTo("qml/graphics/repost.png")
                        height: parent.height
                        width: height
                        fillMode: Image.PreserveAspectFit
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: inner.reposts_count
                        font.bold: repostMouse._press
                        font.pixelSize: parent.height
                        color: repostMouse._press ? Theme.highlightColor : Theme.secondaryColor
                    }
                }
                onClicked: {
                    weiboCard.repostButtonClicked();
                }
            }
            Rectangle {
                width: 1
                height: parent.height
                color: Theme.highlightColor
            }
            MouseArea {
                id: commentMouse
                height: parent.height
                width: childrenRect.width
                property bool _press: commentMouse.pressed && commentMouse.containsMouse
                Row {
                    height: parent.height
                    spacing: Theme.paddingSmall/2
                    Image {
                        source: appUtility.pathTo("qml/graphics/comment.png")
                        height: parent.height
                        width: height
                        fillMode: Image.PreserveAspectFit
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: inner.comments_count
                        font.bold: commentMouse._press
                        font.pixelSize: parent.height
                        color: commentMouse._press ? Theme.highlightColor : Theme.secondaryColor
                    }
                }
                onClicked: {
                    weiboCard.commentButtonClicked();
                }
            }
            Rectangle {
                width: 1
                height: parent.height
                color: Theme.highlightColor
            }
            MouseArea {
                id: likeMouse
                height: parent.height
                width: childrenRect.width
                property bool _press: likeMouse.pressed && likeMouse.containsMouse
                Row {
                    height: parent.height
                    spacing: Theme.paddingSmall/2
                    Image {
                        source: appUtility.pathTo("qml/graphics/like.png")
                        height: parent.height
                        width: height
                        fillMode: Image.PreserveAspectFit
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: inner.attitudes_count
                        font.bold: likeMouse._press
                        font.pixelSize: parent.height
                        color: likeMouse._press ? Theme.highlightColor : Theme.secondaryColor
                    }
                }
                onClicked: {
                    weiboCard.likeButtonClicked();
                }
            }
        }
    }
}
