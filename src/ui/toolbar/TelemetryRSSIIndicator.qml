/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.11
import QtQuick.Layouts  1.11

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

//-------------------------------------------------------------------------
//-- Telemetry RSSI
/* Item {
    id:             _root
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          telemIcon.width * 1.1

    property bool showIndicator: _hasTelemetry

    property var  _activeVehicle:   QGroundControl.multiVehicleManager.activeVehicle
    property bool _hasTelemetry:    _activeVehicle ? _activeVehicle.telemetryLRSSI !== 0 : false
    property bool   _rcRSSIAvailable:   activeVehicle ? activeVehicle.rcRSSI > 0 && activeVehicle.rcRSSI <= 100 : false
    

    Component {
        id: telemRSSIInfo
        Rectangle {
            width:  telemCol.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: telemCol.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window
            border.color:   qgcPal.text
            Column {
                id:                 telemCol
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                width:              Math.max(telemGrid.width, telemLabel.width)
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.centerIn:   parent
                QGCLabel {
                    id:             telemLabel
                    text:           qsTr("Telemetry RSSI Status")
                    font.family:    ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                GridLayout {
                    id:                 telemGrid
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    columnSpacing:      ScreenTools.defaultFontPixelWidth
                    columns:            2
                    anchors.horizontalCenter: parent.horizontalCenter
                    QGCLabel { text: qsTr("Local RSSI:") }
                    QGCLabel { text: activeVehicle.telemetryLRSSI + " dBm"}
                    QGCLabel { text: qsTr("Remote RSSI:") }
                    QGCLabel { text: activeVehicle.telemetryRRSSI + " dBm"}
                    QGCLabel { text: qsTr("RX Errors:") }
                    QGCLabel { text: activeVehicle.telemetryRXErrors }
                    QGCLabel { text: qsTr("Errors Fixed:") }
                    QGCLabel { text: activeVehicle.telemetryFixed }
                    QGCLabel { text: qsTr("TX Buffer:") }
                    QGCLabel { text: activeVehicle.telemetryTXBuffer }
                    QGCLabel { text: qsTr("Local Noise:") }
                    QGCLabel { text: activeVehicle.telemetryLNoise }
                    QGCLabel { text: qsTr("Remote Noise:") }
                    QGCLabel { text: activeVehicle.telemetryRNoise }
                    QGCLabel { text: qsTr("RSSI:") }
                    QGCLabel { text: activeVehicle ? (activeVehicle.rcRSSI + "%") : 0 }
                }
            }
        }
    }
    Row {
        id:             telerOW
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        QGCColoredImage {
        id:                 telemIcon
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        width:              height
        sourceSize.height:  height
        source:             "/qmlimages/ControlIcon.svg"
        fillMode:           Image.PreserveAspectFit
        color:              qgcPal.buttonText
        }
        QGCLabel {
                text: activeVehicle ? (activeVehicle.rcRSSI + "%") : 0
                font.pointSize:         ScreenTools.mediumFontPointSize
                anchors.verticalCenter: parent.verticalCenter
            }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            mainWindow.showPopUp(_root, telemRSSIInfo)
        }
    }
} */
Item {
    id:             _root
    width:          joystickRow.width * 1.1
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    //visible:        activeVehicle ? activeVehicle.sub : false

    property bool showIndicator: true
    property bool   _rcRSSIAvailable:   activeVehicle ? activeVehicle.rcRSSI > 0 && activeVehicle.rcRSSI <= 100 : false

    function getControlPercent()
    {   
        if(activeVehicle) {
            if(joystickManager.activeJoystick) {
                return "100%"
            }
            if(activeVehicle.joystickEnabled) {
                return "0"
            }
        }
        return "N/A"
    }
    Component {
        id: joystickInfo

        Rectangle {
            width:  joystickCol.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: joystickCol.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window
            border.color:   qgcPal.text

            Column {
                id:                 joystickCol
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                width:              Math.max(joystickGrid.width, joystickLabel.width)
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.centerIn:   parent

                QGCLabel {
                    id:             joystickLabel
                    text:           qsTr("Status do Controle")
                    font.family:    ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                GridLayout {
                    id:                 joystickGrid
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    columnSpacing:      ScreenTools.defaultFontPixelWidth
                    columns:            2
                    anchors.horizontalCenter: parent.horizontalCenter

                    QGCLabel { text: qsTr("Conectado:") }
                    QGCLabel {
                        text:  joystickManager.activeJoystick ? "Yes" : "No"
                        color: joystickManager.activeJoystick ? qgcPal.buttonText : "red"
                    }
                    QGCLabel { text: qsTr("Habilitado:") }
                    QGCLabel {
                        text:  activeVehicle && activeVehicle.joystickEnabled ? "Yes" : "No"
                        color: activeVehicle && activeVehicle.joystickEnabled ? qgcPal.buttonText : "red"
                    }
                }
            }
        }
    }

    Row {
        id:             joystickRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        spacing:        ScreenTools.defaultFontPixelWidth

        QGCColoredImage {
            width:              height
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            sourceSize.height:  height
            source:             "/qmlimages/ControlIcon.svg"
            fillMode:           Image.PreserveAspectFit
            //color:              activeVehicle && activeVehicle.joystickEnabled && joystickManager.activeJoystick ? qgcPal.buttonText : "red"
        }
        QGCLabel {
                text:                   getControlPercent()
                font.pointSize:         ScreenTools.mediumFontPointSize
                anchors.verticalCenter: parent.verticalCenter
                //color:                  activeVehicle && activeVehicle.joystickEnabled && joystickManager.activeJoystick ? qgcPal.buttonText : "red"
            }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked: {
            mainWindow.showPopUp(_root, joystickInfo)
        }
    }
}

