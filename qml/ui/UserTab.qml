import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import "../js/dateutils.js" as DateUtils
import "../js/weiboapi.js" as WB
import "../components"

Tab {
    id: userTab
    title: i18n.tr("User")

    Component.onCompleted: {
//        userGetInfo(settings.getAccess_token(), settings.getUid())
    }

    function getInfo() {
        pageMe.userGetInfo(settings.getAccess_token())
    }

    page: UserPage {
        id: pageMe

        uid: settings.getUid()
    }
}
