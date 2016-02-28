import QtQuick 2.0

QtObject {
    id: userInfoObject
    objectName: "UserInfoObject"
    function deleteSelf() {
        console.log("[UserInfoObject] : Destroying...");
//        userInfoObject.deleteLater();
        userInfoObject.destroy();
    }

    signal infoChanged
    //scheme for show a specific user's weibo, used for HackStatusesUserTimeline
//    property string userWeiboDisplayScheme: ""
    property string userWeiboListScheme: ""
    //containerid for user favorites (HackLogin only)
    property string containerid: ""
//    onContaineridChanged: {
//        console.log("==== userInfoObject onContaineridChanged " +containerid);
//        userWeiboDisplayScheme = containerid+"_-_WEIBO_SECOND_PROFILE_WEIBO";
//        console.log("==== userInfoObject userWeiboDisplayScheme " +userWeiboDisplayScheme);
//    }

    property url cover_image_phone: ""

//    id 	int64 	用户UID
    property string id: ""
//    idstr 	string 	字符串型的用户UID
//    screen_name 	string 	用户昵称
    property string screen_name: undefined
//    name 	string 	友好显示名称
//    province 	int 	用户所在省级ID
//    city 	int 	用户所在城市ID
//    location 	string 	用户所在地
    property string location: ""
//    description 	string 	用户个人描述
    property string description: ""
//    url 	string 	用户博客地址
//    profile_image_url 	string 	用户头像地址（中图），50×50像素
    property url profile_image_url: ""
//    profile_url 	string 	用户的微博统一URL地址
//    domain 	string 	用户的个性化域名
//    weihao 	string 	用户的微号
//    gender 	string 	性别，m：男、f：女、n：未知
//    followers_count 	int 	粉丝数
    property int followers_count: 0
//    friends_count 	int 	关注数
    property int friends_count: 0
//    statuses_count 	int 	微博数
    property int statuses_count: 0
//    favourites_count 	int 	收藏数
//    created_at 	string 	用户创建（注册）时间
//    following 	boolean 	暂未支持
    property bool following: false
//    allow_all_act_msg 	boolean 	是否允许所有人给我发私信，true：是，false：否
//    geo_enabled 	boolean 	是否允许标识用户的地理位置，true：是，false：否
//    verified 	boolean 	是否是微博认证用户，即加V用户，true：是，false：否
//    verified_type 	int 	暂未支持
//    remark 	string 	用户备注信息，只有在查询用户关系时才返回此字段
//    status 	object 	用户的最近一条微博信息字段 详细
//    allow_all_comment 	boolean 	是否允许所有人对我的微博进行评论，true：是，false：否
//    avatar_large 	string 	用户头像地址（大图），180×180像素
//    avatar_hd 	string 	用户头像地址（高清），高清头像原图
    property string avatar_hd: ""
//    verified_reason 	string 	认证原因
//    follow_me 	boolean 	该用户是否关注当前登录用户，true：是，false：否
    property bool follow_me: false
//    online_status 	int 	用户的在线状态，0：不在线、1：在线
//    bi_followers_count 	int 	用户的互粉数
//    lang 	string 	用户当前的语言版本，zh-cn：简体中文，zh-tw：繁体中文，en：英语


    property var userInfo: {
        "id":-1,
        "idstr":"",
        "class":1,
        "screen_name":"",
        "name":"",
        "province":"",
        "city":"",
        "location":"",
        "description":"",
        "url":"",
        "cover_image_phone":"",
        "profile_image_url":"",
        "profile_url":"",
        "domain":"",
        "weihao":"",
        "gender":"",
        "followers_count":0,
        "friends_count":0,
        "pagefriends_count": 0,
        "statuses_count":0,
        "favourites_count":0,
        "created_at":"Sun Jan 22 13:32:37 +0800 1999",
        "following":false,
        "allow_all_act_msg":false,
        "geo_enabled":true,
        "verified":false,
        "verified_type":-1,
        "remark":"",
        "status":{
            "created_at": "Mon Jan 04 23:36:38 +0800 2016",
                    "id": 0,
                    "mid": "",
                    "idstr": "",
                    "text": "",
                    "source_allowclick": 0,
                    "source_type": 1,
                    "source": "",
                    "favorited": false,
                    "truncated": false,
                    "in_reply_to_status_id": "",
                    "in_reply_to_user_id": "",
                    "in_reply_to_screen_name": "",
                    "pic_urls": [],
                    "geo": null,
                    "reposts_count": 0,
                    "comments_count": 0,
                    "attitudes_count": 0,
                    "isLongText": false,
                    "mlevel": 0,
                    "visible": {
                        "type": 0,
                        "list_id": 0
                    },
                    "biz_feature": 0,
                    "darwin_tags": [],
                    "userType": 0
        },
        "ptype":0,
        "allow_all_comment":true,
        "avatar_large":"",
        "avatar_hd":"",
        "verified_reason":"",
        "verified_trade": "",
        "verified_reason_url": "",
        "verified_source": "",
        "verified_source_url": "",
        "follow_me":false,
        "online_status":0,
        "bi_followers_count":0,
        "lang":"zh-cn",
        "star":0,
        "mbtype":0,
        "mbrank":0,
        "block_word":0,
        "block_app": 0,
        "credit_score": 0,
        "user_ability": 0,
        "urank": 0
    }
    onUserInfoChanged: {
        userInfoObject.cover_image_phone = cover_image_phone;
        userInfoObject.profile_image_url = profile_image_url;
        userInfoObject.screen_name = screen_name;
        userInfoObject.avatar_hd = avatar_hd;
        userInfoObject.location = location;
        userInfoObject.follow_me = follow_me;
        userInfoObject.description = description;
        userInfoObject.statuses_count = statuses_count;
        userInfoObject.friends_count = friends_count;
        userInfoObject.followers_count = followers_count;
        userInfoObject.following = following;
        userInfoObject.id = id;


        userInfoObject.infoChanged();
    }
}
