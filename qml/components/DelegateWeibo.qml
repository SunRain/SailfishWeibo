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
        left: parent.left; right: parent.right
        //                    leftMargin: units.gu(1); rightMargin: units.gu(1)
    }
    height: columnWContent.height + Theme.paddingMedium 
    //color: Qt.rgba(255, 255, 255, 0.3)
    //radius: "medium"
    //color: Qt.rgba(255, 255, 255, 0.3)
    
    //signal cicked
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
    
    //    WorkerScript {
    //        id: workerImages
    //        source: "../js/addImages.js"
    
    ////        onMessage: console.log("addImages.js done: ", messageObject.reply)
    //    }
    Image {
        id: background
        anchors {
            top: parent.top
            //topMargin: Theme.paddingSmall //units.gu(1)
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            //leftMargin: Theme.paddingLarge
            //rightMargin: Theme.paddingLarge
        }
        source: "../graphics/mask_background_grid.png"
        fillMode: Image.PreserveAspectCrop
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
    
    Column {
        id: columnWContent
        anchors {
            top: parent.top
            topMargin: Theme.paddingSmall //units.gu(1)
            left: parent.left
            right: parent.right
            leftMargin: Theme.paddingLarge 
            rightMargin: Theme.paddingLarge 
        }
        spacing: Theme.paddingMedium//Theme.paddingSmall //units.gu(1)
        Row {
            id: rowUser
//            anchors {
//                left: parent.left
//                right: parent.right
//            }
            spacing: Theme.paddingMedium
            //height: rowUserColumn.height > 64 ? rowUserColumn.height : usAvatar.height//usAvatar.height
            
            Item {
                id: usAvatar
                width: 64//units.gu(6)
                height: width
                //color: "#c5ca2c"
                Image {
                    width: parent.width
                    height: parent.height
                    smooth: true
                    fillMode: Image.PreserveAspectFit
                    source: model.user.profile_image_url
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        //console.log("===  usAvatar clicked");
                        toUserPage(model.user.id)
                    }
                }
            }
            
            Column {
                id:rowUserColumn
                spacing: Theme.paddingSmall
                
                Label {
                    id: labelUserName
                    color: Theme.primaryColor
                    text: model.user.screen_name
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
                
                Label {
                    id: labelWeiboTime
                    color: Theme.secondaryColor
                    text: {
                        //                        console.log("appData.dateParse(model.created_at): ", appData.dateParse(model.created_at))
                        //                        var ddd = new Date(appData.dateParse(model.created_at) + "")
                        //                        console.log("ddd: ", ddd.getTime())
                        return DateUtils.formatRelativeTime(/*i18n,*/ DateUtils.parseDate(appData.dateParse(model.created_at)))
                        + qsTr(" From ") + GetURL.linkToStr(model.source)
                    }
                    font.pixelSize: Theme.fontSizeTiny 
                }
            }
        }
        
        Label {
            id: labelWeibo
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: Theme.primaryColor 
            text: GetURL.replaceReg(model.text, Theme.highlightColor)
            font.pixelSize: Theme.fontSizeMedium
            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }
        
        Grid {
            id: gridWeiboPics
            columns: 3; spacing: Theme.paddingSmall//units.gu(0.5); /*visible: model.pic_urls == undefined ? false : model.pic_urls.count != 0*/
            //width: parent.width; height: childrenRect.height
            
            Repeater {
                model: ListModel { id: modelImages }
                delegate: Component {
                    Image {
                        fillMode: Image.PreserveAspectCrop;
                        width: modelImages.count == 1 ? implicitWidth : columnWContent.width / 3 - Theme.paddingSmall
                        height: modelImages.count == 1 ? implicitHeight : width
                        source: model.thumbnail_pic
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                toGalleryPage(modelImages, index)
                            }
                        }
                    }
                }
            }
        }
        
        Item {
            id: itemRetweetContainer
//            anchors {
//                left: parent.left; right: parent.right
//                //leftMargin: Theme.paddingSmall//units.gu(1);
//                //rightMargin: Theme.paddingSmall//units.gu(1)
//            }
            width: parent.width
            height: delegateRepostedWeibo.height//childrenRect.height

            DelegateRepostedWeibo{
                id:delegateRepostedWeibo
                visible: model.retweeted_status != undefined || model.retweeted_status != ""
                retweetWeibo: model.retweeted_status
                
                onRetweetClicked: {
                    //usWeiboContent.clicked()
                    usWeiboContent.repostedWeiboClicked();
                }
            }
        }
        
        Column {
            width: parent.width//; height: childrenRect.height
            spacing: Theme.paddingSmall

            Row {
                //width: childrenRect.width; height: childrenRect.height
                anchors.horizontalCenter: parent.horizontalCenter
                
                Item {
                    width: columnWContent.width / 3 -Theme.paddingSmall 
                    height: Theme.fontSizeSmall
                    
                    Label {
                        anchors.centerIn: parent
                        color: Theme.secondaryColor//"black"
                        font.pixelSize: Theme.fontSizeTiny
                        text: qsTr("repost: ") + model.reposts_count
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            //console.log("repost id" + model.id);
                            toSendPage("repost", {"id": model.id})
                        }
                    }
                }
                Rectangle {
                    //y:0.2// units.gu(0.2);
                    width: 1//units.gu(0.1);
                    height: Theme.fontSizeSmall -2
                    color: Theme.highlightColor//"grey"
                }
                Item {
                    width: columnWContent.width / 3 - 0.5//units.gu(0.5);  
                    height: Theme.fontSizeSmall
                    
                    Label {
                        anchors.centerIn: parent
                        color: Theme.secondaryColor//"black"
                        font.pixelSize: Theme.fontSizeTiny
                        text: qsTr("comment: ") + model.comments_count
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            toSendPage("comment", {"id": model.id})
                        }
                    }
                }
                Rectangle {
                    //y: 0.2//units.gu(0.2); 
                    width: 1//units.gu(0.1); 
                    height: Theme.fontSizeSmall -2
                    color: Theme.highlightColor//"grey"
                }
                Item {
                    width: columnWContent.width / 3 - 0.5//units.gu(0.5);  
                    height: Theme.fontSizeSmall
                    
                    Label {
                        anchors.centerIn: parent
                        color: Theme.secondaryColor//"black"
                        font.pixelSize: Theme.fontSizeTiny
                        text: qsTr("like: ") + model.attitudes_count
                    }
//                    MouseArea {
//                        anchors.fill: parent
//                        onClicked: {
//                            mainView.toSendPage("comment", {"id": model.id})
//                        }
//                    }
                }
            }
        }
        
        Separator {
            width: parent.width
            color: Theme.highlightColor
        }
    }
}
