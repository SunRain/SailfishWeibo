import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

import "../js/weiboapi.js" as WB
//import "../js/Settings.js" as Settings

Item {
    id:atUserComponent
    
    anchors.fill: parent
    
    signal userClicked(string userName)
    signal closeIconClicked
    signal fetchPending
    signal fetchFinish
    
//    Connections {
//        target: api
//        //void weiboPutSucceed(QWeiboMethod::WeiboAction action, const QString& replyData);
//        onWeiboPutSucceed: {
//            if (action == WeiboMethod.WBOPT_GET_SEARCH_SUGGESTIONS_AT_USERS) {
//                var jsonObj = JSON.parse(replyData);
//                modelAtUser.clear();
//                for (var i=0; i<jsonObj.length; i++) {
//                    modelAtUser.append(jsonObj[i])
//                }
//                fetchFinish();
//            }
//        }
//        onTokenExpired: {}
//    }
    /*SearchSuggestionsAtUsers*/WrapperSearchSuggestionsAtUsers {
        id: searchSuggestionsAtUsers
        onRequestAbort: {}
        onRequestFailure: { //replyData
        }
        onRequestSuccess: { //replyData
            var jsonObj = JSON.parse(replyData);
            modelAtUser.clear();
            for (var i=0; i<jsonObj.length; i++) {
                modelAtUser.append(jsonObj[i])
            }
            fetchFinish();
        }
    }

    Column {
        id:mainColumn
        width: parent.width
        spacing: Theme.paddingSmall 
        
        PageHeader {
            id:pageHeader
            title: qsTr("SearchUser")
            visible: modelAtUser.count <= 0
        }
        
        Row {
            id:searchArea
            spacing: Theme.paddingSmall 
            height: Math.max(searchInput.height, searchIcon.height + Theme.paddingSmall)//searchInput.height > searchIcon.height ? searchInput.height : searchIcon.height + Theme.paddingSmall
            
            TextField {
                id:searchInput
                width: drawer.width - searchIcon.width - closeIcon.width - Theme.paddingSmall
                label: qsTr("search") + " " +searchInput.text
                placeholderText: "Type here"
                focus: true
                horizontalAlignment: TextInput.AlignLeft
                EnterKey.onClicked: {
                    //text = "Return key pressed";
                    parent.focus = true;
                }
            }
            
            IconButton {
                id:searchIcon
                icon.source: "image://theme/icon-m-search"
                highlighted: down || searchInput._editor.activeFocus
                enabled: searchInput.enabled
                onClicked: {
                    modelAtUser.searchAtUser(searchInput.text);
                }
            }
            IconButton {
                id:closeIcon
                icon.source: "image://theme/icon-m-clear"
                highlighted: down || searchInput._editor.activeFocus
                
                enabled: searchInput.enabled
                
                onClicked: {
                    atUserComponent.closeIconClicked();
                }
            }
            
        }
        
        SilicaListView {
            id:findUserList
            width: parent.width
            height: atUserComponent.height - pageHeader.height - searchArea.height -Theme.paddingSmall *2
            
            currentIndex:  -1;
            model: modelAtUser

            delegate: BackgroundItem {
                id: backgroundItem
                
                ListView.onAdd: AddAnimation {
                    target: backgroundItem
                }
                ListView.onRemove: RemoveAnimation {
                    target: backgroundItem
                }
                
                onClicked: {
                    atUserComponent.userClicked(model.nickname);
                }

                Label {
                    anchors{
                        left: parent.left
                        leftMargin: Theme.paddingMedium
                        right: parent.right
                        rightMargin: Theme.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                    textFormat: Text.StyledText
                    text: model.nickname
                    font.pixelSize:Theme.fontSizeExtraSmall
                }
            }
            VerticalScrollDecorator {}
        }
        ListModel {
            id:modelAtUser
            
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
        }
    }
}
