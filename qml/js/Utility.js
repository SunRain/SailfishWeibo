.pragma library

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
    var userObject = jsonObject[0].card_group[0];

    target.cover_image_phone = "";
    target.profile_image_url = userObject.user.profile_image_url;
    target.screen_name = userObject.user.screen_name;
}
