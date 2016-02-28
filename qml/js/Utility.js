.pragma library

//Qt.include("JsonPath.js")

function parserRemind(target, jsonObject) {
    if (!target || !jsonObject) {
        console.log("[parserRemind]: no remind object or remind data found!");
        return;
    }
    /*****
    {"qp":{"pl":1,"sx":3，"new":2},"ht":{"pl":1,"sx":3}}
    pl 评论
    sx 私信
    new 新微博
    fs 粉丝
    at at me
    atcmt at me comment
    attitude
     ******/
//            console.log("[Panel]: parserRemind " + "cmt " + jsonObject.qp.pl
//                        + " dm " + jsonObject.qp.sx);
    target.cmt = jsonObject.qp.pl == undefined ? 0 : jsonObject.qp.pl;
    target.mention_cmt = jsonObject.qp.atcmt == undefined ? 0 : jsonObject.qp.atcmt;
    target.mention_status = jsonObject.qp.at == undefined ? 0 : jsonObject.qp.at;
    target.dm = jsonObject.qp.sx == undefined ? 0 : jsonObject.qp.sx;
    target.status = jsonObject.qp.new == undefined ? 0 : jsonObject.qp.new;
    target.attitude = jsonObject.qp.attitude == undefined ? 0 : jsonObject.qp.attitude;
}

function parserUserInfoMe(target, jsonObject) {
    for (var i=0; i<jsonObject.length; ++i) {
        var mainArray = jsonObject[i].card_group;
        for (var j=0; j<mainArray.length; ++j) {
            var main = mainArray[j];
            if (main.card_type == "30") { //userInfo
                target.id = main.user.id
                target.cover_image_phone = "";
                target.profile_image_url = main.user.profile_image_url;
                target.screen_name = main.user.screen_name;
                if (main.user.screen_name == "" || main.user.screen_name == undefined)
                    target.screen_name = main.user.name;
                target.location = main.user.nativePlace;
                target.description = main.user.description;
                target.followers_count = main.user.fansNum;
                target.friends_count = main.user.attNum;
                target.statuses_count = main.user.mblogNum;
                target.avatar_hd = main.user.avatar_hd;
                target.follow_me = main.user.follow_me;
                target.following = main.user.following;
            } else if (main.card_type == "4") { // Favorites and others
                var itemID = main.itemid;
                if (itemID == undefined)
                    continue;
                if (itemID.match("WEIBO_INDEX_PROFILE_FAVORITE")) {
                    target.containerid = main.scheme.replace(/\/p\/index\?containerid=/, "");
                    var p = itemID.replace(/_-_WEIBO_INDEX_PROFILE_FAVORITE/, "");
                    target.userWeiboListScheme = p+"_-_WEIBO_SECOND_PROFILE_WEIBO";
                }
            }
        }
    }
}

function parserOthersUserInfo(target, jsonObject) {
    for (var i=0; i<jsonObject.length; ++i) {
        var top = jsonObject[i];
        if (top.id != undefined) { //for user Info
            target.id = top.id
            target.cover_image_phone = "";
            target.profile_image_url = top.profile_image_url;
            target.screen_name = top.name;
            target.location = top.nativePlace;
            target.description = top.description;
            target.followers_count = top.fansNum;
            target.friends_count = top.attNum;
            target.statuses_count = top.mblogNum;
            target.avatar_hd = top.avatar_hd;
            target.follow_me = top.follow_me;
            target.following = top.following;
        } else if (top.card_group != undefined) {
            var snd = top.card_group;
            for (var j=0; j<snd.length; ++j) {
                var trd = snd[i];
                if (trd.card_type == "11") {
                    var itemID = trd.itemid;
                    if (itemID == undefined)
                        continue;
                    if (itemID.match("WEIBO_INDEX_PROFILE_WEIBO_GROUP_OBJ")) {
//                        target.containerid = itemID.replace(/_-_WEIBO_INDEX_PROFILE_WEIBO_GROUP_OBJ/, "");
//                        console.log("====== parserOthersUserInfo containerid  match " + target.containerid);
                        var p = itemID.replace(/_-_WEIBO_INDEX_PROFILE_WEIBO_GROUP_OBJ/, "");
                        target.userWeiboListScheme = p+"_-_WEIBO_SECOND_PROFILE_WEIBO";
                        break;
                    } else {
                        continue;
                    }
                } else {
                    continue;
                }
            }
        } /*else {
            target.containerid = "";
        }*/
    }
    console.log("====== parserOthersUserInfo userWeiboListScheme " + target.userWeiboListScheme);
}
