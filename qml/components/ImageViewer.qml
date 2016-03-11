import QtQuick 2.0
import Sailfish.Silica 1.0

PinchArea {
    id: pinchArea
    width: parent ? parent.width : Screen.width
    height: parent ? parent.height : Screen.height

    property alias source: imageWrapper._source
    onSourceChanged: {
        if (_errorLabel)
            _errorLabel.destroy();
    }

    property var _errorLabel
    property real _fittedScale: 1.0
    property real _scale
    property bool _scaling: false

    signal loadingStatus(var status)

    pinch.minimumScale: _fittedScale

    function _updateFittedScale(width, height) {
        var scale = 1;
        if (height/width > 5) { // for long weibo images
            if (width > pinchArea.width)
                scale = pinchArea.width / width
            if (scale > 0.5)
                scale = 0.3
        } else {
            scale = Math.min(pinchArea.width/width, pinchArea.height/height)
        }
        if (scale > 1)
            scale = 1;
        _fittedScale = scale;
        _scale = _fittedScale;
        imageWrapper.initialWidth = width
        imageWrapper.initialHeight = height;
    }

    onPinchStarted: {
        _scaling = true;
    }
    onPinchUpdated: {
        pinchArea._scale = (pinch.scale - pinch.previousScale + 1) * pinchArea._scale;
    }
    onPinchFinished: {
        if (pinchArea._scale < _fittedScale)
            _scale = _fittedScale;
        _scaling = false;
    }

    Component {
        id: errorLabelComponent
        Label {
            id: errorLabel
            text: qsTr("Oops, can't display the image")
            width: parent.width
            anchors.centerIn: parent - Theme.paddingMedium*2
            font.pixelSize: Theme.fontSizeMedium
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            color: Theme.secondaryColor
        }
    }

    Flickable {
        id: flickable
        width: parent.width > imageWrapper.width ? imageWrapper.width : parent.width
        height: parent.height > imageWrapper.height ? imageWrapper.height : parent.height
        x: parent.width > imageWrapper.width ? (parent.width - imageWrapper.width)/2 : 0
        y: parent.height > imageWrapper.height ? (parent.height - imageWrapper.height)/2 : 0

        property bool flickRestrict: width > contentWidth || height > contentHeight
        contentWidth: imageWrapper.width
        contentHeight: imageWrapper.height
        contentX: (contentWidth - flickable.width)/2
        contentY: (contentHeight - flickable.height)/2

        clip: true
        interactive: !_scaling
        flickableDirection: flickRestrict
                            ? width >= contentWidth && height < contentHeight
                              ? Flickable.VerticalFlick
                              : (width < contentWidth && height >= contentHeight
                                 ? Flickable.HorizontalFlick
                                 : Flickable.HorizontalAndVerticalFlick
                                )
                            : Flickable.AutoFlickDirection

        Item {
            id: imageWrapper
            width: initialWidth * _scale
            height: initialHeight *_scale

            property var _source
            property real initialWidth: 0.0
            property real initialHeight: 0.0

            on_SourceChanged: {
                loader.sourceComponent = loader.Null
                var tmp = _source + "";
                if (tmp.substr(-4,4) == ".gif") {
                    loader.sourceComponent = aiComponent;
                } else {
                    loader.sourceComponent = photoComponent
                }
            }

            Loader {
                id: loader
                anchors.fill: parent
            }
            Component {
                id: aiComponent
                AnimatedImage {
                    id: aImage
                    anchors.fill: parent
                    asynchronous: true
                    cache: true
                    source: imageWrapper._source
                    fillMode: Image.PreserveAspectFit
                    onStatusChanged: {
                        loadingStatus(status)
                        if (status == Image.Ready) {
                            _updateFittedScale(aImage.implicitWidth, aImage.implicitHeight);
                        }
                        if (status == Image.Error) {
                            errorLabel = errorLabelComponent.createObject(pinchArea)
                        }
                    }
                }
            }
            Component {
                id: photoComponent
                Image {
                    id: photo
                    anchors.fill: parent
                    asynchronous: true
                    cache: true
                    source: imageWrapper._source
                    fillMode: Image.PreserveAspectFit
                    onStatusChanged: {
                        loadingStatus(status)
                        if (status == Image.Ready) {
                            _updateFittedScale(photo.implicitWidth, photo.implicitHeight);
                        }
                        if (status == Image.Error) {
                            errorLabel = errorLabelComponent.createObject(pinchArea)
                        }
                    }
                }
            }
        }
    }
}

