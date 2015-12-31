.pragma library

function getWeicoAuthorizeUrl() {
    ///weico的新登陆验证方式（需要使用webview进行认证）
    var kOAuth2AccessAuthorize = "https://open.weibo.cn/oauth2/authorize";
    var kAppId = "211160679";
    var kAppKeyHash = "1e6e33db08f9192306c4afa0a61ad56c";
    var kRedirectUri = "http://oauth.weico.cc";
    var kPackageName = "com.eico.weico";
    var kScope = "email,direct_messages_read,direct_messages_write,friendships_groups_read,friendships_groups_write,statuses_to_me_read,follow_app_official_microblog,invitation_write";
    var kWeicoApi = kOAuth2AccessAuthorize+ "?" + "client_id=" + kAppId
            + "&response_type=token&redirect_uri=" + kRedirectUri
            + "&key_hash=" + kAppKeyHash + "&packagename=" + kPackageName
            + "&display=mobile" + "&scope=" + kScope;
    return kWeicoApi;
}

