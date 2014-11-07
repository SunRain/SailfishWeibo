import QtQuick 2.0
//import Ubuntu.Components 0.1
//import Ubuntu.Components.ListItems 0.1 as ListItem
import "../js/dateutils.js" as DateUtils
import "../js/getURL.js" as GetURL
import Sailfish.Silica 1.0

/**********************************************
 *  微博内容展示框
 *  包含
 *  - 用户头像/用户名/微博发送时间
 *  - 微博文字内容
 *  - 转发微博时候相关的转发信息（使用另一个代理）
 *  - 下部的转发/评论/顶的按钮
 *  
************************************************/
Item {
    id: usWeiboContent
    anchors {
        left: parent.left
        right: parent.right
    }
    height: columnWContent.height + Theme.paddingMedium 

    property alias optionMenu: usWeibo.optionMenu

    signal repostedWeiboClicked
    signal usWeiboClicked

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
            avaterHeaderUserName: model.user.screen_name
            avaterHeaderAvaterImage: model.user.profile_image_url
            avaterHeaderWeiboTime: DateUtils.formatRelativeTime(DateUtils.parseDate(appData.dateParse(model.created_at)))
                                   + qsTr(" From ") + GetURL.linkToStr(model.source)
            
            labelFontSize: Theme.fontSizeMedium
            labelContent: util.parseWeiboContent(model.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
            picURLs: model.pic_urls
            
            onUserAvatarHeaderClicked: {
                toUserPage(model.user.id);
            }
            onLabelLinkClicked: {
                 Qt.openUrlExternally(link);
            }
            onBaseWeiboCardClicked: {
                usWeiboContent.usWeiboClicked();
            }
            onLabelImageClicked: {
                toGalleryPage(modelImages, index);
            }
        }
        
        Loader{
            id:repostedLoader
            width: parent.width
            height: childrenRect.height
            sourceComponent: model.retweeted_status == undefined 
                             ? repostedLoader.Null
                             : repostedBaseWeiboCard
        }

        Component {
            id:repostedBaseWeiboCard
            BaseWeiboCard {
                id:delegateRepostedWeibo
                isInvalid:  model.retweeted_status == undefined
                avatarHeaderHeight: Theme.itemSizeSmall
                avaterHeaderFontSize: Theme.fontSizeExtraSmall
                avaterHeaderUserName: model.retweeted_status.user.screen_name
                avaterHeaderAvaterImage: model.retweeted_status.user.profile_image_url
                avaterHeaderWeiboTime: DateUtils.formatRelativeTime(DateUtils.parseDate(appData.dateParse(model.retweeted_status.created_at)))
                                       + qsTr(" From ") + GetURL.linkToStr(model.retweeted_status.source)
                
                labelFontSize: Theme.fontSizeMedium
                labelContent: util.parseWeiboContent(model.retweeted_status.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
                picURLs: {
                    console.log(" Delegate Weibo repost pics " + JSON.stringify(model.retweeted_status.pic_urls))
                    return JSON.parse(JSON.stringify(model.retweeted_status.pic_urls))
                }

                onUserAvatarHeaderClicked: {
                    toUserPage(model.retweeted_status.user.id);
                }
                onLabelLinkClicked: {
                    Qt.openUrlExternally(link);
                }
                onBaseWeiboCardClicked: {
                    usWeiboContent.repostedWeiboClicked();
                }
                onLabelImageClicked: {
                    toGalleryPage(modelImages, index);
                }
                
                Image {
                    id: background
                    anchors {
                        top: delegateRepostedWeibo.top
                        left: delegateRepostedWeibo.left
                        right: delegateRepostedWeibo.right
                        bottom: delegateRepostedWeibo.bottom
                    }
                    source: "../graphics/mask_background_reposted.png"
                    fillMode:Image.TileHorizontally
                }
            }
        }
        
        Column {
            width: parent.width
            spacing: Theme.paddingSmall

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                
                Item {
                    width: columnWContent.width / 3 -Theme.paddingSmall 
                    height: Theme.fontSizeSmall
                    
                    Label {
                        anchors.centerIn: parent
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeTiny
                        text: qsTr("repost: ") + model.reposts_count
                    }
                }
                Rectangle {
                    width: 1
                    height: Theme.fontSizeSmall -2
                    color: Theme.highlightColor
                }
                Item {
                    width: columnWContent.width / 3 - Theme.paddingSmall
                    height: Theme.fontSizeSmall
                    
                    Label {
                        anchors.centerIn: parent
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeTiny
                        text: qsTr("comment: ") + model.comments_count
                    }
                }
                Rectangle {
                    width: 1
                    height: Theme.fontSizeSmall -2
                    color: Theme.highlightColor
                }
                Item {
                    width: columnWContent.width / 3 - Theme.paddingSmall  
                    height: Theme.fontSizeSmall
                    
                    Label {
                        anchors.centerIn: parent
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeTiny
                        text: qsTr("like: ") + model.attitudes_count
                    }
                }
            }
        }
        
        Separator {
            width: parent.width
            color: Theme.highlightColor
        }
        Item {
            width: parent.width
            height: Theme.paddingSmall
        }
    }
}
