import QtQuick 2.0
import U1db 1.0 as U1db

Item {
    id: settings

    function getAccess_token() {
        return settingsDocument.contents.access_token
    }

    function setAccess_token(value) {
        var cont = settingsDocument.contents
        cont.access_token = value
        settingsDocument.contents = cont
    }

    function getUid() {
        return settingsDocument.contents.uid
    }

    function setUid(value) {
        var cont = settingsDocument.contents
        cont.uid = value
        settingsDocument.contents = cont
    }

    function useListMode() {
        return settingsDocument.contents.useListMode
    }

    function setUseListMode(value) {
        var cont = settingsDocument.contents
        cont.useListMode = value
        settingsDocument.contents = cont
        useListModeChanged(value)
    }

    function dbVersion() {
        return settingsDocument.contents.dbVersion
    }

    function setDbVersion(value) {
        var cont = settingsDocument.contents
        cont.dbVersion = value
        settingsDocument.contents = cont
    }

    function dbLastUpdate() {
        return settingsDocument.contents.dbLastUpdate
    }

    function setDbLastUpdate(value) {
        var cont = settingsDocument.contents
        cont.setDbLastUpdate = value
        settingsDocument.contents = cont
    }

    U1db.Database {
        id: settingsDataBase
        path: "WeiboSettings"
    }

    U1db.Document {
        id: settingsDocument
        database: settingsDataBase
        docId: 'settingsDocument'
        create: true
        defaults: { "access_token" : "", "uid" : "" }
    }
}
