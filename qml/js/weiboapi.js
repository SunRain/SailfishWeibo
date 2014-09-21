
//////////////////////////////////////////////////////////////////////////////////////     account
//login
function weiboGetAccessCode(id, secret, code, observer)
{
    var url = "https://api.weibo.com/oauth2/access_token?client_id=" + id + "&client_secret=" + secret + "&grant_type=authorization_code&code=" + code + "&redirect_uri=https://api.weibo.com/oauth2/default.html"
    console.log("get access_token start...")

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log("   access_token in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!Network connection failed!")
                    observer.update("error", doc.status)
                }
                else {
                    console.log("-- got access_token !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("token: ", doc.responseText)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("POST", url, true);
    doc.setRequestHeader("Content-type", "application/json");
    doc.send();
}

//check token available
function weiboCheckToken(token, observer)
{
    var url = "https://api.weibo.com/oauth2/get_token_info?access_token=" + token
    console.log("check access_token start...")

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" check  access_token in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!Network connection failed!", doc.status, "...", doc.responseText)
                    if (doc.status == 0) {
                        observer.update("no_network", {})
                    }
                    else {
                        var json0 = JSON.parse('' + doc.responseText+ '')
                        observer.update("error", json0)
                    }
                }
                else {
                    console.log("-- checked access_token !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("check token: ", doc.responseText)
                        var json = JSON.parse('' + doc.responseText+ '')
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("POST", url, true);
    doc.setRequestHeader("Content-type", "application/json");
    doc.send();
}

//log out
function weiboLogOut(token, observer)
{
    var url = "https://api.weibo.com/oauth2/revokeoauth2?access_token=" + token
    console.log("weiboLogOut start...")

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" weiboLogOut in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!weiboLogOut failed!", doc.status, doc.responseText)
                    var json = JSON.parse('' + doc.responseText+ '')
                    observer.update("error", json)
                }
                else {
                    console.log("-- weiboLogOut !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("weiboLogOut: ", doc.responseText)
                        var json = JSON.parse('' + doc.responseText+ '')
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("GET", url, true);
    doc.setRequestHeader("Content-type", "application/json");
    doc.send();
}

//////////////////////////////////////////////////////////////////////////////////////     weibo
//home status
function weiboHomeStatus(token, page , observer)
{
    var url = "https://api.weibo.com/2/statuses/home_timeline.json?access_token=" + token + "&page=" + page
    console.log("home status start...")

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" home status in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!Network connection failed!")
                    observer.update("error", doc.status)
                }
                else {
                    console.log("-- home status !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("home status: done"  /*, doc.responseText*/)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("GET", url, true);
    doc.setRequestHeader("Content-type", "application/json");
    doc.send();
}

//send weibo
function weiboSendStatus(token, status , observer)
{
    var weibo = encodeURIComponent(status)
    var url = "https://api.weibo.com/2/statuses/update.json?access_token=" + token + "&status=" + weibo
    console.log("send status start... ", url)

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" send status in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!Network connection failed!", doc.status, doc.responseText)
                    observer.update("error", doc.status)
                }
                else {
                    console.log("-- send status !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("send status: "  , doc.responseText)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("POST", url, true);
    doc.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    doc.send();
}

//get weibo comments
function weiboGetComments(token, id , page , observer)
{
    var url = "https://api.weibo.com/2/comments/show.json?access_token=" + token + "&id=" + id + "&page=" + page
    console.log("GetComments start...")

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" GetComments in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!Network connection failed!", doc.responseText)
                    observer.update("error", doc.status)
                }
                else {
                    console.log("-- GetComments !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("GetComments: done"  /*, doc.responseText*/)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("GET", url, true);
    doc.setRequestHeader("Content-type", "application/json");
    doc.send();
}

//send comment
function weiboSendComment(token, comment, weiboid, comment_ori , observer)
{
    var comment_e = encodeURIComponent(comment)
    var url = "https://api.weibo.com/2/comments/create.json?access_token=" + token + "&comment=" + comment_e + "&id=" + weiboid + "&comment_ori=" + comment_ori
    console.log("send comment start... ", url)

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" send comment in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!send comment failed!", doc.status, doc.responseText)
                    observer.update("error", doc.responseText)
                }
                else {
                    console.log("-- send comment !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("send comment: "  , doc.responseText)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("POST", url, true);
    doc.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    doc.send();
}

//reply comment
function weiboReplyComment(token, comment, weiboid, comment_ori, commentid, without_mention , observer)
{
    var comment_e = encodeURIComponent(comment)
    var url = "https://api.weibo.com/2/comments/reply.json?access_token=" + token + "&comment=" + comment_e + "&id=" + weiboid + "&cid=" + commentid + "&without_mention=" + without_mention + "&comment_ori=" + comment_ori
    console.log("reply comment start... ", url)

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" reply comment in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!reply comment failed!", doc.status, doc.responseText)
                    var json0 = JSON.parse('' + doc.responseText+ '');
                    observer.update("error", json0);
                }
                else {
                    console.log("-- reply comment !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("reply comment: "  , doc.responseText)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("POST", url, true);
    doc.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    doc.send();
}

//repost weibo
function weiboRepostStatus(token, status, id, is_comment , observer)
{
    var weibo = encodeURIComponent(status)
    var url = "https://api.weibo.com/2/statuses/repost.json?access_token=" + token + "&id=" + id + "&status=" + weibo + "&is_comment=" + is_comment
    console.log("repost status start... ", url)

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" repost status in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!repost status failed!", doc.status, doc.responseText)
                    observer.update("error", doc.responseText)
                }
                else {
                    console.log("-- repost status !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("repost status: "  , doc.responseText)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("POST", url, true);
    doc.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    doc.send();
}

//////////////////////////////////////////////////////////////////////////////////////     user
//get user info by user id
function userGetInfoByUid(token, uid , observer)
{
    var url = "https://api.weibo.com/2/users/show.json?access_token=" + token + "&uid=" + uid
    console.log("GetInfoByUid start...")

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" GetInfoByUid in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!GetInfoByUid failed!", doc.responseText)
                    observer.update("error", doc.status)
                }
                else {
                    console.log("-- GetInfoByUid !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("GetInfoByUid: done"  /*, doc.responseText*/)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("GET", url, true);
    doc.setRequestHeader("Content-type", "application/json");
    doc.send();
}

//get following list
function userGetFollowing(token, uid, count, cursor, observer)
{
    var url = "https://api.weibo.com/2/friendships/friends.json?access_token=" + token + "&uid=" + uid + "&count=" + count + "&cursor=" + cursor
    console.log("userGetFollowing start...")

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" userGetFollowing in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!userGetFollowing failed!", doc.responseText)
                    observer.update("error", doc.status)
                }
                else {
                    console.log("-- userGetFollowing !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("userGetFollowing: done"  /*, doc.responseText*/)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("GET", url, true);
    doc.setRequestHeader("Content-type", "application/json");
    doc.send();
}

//get follower list
function userGetFollower(token, uid, count, cursor, observer)
{
    var url = "https://api.weibo.com/2/friendships/followers.json?access_token=" + token + "&uid=" + uid + "&count=" + count + "&cursor=" + cursor
    console.log("userGetFollower start..." + url)

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" userGetFollower in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!userGetFollower failed!", doc.responseText)
                    observer.update("error", doc.status)
                }
                else {
                    console.log("-- userGetFollower !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("userGetFollower: done"  /*, doc.responseText*/)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("GET", url, true);
    doc.setRequestHeader("Content-type", "application/json");
    doc.send();
}

//get Bilateral list
function userGetBilateral(token, uid, count, page, observer)
{
    var url = "https://api.weibo.com/2/friendships/friends/bilateral.json?access_token=" + token + "&uid=" + uid + "&count=" + count + "&page=" + page
    console.log("userGetBilateral start...")

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" userGetBilateral in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!userGetBilateral failed!", doc.responseText)
                    observer.update("error", doc.status)
                }
                else {
                    console.log("-- userGetBilateral !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("userGetBilateral: done"  /*, doc.responseText*/)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("GET", url, true);
    doc.setRequestHeader("Content-type", "application/json");
    doc.send();
}

//get user weibo
function userGetWeibo(token, uid, page, observer)
{
    var url = "https://api.weibo.com/2/statuses/user_timeline.json?access_token=" + token + "&uid=" + uid + "&page=" + page
    console.log("userGetWeibo start..." + url);

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" userGetWeibo in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!userGetWeibo failed!", doc.responseText)
                    observer.update("error", doc.status)
                }
                else {
                    console.log("-- userGetWeibo !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("userGetWeibo: done"  , doc.responseText)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("GET", url, true);
    doc.setRequestHeader("Content-type", "application/json");
    doc.send();
}

//get user photo album
function userGetPhoto(token, uid, page, observer)
{
    var url = "https://api.weibo.com/2/place/users/photos.json?access_token=" + token + "&uid=" + uid + "&page=" + page
    console.log("userGetPhoto start...")

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" userGetPhoto in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!userGetPhoto failed!", doc.responseText)
                    observer.update("error", doc.status)
                }
                else {
                    console.log("-- userGetPhoto !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("userGetPhoto: done"  /*, doc.responseText*/)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("GET", url, true);
    doc.setRequestHeader("Content-type", "application/json");
    doc.send();
}

//follow a user
function userFriendshipCreate(token, uid, observer)
{
//    var weibo = encodeURIComponent(status)
    var url = "https://api.weibo.com/2/friendships/create.json?access_token=" + token + "&uid=" + uid
    console.log("userFriendshipCreate start... ")

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" userFriendshipCreate in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!userFriendshipCreate failed!", doc.status, doc.responseText)
                    observer.update("error", doc.responseText)
                }
                else {
                    console.log("-- userFriendshipCreate !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("userFriendshipCreate: "  /*, doc.responseText*/)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("POST", url, true);
    doc.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    doc.send();
}

//cancel follow a user
function userFriendshipdestroy(token, uid, observer)
{
    //    var weibo = encodeURIComponent(status)
    var url = "https://api.weibo.com/2/friendships/destroy.json?access_token=" + token + "&uid=" + uid
    console.log("userFriendshipdestroy start... ")

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            console.log(" userFriendshipdestroy in progress...");
        }
        else if (doc.readyState == XMLHttpRequest.DONE)
        {
            if(doc.status != 200) {
                console.log("!!!userFriendshipdestroy failed!", doc.status, doc.responseText)
                observer.update("error", doc.responseText)
            }
            else {
                console.log("-- userFriendshipdestroy !");
                if(doc.responseText == null) {
                    observer.update("null", doc.status)
                }
                else {
                    console.log("userFriendshipdestroy: "  /*, doc.responseText*/)
                    var json = JSON.parse('' + doc.responseText+ '');
                    observer.update("fine", json);
                }
            }
        }
    }

    doc.open("POST", url, true);
    doc.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    doc.send();
}

