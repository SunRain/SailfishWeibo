import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../js/getURL.js" as GetURL

import "../components"

import com.sunrain.sinaweibo 1.0

Page {
    id: weiboPage
    property string weiboTitle: ""
    property var weiboModel
    property var newIndex
    property var weiboItem: null
    property bool preventIndexChangeHandler: false
    
    property var commentInfo
    
    
    SilicaListView {
        id: weiboListview
        anchors.fill: parent
        
        header: PageHeader {
            id:pageHeader
            title: qsTr("Sailfish Weibo")
        }
        
        model: weiboListviewModel
        delegate: xmlDelegate
        clip: true
        onCurrentIndexChanged: {
            //                    console.log("ListView onCurrentIndexChanged", currentIndex, preventIndexChangeHandler)
            //                    console.log("listView weiboListviewModel count is " + /*weiboModel.count*/weiboListviewModel.count);
            
            if (preventIndexChangeHandler) {
                preventIndexChangeHandler = false
                return
            }
            
            /*if (weiboModel.count == 0)*/ // It is normal bevaviour.
            if (weiboListviewModel.count == 0)
                return
            
            //            if (weiboModel == null || weiboModel.get == undefined) {
            if (weiboListviewModel == null || weiboListviewModel.get == undefined) {
                console.log("---- Stange behavior ----")
                console.trace()
                return
            }
            
            weiboItem = weiboListviewModel.get(currentIndex);//weiboModel.get(currentIndex)
            
            currentItem.getComments(/*Settings.getAccess_token(),*/ weiboItem.id, 1)
            //            console.log("weiboItem: ", JSON.stringify(weiboItem))
            //            commentsWanted(weiboItem.id, currentIndex)
            
            //            weiboTitle = weiboItem.feed_name
            
            //            if (weiboItem.status != "1") {
            //                var dbResult = DB.updateArticleStatus(weiboItem.id, "1")
            //                if (dbResult.rowsAffected == 1) {
            //                    articleStatusChanged(weiboItem.tagId, weiboItem.id, "1")
            //                }
            //            }
        }
        
        Component.onCompleted: {
            //                    console.log("== weiboPageSilicaFlickable onCompleted");
            //                    console.log("== listview heigt is " + weiboListview.height);
            //                    console.log("== weiboPageSilicaFlickable heigt is " + mainFlickableView.height);
            
            weiboListviewModel.clear();
            //TODO MagicNumber
            if (newIndex == "-100") {
                console.log("WeiboPage === use MagicNubmer");
                weiboListviewModel.append(weiboModel)
            } else {
                weiboListviewModel.append(weiboModel.get(newIndex));
            }
            weiboListview.currentIndex = 0//newIndex;
            weiboListview.positionViewAtIndex(weiboListview.currentIndex, ListView.Center);
            
        }
        
        VerticalScrollDecorator { flickable: weiboListview }
    }
    //        }
    //    }
    
    ListModel {
        id:weiboListviewModel
    }
    
    //////////////////////////////////////////////      delegate for ListView
    Component {
        id: xmlDelegate
        
        SilicaFlickable {
            id: scrollArea
            
            //            clip: true
            boundsBehavior: (contentHeight > height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
            
            width: weiboListview.width
            height: weiboListview.height
            
            contentWidth: width
            contentHeight: innerAreaColumn.height
            
            property int weiboIndex: index
            
            //////////////////////////////////////////////////////////////////         get comments
            function getComments(/*token, */id, page)
            {
                //                function observer() {}
                //                observer.prototype = {
                //                    update: function(status, result)
                //                    {
                //                        if(status != "error"){
                //                            if(result.error) {
                //                                // TODO  error handler
                //                            }else {
                //                                // right result
                //                                //                                console.log("comments length: ", result.comments.length)
                //                                //                                console.log("comments : ", JSON.stringify(result))
                //                                modelComment.clear()
                //                                for (var i=0; i<result.comments.length; i++) {
                //                                    modelComment.append(result.comments[i])
                //                                }
                //                            }
                //                        }else{
                //                            // TODO  empty result
                //                        }
                //                    }
                //                }
                
                //WB.weiboGetComments(token, id, page, new observer())
                //var url = "https://api.weibo.com/2/comments/show.json?access_token=" + token + "&id=" + id + "&page=" + page
                modelComment.clear();
                var method = WeiboMethod.WBOPT_GET_COMMENTS_SHOW;
                api.setWeiboAction(method, {'id':" "+id+" ", 'page':page});
            }
            Connections {
                target: api
                onWeiboPutSucceed: {
                    if (action == WeiboMethod.WBOPT_GET_COMMENTS_SHOW) {
                        var json = JSON.parse(replyData);
                        for (var i=0; i<json.comments.length; i++) {
                            modelComment.append(json.comments[i])
                        }
                    }
                }
            }
            
            Column {
                id: innerAreaColumn
                
                spacing: Theme.paddingSmall//units.gu(2)
                anchors {
                    left: parent.left; right: parent.right
                    leftMargin: Theme.paddingSmall//units.gu(1)
                    rightMargin: Theme.paddingSmall//units.gu(1)
                }
                
                DelegateWeibo {
                    //                    onClicked: {
                    //                        //TODO:添加相关功能的具体实现
                    //                        console.log("WeiboPage ==== DelegateWeibo item clicked");
                    ////                        console.log("model.pic_urls: ", JSON.stringify(pic_urls))
                    ////                        var tmp = []
                    ////                        if (model.pic_urls != undefined && model.pic_urls.count > 0) {
                    ////                            for (var i=0; i<model.pic_urls.count; i++) {
                    ////                                tmp.push(model.pic_urls.get(i))
                    ////                            }
                    ////                            mainView.toGalleryPage(tmp, 1)
                    ////                        }
                    //                        //controlPanel.open = !controlPanel.open
                    //                        //actionPanel.open = !actionPanel.open;
                    //                    }
                    onUsWeiboClicked: {
                        console.log("WeiboPage ==== onUsWeiboClicked item clicked");
                    }
                    onRepostedWeiboClicked: {
                        //toWeiboPage(weiboListviewModel.get(0).retweeted_status, "-100");
                        pageStack.replace(Qt.resolvedUrl("WeiboPage.qml"),
                                          {"weiboModel":weiboListviewModel.get(0).retweeted_status,
                                              "newIndex":"-100"})
                    }
                }
                
                //////////////微博下面评论/转发的内容（listView展示）
                Item {
                    width: parent.width
                    height: childrenRect.height
                    
                    SilicaListView {
                        width: parent.width
                        height: contentItem.childrenRect.height
                        interactive: false
                        clip: true
                        spacing:Theme.paddingSmall
                        model: ListModel { 
                            id: modelComment 
                        }
                        delegate: delegateComment
                    }
                }
                
                //////////////微博下面评论/转发的内容（listView的代理）
                Component {
                    id: delegateComment
                    
                    ListItem {
                        width: parent.width
                        contentHeight: columnWContent.height + Theme.paddingMedium 
                        //color: Qt.rgba(255, 255, 255, 0.3)
                        
                        menu: contextMenu
                        Column {
                            id: columnWContent
                            anchors {
                                top: parent.top
                                topMargin: Theme.paddingSmall //units.gu(1)
                                left: parent.left
                                right: parent.right
                                leftMargin: Theme.paddingSmall //units.gu(1)
                                rightMargin: Theme.paddingSmall //units.gu(1)
                            }
                            spacing: Theme.paddingMedium //units.gu(1)
                            
                            ////////用户头像/姓名/评论发送时间
                            Row {
                                id: rowUser
                                anchors { 
                                    left: parent.left
                                    leftMargin: Theme.paddingSmall
                                    right: parent.right
                                    rightMargin: Theme.paddingSmall
                                }
                                spacing:Theme.paddingSmall
                                //height: usAvatar.height
                                height: rowUserColumn.height > 64 ? rowUserColumn.height : usAvatar.height
                                
                                Item {
                                    id: usAvatar
                                    width: 48
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
                                    spacing: Theme.paddingSmall/2
                                    
                                    Label {
                                        id: labelUserName
                                        color: Theme.secondaryColor //"black"
                                        text: model.user.screen_name
                                        font.pixelSize: Theme.fontSizeTiny
                                    }
                                    
                                    Label {
                                        id: labelCommentTime
                                        color: Theme.secondaryColor // "grey"
                                        text:  {
                                            return DateUtils.formatRelativeTime(DateUtils.parseDate(appData.dateParse(model.created_at)))
                                                    + qsTr(" From ") + GetURL.linkToStr(model.source)
                                        }
                                        font.pixelSize: Theme.fontSizeTiny
                                    }
                                }
                            }
                            
                            /////////评论/转发内容
                            Label {
                                id: labelWeibo
                                width: parent.width
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                //color: Theme.primaryColor
                                textFormat: Text.StyledText
                                font.pixelSize: Theme.fontSizeExtraSmall
                                text: util.parseWeiboContent(model.text, Theme.primaryColor, Theme.highlightColor, Theme.secondaryHighlightColor)
                            }
                        }
                        
                        Component {
                            id: contextMenu
                            ContextMenu {
                                MenuItem {
                                    text: qsTr("Reply")
                                    onClicked: {
                                        //console.log("weiboPage ==== delegateComment click, weiboIndex is " + weiboIndex);
                                        weiboPage.commentInfo = { "id": weiboListviewModel.get(weiboIndex).id, "cid": model.id}
                                        pageStack.push(Qt.resolvedUrl("../ui/SendPage.qml"),
                                                       {"mode":"reply",
                                                           "info":weiboPage.commentInfo})
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        } // Flickable
    } // Component
}
