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
//-- Battery Indicator
Item {
    id:             _root
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          batteryIndicatorRow.width

    property bool showIndicator: true

    function getBatteryColor() {
        if(activeVehicle) {
            if(activeVehicle.battery.percentRemaining.value > 75) {
                return qgcPal.text
            }
            if(activeVehicle.battery.percentRemaining.value > 50) {
                return qgcPal.colorOrange
            }
            if(activeVehicle.battery.percentRemaining.value > 0.1) {
                return qgcPal.colorRed
            }
        }
        return qgcPal.colorGrey
    }

    function getBatteryPercentageText() {
        if(activeVehicle) {
            if(activeVehicle.battery.percentRemaining.value > 98.9) {
                return "100%"
            }
            if(activeVehicle.battery.percentRemaining.value > 0.1) {
                return activeVehicle.battery.percentRemaining.valueString + activeVehicle.battery.percentRemaining.units
            }
            if(activeVehicle.battery.voltage.value >= 0) {
                return activeVehicle.battery.voltage.valueString + activeVehicle.battery.voltage.units
            }
        }
        return "N/A"
    }
    //--------------Bateria em barras ----SkyDrones
    function getBatteryPercentageImage() {
        if (activeVehicle) {
            if (activeVehicle.battery.percentRemaining.value > 90.9) {
                return "/qmlimages/Battery100.svg";
            } else if (activeVehicle.battery.percentRemaining.value > 69.9) {
                return "/qmlimages/Battery75.svg";
            } else if (activeVehicle.battery.percentRemaining.value > 39.9) {
                return "/qmlimages/Battery50.svg";
            } else if (activeVehicle.battery.percentRemaining.value > 10.9) {
                return "/qmlimages/Battery25.svg";
            } else {
                return "/qmlimages/Battery0.svg";
            }
        }
        return "N/A";
    }




    
    Component {
        id: batteryInfo

        Rectangle {
            width:  battCol.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: battCol.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window
            border.color:   qgcPal.text

            Column {
                id:                 battCol
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                width:              Math.max(battGrid.width, battLabel.width)
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.centerIn:   parent

                QGCLabel {
                    id:             battLabel
                    text:           qsTr("Status da Bateria")
                    font.family:    ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                GridLayout {
                    id:                 battGrid
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    columnSpacing:      ScreenTools.defaultFontPixelWidth
                    columns:            2
                    anchors.horizontalCenter: parent.horizontalCenter

                    QGCLabel { text: qsTr("Voltage,:") }
                    QGCLabel { 
                        text: (activeVehicle && activeVehicle.battery.voltage.value !== -1) ? (activeVehicle.battery.voltage.valueString + " " + activeVehicle.battery.voltage.units) : "N/A" 
                        color: activeVehicle && activeVehicle.battery.voltage.value > 40.9 ? qgcPal.buttonText : "red"
                        }
                    QGCLabel { text: qsTr("Consumo Acumulado:") }
                    QGCLabel { text: (activeVehicle && activeVehicle.battery.mahConsumed.value !== -1) ? (activeVehicle.battery.mahConsumed.valueString + " " + activeVehicle.battery.mahConsumed.units) : "N/A" }
                }
            }
        }
    }

    Row {
        id:             batteryIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        opacity:        (activeVehicle && activeVehicle.battery.voltage.value >= 0) ? 1 : 0.5
        QGCColoredImage {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            width:              height
            sourceSize.width:   width
            //source:             "/qmlimages/Battery100.svg"
            source:             getBatteryPercentageImage()//"/qmlimages/Battery.svg"
            fillMode:           Image.PreserveAspectFit
            color:              qgcPal.text
        }
       /*  QGCColoredImage {
            source:             getBatteryIcon()
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            width:              height
            sourceSize.width:   width
            fillMode:           Image.PreserveAspectFit
            //anchors.fill:       parent
            //color:              qgcPal.buttonText
           // sourceSize.height:  size
        } */
        QGCLabel {
            text:                   getBatteryPercentageText()
            font.pointSize:         ScreenTools.mediumFontPointSize * 1
            //color:                  getBatteryColor()
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    MouseArea {
        anchors.fill:   parent
        onClicked: {
            mainWindow.showPopUp(_root, batteryInfo)
        }
    }
}
