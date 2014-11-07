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

    property var userWeiboJSONContent
    
    SilicaFlickable {
        id: main
        anchors.fill: parent

        boundsBehavior: (contentHeight > height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
        contentHeight: column.height
        
        property int commentsPage:1
        property string commentsId

        Column {
            id:column
            
            anchors{left:parent.left; right:parent.right }
            spacing: Theme.paddingMedium
            
            PageHeader {
                id:pageHeader
                title: qsTr("Sailfish Weibo")
            }
                
            Item {
                anchors{left:parent.left; right:parent.right; }
                height: childrenRect.height
                WeiboCard {
                    id:weiboCard
                    weiboJSONContent: userWeiboJSONContent
                    optionMenu: options
                    onRepostedWeiboClicked: {
                        //toWeiboPage(userWeiboJSONContent.retweeted_status);
                        pageStack.replace(Qt.resolvedUrl("WeiboPage.qml"),
                                          {"userWeiboJSONContent":userWeiboJSONContent.retweeted_status})
                    }
                    onAvatarHeaderClicked: {
                        toUserPage(userId);
                    }
                    onLabelLinkClicked: {
                        Qt.openUrlExternally(link);
                    }
                    onLabelImageClicked: {
                        toGalleryPage(modelImages, index);
                    }
                    ContextMenu {
                        id:options
                        MenuItem {
                            text: qsTr("Repost")
                            onClicked: {
                                toSendPage("repost", {"id": userWeiboJSONContent.id}, 
                                           (userWeiboJSONContent.retweeted_status == undefined || userWeiboJSONContent.retweeted_status == "") == true ?
                                               "" :
                                               "//@"+userWeiboJSONContent.user.name +": " + userWeiboJSONContent.text ,
                                               true)
                            }
                        }
                        MenuItem {
                            text: qsTr("Comment")
                            onClicked: {
                                toSendPage("comment", {"id": userWeiboJSONContent.id}, "", true)                        
                            }
                        }
                    }
                }
            }
            
            Separator {
                width: parent.width
                color: Theme.highlightColor
            }            
            //////////////微博下面评论/转发的内容（listView展示）
            Item {
                width: parent.width
                height: childrenRect.height
                
                SilicaListView {
                    id:commentListView
                    width: parent.width
                    height: contentItem.childrenRect.height
                    interactive: false
                    clip: true
                    spacing:Theme.paddingSmall
                    model: ListModel { 
                        id: modelComment 
                    }
                    delegate: delegateComment
                    footer: FooterLoadMore {
                        visible: modelComment.count != 0
                        onClicked: {
                            main.addMore();
                        }
                    }
                    VerticalScrollDecorator { flickable: commentListView }
                }
            }
        }
        Component.onCompleted: {
            getComments(userWeiboJSONContent.id)
        }

        function getComments(id) {
            commentsId = String(id);
            modelComment.clear();
            var method = WeiboMethod.WBOPT_GET_COMMENTS_SHOW;
            api.setWeiboAction(method, {'id':" "+id+" ", 'page':commentsPage});
        }
        function addMore() {
            commentsPage++;
            var method = WeiboMethod.WBOPT_GET_COMMENTS_SHOW;
            api.setWeiboAction(method, {'id':" "+commentsId+" ", 'page':commentsPage});
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
        
    }
    
    Component {
        id: delegateComment
        
        OptionItem {
            width: parent.width
            contentHeight: columnWContent.height // + Theme.paddingMedium 
            menu: contextMenu
            Column {
                id: columnWContent
                anchors {
                    top: parent.top
//                    topMargin: Theme.paddingSmall
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingSmall
                    rightMargin: Theme.paddingSmall
                }
                spacing: Theme.paddingMedium
                
                ////////用户头像/姓名/评论发送时间
                UserAvatarHeader {
                    id:commnetAvaterHeader
                    width: parent.width
                    height:Theme.itemSizeExtraSmall 
                    
                    userName: model.user.screen_name
                    userNameFontSize: Theme.fontSizeTiny
                    userAvatar: model.user.profile_image_url
                    weiboTime:  DateUtils.formatRelativeTime(DateUtils.parseDate(appData.dateParse(model.created_at)))
                                + qsTr(" From ") + GetURL.linkToStr(model.source)
                    onUserAvatarClicked: {
                        toUserPage(model.user.id)
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
                            var commentInfo = { "id": userWeiboJSONContent.id, "cid": model.id}
                            pageStack.push(Qt.resolvedUrl("../ui/SendPage.qml"),
                                           {"mode":"reply",
                                               "userInfo":commentInfo})
                        }
                    }
                }
            }
        }
    
    }
}
