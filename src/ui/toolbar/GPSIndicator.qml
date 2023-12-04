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
//-- GPS Indicator ----------------------- SKYDRONES EDIT
Item {
    id:                     _root
    width:                  gpsRow.width
    anchors.top:            parent.top
    anchors.bottom:         parent.bottom

    function getGPSSignal() {
        if(!activeVehicle || activeVehicle.gps.count.rawValue < 1 || activeVehicle.gps.hdop.rawValue > 1.4) {
            return 0;

        } else if(activeVehicle.gps.hdop.rawValue < 1.0) {
            return 100;
        } else if(activeVehicle.gps.hdop.rawValue < 1.1) {
            return 75;
        } else if(activeVehicle.gps.hdop.rawValue < 1.2) {
            return 50;
        } else {
            return 25;
        }
    }
    //-------------------------Skydrones
    function getGPSLock(){
        if(!activeVehicle || activeVehicle.gps.lock.enumIndex <=2){
            return false;
        }else if(activeVehicle.gps.lock.enumIndex >2 && activeVehicle.gps.lock.enumIndex <7) {
            return true;
        }
    }

    function getGPSCount(){
    if(!activeVehicle){
        return "-";
        }else {
        return activeVehicle.gps.count.valueString;

    }
    }

    // Window info
    Component {
        id: gpsInfo

        Rectangle {
            width:  gpsCol.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: gpsCol.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window
            border.color:   qgcPal.text
            Column {
                id:                 gpsCol
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                width:              Math.max(gpsGrid.width, gpsLabel.width)
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.centerIn:   parent

                QGCLabel {
                    id:             gpsLabel
                    text:           (activeVehicle && activeVehicle.gps.count.value >= 0) ? qsTr("Status do GPS") : qsTr("Dados GPS inválidos")
                    font.family:    ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                GridLayout {
                    id:                 gpsGrid
                    visible:            (activeVehicle && activeVehicle.gps.count.value >= 0)
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    columnSpacing:      ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    columns: 2

                    QGCLabel { text: qsTr("Sátelites GPS:") }
                    QGCLabel { text: activeVehicle ? activeVehicle.gps.count.valueString : qsTr("N/A", "No data to display") }
                    QGCLabel { text: qsTr("Tranca GPS:") }
                    QGCLabel { text: activeVehicle ? activeVehicle.gps.lock.enumStringValue : qsTr("N/A", "No data to display") }
                    QGCLabel { text: qsTr("Sinal do  GPS:")}
                    QGCLabel { text: activeVehicle ? (activeVehicle.gps.hdop.rawValue + "%") : 0 }
                    QGCLabel { text: qsTr("HDOP:") }
                    QGCLabel { text: activeVehicle ? activeVehicle.gps.hdop.valueString : qsTr("--.--", "No data to display") }
                    QGCLabel { text: qsTr("VDOP:") }
                    QGCLabel { text: activeVehicle ? activeVehicle.gps.vdop.valueString : qsTr("--.--", "No data to display") }
                    QGCLabel { text: qsTr("Curso sobre o solo:") }
                    QGCLabel { text: activeVehicle ? activeVehicle.gps.courseOverGround.valueString : qsTr("--.--", "No data to display") }
                }
            }
        }
    }

    Row {
        id:             gpsRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        anchors.left:     parent.left
        spacing:        ScreenTools.defaultFontPixelWidth * 0.25
        QGCColoredImage {
            width:              height
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            sourceSize.height:  height
            source:             "/qmlimages/GpsNew.svg"
            //color:              getGPSLock() ? qgcPal.colorGreen:qgcPal.warningText
            fillMode:           Image.PreserveAspectFit
            opacity:            1//getGPSSignal() > 0 ? 1 : 0.5
        }
        QGCLabel {
            text:                   getGPSCount()
            font.pointSize:         ScreenTools.mediumFontPointSize
            //color:                  getGPSLock() ? qgcPal.colorGreen:qgcPal.warningText
            anchors.top:            parent.top
            }
            /* QGCLabel {
            id:                   getGpsIcon()
            font.pointSie:          ScreenTools.mediumFontSize
            anchors.top:            parent.top 
         } */
        SignalStrength {
            anchors.verticalCenter: parent.verticalCenter
            anchors.top:            parent.top 
            size:                   parent.height * 0.7
            percent:                getGPSSignal()
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked: {
            mainWindow.showPopUp(_root, gpsInfo)
        }
    }
}

