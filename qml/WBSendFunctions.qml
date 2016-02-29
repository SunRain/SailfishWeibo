import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

import "components"

Item {
    id: wbSendFunctions

    property string mode: ""
//    property var repostType: [qsTr("No comments"), qsTr("Comment current Weibo"), qsTr("Comment original Weibo"), qsTr("Both")]
//    property var commentType: [qsTr("Do not comment original Weibo"), qsTr("Also comment original Weibo")]

    property string sendTitle
    property var userInfo         // include id, cid, etc..
    property string placeHoldText:""
    //property string imgPath: ""
    property string imgPath: ""
    property int optionIndex: 0

    property var contentText

    function popAndShowError() {
        wbFunc.addNotification(qsTr("Oops.. something wrong"), 3)
        pageStack.pop();
    }

    //////////////////////////////////////////////////////////////////         send weibo
    function sendStatus(status)  {
        statusesUpdate.setParameters("status", status);
        statusesUpdate.postRequest();
    }

    WrapperStatusesUpdate {
        id: statusesUpdate
        onRequestAbort: {
            console.log("== statusesUpdate onRequestAbort");
            popAndShowError();
        }
        onRequestFailure: { //replyData
            console.log("== statusesUpdate onRequestFailure ["+replyData+"]")
            popAndShowError();
        }
        onRequestSuccess: { //replyData
            var result = JSON.parse(replyData);
            if (result.error) {
                popAndShowError();
                return;
            }
            if (result.id != undefined) {
                wbFunc.addNotification(qsTr("New Weibo sent"), 3)
                pageStack.pop()
            } else {
                wbFunc.addNotification(qsTr("Oops.. something wrong"), 3)
            }
        }
    }
    WrapperImageUploader {
        id: imageUploader
        onRequestAbort: {
            console.log("== imageUploader onRequestAbort");
            wbFunc.addNotification(qsTr("Oops.. something wrong"), 3)
        }
        onRequestFailure: { //replyData
            console.log("== imageUploader onRequestFailure ["+replyData+"]")
            wbFunc.addNotification(qsTr("Oops.. something wrong"), 3)
        }
        onRequestSuccess: { //replyData
            console.log("===== imageUploader onRequestSuccess [" + replyData +"]")
            var reply = JSON.parse(replyData)
            if (tokenProvider.useHackLogin) {
                if (reply.ok) {
                    if (imgPath == "" )
                        imgPath = reply.pic_id;
                    else
                        imgPath = imgPath +"," + reply.pic_id;
                }
            } else {
                if (reply.error) {
                    wbFunc.addNotification(qsTr("Oops.. something wrong"), 3)
                } else {
                    if (reply.id != undefined) {
                        wbFunc.addNotification(qsTr("New Weibo sent"), 3)
                        pageStack.pop()
                    }
                }
            }
        }
    }

    WrapperStatusesRepost {
        id: statusesRepost
        onRequestAbort: {
            console.log("== statusesRepost onRequestAbort");
            popAndShowError();
        }
        onRequestFailure: { //replyData
            console.log("== statusesRepost onRequestFailure ["+replyData+"]")
            popAndShowError();
        }
        onRequestSuccess: { //replyData
            var result = JSON.parse(replyData);
            if (result.error) {
                popAndShowError();
                return;
            }
            if (result.id != undefined) {
                wbFunc.addNotification(qsTr("Repost sent"), 3)
                pageStack.pop()
            }else {
                wbFunc.addNotification(qsTr("Oops.. something wrong"), 3)
            }
        }
    }

    WrapperCommentsCreate {
        id: commentsCreate
        onRequestAbort: {
            console.log("== commentsCreate onRequestAbort");
            popAndShowError();
        }
        onRequestFailure: { //replyData
            console.log("== commentsCreate onRequestFailure ["+replyData+"]")
            popAndShowError();
        }
        onRequestSuccess: { //replyData
            var result = JSON.parse(replyData);
            if (result.error) {
                popAndShowError();
                return;
            }
            if (result.id != undefined) {
                wbFunc.addNotification(qsTr("Comment sent"), 3)
                pageStack.pop()
            }else {
                wbFunc.addNotification(qsTr("Oops.. something wrong"), 3)
            }
        }
    }

    WrapperCommentsReply {
        id: commentsReply
        onRequestAbort: {
            console.log("== commentsReply onRequestAbort");
            popAndShowError();
        }
        onRequestFailure: { //replyData
            console.log("== commentsReply onRequestFailure ["+replyData+"]")
            popAndShowError();
        }
        onRequestSuccess: { //replyData
            var result = JSON.parse(replyData);
            if (result.error) {
                popAndShowError();
                return;
            }
            if (result.id != undefined) {
                wbFunc.addNotification(qsTr("Reply sent"), 3)
                pageStack.pop()
            } else {
                wbFunc.addNotification(qsTr("Oops.. something wrong"), 3)
            }
        }
    }
    //////////////////////////////////////////////////////////////////         send repost
    // is_comment 是否在转发的同时发表评论，0：否、1：评论给当前微博、2：评论给原微博、3：都评论，默认为0 。
    function repostStatus(status, id, is_comment) {
        statusesRepost.setParameters("status", status);
        statusesRepost.setParameters("id", " "+id+" ");
        statusesRepost.setParameters("is_comment", is_comment);
        //TODO 同时评论的用户id（即发送被转发的微博的用户id） for hacklogin
        statusesRepost.setParameters("rtcomment", "");
        statusesRepost.postRequest();
    }

    //////////////////////////////////////////////////////////////////         send comment
    // id 需要评论的微博ID。  // comment_ori 当评论转发微博时，是否评论给原微博，0：否、1：是，默认为0。
    function sendComment(comment, id, comment_ori)  {
        commentsCreate.setParameters("comment", comment);
        commentsCreate.setParameters("id", " "+id+" ");
        commentsCreate.setParameters("comment_ori", comment_ori);
        commentsCreate.postRequest();
    }

    //////////////////////////////////////////////////////////////////         reply comment
    // id, comment_ori same above // commentid 需要回复的评论ID。  without_mention 回复中是否自动加入“回复@用户名”，0：是、1：否，默认为0。
    function replyComment(comment, id, comment_ori, commentid, without_mention) {
        commentsReply.setParameters("id", comment);
        commentsReply.setParameters("comment", " "+id+" ");
        commentsReply.setParameters("comment_ori", comment_ori);
        commentsReply.setParameters("cid", " "+commentid+" ");
        commentsReply.setParameters("without_mention", without_mention);
        commentsReply.postRequest();
    }

    //////////////////////////////////////////////////////////////////         set img path
    function setImgPath(filePath) {
        console.log("filePath: ", filePath)
        if (!tokenProvider.useHackLogin) {
            imgPath = filePath
        } else {
            imageUploader.uploadImage(filePath);
        }
    }

    function sendWeibo() {
        switch (wbSendFunctions.mode) {
        case "repost" :
            repostStatus(contentText, userInfo.id, optionIndex)
            break
        case "comment" :
            sendComment(contentText, userInfo.id, optionIndex)
            break
        case "reply" :
            replyComment(contentText, userInfo.id, optionIndex, userInfo.cid, 0)
            break
        default:
            if (tokenProvider.useHackLogin) {
                var status = encodeURIComponent(contentText)
                statusesUpdate.setParameters("status", status);
                if (imgPath != "" && imgPath != undefined) {
                    statusesUpdate.setParameters("picId", imgPath);
                }
                statusesUpdate.postRequest();
            } else {
                if (imgPath == "" || imgPath == undefined) {
                    sendStatus(contentText)
                } else {
                    wbFunc.addNotification(qsTr("Uploading, please wait.."), 2)
                    status = encodeURIComponent(contentText)
                    imageUploader.sendWeiboWithImage(status, imgPath);
                }
            }
            break
        }
    }

}

