/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

//-------------------------------------------------------------------------
//-- Message Indicator
/* Item {
    width:          height
    anchors.top:    parent.top
    anchors.bottom: parent.bottom

    property bool showIndicator: true

    property bool _isMessageImportant:    activeVehicle ? !activeVehicle.messageTypeNormal && !activeVehicle.messageTypeNone : false

    function getMessageColor() {
        if (activeVehicle) {
            if (activeVehicle.messageTypeNone)
                return qgcPal.colorGrey
            if (activeVehicle.messageTypeNormal)
                return qgcPal.colorBlue;
            if (activeVehicle.messageTypeWarning)
                return qgcPal.colorOrange;
            if (activeVehicle.messageTypeError)
                return qgcPal.colorRed;
            // Cannot be so make make it obnoxious to show error
            console.log("Invalid vehicle message type")
            return "purple";
        }
        //-- It can only get here when closing (vehicle gone while window active)
        return qgcPal.colorGrey
    }

    Image {
        id:                 criticalMessageIcon
        anchors.fill:       parent
        source:             "/qmlimages/Yield.svg"
        sourceSize.height:  height
        fillMode:           Image.PreserveAspectFit
        cache:              false
        visible:            activeVehicle && activeVehicle.messageCount > 0 && _isMessageImportant
    }

   Row {
        id:             cameraRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        //spacing:        ScreenTools.defaultFontPixelWidth * 0.45
        QGCColoredImage {
            width:              height
            //anchors.fill:       parent
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             "/qmlimages/FHD.svg"
            //sourceSize.height:  height
            //sourceSize.height:  height
            //fillMode:           Image.PreserveAspectFit
            //color:              getMessageColor()
            //visible:            !criticalMessageIcon.visible
        }
        SignalStrength {
            anchors.verticalCenter: parent.verticalCenter
            anchors.top:            parent.top 
            size:                   parent.height * 0.7
            percent:                getGPSSignal()
            anchors.rightMargin:    10
            }
   }
    MouseArea {
        anchors.fill:   parent
        onClicked:      mainWindow.showVehicleMessages()
    }
} */

//-------------- CAMERA SKYDRONES  - (SÓ FUNCIONOU AQUI!)
Item {
    id: _root
    width:          cameraRow.width * 1.1
    anchors.top:    parent.top
    anchors.bottom: parent.bottom

    property bool showIndicator: true

    function getCamSignal() {
        if (!activeVehicle || !activeVehicle.videoManager) {
            // Não há veículo ativo ou o veículo não possui um videoManager
            return 100;
        } else {
            if(activeVehicle._cameraStatus == "disconnected"){
                return 0;
            }
        }
    }

    Component{
        id: cameraInfo

        Rectangle{
            width:  camCol.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: camCol.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window
            border.color:   qgcPal.text

            Column {
                id:                 camCol
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                width:              Math.max(camGrid.width, battLabel.width)
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.centerIn:   parent

                QGCLabel {
                    id:             camLabel
                    text:           qsTr("Camera Status")
                    font.family:    ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                GridLayout {
                    id:                 camGrid
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    columnSpacing:      ScreenTools.defaultFontPixelWidth
                    columns:            2
                    anchors.horizontalCenter: parent.horizontalCenter

                QGCLabel { text: qsTr("Signal Camera:")}
                    QGCLabel { text: activeVehicle ? (activeVehicle._cameraStatus.rawValue + "%") : 0 }
                }
            }
        }
    }


    Row {
        id:             cameraRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        spacing:        ScreenTools.defaultFontPixelWidth * 1

        QGCColoredImage {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            width:              height
            sourceSize.width:   width
            source:             "/qmlimages/FHD.svg"
            fillMode:           Image.PreserveAspectFit
            color:              qgcPal.text
        }
        SignalStrength {
            anchors.verticalCenter:     parent.verticalCenter * 0.5
            anchors.bottom:             parent.bottom 
            anchors.top:                parent.top
            size:                       parent.height * 0.7
            percent:                    getCamSignal()
        }
    }   
    MouseArea {
        anchors.fill:   parent
        onClicked: {
            mainWindow.showPopUp(_root, cameraInfo)
        }
    }
}
