import QtQuick 2.0
import Sailfish.Silica 1.0
import com.sunrain.sinaweibo 1.0

import "../js/Settings.js" as Settings
import "../components"

SilicaListView {
    id: groupItem

    signal fetchPending
    signal fetchFinished
    signal clickItem(string idstr, string name)

    function fetchGroups() {
        //WBOPT_GET_FRIENDSHIPS_GROUPS
        groupItem.fetchPending();
        listModel.clear();
        var method = WeiboMethod.WBOPT_GET_FRIENDSHIPS_GROUPS;
        api.setWeiboAction(method, {'access_token':Settings.getAccess_token()});
    }

    function deleteGroup(idstr) {
        groupItem.fetchPending();
        var method = WeiboMethod.WBOPT_POST_FRIENDSHIPS_GROUPS_DESTROY;
        api.setWeiboAction(method, {
                               "access_token":Settings.getAccess_token(),
                               "list_id":idstr
                           });
    }

    Connections {
        target: api
        //void weiboPutSucceed(QWeiboMethod::WeiboAction action, const QString& replyData);
        onWeiboPutSucceed: {
            if (action == WeiboMethod.WBOPT_GET_FRIENDSHIPS_GROUPS) {
                var jsonObj = JSON.parse(replyData);
                listModel.append({"JSON":{
                                         "id": "",
                                         "idstr":"",
                                         "name": ""
                                     }}); //添加一个空列表用于显示所有分组功能
                for (var i=0; i<jsonObj.lists.length; i++) {
                    listModel.append( {"JSON":jsonObj.lists[i] })
                }
                groupItem.fetchFinished();
            }
            if (action == WeiboMethod.WBOPT_POST_FRIENDSHIPS_GROUPS_DESTROY) {
                groupItem.fetchFinished();
                groupItem.fetchGroups();
            }
        }
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
            anchors {
                left:parent.left
                right:parent.right
            }
            height: Math.max(label.height, optionItem.height)

            RemorseItem {id: remorseItem}

            BackgroundItem {
                id: text
                anchors {
                    left: listItem.left
                    leftMargin: Theme.paddingLarge
                    right: optionItem.left
                }
                height: Math.max(label.height, Theme.itemSizeSmall)
                Label {
                    id: label
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    text: model.JSON.name == "" ||  model.JSON.idstr == ""
                          ? qsTr("All Groups")
                          : model.JSON.name
                    color: text.highlighted ? Theme.highlightColor : Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                }
                onClicked: {
                    groupItem.clickItem(model.JSON.idstr, model.JSON.name);
                }
            }

            OptionItem {
                id: optionItem
                anchors {
                    left: optionItem.menuOpen ? listItem.left : undefined
                    right: listItem.right
                    rightMargin: Theme.paddingLarge
                }
                width: optionItem.menuOpen ? Screen.width : image.width

                visible: !(model.JSON.idstr == "" || model.JSON.id == "" || model.JSON.name == "")
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
                                "../graphics/action_collapse.png" :
                                "../graphics/action_open.png"
                }

                menu: ContextMenu {
                    id:options
                    MenuItem {
                        text: qsTr("Delete Group")
                        onClicked: {
                            remorseItem.execute(listItem,"Deleting", function(){
                                                groupItem.deleteGroup(model.JSON.idstr);
                                                listModel.remove(index);})
                        }
                    }
                }
            }
        }
    }
}
