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

    property alias optionMenu: optionItem.menu

    signal repostedWeiboClicked
    signal usWeiboClicked
    
    Component.onCompleted: {
        //        if (model.retweeted_status) {
        ////            var compo = Qt.createComponent("./DelegateRepostedWeibo.qml")
        //            var retweet = parentView.itemRetweet.createObject(itemRetweetContainer, { /*"parentVi
        //font.family: "Liberation Sans"ew": view, */"retweetWeibo": model.retweeted_status })
        //        }
        if (model.pic_urls != undefined && model.pic_urls.count > 0) {
            modelImages.clear()
            for (var i=0; i<model.pic_urls.count; i++) {
                modelImages.append( model.pic_urls.get(i) )
                //                workerImages.sendMessage( { "model": modelImages, "pic_urls": model.pic_urls.get(i) } )
            }
            //            workerImages.sendMessage( { /*model: modelImages, */"pic_urls": pic_urls.get(0) } )
        }
    }
    
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
        Item {
            width: columnWContent.width
            height: optionItem.menuOpen ? avaterHeader.height + optionItem.height : avaterHeader.height
            UserAvatarHeader {
                id:avaterHeader
                width: parent.width *7/10
                height:Theme.itemSizeSmall
                
                userName: model.user.screen_name
                userNameFontSize: Theme.fontSizeExtraSmall
                userAvatar: model.user.profile_image_url
                weiboTime: DateUtils.formatRelativeTime(DateUtils.parseDate(appData.dateParse(model.created_at)))
                                                    + qsTr(" From ") + GetURL.linkToStr(model.source)
                onUserAvatarClicked: {
                    console.log("======== UserAvatarHeader onUserAvatarClicked");
                    toUserPage(model.user.id)
                }
            }
            OptionItem{
                id:optionItem
                anchors{
                    left: avaterHeader.right
                    right: parent.right
                }
                visible: optionMenu != null
                Image {
                    anchors{
                        top:parent.top
                        bottom: parent.bottom
                        right: parent.right
                    }
                    width: Theme.iconSizeMedium
                    height: width
                    source: optionItem.menuOpen ? 
                                "../graphics/action_collapse.png" : 
                                "../graphics/action_open.png"
                }
                onMenuStateChanged: {
//                    console.log("====== option Item " + menuOpen);
                }
            }
            
//            MouseArea {
//                anchors.fill: parent
//                onClicked: {
//                    console.log("=== DelegateWeibo usAvatar2222 clicked");
//                    toUserPage(model.user.id)
//                }
//            }
        }
        
        Label {
            id: labelWeibo
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            textFormat: Text.StyledText
            text: util.parseWeiboContent(model.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
            font.pixelSize: Theme.fontSizeMedium
            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    //usWeiboContent.clicked()
                    usWeiboContent.usWeiboClicked();
                    //            var tmp = model.pic_urls
                    //            console.log("model.pic_urls: ", JSON.stringify(tmp), gridWeiboPics.height, itemRetweetContainer.height)
                }
            }
        }
        
        Grid {
            id: gridWeiboPics
            columns: 3; spacing: Theme.paddingSmall
            Repeater {
                model: ListModel { id: modelImages }
                delegate: Component {
                    Image {
                        id:image
                        fillMode: Image.PreserveAspectCrop;
                        width: modelImages.count == 1 ? implicitWidth : columnWContent.width / 3 - Theme.paddingSmall
                        height: modelImages.count == 1 ? implicitHeight : width
                        source: util.parseImageUrl(model.thumbnail_pic)//model.thumbnail_pic
                        
                        //onStatusChanged: playing = (status == AnimatedImage.Ready)
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                toGalleryPage(modelImages, index)
                            }
                        }
                        onStatusChanged: {
                            if(image.status == Image.Ready) {
                                util.saveRemoteImage(model.thumbnail_pic);
                            }
                        }
                    }
                }
            }
        }
        
        Item {
            id: itemRetweetContainer
            width: parent.width
            height: delegateRepostedWeibo.height

            DelegateRepostedWeibo{
                id:delegateRepostedWeibo
                visible: {
//                    console.log("========================DelegateWeibo  model.retweeted_statu " + model.retweeted_status)
                    model.retweeted_status != undefined || model.retweeted_status != ""
                }
                retweetWeibo: model.retweeted_status
                
                onRetweetClicked: {
                    //usWeiboContent.clicked()
                    usWeiboContent.repostedWeiboClicked();
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
