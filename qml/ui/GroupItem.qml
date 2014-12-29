import QtQuick 2.0
import Sailfish.Silica 1.0
import com.sunrain.sinaweibo 1.0

import "../js/Settings.js" as Settings

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
        ListItem {
            id: listItem
            anchors {
                left:parent.left
                right:parent.right
            }
            height: Math.max(label.height, image.height)

            function remove() {
                remorseAction("Deleting", function(){
                    groupItem.deleteGroup(model.JSON.idstr);
                    listModel.remove(index);
                });
            }
            ListView.onRemove: animateRemoval()

            Label {
                id: label
                anchors {
                    left: parent.left
                    leftMargin: Screen.width/5
                    verticalCenter: parent.verticalCenter
                }

                text: model.JSON.name == "" ||  model.JSON.idstr == ""
                      ? qsTr("All Groups")
                      : model.JSON.name
                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
            }
            Image {
                id: image
                anchors {
                    right: parent.right
                    rightMargin: Screen.width/10
                    verticalCenter: parent.verticalCenter
                }
                visible: model.JSON.name != "" &&  model.JSON.idstr != ""
                fillMode: Image.PreserveAspectFit
                width: Theme.iconSizeMedium
                height: image.width
                source: "../graphics/icon-cancel.png"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        listItem.remove();
                    }
                }
            }
            onClicked: {
                groupItem.clickItem(model.JSON.idstr, model.JSON.name);
            }
        }
    }
}
