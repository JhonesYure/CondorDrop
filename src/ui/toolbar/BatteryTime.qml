/**
 * 
 * (c) 2023 - SkyDrones Tecnologia Aviônica <https://skydrones.com.br/>
 * 
 * ---------------------------------------- */


import QtQuick                              2.11
import QtQuick.Controls                     1.4
import QtQuick.Layouts                      1.11

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.FactControls          1.0
import QGroundControl.Battery               1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.FactControls          1.0

Item {

    FactPanelController {
        id:                 controller
    }

    id:                     _Battery
    property var            battery1:           activeVehicle ? activeVehicle.battery  : null
    property var            battery2:           activeVehicle ? activeVehicle.battery2 : null
    property bool           hasSecondBattery:   battery2 && battery2.voltage.value !== -1
    property bool           batt1ParamsAvailable
    property bool           batt2ParamsAvailable
    property Fact           battCapacity

    Connections{
        target: QGroundControl.multiVehicleManager.activeVehicle
        onConnectionLostChanged: {

        }
        onActiveChanged : {

        }
    }

    function secondsToHHMMSS(times) {
        var sec_num = parseInt(timeS, 10);
        var hours   = Math.floor(sec_num / 3600);
        var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
        var seconds = sec_num - (hours * 3600) - (minutes * 60);
        if (hours   < 10) {hours   = "0"+hours;}
        if (minutes < 10) {minutes = "0"+minutes;}
        if (seconds < 10) {seconds = "0"+seconds;}
        return hours+":"+ minutes+':'+seconds;
    }
    
    //------------------------BATTERY COLOR ---------------------
    function getBatteryColor(battery) {
        if(battery &&  !Battery.showFeatures) {
                var _temp=qgcPal.colorGrey
                if(battery.percentRemaining.value >= 70) {
                    _temp= qgcPal.colorGreen
                }
                if(battery.percentRemaining.value < 70 && battery.percentRemaining.value > 30) {
                    _temp= qgcPal.colorOrange
                }
                if(battery.percentRemaining.value <=30) {
                    _temp= qgcPal.colorRed
                }
            }else{
                if(battery && Battery.showFeatures) {
                    Battery.batt=battery
                    if(Battery.levelEstimate >= 70) {
                        _temp=qgcPal.colorGreen
                    }
                    if(Battery.levelEstimate < 70 && Battery.levelEstimate > 30) {
                        _temp=qgcPal.colorOrange
                    }
                    if(Battery.levelEstimate <=30) {
                        _temp= qgcPal.colorRed
                    }
                }


            }
            return _temp;
    }

    //----------- BATTERY PERCENT ----------------

    function barLen(battery){
        var _percent=10;
        if (battery.voltage.value>0 && !Battery.showFeatures){
            _percent=battery.percentRemaining.value * (mainWindow.width/100);
        }else{

            if (battery.voltage.value>0 && Battery.showFeatures){
                Battery.batt=battery
                _percent=Battery.levelEstimate * (mainWindow.width/70);

            }
        }
        if (_communicationLost){
            _percent=0
        }

        return _percent;
    }

    //------------- BATTERY TIME ESTIMATE ----------

    function getTimeEstimate(battery){
        var time

        if (battery.percentRemaining.value >0.1 && Battery.showFeatures ){
            time=Battery.timeEstimate
            if (time!== -1){
                return secondsToHHMMSS(time)
            }
        }
        if (battery.percentRemaining.value >0.1 && !Battery.showFeatures ){
                return battery.percentRemaining.value + "%"
        }
        return "--/--"
    }

    //--------------BATTERY CAPACITY 

    function getBatteryCapacity(){

          batt1ParamsAvailable= controller.parameterExists(-1, "BATT_CAPACITY")
          if (batt1ParamsAvailable){
              battCapacity= controller.getParameterFact(-1, "BATT_CAPACITY", false /* reportMissing */)
          }

          if (battCapacity.value>0){ Battery.cellCapacity=battCapacity.value }
    }

    Rectangle {
            id: bar
            anchors.top:parent
            width: barLen(activeVehicle ? activeVehicle.battery : null)
            height: 10
            color: getBatteryColor(activeVehicle ? activeVehicle.battery : null)
            border.color: "black"
            border.width: 1
            radius: 1
            visible: true
            //-----------skydrones
            anchors.topMargin: 4
            //anchors.top: parent.top 
            //anchors.right: parent.right 
            //anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                color: qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1,1,1,0.95) : Qt.rgba(0,0,0,0.6)
                width:                  time.width
                height:                 time.height
                radius: 5
                anchors.right: bar.right
                anchors.rightMargin: 0
                anchors.top: bar.bottom
                anchors.topMargin: 0

                QGCLabel {
                    id: time
                    text:getTimeEstimate(activeVehicle ? activeVehicle.battery : null)
                    font.pointSize:         ScreenTools.mediumFontPointSize
                }

        }
}
