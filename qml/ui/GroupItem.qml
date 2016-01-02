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

    FriendshipsGroups {
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

    FriendshipsGroupsDestroy {
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
//        var method = WeiboMethod.WBOPT_GET_FRIENDSHIPS_GROUPS;
//        api.setWeiboAction(method, {'access_token':settings.accessToken/*Settings.getAccess_token()*/});
        friendshipsGroups.getRequest();
    }

    function deleteGroup(idstr) {
        groupItem.fetchPending();
//        var method = WeiboMethod.WBOPT_POST_FRIENDSHIPS_GROUPS_DESTROY;
//        api.setWeiboAction(method, {
//                               "access_token":settings.accessToken,//Settings.getAccess_token(),
//                               "list_id":idstr
//                           });
        friendshipsGroupsDestroy.setParameters("list_id", idstr);
        friendshipsGroups.postRequest();
    }

    function updateGroupName() {
        // WBOPT_POST_FRIENDSHIPS_GROUPS_UPDATE, //更新好友分组
        groupItem.fetchPending();
//        var method = WeiboMethod.WBOPT_POST_FRIENDSHIPS_GROUPS_UPDATE;
//        api.setWeiboAction(method, {
//                               "access_token":settings.accessToken,//Settings.getAccess_token(),
//                               "list_id":_newGroupIdstr,
//                               "name":_newGroupName
//                           });
        friendshipsGroupsUpdate.setParameters("list_id", _newGroupIdstr);
        friendshipsGroupsUpdate.setParameters("name", _newGroupName);
        friendshipsGroupsUpdate.postRequest();

    }

//    Connections {
//        target: api
//        //void weiboPutSucceed(QWeiboMethod::WeiboAction action, const QString& replyData);
//        onWeiboPutSucceed: {
//            if (action == WeiboMethod.WBOPT_GET_FRIENDSHIPS_GROUPS) {
//                var jsonObj = JSON.parse(replyData);
//                listModel.append({"JSON":{
//                                         "id": "",
//                                         "idstr":"",
//                                         "name": ""
//                                     }}); //添加一个空列表用于显示所有分组功能
//                for (var i=0; i<jsonObj.lists.length; i++) {
//                    listModel.append(jsonObj.lists[i])
//                }
//                groupItem.fetchFinished();
//            }
//            if (action == WeiboMethod.WBOPT_POST_FRIENDSHIPS_GROUPS_DESTROY
//                    || action == WeiboMethod.WBOPT_POST_FRIENDSHIPS_GROUPS_UPDATE) {
//                groupItem.fetchFinished();
//                groupItem.fetchGroups();
//            }
//        }
//    }

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
            anchors {
                left:parent.left
                right:parent.right
            }
            height: childrenRect.height

            //TODO: ugly hack for fix contextMenu display
            property bool _contextMenuOpen: false
            property bool _showInputType: false

            RemorseItem {id: remorseItem}

            Loader {
                id: leftLoader
                anchors {
                    left: listItem.left
                    leftMargin: Theme.paddingLarge
                    right: listItem._showInputType
                           ? listItem.right
                           : rightLoader.left
                }
                sourceComponent: listItem._showInputType ? textInputComponent : infoItemComponent
            }
            Loader {
                id: rightLoader
                anchors {
                    //TODO: remove this, but how can I fix the contextMenuOpen display ?
//                    left: listItem._contextMenuOpen ? listItem.left : parent.left
                    right: listItem.right
                    rightMargin: Theme.paddingLarge
                }
                sourceComponent: listItem._showInputType
                                 ? rightLoader.Null
                                 : optionComponent
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
                BackgroundItem {
                    id: text
                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    height: Math.max(label.height, Theme.itemSizeSmall)
                    Label {
                        id: label
                        width: parent.width
                        anchors.verticalCenter: parent.verticalCenter
                        text: model.name == "" ||  model.idstr == ""
                              ? qsTr("All Groups")
                              : model.name
                        color: text.highlighted ? Theme.highlightColor : Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                    }
                    onClicked: {
                        groupItem.clickItem(model.idstr, model.name);
                    }
                }

            }
            Component {
                id: optionComponent
                OptionItem {
                    id: optionItem
                    width: optionItem.menuOpen ? Screen.width : image.width

                    visible: !(model.idstr == "" || model.id == "" || model.name == "")
                    Image {
                        id: image
                        anchors{
                            top:parent.top
                            bottom: parent.bottom
                            right: parent.right
                        }
                        smooth: true
                        width: Theme.iconSizeMedium
                        height: width
                        fillMode: Image.PreserveAspectFit
                        source: optionItem.menuOpen ?
                                    util.pathTo("qml/graphics/action_collapse.png") :
                                    util.pathTo("qml/graphics/action_open.png")
                    }

                    onMenuStateChanged: {
                        listItem._contextMenuOpen = opened;
                    }

                    menu: ContextMenu {
                        id:options
                        MenuItem {
                            text: qsTr("Delete Group")
                            onClicked: {
                                remorseItem.execute(listItem,"Deleting", function(){
                                    groupItem.deleteGroup(model.idstr);
                                    listModel.remove(index);})
                            }
                        }
                        MenuItem {
                            text: qsTr("Rename Group")
                            onClicked: {
                                listItem._showInputType = true;
                            }
                        }
                    }
                }
            }
        }
    }
}
