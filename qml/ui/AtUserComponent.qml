import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

SilicaListView {
    id: atUserComponent
    width: parent ? parent.width : Screen.width
    height: parent ? parent.height : Screen.height

    signal userClicked(string userName)
    signal fetchPending
    signal fetchFinish
    
    function searchAtUser(kw) {
        fetchPending();
        var q = encodeURIComponent(kw);
//                var method = WeiboMethod.WBOPT_GET_SEARCH_SUGGESTIONS_AT_USERS;
//                api.setWeiboAction(method, {
//                                       "access_token":settings.accessToken,
//                                       "q":q,
//                                       "type":0,
//                                       "range":2});
        searchSuggestionsAtUsers.setParameters("q", q);
        searchSuggestionsAtUsers.setParameters("type", 0);
        searchSuggestionsAtUsers.setParameters("range", 2);
        searchSuggestionsAtUsers.getRequest();
    }

    WrapperSearchSuggestionsAtUsers {
        id: searchSuggestionsAtUsers
        onRequestAbort: {}
        onRequestFailure: { //replyData
        }
        onRequestSuccess: { //replyData
            var jsonObj = JSON.parse(replyData);
            modelAtUser.clear();
            for (var i=0; i<jsonObj.length; i++) {
                if (tokenProvider.useHackLogin)
                    modelAtUser.append(jsonObj[i].user);
                else
                    modelAtUser.append(jsonObj[i]);
            }
            fetchFinish();
        }
    }
    clip: true
    currentIndex:  -1;
    model: ListModel {
        id: modelAtUser
    }
    delegate: BackgroundItem {
        id: backgroundItem
        onClicked: {
            if (tokenProvider.useHackLogin)
                atUserComponent.userClicked(model.screen_name);
            else
                atUserComponent.userClicked(model.nickname);
        }
        Image {
            id: image
            enabled: tokenProvider.useHackLogin
            visible: tokenProvider.useHackLogin
            source: model.profile_image_url
            height: parent.height *0.8
            width: height
            fillMode: Image.PreserveAspectFit
            anchors {
                left: parent.left
                leftMargin: Theme.horizontalPageMargin
                verticalCenter: parent.verticalCenter
            }
        }
        Label {
            anchors {
                left: image.right
                leftMargin: Theme.paddingSmall
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
                verticalCenter: parent.verticalCenter
            }
            textFormat: Text.StyledText
            text: tokenProvider.useHackLogin ? model.screen_name : model.nickname
            font.pixelSize:Theme.fontSizeSmall
        }
    }
    VerticalScrollDecorator {}
}
