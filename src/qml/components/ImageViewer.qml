import QtQuick 2.0
import Sailfish.Silica 1.0

/*
 * ImageViewer from Jolla Sailfish Gallery Component
 * With some modification
 *
 */

SilicaFlickable {
    id: flickable
    //anchors.centerIn: parent
//    anchors.fill: parent
    property bool menuOpen: false
    property bool enableZoom: !menuOpen
    property bool scaled: false

    property alias source: image.source

    signal clicked()

    property real _fittedScale//: Math.min(width / implicitWidth, height / implicitHeight)
    property real _menuOpenScale //: Math.max(_viewOpenWidth / implicitWidth, _viewOpenHeight / implicitHeight)
    property real _scale

    property int _actualWidth
    property int _actualHeight
    property int _viewOpenWidth:  flickable.width//Screen.width
    property int _viewOpenHeight: flickable.height/2 //Screen.height / 2

//        width: image.width > Screen.width
//               ? Screen.width
//               : ( image.width > image.implicitWidth ? image.width : image.implicitWidth)
//        height: image.height> Screen.height
//               ? Screen.height
//               : ( image.height > image.implicitHeight ? image.height : image.implicitHeight)

    implicitWidth: _actualWidth
    implicitHeight: _actualHeight


    contentWidth: container.width //image.width
    contentHeight: container.height //image.height


    children: ScrollDecorator {}

     interactive: scaled
     // Override SilicaFlickable's pressDelay because otherwise it will
     // block touch events going to PinchArea in certain cases.
     pressDelay: 0

     function _updateScale() {
         if (image.status != Image.Ready) {
             return
         }
         state = menuOpen ? "menuOpen" : "fullscreen"
     }

    function _resetScale() {
        if (scaled) {
            _scale = _fittedScale
            scaled = false
        }
    }

    function _scaleImage(scale, center, prevCenter) {

        console.log("==== _scaleImage " + scale + " " + center + " " + prevCenter );

        var newWidth
        var newHeight
        var oldWidth = image.width//contentWidth
        var oldHeight = image.height//contentHeight

        console.log("==== oldWidth " + oldWidth + " oldHeight " + oldHeight  );

        // move center
        contentX += prevCenter.x - center.x
        contentY += prevCenter.y - center.y

        console.log("==== contentX " + contentX + " contentY " + contentY  );


        //            if (fit == Fit.Width) {
        // Scale and bounds check the width, and then apply the same scale to height.
        newWidth = image.width * scale

        console.log("==== newWidth " + newWidth  );

        if (newWidth <= _fittedScale * flickable.implicitWidth) {
            console.log(" ===  _reset to Scale() ");
            _resetScale()
            return
        } else {
            newWidth = /*Math.min*/Math.max(newWidth, flickable._actualWidth)
            _scale = newWidth / flickable.implicitWidth
            newHeight = Math.max(image.height, Screen.height)

            console.log("==== newWidth " + newWidth + " newHeight " + newHeight  );
        }

        // scale about center
        if (newWidth > flickable.width)
            contentX -= (oldWidth - newWidth)/(oldWidth/prevCenter.x)
        if (newHeight > flickable.height)
            contentY -= (oldHeight - newHeight)/(oldHeight/prevCenter.y)

        scaled = true;
    }

    PinchArea {
        id: container
        //anchors.fill: parent
        //pinch.maximumScale: 20;
        // pinch.minimumScale: 0.2;
        // pinch.minimumRotation: 0;
        //pinch.maximumRotation: 90;
        enabled: !flickable.menuOpen && flickable.enableZoom && image.status == Image.Ready
        width: Math.max(flickable.width, image.width)
        height: Math.max(flickable.height, image.height)

        onPinchStarted: {
            //pinch.accepted = true;
            console.log("===== onPinchStarted");
        }
        onPinchUpdated: {
            console.log("===== onPinchUpdated pinch.scale " + pinch.scale+" pinch.previousScale " + pinch.previousScale);
            //transformRect.scale *= pinch.scale;
            //transformRect.rotation += pinch.rotation;
             flickable._scaleImage(1.0 + pinch.scale - pinch.previousScale, pinch.center, pinch.previousCenter)
        }
        onPinchFinished: {
            console.log("===== onPinchFinished");
            //transformRect.scale *= pinch.scale;
            //transformRect.rotation += pinch.rotation;
            flickable.returnToBounds();
        }


        Image {
            id: image
            anchors.centerIn: parent
            horizontalAlignment: Image.Left
            verticalAlignment: Image.Top
            width: Math.ceil(flickable._actualWidth * flickable._scale)
            height: Math.ceil(flickable._actualHeight * flickable._scale)
            fillMode: Image.PreserveAspectFit
            //sourceSize.height: implicitHeight
            //sourceSize.width: implicitWidth>Screen.width ? Screen.width : implicitWidth

            //asynchronous for LOCAL filesystem, http are always loaded asynchonously.
            //anyway, we set this
            asynchronous: true

            opacity: status == Image.Ready ? 1 : 0
            Behavior on opacity { FadeAnimation{} }

            onStatusChanged: {
                if (image.status == Image.Ready) {
                    //runningBusyIndicator = false;
                    flickable._actualWidth = image.implicitWidth//image.width
                    flickable._actualHeight = image.implicitHeight//image.height
                    console.log("===== flickable.width  " + flickable.width
                                + " flickable.implicitWidth " + flickable.implicitWidth
                                + " flickable.height " + flickable.height
                                + " flickable.implicitHeight " + flickable.implicitHeight)

                    flickable._fittedScale = Math.min(flickable.width / flickable.implicitWidth, flickable.height / flickable.implicitHeight)
                    flickable._menuOpenScale = Math.max(flickable._viewOpenWidth / flickable.implicitWidth, flickable._viewOpenHeight / flickable.implicitHeight)
                    //flickable._resetScale();
                     flickable._scale = flickable._fittedScale

                    console.log(" === onCompleted width is " + image.width + " height is " + image.height);

                    console.log("==== Image.Ready _actualWidth " + flickable._actualWidth
                                + " _actualHeight " + flickable._actualHeight
                                + " _scale " + flickable._scale);

                }
            }
            onSourceChanged: {
                console.log("===== SourceChange to " + image.source);
                flickable.scaled = false
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: !flickable.scaled
            onCanceled: {
                flickable.clicked()
            }
        }
    }

    states: [
            State {
                name: "menuOpen"
                when: flickable.menuOpen && photo.status === Image.Ready
                PropertyChanges {
                    target: flickable
                    _scale: flickable._menuOpenScale
                    scaled: false
                    contentX: (flickable.implicitWidth  * flickable._menuOpenScale - flickable._viewOpenWidth ) / 2
                    contentY:  0
                }
            },
            State {
                name: "fullscreen"
                PropertyChanges {
                    target: flickable
                    // 1.0 for smaller images. _fittedScale for images which are larger than view
                    _scale: flickable._fittedScale //flickable._fittedScale >= 1 ? 1.0 : flickable._fittedScale
                    scaled: false
                    contentX: 0
                    contentY: 0
                }
            }
        ]

    transitions: [
            Transition {
                from: '*'
                to: 'menuOpen'
                PropertyAnimation {
                    target: flickable
                    properties: "_scale,contentX,contentY"
                    duration: 300
                    easing.type: Easing.InOutCubic
                }
            },
            Transition {
                from: 'menuOpen'
                to: '*'
                PropertyAnimation {
                    target: flickable
                    properties: "_scale,contentX,contentY"
                    duration: 300
                    easing.type: Easing.InOutCubic
                }
            }
        ]

}
