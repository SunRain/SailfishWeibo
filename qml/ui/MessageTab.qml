import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../components"

import com.sunrain.sinaweibo 1.0

Page {
    id: messageTab

    property alias contentItem: innerAreaColumn
    property bool withPanelView: true

    //property var remind: {"status":0,"follower":0,"cmt":0,"dm":0,"mention_status":0,"mention_cmt":0,"group":0,"notice":0,"invite":0,"badge":0,"photo":0}
    RemindObject {
        id: remindObject
    }

    function refresh() {
        showBusyIndicator();
        messageGetRemind()
    }
    
    Component.onCompleted: {
        refresh();
    }
    
    function messageGetRemind()
    {
        //WBOPT_GET_REMIND_UNREAD_COUNT
//        REQUEST_API_BEGIN(remind_unread_count, "2/remind/unread_count")
//                ("source", "")  //采用OAuth授权方式不需要此参数，其他授权方式为必填参数，数值为应用的AppKey。
//                ("access_token", "")  //采用OAuth授权方式为必填参数，其他授权方式不需要此参数，OAuth授权后获得。
//                ("uid", 0)  //需要获取消息未读数的用户UID，必须是当前登录用户。
//                ("callback", "")  //JSONP回调函数，用于前端调用返回JS格式的信息。
//                ("unread_message", 0)  //未读数版本。0：原版未读数，1：新版未读数。默认为0。
//        REQUEST_API_END()
        var method = WeiboMethod.WBOPT_GET_REMIND_UNREAD_COUNT;
        api.setWeiboAction(method, "");
    }
    
    Connections {
        target: api
        //void weiboPutSucceed(QWeiboMethod::WeiboAction action, const QString& replyData);
        onWeiboPutSucceed: {
            if (action == WeiboMethod.WBOPT_GET_REMIND_UNREAD_COUNT) {
                var result = JSON.parse(replyData);
                
                //                        status	int	新微博未读数
                //                        follower	int	新粉丝数
                //                        cmt	int	新评论数
                //                        dm	int	新私信数
                //                        mention_status	int	新提及我的微博数
                //                        mention_cmt	int	新提及我的评论数
                
                //remind = result
                remindObject.remind = result
                var mCount = result.follower + result.cmt + result.mention_status + result.mention_cmt
                if (mCount > 1) {
                    addNotification(qsTr("You have ") + mCount + qsTr(" new messages"), 3)
                }
                else if (mCount > 0) {
                    addNotification(qsTr("You have ") + mCount + qsTr(" new message"), 3)
                }
                else {
                    addNotification(qsTr("You have no new message"), 3)
                }
                
                listModel.append({"title":"New comment", "text":remindObject.remind.cmt, "page":"CommentAllPage.qml", "toFunction":"0"});
                listModel.append({"title":"New mentioned comment", "text":remindObject.remind.mention_cmt, "page":"CommentMentioned.qml","toFunction":"0"});
                listModel.append({"title":"New mentioned weibo", "text":remindObject.remind.mention_status, "page":"WeiboMentioned.qml", "toFunction":"0"});
                listModel.append({"title":"New follower", "text":remindObject.remind.follower, "page":"follower", "toFunction":"1"});
                
                if (innerAreaColumn.model == undefined) {
                    innerAreaColumn.model = listModel;
                }
                
                stopBusyIndicator();
            }
        }
    }
    
    ListModel {
        id:listModel
    }
    
    SilicaListView{
        id: innerAreaColumn
        anchors.fill: parent
        
        header:PageHeader {
            id:pageHeader
            title: qsTr("Message")
        }
        
//        model: listModel
        
        delegate: Item {
            width: parent.width
            height: Theme.iconSizeMedium
            
            Label {
                id: title
                anchors{
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    right: right.left
                    verticalCenter: parent.verticalCenter
                }
                text: qsTr(model.title)
                font.pixelSize: Theme.fontSizeMedium
            }
            Item {
                id:right
                anchors{
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalRight
                }
                Loader {
                    id:rightLoader
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalRight
                }
                Component.onCompleted: {
                    if (model.text == "0") {
                        rightLoader.sourceComponent = imageComponent
                    } else {
                        rightLoader.sourceComponent = numberComponent
                    }
                }
                
                Component {
                    id:imageComponent
                    Image {
                        source: "image://theme/icon-m-right"
                    }
                }
                
                Component {
                    id:numberComponent
                    Label {
                        text:model.text
                        font.pixelSize: Theme.fontSizeMedium
                    }
                }
                
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (model.toFunction === "1") {
                        pageStack.push(Qt.resolvedUrl("FriendsPage.qml"), { mode: "follower", uid: Settings.getUid() })
                    } else {
                        //page
                        pageStack.push(Qt.resolvedUrl(model.page));
                    }
                }
            }
        }
    }
}

