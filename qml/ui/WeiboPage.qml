import QtQuick 2.0
import Sailfish.Silica 1.0
//import QtQuick.XmlListModel 2.0
//import Ubuntu.Components 0.1
//import Ubuntu.Components.ListItems 0.1 as ListItem
//import Ubuntu.Components.Popups 0.1
import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../components"

Page {
    //objectName: "weibofeedpage"
    id: weiboPage
    //title: qsTr("Weibo Content")
    //flickable: null

//    signal articleStatusChanged(int tagId, int articleId, string status)
//    signal articleFavouriteChanged(var article, string favourite)
    //signal commentsWanted(var weiboId, int modelIndex)

    //property string weiboModelUrl: ""
    property string weiboTitle: ""
    property var weiboModel
    property var newIndex
    property var weiboItem: null
    property bool preventIndexChangeHandler: false

    property var commentInfo

    DockedPanel {
        id: actionPanel
        
        width:parent.width// weiboPage.isPortrait ? parent.width : Theme.itemSizeExtraSmall /*  + Theme.paddingLarge*/
        height:Theme.itemSizeExtraSmall+Theme.paddingMedium*2// weiboPage.isPortrait ? Theme.itemSizeExtraSmall /*  + Theme.paddingLarge*/ : parent.height
        
        dock: Dock.Top// weiboPage.isPortrait ? Dock.Top : Dock.Left
        
        Flow {
            anchors.centerIn: parent
            spacing: Theme.paddingSmall 
            //TODO:添加具体的点击功能
            Button {
                text: qsTr("Reply")
                width: Theme.itemSizeSmall
                height: Theme.itemSizeSmall
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../ui/SendPage.qml"),
                                    {"mode":"reply",
                                       "info":weiboPage.commentInfo})
                }
            }
            Button {
                text: qsTr("Copy")
                width: Theme.itemSizeSmall
                height: Theme.itemSizeSmall
                //onClicked: PopupUtils.close(dialogue)
            }
            Button{
                text: qsTr("Cancel")
                width: Theme.itemSizeSmall
                height: Theme.itemSizeSmall
                //onClicked: PopupUtils.close(dialogue)
            }
        }
    }
    //////////////////////////////////////////////      a listview to show the weibo content
    SilicaFlickable {
        id:mainFlickableView
        anchors {
            fill: parent
            //leftMargin: page.isPortrait ? 0 : actionPanel.visibleSize
            topMargin: actionPanel.visibleSize ? actionPanel.height : 0//page.isPortrait ? actionPanel.visibleSize : 0
            //rightMargin: page.isPortrait ? 0 : actionPanel.visibleSize
            //bottomMargin: page.isPortrait ? actionPanel.visibleSize : 0
        }
        Behavior on topMargin {
            FadeAnimation {}
        }
        contentHeight: column.height
        
        Column {
            id:column
            spacing: Theme.paddingSmall 
            anchors.fill: parent

            SilicaListView {
                id: weiboListview
                width: mainFlickableView.width 
                height: mainFlickableView.height// - pageHeader.height - Theme.paddingSmall

                header: PageHeader {
                    id:pageHeader
                    title: qsTr("Sailfish Weibo")
                }
                
                model: weiboListviewModel//weiboModel
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
                    
                    currentItem.getComments(Settings.getAccess_token(), weiboItem.id, 1)
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
        }
    }
    
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
            function getComments(token, id, page)
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
                                console.log("comments length: ", result.comments.length)
//                              console.log("comments : ", JSON.stringify(result))
                                modelComment.clear()
                                for (var i=0; i<result.comments.length; i++) {
                                    modelComment.append(result.comments[i])
                                }
                            }
                        }else{
                            // TODO  empty result
                        }
                    }
                }

                WB.weiboGetComments(token, id, page, new observer())
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
                        //TODO 添加方法
                        console.log("WeiboPage ==== onRepostedWeiboClicked item clicked");
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
                        spacing:Theme.paddingSmall// units.gu(1)
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
                                        //TODO:添加微博的时间
                                        text: "weibo Time" /*{
                                            return DateUtils.formatRelativeTime(i18n, DateUtils.parseDate(appData.dateParse(model.created_at)))
                                        }*/
                                        font.pixelSize: Theme.fontSizeTiny
                                    }
                                }
                            }

                            /////////评论/转发内容
                            Label {
                                id: labelWeibo
                                width: parent.width
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                                text: model.text
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
