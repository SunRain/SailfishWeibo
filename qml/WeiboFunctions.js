//.pragma library

function cleanup(object, component, incubator) {
    if (component) {
        component.destroy();
        component = null;
    }
    if (incubator) {
        // We can't cancel incubation, so we'll force completion and destroy the
        // object immediately
        incubator.onStatusChanged = undefined;
        if (incubator.status == Component.Loading) {
            incubator.forceCompletion();
        }
        if (incubator.object) {
            incubator.object.destroy();
        }
        incubator = null;
    }
    if (object) {
        object.destroy();
        object = null;
    }
}

function incubate(component, parent, callback) {
    var incubator = component.incubateObject(parent)
    incubator.onStatusChanged = function(status) {
        if (status == Component.Ready) {
            var object = incubator.object;
            incubator = null;
            callback.call(this, object, component, incubator);
        } else if (status == Component.Error) {
            console.log("WeiboFunctions.js: failed to create object from component with url ", component.url)
            incubator = null
            callback.call(this, null, component, null);
        }
    }
}

function create(url, parent, callback) {
    if (!url) {
        callback.call(this, null, null, null);
    } else {
        var component = Qt.createComponent(Qt.resolvedUrl(url), Component.Asynchronous);
        if (component) {
            if (component.status === Component.Ready) {
                incubate(component, parent, callback);
                return;
            } else if (component.status === Component.Loading) {
                component.statusChanged.connect(
                    function(status) {
                        if (component && status == Component.Ready) {
                            incubate(component, parent, callback);
                        }
                    });
                return;
            } else {
                console.log("WeiboFunctions.js: error while creating object from", url)
                if (component.status === Component.Error) {
                    console.log("WeiboFunctions.js: createComponent error: ", component.errorString())
                } else if (component.status === Component.Null) {
                    console.log("WeiboFunctions.js: no data available for component")
                }
            }
             callback.call(this, null, component, null);
        } else {
            console.log("WeiboFunctions.js: unable to create object from ", url)
            callback.call(this, null, null, null);
        }
    }
}

