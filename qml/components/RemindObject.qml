import QtQuick 2.0

QtObject {
    id: remindObject
    objectName: "RemindObject"

    function deleteSelf() {
        console.log("[RemindObject] : Destroying...");
//        remindObject.deleteLater();
        remindObject.destroy();
    }

    signal remindInfoChanged

    //status 	int 	新微博未读数
    property int status: 0
    // mention_status 	int 	新提及我的微博数
    property int mention_status: 0
    //mention_cmt 	int 	新提及我的评论数
    property int mention_cmt: 0
    //cmt 	int 	新评论数
    property int cmt: 0
    //dm 	int 	新私信数
    property int dm: 0

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
    property var remind: ({
        "status": 0,
        "follower": 0,
        "cmt": 0,
        "dm": 0,
        "chat_group_pc": 0,
        "chat_group_client": 0,
        "mention_status": 0,
        "mention_cmt": 0,
        "group": 0,
        "notice": 0,
        "invite": 0,
        "badge": 0,
        "photo": 0,
        "all_mention_status": 0,
        "attention_mention_status": 0,
        "all_mention_cmt": 0,
        "attention_mention_cmt": 0,
        "all_cmt": 0,
        "attention_cmt": 0,
        "all_follower": 0,
        "attention_follower": 0,
        "page_friends_to_me": 0,
        "chat_group_notice": 0
    })
    onRemindChanged: {
        if (remind) {
            remindObject.mention_cmt = remind.mention_cmt
            remindObject.mention_status = remind.mention_status
            remindObject.cmt = remind.cmt
            remindObject.dm = remind.dm
            remindObject.status = remind.status
            remindObject.remindInfoChanged();
        }
    }
}
