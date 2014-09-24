

.import "LocalStore.js" as LocalStore


/*ar keys = {
    SOUND: "sound",
    DIGITAL_ZOOM: "digital_zoom",
    SCAN_DURATION: "scan_duration",
    RESULT_VIEW_DURATION: "result_view_duration",
    MARKER_COLOR: "marker_color"
}

var dBValues = {
    B_TRUE: "true",
    B_FALSE: "false"
}*/

function get(key) {
    return LocalStore.get(key);
}

function getBoolean(key) {
    return LocalStore.get(key) === dBValues.B_TRUE;
}

function set(key, value) {
    LocalStore.set(key, value);
}

function setBoolean(key, value) {
    var booleanStr = value ? dBValues.B_TRUE : dBValues.B_FALSE;
    LocalStore.set(key, booleanStr);
}

/**
 * Should be invoked after application start.
 */
function initialize() {
    var defaultValues = {
        /*sound: dBValues.B_FALSE,
        digital_zoom: 3,
        scan_duration: 20,
        result_view_duration: 2,
        marker_color: "#00FF00"*/
        
        access_token : "", 
        uid : "",
        useListMode: "true"
    }

    LocalStore.initializeDatabase(defaultValues);
}


function getAccess_token() {
    return get("access_token");//settingsDocument.contents.access_token
}

function setAccess_token(value) {
    //var cont = settingsDocument.contents
    //cont.access_token = value
    //settingsDocument.contents = contset
    set("access_token", value);
}

function getUid() {
    return get("uid");//settingsDocument.contents.uid
}

function setUid(value) {
    //var cont = settingsDocument.contents
    //cont.uid = value
    //settingsDocument.contents = cont
    set("uid", value);
}

function useListMode() {
    return get("useListMode");//settingsDocument.contents.useListMode
}

function setUseListMode(value) {
    //var cont = settingsDocument.contents
    //cont.useListMode = value
    //settingsDocument.contents = cont
    //useListModeChanged(value)
    set("useListMode", value);
}

/*function dbVersion() {
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
}*/

/*
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
*/
