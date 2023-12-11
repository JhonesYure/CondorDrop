/*--------------
----------------------------------------------------
--------- A create SKYDRONES BR ----------------
--------------------------- */

import QtQuick          2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts  1.11
import QtQuick.Dialogs  1.3

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.Palette               1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Controllers           1.0

//------------------- 
//--- Notification Indicator 
Item {
    id:         notificationIndicator
    y:          10
    visible:    true

    Text {
        id: textIndicator
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        font.pointSize: 15
        font.bold: true
        color: "white"

        // Vincule o texto à propriedade 'activeVehicle' para exibir "CONECTADO" ou "DESCONECTADO"
        text: activeVehicle ? "DESCONECTADO" : "CONECTADO"
    }

    // Substitua isso pelo objeto que contém a propriedade 'activeVehicle'
    property bool activeVehicle: false

    Component.onCompleted: {
        yourObject.activeVehicleChanged.connect(function() {
            textIndicator.text = yourObject.activeVehicle ? "DESCONECTADO" : "DISPARO EFETUADO COM SUCESSO";
        });
    }
}




