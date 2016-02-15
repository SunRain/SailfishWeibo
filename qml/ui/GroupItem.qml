import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailfish_sinaweibo.sunrain 1.0

import "../components"

SilicaListView {
    id: groupItem

    signal fetchPending
    signal fetchFinished
    signal clickItem(string idstr, string name)

    property string _newGroupName: ""
    property string _newGroupIdstr: ""

    WrapperFriendshipsGroups {
        id: friendshipsGroups
        onRequestAbort: {
            console.log("== friendshipsGroups onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== friendshipsGroups onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            console.log("== friendshipsGroups onRequestSuccess ["+replyData+"]")
            var jsonObj = JSON.parse(replyData);
            listModel.append({"JSON":{
                                     "id": "",
                                     "idstr":"",
                                     "name": ""
                                 }}); //添加一个空列表用于显示所有分组功能
            for (var i=0; i<jsonObj.lists.length; i++) {
                listModel.append(jsonObj.lists[i])
            }
            groupItem.fetchFinished();
        }
    }

    WrapperFriendshipsGroupsDestroy {
        id: friendshipsGroupsDestroy
        onRequestAbort: {
            console.log("== friendshipsGroupsDestroy onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== friendshipsGroupsDestroy onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            console.log("== friendshipsGroupsDestroy onRequestSuccess ["+replyData+"]")
            groupItem.fetchFinished();
            groupItem.fetchGroups();
        }
    }
    FriendshipsGroupsUpdate {
        id: friendshipsGroupsUpdate
        onRequestAbort: {
            console.log("== friendshipsGroupsUpdate onRequestAbort");
        }
        onRequestFailure: { //replyData
            console.log("== friendshipsGroupsUpdate onRequestFailure ["+replyData+"]")
        }
        onRequestSuccess: { //replyData
            console.log("== friendshipsGroupsUpdate onRequestSuccess ["+replyData+"]")
            groupItem.fetchFinished();
            groupItem.fetchGroups();
        }
    }

    function fetchGroups() {
        //WBOPT_GET_FRIENDSHIPS_GROUPS
        groupItem.fetchPending();
        listModel.clear();
        friendshipsGroups.getRequest();
    }

    function deleteGroup(idstr) {
        groupItem.fetchPending();
        friendshipsGroupsDestroy.setParameters("list_id", idstr);
        if (tokenProvider.useHackLogin) {
            friendshipsGroupsDestroy.getRequest();
        } else {
            friendshipsGroupsDestroy.postRequest();
        }
    }

    function updateGroupName() {
        groupItem.fetchPending();
        friendshipsGroupsUpdate.setParameters("list_id", _newGroupIdstr);
        friendshipsGroupsUpdate.setParameters("name", _newGroupName);
        friendshipsGroupsUpdate.postRequest();

    }

    ListModel {
        id: listModel
    }

    model: listModel
    delegate: listViewdDlegate
    spacing: Theme.paddingMedium

    ScrollDecorator{}

    Component {
        id: listViewdDlegate
        Item {
            id: listItem
            width: parent.width
            height: childrenRect.height

            //TODO: ugly hack for fix contextMenu display
            property bool _contextMenuOpen: false
            property bool _showInputType: false

            RemorseItem {id: remorseItem}

            Loader {
                id: leftLoader
                width: parent.width
                sourceComponent: listItem._showInputType
                                 ? textInputComponent
                                 : infoItemComponent
            }

            Component {
                id: textInputComponent
                TextField {
                    id: textField
                    width: parent.width
                    label: qsTr("Rename %1 ==> %2 (%3/8)").arg(model.name).arg(textField.text).arg(textField.text.length)
                    placeholderText: model.name
                    horizontalAlignment: TextInput.AlignLeft
//                    EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                    EnterKey.text: qsTr("Rename")
                    EnterKey.highlighted: true
                    EnterKey.onClicked: {
                        groupItem._newGroupName = textField.text;
                        groupItem._newGroupIdstr = model.idstr;
                        parent.focus = true;
//                        groupItem.focus = true;
                        updateGroupName();
                    }
                    Component.onCompleted: {
                        groupItem._newGroupName = model.name;
                    }
                }
            }

            Component {
                id: infoItemComponent
                OptionItem {
                    id: text
                    width: Screen.width
//                    menu: model.name == "" ||  model.idstr == ""
//                          || model.name == undefined ||  model.idstr == undefined
//                        ? null
//                        : menuComponent
                    contentHeight: Math.max(label.height, Theme.itemSizeSmall)
//                    var idstr = model.idstr;
                    Label {
                        id: label
                        width: parent.width - Theme.horizontalPageMargin *2
                        anchors.centerIn: parent
                        text: model.name == "" ||  model.idstr == ""
                              || model.name == undefined ||  model.idstr == undefined
                              ? qsTr("All Groups")
                              : model.name
                        color: text.highlighted ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    onClicked: {
                        console.log("==== click idstr "+model.idstr+" name "+model.name)
                        groupItem.clickItem(model.idstr, model.name);
                    }

//                    Component {
//                        id: menuComponent
                        menu: ContextMenu {
                            id:options
                            MenuItem {
                                text: qsTr("Delete Group")
                                onClicked: {
                                    remorseItem.execute(listItem,"Deleting", function(){
                                        groupItem.deleteGroup(idstr);
                                        listModel.remove(index);})
                                }
                            }
//                            MenuItem {
//                                text: qsTr("Rename Group")
//                                onClicked: {
//                                    listItem._showInputType = true;
//                                }
//                            }
//                        }
                    }
                }

            }
        }
    }
}