//////////////////////////////////////////////////////////////////////////////////////     message
//get message remind
function messageGetRemind(token, uid, observer)
{
    var url = "https://rm.api.weibo.com/2/remind/unread_count.json?access_token=" + token + "&uid=" + uid
    console.log("messageGetRemind start...")

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" messageGetRemind in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!messageGetRemind failed!", doc.responseText)
                    observer.update("error", doc.status)
                }
                else {
                    console.log("-- messageGetRemind !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("messageGetRemind: done"  /*, doc.responseText*/)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("GET", url, true);
    doc.setRequestHeader("Content-type", "application/json");
    doc.send();
}

//get comment all
function messageGetAllComment(token, page, observer)
{
    var url = "https://api.weibo.com/2/comments/timeline.json?access_token=" + token + "&page=" + page
    console.log("messageGetAllComment start...")

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" messageGetAllComment in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!messageGetAllComment failed!", doc.responseText)
                    observer.update("error", doc.status)
                }
                else {
                    console.log("-- messageGetAllComment !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("messageGetAllComment: done"  /*, doc.responseText*/)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("GET", url, true);
    doc.setRequestHeader("Content-type", "application/json");
    doc.send();
}

//get comment mentioned me
function messageGetCommentMentioned(token, page, observer)
{
    var url = "https://api.weibo.com/2/comments/mentions.json?access_token=" + token + "&page=" + page
    console.log("messageGetCommentMentioned start...")

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" messageGetCommentMentioned in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!messageGetCommentMentioned failed!", doc.responseText)
                    observer.update("error", doc.status)
                }
                else {
                    console.log("-- messageGetCommentMentioned !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("messageGetCommentMentioned: done"  /*, doc.responseText*/)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("GET", url, true);
    doc.setRequestHeader("Content-type", "application/json");
    doc.send();
}

//get weibo mentioned me
function messageGetWeiboMentioned(token, page, observer)
{
    var url = "https://api.weibo.com/2/statuses/mentions.json?access_token=" + token + "&page=" + page
    console.log("messageGetWeiboMentioned start...")

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" messageGetWeiboMentioned in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!messageGetWeiboMentioned failed!", doc.responseText)
                    observer.update("error", doc.status)
                }
                else {
                    console.log("-- messageGetWeiboMentioned !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("messageGetWeiboMentioned: done"  /*, doc.responseText*/)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("GET", url, true);
    doc.setRequestHeader("Content-type", "application/json");
    doc.send();
}

//////////////////////////////////////////////////////////////////////////////////////     search
//search user
function searchUser(token, kw, count, observer)
{
    var q = encodeURIComponent(kw)
    var url = "https://api.weibo.com/2/search/suggestions/users.json?access_token=" + token + "&q=" + q + "&count=" + count
    console.log("searchUser start...")

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" searchUser in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!searchUser failed!", doc.responseText)
                    observer.update("error", doc.status)
                }
                else {
                    console.log("-- searchUser !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("searchUser: done"  /*, doc.responseText*/)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("GET", url, true);
    doc.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    doc.send();
}

//search user
function searchAtUser(token, kw, count, type, range, observer)
{
    var q = encodeURIComponent(kw)
    var url = "https://api.weibo.com/2/search/suggestions/at_users.json?access_token=" + token + "&q=" + q + "&count=" + count + "&type=" + type + "&range=" + range
    console.log("searchAtUser start...")

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(" searchAtUser in progress...");
            }
            else if (doc.readyState == XMLHttpRequest.DONE)
            {
                if(doc.status != 200) {
                    console.log("!!!searchAtUser failed!", doc.responseText)
                    observer.update("error", doc.status)
                }
                else {
                    console.log("-- searchAtUser !");
                    if(doc.responseText == null) {
                        observer.update("null", doc.status)
                    }
                    else {
                        console.log("searchAtUser: done"  /*, doc.responseText*/)
                        var json = JSON.parse('' + doc.responseText+ '');
                        observer.update("fine", json);
                    }
                }
            }
    }

    doc.open("GET", url, true);
    doc.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    doc.send();
}
