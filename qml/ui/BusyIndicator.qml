import QtQuick 2.0
import Sailfish.Silica 1.0

Component {
    id:busyIndicator
    
    property int running: 0
    
    SilicaFlickable{
        anchors.fill: parent
        
        BusyIndicator{
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
            running: runningBusyIndicator != 0
            opacity: runningBusyIndicator != 0 ? 1: 0
        }  
    }
}
