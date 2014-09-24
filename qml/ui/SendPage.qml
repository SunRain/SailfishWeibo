import QtQuick 2.0
//import Ubuntu.Components 0.1
//import Ubuntu.Components.Popups 0.1
//import Ubuntu.Components.ListItems 0.1 as ListItem
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import Sailfish.Silica 1.0

//import QtDocGallery 5.0
//import org.nemomobile.thumbnailer 1.0

import "../components"
import com.sunrain.sinaweibo 1.0

Page {
    id: sendPage
    //    title: qsTr("Send Weibo")
    //flickable: null
    
    property string mode: ""
//    property var repostType: [qsTr("No comments"), qsTr("Comment current Weibo"), qsTr("Comment original Weibo"), qsTr("Both")]
//    property var commentType: [qsTr("Do not comment original Weibo"), qsTr("Also comment original Weibo")]
    
    property string sendTitle
    property var info         // include id, cid, etc..
    //property string imgPath: ""
    property var imgPath: ""
    property int optionIndex: 0

    //////////////////////////////////////////////////////////////////         send weibo
    function sendStatus(token, status)
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
                        if (result.id != undefined) {
                            addNotification(qsTr("New Weibo sent"), 3)
                            pageStack.pop()
                        }
                    }
                }else{
                    // TODO  empty result
                    addNotification(qsTr("Oops.. something wrong"), 3)
                }
            }
        }
        
        WB.weiboSendStatus(token, status, new observer())
    }
    
    NetworkHelper {
        id: networkHelper
    }
    
    // Connections for upload image
    Connections {
        id: connNetworkHelper
        target: networkHelper
        
        onUploadFinished: {
            var reply = JSON.parse(response)
            if (reply.error) {
                addNotification(qsTr("Oops.. something wrong"), 3)
            }
            else {
                if (reply.id != undefined) {
                    addNotification(qsTr("New Weibo sent"), 3)
                    pageStack.pop()
                }
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////         send repost
    // is_comment 是否在转发的同时发表评论，0：否、1：评论给当前微博、2：评论给原微博、3：都评论，默认为0 。
    function repostStatus(token, status, id, is_comment)
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
                        if (result.id != undefined) {
                            addNotification(qsTr("Repost sent"), 3)
                            pageStack.pop()
                        }
                    }
                }else{
                    // TODO  empty result
                    addNotification(qsTr("Oops.. something wrong"), 3)
                }
            }
        }
        
        WB.weiboRepostStatus(token, status, id, is_comment, new observer())
    }
    
    //////////////////////////////////////////////////////////////////         send comment
    // id 需要评论的微博ID。  // comment_ori 当评论转发微博时，是否评论给原微博，0：否、1：是，默认为0。
    function sendComment(token, comment, id, comment_ori)
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
                        if (result.id != undefined) {
                            addNotification(qsTr("Comment sent"), 3)
                            pageStack.pop()
                        }
                    }
                }else{
                    // TODO  empty result
                    addNotification(qsTr("Oops.. something wrong"), 3)
                }
            }
        }
        
        WB.weiboSendComment(token, comment, id, comment_ori , new observer())
    }
    
    //////////////////////////////////////////////////////////////////         reply comment
    // id, comment_ori same above // commentid 需要回复的评论ID。  without_mention 回复中是否自动加入“回复@用户名”，0：是、1：否，默认为0。
    function replyComment(token, comment, id, comment_ori, commentid, without_mention)
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
                        if (result.id != undefined) {
                            addNotification(qsTr("Reply sent"), 3)
                            pageStack.pop()
                        }
                    }
                }else{
                    // TODO  empty result
                    addNotification(qsTr("Oops.. something wrong"), 3)
                }
            }
        }
        
        WB.weiboReplyComment(token, comment, id, comment_ori, commentid, without_mention , new observer())
    }
    
    //////////////////////////////////////////////////////////////////         set img path
    function setImgPath(filePath) {
        console.log("filePath: ", filePath)
        imgPath = filePath
        //        mainStack.pop()
    }
    
    function sendWeibo() {
        switch (sendPage.mode) {
        case "repost" :
            repostStatus(Settings.getAccess_token(), content.text, info.id, optionIndex)
            break
        case "comment" :
            sendComment(Settings.getAccess_token(), content.text, info.id, optionIndex)
            break
        case "reply" :
            replyComment(Settings.getAccess_token(), content.text, info.id, optionIndex, info.cid, 0)
            break
        default:
            if (imgPath == "" || imgPath == undefined) {
                sendStatus(Settings.getAccess_token(), content.text)
            }
            else {
                addNotification(qsTr("Uploading, please wait.."), 2)
                var status = encodeURIComponent(content.text)
                networkHelper.uploadImgStatus(Settings.getAccess_token(), status, imgPath)
            }
            break
        }
    }

    Component {
        id:atUserSheet
        AtUserComponent {
            id:atUserComponent
            anchors.fill: parent           
            onUserClicked: {
                console.log("SendPage === We love " + userName);
                drawer.open = !drawer.open;
                parent.focus = true;
                
                content.text += " @" + userName + " "
            }
            onCloseIconClicked: {
                drawer.hide();
                parent.focus = true;
            }
        }
    }
    
    Component {
        id:insertImageSheet
        ImagePreviewComponent {
            id: imagePreviewComponent
            anchors.fill: parent

            onImageClicked: {
                //console.log("SendPage == imagePreviewComponent clicked " +  model.url);
                //TODO 暂时只支持上传一张图片
                modelImages.clear();
                modelImages.append(
                            {"path":/*model.get(index).url*/model.url.toString()}
                            );
                setImgPath(model.url.toString());
            }
        }
    }

    Component {
        id:commentOption
        ComboBox {
            id: commentOptionComboBox
            width: parent.width
            label: qsTr("comment option")
            currentIndex: 0
            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Do not comment original Weibo")
                    onClicked: { optionIndex = 0; }
                }
                MenuItem {
                    text: qsTr("Also comment original Weibo")
                    onClicked: { optionIndex = 1;}
                }
            }
        }
    }

    Component {
        id: repostOption
        ComboBox {
            id: repostTypeComboBox
            width: parent.parent
            label: qsTr("repost option")
            currentIndex: 0
            menu: ContextMenu {
                MenuItem {
                    text: qsTr("No comments")
                    onClicked: { optionIndex = 0; }
                }
                MenuItem {
                    text: qsTr("Comment current Weibo")
                    onClicked: { optionIndex = 1; }
                }
                MenuItem {
                    text: qsTr("Comment original Weibo")
                    onClicked:  { optionIndex = 2; }
                }
                MenuItem {
                    text: qsTr("Both")
                    onClicked:  { optionIndex = 3; }
                }
            }
        }
    }
    
    /////////////////////////////// 主页面
    Drawer {
        id: drawer
        anchors.fill: parent
        dock: Dock.Bottom
        
        background: Loader {
            id:drawerBackgroundLoader
            anchors.fill: parent
            //sourceComponent: atUserSheet
        }
        
        SilicaFlickable {
            anchors {
                fill: parent
                //leftMargin: page.isPortrait ? 0 : controlPanel.visibleSize
                //topMargin: page.isPortrait ? controlPanel.visibleSize : 0
                //rightMargin: page.isPortrait ? 0 : progressPanel.visibleSize
                //bottomMargin: page.isPortrait ? progressPanel.visibleSize : 0
            }
            
//            //打开Draw的时候点击任意界面关闭
            MouseArea {
                enabled: drawer.open
                anchors.fill: column
                onClicked: drawer.open = false
            }
            
            PullDownMenu {
                MenuItem {
                    text: qsTr("Send")
                    onClicked: {
                        console.log("SendPage == SendIcon click, we send [" + content.text +"]  for mode " 
                                    + sendPage.mode + " with option " + optionIndex);
                        sendWeibo();
                        //TODO 是否添加图片在微博中
                        //noPic added in content
                        //sendStatus(Settings.getAccess_token(), content.text)
                        //pic addedin content
                        //mainView.addNotification(i18n.tr("Uploading, please wait.."), 2)
                        //var status = encodeURIComponent(textSendContent.text)
                        // networkHelper.uploadImgStatus(Settings.getAccess_token(), status, imgPath)
//                        switch (sendPage.mode) {
//                        case "repost" :
//                            repostStatus(Settings.getAccess_token(), content.text, info.id, optionIndex)
//                            break
//                        case "comment" :
//                            sendComment(Settings.getAccess_token(), content.text, info.id, optionIndex)
//                            break
//                        case "reply" :
//                            replyComment(Settings.getAccess_token(), content.text, info.id, optionIndex, info.cid, 0)
//                            break
//                        default:
//                            if (imgPath == "" || imgPath == undefined) {
//                                sendStatus(Settings.getAccess_token(), content.text)
//                            }
//                            else {
//                                addNotification(i18n.tr("Uploading, please wait.."), 2)
//                                var status = encodeURIComponent(content.text)
//                                networkHelper.uploadImgStatus(Settings.getAccess_token(), status, imgPath)
//                            }
//                            break
//                        }
                    }
                }
            }

            PushUpMenu {
                MenuItem {
                    text: qsTr("@SomeOne")
                    onClicked: {
                        drawerBackgroundLoader.sourceComponent = drawerBackgroundLoader.Null
                        drawerBackgroundLoader.sourceComponent = atUserSheet;
                        if (!drawer.opened) {
                            drawer.open = true;
                        }
                    }
                }
                MenuItem {
                    text: qsTr("Add Image")
                    onClicked: {
                        drawerBackgroundLoader.sourceComponent = drawerBackgroundLoader.Null
                        drawerBackgroundLoader.sourceComponent = insertImageSheet;
                        if (!drawer.opened) {
                            drawer.open = true;
                        } 
                    }
                }
            }

            contentHeight: column.height + Theme.paddingLarge
            
            VerticalScrollDecorator {}
            
            Column {
                id: column
                spacing: Theme.paddingLarge
                width: parent.width
                enabled: !drawer.opened

                PageHeader { title: sendTitle }
                
                ////////////////////////////////////////文字输入框
                
                TextArea {
                    id:content
                    width: parent.width
                    height: Math.max(parent.width/2, implicitHeight)
                    focus: true
                    horizontalAlignment: TextInput.AlignLeft
                    placeholderText: qsTr("Input Weibo content here");
                    label: "Expanding text area"                   
                }
                
                Label {
                    visible: modelImages.count > 0
                    width: parent.width
                    color: Theme.secondaryColor
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: qsTr("Click the inserted image to remove from the uploading queue")
                }

                Grid {
                    id: gridWeiboPics
                    //columns: 4
                    columns: 1
                    spacing: Theme.paddingSmall
                    width: parent.width
                    height: childrenRect.height
                    
                    Repeater {
                        model: ListModel { id: modelImages }
                        delegate: Component {
                            Image {
                                id:image
                                fillMode: Image.PreserveAspectFit
                                width: modelImages.count == 1 ? implicitWidth : column.width / 4 - Theme.paddingSmall
                                height: modelImages.count == 1 ? implicitHeight : width
                                source: path
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        console.log("SendPage === inserted image clicked" + index);
                                        modelImages.remove(index);
                                        setImgPath("");
                                    }
                                    onDoubleClicked: {
                                        console.log("SendPage === inserted image onDoubleClicked")
                                    }
                                }
                            }
                        }
                    }
                }

                Loader {
                    id: optionLoader
                    width: parent.width
                }
            }

            //添加输入框下部选型列表
            Component.onCompleted: {
                optionLoader.sourceComponent = optionLoader.Null;
                switch (mode) {
                case "repost" :
                    sendTitle = qsTr("Repost")
                    //selectorType.values = repostType
                    optionLoader.sourceComponent = repostOption;
                    break;
                case "comment" :
                    sendTitle = qsTr("Comment")
                    //selectorType.values = commentType
                    optionLoader.sourceComponent = commentOption;
                    break;
                case "reply" :
                    sendTitle = qsTr("Reply")
                    // selectorType.values = commentType
                    optionLoader.sourceComponent = commentOption;
                    break;
                default:
                    //sendPage.mode = ""
                    sendTitle = qsTr("Send Weibo")
                    // selectorType.values = [""]
                    break
                }
            }
        }
    }
}
    
