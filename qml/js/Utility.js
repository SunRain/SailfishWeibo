.pragma library

Qt.include("JsonPath.js")

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
     ******/
//            console.log("[Panel]: parserRemind " + "cmt " + jsonObject.qp.pl
//                        + " dm " + jsonObject.qp.sx);
    target.cmt = jsonObject.qp.pl == undefined ? 0 : jsonObject.qp.pl;
    //TODO mention_cmt?
    target.mention_cmt = 0;
    //TODO mention_status
    target.mention_status = 0;
    target.dm = jsonObject.qp.sx == undefined ? 0 : jsonObject.qp.sx;
    target.status = jsonObject.qp.new == undefined ? 0 : jsonObject.qp.new;
}

function parserUserInfoMe(target, jsonObject) {
    for (var i=0; i<jsonObject.length; ++i) {
        var mainArray = jsonObject[i].card_group;
        for (var j=0; j<mainArray.length; ++j) {
            var main = mainArray[j];
            if (main.card_type == "30") { //userInfo
                target.cover_image_phone = "";
                target.profile_image_url = main.user.profile_image_url;
                target.screen_name = main.user.screen_name;
            } else if (main.card_type == "4") { // Favorites and others
                var itemID = main.itemid;
                if (itemID == undefined)
                    continue;
                if (itemID.match("WEIBO_INDEX_PROFILE_FAVORITE")) {
                    target.containerid = main.scheme.replace(/\/p\/index\?containerid=/, "");
                }
            }
        }
    }
}
