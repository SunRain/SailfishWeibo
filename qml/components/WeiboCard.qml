import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/getURL.js" as GetURL
Item {
    id:weiboCard
    
    anchors {
        left: parent.left
        right: parent.right
    }
    height: columnWContent.height

    property var weiboJSONContent
    property alias optionMenu: usWeibo.optionMenu
    
    property var repostButtonColor
    property var commentButtonColor
    property var likeButtonColor
    
    signal repostedWeiboClicked
    signal usWeiboClicked
    signal avatarHeaderClicked(string userId)
    signal labelLinkClicked(string link)
    signal labelImageClicked(var modelImages, string index)
    signal commentButtonClicked
    signal repostButtonClicked
    signal likeButtonClicked

    Column {
        id: columnWContent
        anchors {
            top: parent.top
            topMargin: Theme.paddingSmall
            left: parent.left
            right: parent.right
            leftMargin: Theme.paddingLarge 
            rightMargin: Theme.paddingLarge 
        }
        spacing: Theme.paddingMedium
        BaseWeiboCard {
            id:usWeibo
            isInvalid: false
            avatarHeaderHeight: Theme.itemSizeSmall
            avaterHeaderFontSize: Theme.fontSizeExtraSmall
            avaterHeaderUserName: weiboJSONContent.user.screen_name
            avaterHeaderAvaterImage: weiboJSONContent.user.profile_image_url
            avaterHeaderWeiboTime: DateUtils.parseDate(appData.dateParse(weiboJSONContent.created_at))
                    + qsTr(" From ") + GetURL.linkToStr(weiboJSONContent.source)

            labelFontSize: Theme.fontSizeMedium
            labelContent: util.parseWeiboContent(weiboJSONContent.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
            picURLs: weiboJSONContent.pic_urls
            
            onUserAvatarHeaderClicked: {
                weiboCard.avatarHeaderClicked(weiboJSONContent.user.id);
            }
            onLabelLinkClicked: {
                weiboCard.labelLinkClicked(link);
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
            sourceComponent: weiboJSONContent.retweeted_status == undefined 
                             ? repostedLoader.Null
                             : repostedBaseWeiboCard
        }

        Component {
            id:repostedBaseWeiboCard
            BaseWeiboCard {
                id:repostedWeibo
                isInvalid:  weiboJSONContent.retweeted_status == undefined
                avatarHeaderHeight: Theme.itemSizeSmall
                avaterHeaderFontSize: Theme.fontSizeExtraSmall
                avaterHeaderUserName: weiboJSONContent.retweeted_status.user.screen_name
                avaterHeaderAvaterImage: weiboJSONContent.retweeted_status.user.profile_image_url
                avaterHeaderWeiboTime: DateUtils.parseDate(appData.dateParse(weiboJSONContent.retweeted_status.created_at))
                        + qsTr(" From ") + GetURL.linkToStr(weiboJSONContent.retweeted_status.source)
                
                labelFontSize: Theme.fontSizeMedium
                labelContent: util.parseWeiboContent(weiboJSONContent.retweeted_status.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
                picURLs: weiboJSONContent.retweeted_status.pic_urls

                onUserAvatarHeaderClicked: {
                    weiboCard.avatarHeaderClicked(weiboJSONContent.retweeted_status.user.id);
                }
                onLabelLinkClicked: {
                    weiboCard.labelLinkClicked(link);
                }
                onBaseWeiboCardClicked: {
                    weiboCard.repostedWeiboClicked();
                }
                onLabelImageClicked: {
                    weiboCard.labelImageClicked(modelImages, index);
                }
                
                Image {
                    id: background
                    anchors {
                        top: repostedWeibo.top
                        left: repostedWeibo.left
                        right: repostedWeibo.right
                        bottom: repostedWeibo.bottom
                    }
                    source: util.pathTo("qml/graphics/mask_background_reposted.png")
                    fillMode:Image.TileHorizontally
                }
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            height: Theme.itemSizeExtraSmall /2
            spacing: Theme.paddingLarge *2

            MouseArea {
                id: repostMouse
                height: parent.height
                width: childrenRect.width
                property bool _press: repostMouse.pressed && repostMouse.containsMouse
                Row {
                    height: parent.height
                    spacing: Theme.paddingSmall/2
                    Image {
                        source: util.pathTo("qml/graphics/repost.png")
                        height: parent.height
                        width: height
                        fillMode: Image.PreserveAspectFit
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: weiboJSONContent.reposts_count
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
                        source: util.pathTo("qml/graphics/comment.png")
                        height: parent.height
                        width: height
                        fillMode: Image.PreserveAspectFit
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: weiboJSONContent.comments_count
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
                        source: util.pathTo("qml/graphics/like.png")
                        height: parent.height
                        width: height
                        fillMode: Image.PreserveAspectFit
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: weiboJSONContent.attitudes_count
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
