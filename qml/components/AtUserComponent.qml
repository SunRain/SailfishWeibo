import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/weiboapi.js" as WB
import "../js/Settings.js" as Settings

Item {
    id:atUserComponent
    
    anchors.fill: parent
    
    signal userClicked(string userName)
    signal closeIconClicked
    
    Column {
        id:mainColumn
        width: parent.width
        
        spacing: Theme.paddingSmall 
        
        PageHeader {
            id:pageHeader
            title: qsTr("SearchUser")
        }
        
        Row {
            id:searchArea
            spacing: Theme.paddingSmall 
            height: searchInput.height > searchIcon.height ? searchInput.height : searchIcon.height + Theme.paddingSmall 
            
            TextField {
                id:searchInput
                width: drawer.width - searchIcon.width - closeIcon.width - Theme.paddingSmall
                label: "Text field"
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
                    //console.log("SendPage == search for UserName " + searchInput.text);
                    modelAtUser.searchAtUser(searchInput.text);
                }
            }
            //icon.source: "image://theme/icon-m-clear"
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
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            atUserComponent.userClicked(model.nickname);
                        }
                    }
                }
            }
            VerticalScrollDecorator {}
        }
        ListModel {
            id:modelAtUser
            
            function searchAtUser(kw) {
                function observer() {}
                observer.prototype = {
                    update: function(status, result)
                    {
                        if(status != "error"){
                            if(result.error) {
                                // TODO  error handler
                            }else {
                                // right result
                                //                                console.log("search at users: ", JSON.stringify(result))
                                modelAtUser.clear()
                                for (var i=0; i<result.length; i++) {
                                    modelAtUser.append(result[i])
                                }
                            }
                        }else{
                            // TODO  empty result
                        }
                    }
                }
                
                WB.searchAtUser(Settings.getAccess_token(), kw, 20, 0, 2, new observer())
            }
        }
    }
}
