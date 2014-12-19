import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings
import "../components"

import com.sunrain.sinaweibo 1.0

QtObject {
    id: remindObject
    objectName: "RemindObject"



//    status 	int 	新微博未读数
//    follower 	int 	新粉丝数
//    cmt 	int 	新评论数
//    dm 	int 	新私信数
//    mention_status 	int 	新提及我的微博数
//    mention_cmt 	int 	新提及我的评论数
//    group 	int 	微群消息未读数
//    private_group 	int 	私有微群消息未读数
//    notice 	int 	新通知未读数
//    invite 	int 	新邀请未读数
//    badge 	int 	新勋章数
//    photo 	int 	相册消息未读数
//    msgbox 	int 	{{{3}}}
    property var remind: {
        "status":0,
        "follower":0,
        "cmt":0,
        "dm":0,
        "mention_status":0,
        "mention_cmt":0,
        "group":0,
        "private_group":0,
        "notice":0,
        "invite":0,
        "badge":0,
        "photo":0,
        "msgbox":0
    }
}
