/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                  2.11
import QtQuick.Controls         2.4
import QtQuick.Dialogs          1.3
import QtQuick.Layouts          1.11
import QtQuick.Controls.Styles  1.4

import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Window           2.2
import QtQml.Models             2.1

import QGroundControl               1.0
import QGroundControl.Airspace      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.FlightMap     1.0


/// Flight Display View
Item {

    PlanMasterController {
        id: _planController
        Component.onCompleted: {
            start(true /* flyView */)
            mainWindow.planMasterControllerView = _planController
        }
    }
    FactPanelController { id: controller; }
    //FactPanelController { id: controller; factPanel: safetyPage.viewPanel }

    property alias  guidedController:              guidedActionsController
    property bool   activeVehicleJoystickEnabled:  activeVehicle ? activeVehicle.joystickEnabled : true
    property bool   mainIsMap:                     QGroundControl.videoManager.hasVideo ? QGroundControl.loadBoolGlobalSetting(_mainIsMapKey,  true) : true
    property bool   isBackgroundDark:              mainIsMap ? (mainWindow.flightDisplayMap ? mainWindow.flightDisplayMap.isSatelliteMap : true) : true

    property var    _missionController:             _planController.missionController
    property var    _geoFenceController:            _planController.geoFenceController
    property var    _rallyPointController:          _planController.rallyPointController
    property bool   _isPipVisible:                  QGroundControl.videoManager.hasVideo ? QGroundControl.loadBoolGlobalSetting(_PIPVisibleKey, true) : false
    property bool   _useChecklist:                  QGroundControl.settingsManager.appSettings.useChecklist.rawValue && QGroundControl.corePlugin.options.preFlightChecklistUrl.toString().length
    property bool   _enforceChecklist:              _useChecklist && QGroundControl.settingsManager.appSettings.enforceChecklist.rawValue
    property bool   _checklistComplete:             activeVehicle && (activeVehicle.checkListState === Vehicle.CheckListPassed)
    property real   _margins:                       ScreenTools.defaultFontPixelWidth / 2
    property real   _pipSize:                       mainWindow.width * 0.2
    property alias  _guidedController:              guidedActionsController
    property alias  _altitudeSlider:                altitudeSlider
    property real   _toolsMargin:                   ScreenTools.defaultFontPixelWidth * 0.75

    property real   _innerRadius:       (width - (_topBottomMargin * 3)) / 4
    property real   _outerRadius:       _innerRadius + _topBottomMargin
    property real   _defaultSize:       ScreenTools.defaultFontPixelHeight * (9)
    property real   _sizeRatio:         ScreenTools.isTinyScreen ? (width / _defaultSize) * 0.5 : width / _defaultSize
    property real   _bigFontSize:       ScreenTools.defaultFontPointSize * 2.5  * _sizeRatio
    property real   _normalFontSize:    ScreenTools.defaultFontPointSize * 1.5  * _sizeRatio
    property real   _labelFontSize:     ScreenTools.defaultFontPointSize * 0.75 * _sizeRatio
    property real   _spacing:           ScreenTools.defaultFontPixelHeight * 0.33
    property real   _topBottomMargin:   (width * 0.05) / 2
    property real   _availableValueHeight: maxHeight - (root.height + _valuesItem.anchors.topMargin)

    readonly property var       _dynamicCameras:        activeVehicle ? activeVehicle.dynamicCameras : null
    readonly property bool      _isCamera:              _dynamicCameras ? _dynamicCameras.cameras.count > 0 : false
    readonly property real      _defaultRoll:           0
    readonly property real      _defaultPitch:          0
    readonly property real      _defaultHeading:        0
    readonly property real      _defaultAltitudeAMSL:   0
    readonly property real      _defaultGroundSpeed:    0
    readonly property real      _defaultAirSpeed:       0
    readonly property string    _mapName:               "FlightDisplayView"
    readonly property string    _showMapBackgroundKey:  "/showMapBackground"
    readonly property string    _mainIsMapKey:          "MainFlyWindowIsMap"
    readonly property string    _PIPVisibleKey:         "IsPIPVisible"


    //---------------------- SKYDRONES
    property string _altitude:              activeVehicle ? (isNaN(activeVehicle.altitudeRelative.value) ? "0.0" : activeVehicle.altitudeRelative.value.toFixed(1)) + ' ' + activeVehicle.altitudeRelative.units : "0.0"
    property string _distanceStr:           isNaN(_distance) ? "0" : _distance.toFixed(0) + ' ' + (activeVehicle ? activeVehicle.altitudeRelative.units : "")
    property real   _heading:               activeVehicle   ? activeVehicle.heading.rawValue : 0

    property real   _distance:              0.0
    property string _messageTitle:          ""
    property string _messageText:           ""

    property var    battery1:           activeVehicle ? activeVehicle.battery  : null
    property bool   batt1ParamsAvailable
    property Fact   battCapacity
    property Fact _rtlAltFact:      controller.getParameterFact(-1, "RTL_ALT")
    property Fact _rtlAltFinalFact: controller.getParameterFact(-1, "RTL_ALT_FINAL")
    property Fact   fact: null
    property Fact rtlAltFact: controller.vehicle.multiRotor ? controller.getParameterFact(-1, "RTL_ALT", false) : controller.getParameterFact(-1, "ALT_HOLD_RTL", false /* reportMissing */)
    property bool _armed:           activeVehicle ? activeVehicle.armed : false
    property string _validateString
    property bool   _rcRSSIAvailable:   activeVehicle ? activeVehicle.rcRSSI > 0 && activeVehicle.rcRSSI <= 100 : false
    property bool _initialDownloadComplete: activeVehicle ? activeVehicle.parameterManager.parametersReady : false
    //------------------- edit
    //------------------------

    function secondsToMMSS(timeS) {
        var sec_num = parseInt(timeS, 10);
        var minutes = Math.floor(sec_num / 60);
        var seconds = sec_num % 60;
        
        if (minutes < 10) {
            minutes = "0" + minutes;
        }
        if (seconds < 10) {
            seconds = "0" + seconds;
        }
        
        return minutes + ':' + seconds;
    }


    function getVerticalSpeed(){
        var _temp="0.0"
        var  _speed
        if (activeVehicle){
            if (activeVehicle.climbRate.value >=0 ){
                _temp= " +" + activeVehicle.climbRate.value.toFixed(1) + ' ' +activeVehicle.climbRate.units;
                //_temp= activeVehicle.climbRate.value.toFixed(1) + ' ' +activeVehicle.climbRate.units;

            }else{

                //_speed= activeVehicle.climbRate.value * -1.0;
                if (true/*_speed < 0.1*/){
                    _temp=" -" + activeVehicle.climbRate.value.toFixed(1)  + ' ' +activeVehicle.climbRate.units;
                    //_temp=_speed  + ' ' +activeVehicle.climbRate.units;

                }else{
                    //_temp= " +" + activeVehicle.climbRate.value.toFixed(1) + ' ' +activeVehicle.climbRate.units;
                   // _temp= activeVehicle.climbRate.value.toFixed(1) + ' ' +activeVehicle.climbRate.units;
                }


            }
        }
        return _temp
    }

    //--------- SKYDRONES EDIT
    function getColorForBatteryPercentage() {
            if (activeVehicle) {
                if (activeVehicle.battery.voltage.value > 43.9) {
                    return "green"; 
                } else if (activeVehicle.battery.voltage.value >= 43.2) {
                    return "yellow"; 
                }  else if (activeVehicle.battery.voltage.value <= 42.0) {
                    return "red"; 
                } else {
                    return "black";
                }
            }
            return "gray"; // Cor padrão caso não haja veículo ativo
    }

    function getBarLengthForBatteryVoltage() {
        if (activeVehicle) {
            if (activeVehicle.battery.voltage.value > 43.9) {
                return mapValue(activeVehicle.battery.voltage.value, 43.9, 0, 50);// Comprimento total da barra (100%)
            } else if (activeVehicle.battery.voltage.value >= 43.2) {
                // Calcula o comprimento da barra com base na voltagem dentro deste intervalo (por exemplo, 75%)
                return mapValue(activeVehicle.battery.voltage.value, 43.2, 43.9, 0, 75);
            } else if (activeVehicle.battery.voltage.value <= 42.0) {
                // Calcula o comprimento da barra com base na voltagem dentro deste intervalo (por exemplo, 50%)
                return mapValue(activeVehicle.battery.voltage.value, 42.0, 43.2, 0, 50);
            } else {
                // Calcula o comprimento da barra com base na voltagem dentro deste intervalo (por exemplo, 25%)
                return mapValue(activeVehicle.battery.voltage.value, 0, 42.0, 0, 25);
            }
        }
        return  // Valor padrão caso não haja veículo ativo
    }
    //----------------------EDIT VERSÃO DRONE PADRÃO -------------------------------------------------//
    /* function getPositionForBatteryPercentage() {
        if (activeVehicle && activeVehicle.battery.voltage.value !== -1) {
            var batteryVoltage = activeVehicle.battery.voltage.value;
            var minVoltage = 41.9;
            var maxVoltage = 49.9;

            var position = (batteryVoltage - minVoltage) / (maxVoltage - minVoltage);

            position = Math.max(0, Math.min(1, position));

            return position;
        }
        return 0;
    } */
    //----------------------EDIT VERSÃO DRONE MENOR -------------------------------------------------//
    function getPositionForBatteryPercentage() {
        if (activeVehicle && activeVehicle.battery.voltage.value !== -1) {
            var batteryVoltage = activeVehicle.battery.voltage.value;
            var minVoltage = 22.8;
            var maxVoltage = 26.1;

            var position = (batteryVoltage - minVoltage) / (maxVoltage - minVoltage);

            position = Math.max(0, Math.min(1, position));

            return position;
        }
        return 0;
    }
    //--------------------------------- 
    //---------------------------------
    //---------------------------------
    Timer {
        id:             checklistPopupTimer
        interval:       1000
        repeat:         false
        onTriggered: {
            if (visible && !_checklistComplete) {
                checklistDropPanel.open()
            }
            else {
                checklistDropPanel.close()
            }
        }
    }

    function setStates() {
        QGroundControl.saveBoolGlobalSetting(_mainIsMapKey, mainIsMap)
        if(mainIsMap) {
            //-- Adjust Margins
            _flightMapContainer.state   = "fullMode"
            _flightVideo.state          = "pipMode"
        } else {
            //-- Adjust Margins
            _flightMapContainer.state   = "pipMode"
            _flightVideo.state          = "fullMode"
        }
    }

    function setPipVisibility(state) {
        _isPipVisible = state;
        QGroundControl.saveBoolGlobalSetting(_PIPVisibleKey, state)
    }

    function isInstrumentRight() {
        if(QGroundControl.corePlugin.options.instrumentWidget) {
            if(QGroundControl.corePlugin.options.instrumentWidget.source.toString().length) {
                switch(QGroundControl.corePlugin.options.instrumentWidget.widgetPosition) {
                case CustomInstrumentWidget.POS_TOP_LEFT:
                case CustomInstrumentWidget.POS_BOTTOM_LEFT:
                case CustomInstrumentWidget.POS_CENTER_LEFT:
                    return false;
                }
            }
        }
        return true;
    }
    
    function showPreflightChecklistIfNeeded () {
        if (activeVehicle && !_checklistComplete && _enforceChecklist) {
            checklistPopupTimer.restart()
        }
    }

    Connections {
        target:                     _missionController
        onResumeMissionUploadFail:  guidedActionsController.confirmAction(guidedActionsController.actionResumeMissionUploadFail)
    }

    Connections {
        target:                 mainWindow
        onArmVehicle:           guidedController.confirmAction(guidedController.actionArm)
        onDisarmVehicle: {
            if (guidedController.showEmergenyStop) {
                guidedController.confirmAction(guidedController.actionEmergencyStop)
            } else {
                guidedController.confirmAction(guidedController.actionDisarm)
            }
        }
        onVtolTransitionToFwdFlight:    guidedController.confirmAction(guidedController.actionVtolTransitionToFwdFlight)
        onVtolTransitionToMRFlight:     guidedController.confirmAction(guidedController.actionVtolTransitionToMRFlight)
        onFlightDisplayMapChanged:      setStates()
    }

    Component.onCompleted: {
        if(QGroundControl.corePlugin.options.flyViewOverlay.toString().length) {
            flyViewOverlay.source = QGroundControl.corePlugin.options.flyViewOverlay
        }
        if(QGroundControl.corePlugin.options.preFlightChecklistUrl.toString().length) {
            checkList.source = QGroundControl.corePlugin.options.preFlightChecklistUrl
        }
    }

    // The following code is used to track vehicle states for showing the mission complete dialog
    property bool vehicleArmed:                     activeVehicle ? activeVehicle.armed : true // true here prevents pop up from showing during shutdown
    property bool vehicleWasArmed:                  false
    property bool vehicleInMissionFlightMode:       activeVehicle ? (activeVehicle.flightMode === activeVehicle.missionFlightMode) : false
    property bool vehicleWasInMissionFlightMode:    false
    property bool showMissionCompleteDialog:        vehicleWasArmed && vehicleWasInMissionFlightMode &&
                                                        (_missionController.containsItems || _geoFenceController.containsItems || _rallyPointController.containsItems ||
                                                        (activeVehicle ? activeVehicle.cameraTriggerPoints.count !== 0 : false))

    onVehicleArmedChanged: {
        if (vehicleArmed) {
            vehicleWasArmed = true
            vehicleWasInMissionFlightMode = vehicleInMissionFlightMode
        } else {
            if (showMissionCompleteDialog) {
                mainWindow.showComponentDialog(missionCompleteDialogComponent, qsTr("Flight Plan complete"), mainWindow.showDialogDefaultWidth, StandardButton.Close)
            }
            vehicleWasArmed = false
            vehicleWasInMissionFlightMode = false
        }
    }

    onVehicleInMissionFlightModeChanged: {
        if (vehicleInMissionFlightMode && vehicleArmed) {
            vehicleWasInMissionFlightMode = true
        }
    }

    

    Component {
        id: missionCompleteDialogComponent

        QGCViewDialog {
            property var activeVehicleCopy: activeVehicle
            onActiveVehicleCopyChanged:
                if (!activeVehicleCopy) {
                    hideDialog()
                }

            QGCFlickable {
                anchors.fill:   parent
                contentHeight:  column.height

                ColumnLayout {
                    id:                 column
                    anchors.margins:    _margins
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    spacing:            ScreenTools.defaultFontPixelHeight

                    QGCLabel {
                        Layout.fillWidth:       true
                        text:                   qsTr("%1 Images Taken").arg(activeVehicle.cameraTriggerPoints.count)
                        horizontalAlignment:    Text.AlignHCenter
                        visible:                activeVehicle.cameraTriggerPoints.count !== 0
                    }

                    QGCButton {
                        Layout.fillWidth:   true
                        text:               qsTr("Remove plan from vehicle")
                        visible:            !activeVehicle.connectionLost// && !activeVehicle.apmFirmware  // ArduPilot has a bug somewhere with mission clear
                        onClicked: {
                            _planController.removeAllFromVehicle()
                            hideDialog()
                        }
                    }

                    QGCButton {
                        Layout.fillWidth:   true
                        Layout.alignment:   Qt.AlignHCenter
                        text:               qsTr("Leave plan on vehicle")
                        onClicked:          hideDialog()
                    }

                    Rectangle {
                        Layout.fillWidth:   true
                        color:              qgcPal.text
                        height:             1
                    }

                    ColumnLayout {
                        Layout.fillWidth:   true
                        spacing:            ScreenTools.defaultFontPixelHeight
                        visible:            !activeVehicle.connectionLost && _guidedController.showResumeMission

                        QGCButton {
                            Layout.fillWidth:   true
                            Layout.alignment:   Qt.AlignHCenter
                            text:               qsTr("Resume Mission From Waypoint %1").arg(_guidedController._resumeMissionIndex)

                            onClicked: {
                                guidedController.executeAction(_guidedController.actionResumeMission, null, null)
                                hideDialog()
                            }
                        }

                        QGCLabel {
                            Layout.fillWidth:   true
                            wrapMode:           Text.WordWrap
                            text:               qsTr("Resume Mission will rebuild the current mission from the last flown waypoint and upload it to the vehicle for the next flight.")
                        }
                    }

                    QGCLabel {
                        Layout.fillWidth:   true
                        wrapMode:           Text.WordWrap
                        color:              qgcPal.warningText
                        text:               qsTr("If you are changing batteries for Resume Mission do not disconnect from the vehicle.")
                        visible:            _guidedController.showResumeMission
                    }
                }
            }
        }
    }

    Window {
        id:             videoWindow
        width:          !mainIsMap ? _mapAndVideo.width  : _pipSize
        height:         !mainIsMap ? _mapAndVideo.height : _pipSize * (9/16)
        visible:        false

        Item {
            id:             videoItem
            anchors.fill:   parent
        }

        onClosing: {
            _flightVideo.state = "unpopup"
            videoWindow.visible = false
        }
    }

    /* This timer will startVideo again after the popup window appears and is loaded.
     * Such approach was the only one to avoid a crash for windows users
     */
    Timer {
    id: videoPopUpTimer
    interval: 2000;
    running: false;
    repeat: false
    onTriggered: {
          // If state is popup, the next one will be popup-finished
        if (_flightVideo.state ==  "popup") {
            _flightVideo.state = "popup-finished"
        }
        QGroundControl.videoManager.startVideo()
    }
    }

    
    QGCMapPalette { id: mapPal; lightColors: mainIsMap ? mainWindow.flightDisplayMap.isSatelliteMap : true }

    
    //-- Battery time Control
    
        Loader {
            id:                     battTimeLoader
            visible:                true
            source:                 "qrc:/qml/QGroundControl/src/ui/toolbar/BatteryTime.qml"
        }
    //--------
    //VOLTAGE
            QGCColoredImage {
                height:                 _indicatorsHeight
                width:                  height
                source:                 "/qmlimages/Battery.svg"
                fillMode:               Image.PreserveAspectFit
                sourceSize.height:      height
                Layout.alignment:       Qt.AlignVCenter | Qt.AlignHCenter
                color:                  qgcPal.text
                visible:                false
            }
            QGCLabel {
                text: (battery1 && battery1.voltage.value !== -1) ? (battery1.voltage.valueString + " " + battery1.voltage.units) : "N/A"
                font.pointSize:         ScreenTools.mediumFontPointSize
                Layout.fillWidth:       true
                Layout.minimumWidth:    indicatorValueWidth
                horizontalAlignment:    firstLabel.horizontalAlignment
                visible:                false

            }

    //--------------------------------
    //-- Airspace Indicator
    Rectangle {
        id:             airspaceIndicator
        width:          airspaceRow.width + (ScreenTools.defaultFontPixelWidth * 3)
        height:         airspaceRow.height * 1.25
        color:          qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1,1,1,0.95) : Qt.rgba(0,0,0,0.75)
        visible:        QGroundControl.airmapSupported && mainIsMap && flightPermit && flightPermit !== AirspaceFlightPlanProvider.PermitNone
        radius:         3
        border.width:   1
        border.color:   qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0,0,0,0.35) : Qt.rgba(1,1,1,0.35)
        anchors.top:    parent.top
        anchors.topMargin: ScreenTools.toolbarHeight + (ScreenTools.defaultFontPixelHeight * 0.25)
        anchors.verticalCenter: parent.verticalCenter
        
        Row {
            id: airspaceRow
            spacing: ScreenTools.defaultFontPixelWidth
            anchors.centerIn: parent
            QGCLabel { text: airspaceIndicator.providerName+":"; anchors.verticalCenter: parent.verticalCenter; }
            QGCLabel {
                text: {
                    if(airspaceIndicator.flightPermit) {
                        if(airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitPending)
                            return qsTr("Approval Pending")
                        if(airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitAccepted || airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitNotRequired)
                            return qsTr("Flight Approved")
                        if(airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitRejected)
                            return qsTr("Flight Rejected")
                    }
                    return ""
                }
                color: {
                    if(airspaceIndicator.flightPermit) {
                        if(airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitPending)
                            return qgcPal.colorOrange
                        if(airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitAccepted || airspaceIndicator.flightPermit === AirspaceFlightPlanProvider.PermitNotRequired)
                            return qgcPal.colorGreen
                    }
                    return qgcPal.colorRed
                }
                anchors.verticalCenter: parent.verticalCenter;
            }
        }
        property var  flightPermit: QGroundControl.airmapSupported ? QGroundControl.airspaceManager.flightPlan.flightPermitStatus : null
        property string  providerName: QGroundControl.airspaceManager.providerName
    }

    //-- Checklist GUI
    Popup {
        id:             checklistDropPanel
        x:              Math.round((mainWindow.width  - width)  * 0.5)
        y:              Math.round((mainWindow.height - height) * 0.5)
        height:         checkList.height
        width:          checkList.width
        modal:          true
        focus:          true
        closePolicy:    Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle {
            anchors.fill:  parent
            color:      Qt.rgba(0,0,0,0)
            clip:       true
        }

        Loader {
            id:         checkList
            anchors.centerIn: parent
        }

        property alias checkListItem: checkList.item

        Connections {
            target: checkList.item
            onAllChecksPassedChanged: {
                if (target.allChecksPassed)
                {
                    checklistPopupTimer.restart()
                }
            }
        }
    }
    // -- Camera View
    Item {
        id:             _mapAndVideo
        anchors.fill:   parent
         //-- Video View
        Item {
            id:             _flightVideo
            z:              mainIsMap ? _mapAndVideo.z + 2 : _mapAndVideo.z + 1
            width:          !mainIsMap ? _mapAndVideo.width  : _pipSize
            height:         !mainIsMap ? _mapAndVideo.height : _pipSize * (9/16)
            anchors.right:   _mapAndVideo.right
            anchors.bottom: _mapAndVideo.bottom * 0.5
            visible:        QGroundControl.videoManager.hasVideo && (!mainIsMap || _isPipVisible)
            
            
            onParentChanged: {
                
                if(parent == _mapAndVideo) {
                    // Do anchors again after popup
                    anchors.right =       _mapAndVideo.right
                    anchors.bottom =     _mapAndVideo.bottom
                    anchors.margins =    _toolsMargin
                }
            }

            states: [
                State {
                    name:   "pipMode"
                    PropertyChanges {
                        target:             _flightVideo
                        anchors.margins:    ScreenTools.defaultFontPixelHeight
                    }
                    PropertyChanges {
                        target:             _flightVideoPipControl
                        inPopup:            false
                    }
                },
                State {
                    name:   "fullMode"
                    PropertyChanges {
                        target:             _flightVideo
                        anchors.margins:    0
                    }
                    PropertyChanges {
                        target:             _flightVideoPipControl
                        inPopup:            false
                    }
                },
                State {
                    name: "popup"
                    StateChangeScript {
                        script: {
                            // Stop video, restart it again with Timer
                            // Avoiding crashes if ParentChange is not yet done
                            QGroundControl.videoManager.stopVideo()
                            videoPopUpTimer.running = true
                        }
                    }
                    PropertyChanges {
                        target:             _flightVideoPipControl
                        inPopup:            true
                    }
                },
                State {
                    name: "popup-finished"
                    ParentChange {
                        target:             _flightVideo
                        parent:             videoItem
                        x:                  0
                        y:                  0
                        width:              videoItem.width
                        height:             videoItem.height
                    }
                },
                State {
                    name: "unpopup"
                    StateChangeScript {
                        script: {
                            QGroundControl.videoManager.stopVideo()
                            videoPopUpTimer.running = true
                        }
                    }
                    ParentChange {
                        target:             _flightVideo
                        parent:             _mapAndVideo
                    }
                    PropertyChanges {
                        target:             _flightVideoPipControl
                        inPopup:             false
                    }
                }
            ]
            //-- Video Streaming
            FlightDisplayViewVideo {
                id:             videoStreaming
                anchors.fill:   parent
                visible:        QGroundControl.videoManager.isGStreamer
            }
            //-- UVC Video (USB Camera or Video Device)
            Loader {
                id:             cameraLoader
                anchors.fill:   parent
                visible:        !QGroundControl.videoManager.isGStreamer
                source:         visible ? (QGroundControl.videoManager.uvcEnabled ? "qrc:/qml/FlightDisplayViewUVC.qml" : "qrc:/qml/FlightDisplayViewDummy.qml") : ""
            }
            

        }
        //-- Map View
        Item {
            id: _flightMapContainer
            z:  mainIsMap ? _mapAndVideo.z + 1 : _mapAndVideo.z + 2
            anchors.right:   _mapAndVideo.right
            anchors.bottom: _mapAndVideo.bottom
            visible:        mainIsMap || _isPipVisible && !QGroundControl.videoManager.fullScreen
            width:          mainIsMap ? _mapAndVideo.width  : _pipSize
            height:         mainIsMap ? _mapAndVideo.height : _pipSize * (9/16)
            states: [
                State {
                    name:   "pipMode"
                    PropertyChanges {
                        target:             _flightMapContainer
                        anchors.margins:    ScreenTools.defaultFontPixelHeight
                    }
                },
                State {
                    name:   "fullMode"
                    PropertyChanges {
                        target:             _flightMapContainer
                        anchors.margins:    0
                    }
                }
            ]
            
            FlightDisplayViewMap {
                id:                         _fMap
                anchors.fill:               parent
                guidedActionsController:    _guidedController
                missionController:          _planController
                flightWidgets:              flightDisplayViewWidgets
                rightPanelWidth:            ScreenTools.defaultFontPixelHeight * 9
                multiVehicleView:           !singleVehicleView.checked
                scaleState:                 (mainIsMap && flyViewOverlay.item) ? (flyViewOverlay.item.scaleState ? flyViewOverlay.item.scaleState : "bottomMode") : "bottomMode"
                Component.onCompleted: {
                    mainWindow.flightDisplayMap = _fMap
                    _fMap.adjustMapSize()
                }
            }
        }

        

        QGCPipable {
            id:                 _flightVideoPipControl
            z:                  _flightVideo.z + 3
            width:              _pipSize
            height:             _pipSize * (9/16)
            anchors.right:       _mapAndVideo.right
            anchors.bottom:     _mapAndVideo.bottom
            anchors.margins:    ScreenTools.defaultFontPixelHeight
            visible:            QGroundControl.videoManager.hasVideo && !QGroundControl.videoManager.fullScreen && _flightVideo.state != "popup"
            isHidden:           !_isPipVisible
            isDark:             isBackgroundDark
            enablePopup:        mainIsMap
            onActivated: {
                mainIsMap = !mainIsMap
                setStates()
                _fMap.adjustMapSize()
            }
            onHideIt: {
                setPipVisibility(!state)
            }
            onPopup: {
                videoWindow.visible = true
                _flightVideo.state = "popup"
            }
            onNewWidth: {
                _pipSize = newWidth
            }
        }

        Row {
            id:                     singleMultiSelector
            anchors.topMargin:      ScreenTools.toolbarHeight + _toolsMargin
            anchors.rightMargin:    _toolsMargin
            anchors.right:          parent.right
            spacing:                ScreenTools.defaultFontPixelWidth
            z:                      _mapAndVideo.z + 4
            visible:                QGroundControl.multiVehicleManager.vehicles.count > 1 && QGroundControl.corePlugin.options.enableMultiVehicleList

            QGCRadioButton {
                id:             singleVehicleView
                text:           qsTr("Single")
                checked:        true
                textColor:      mapPal.text
            }

            QGCRadioButton {
                text:           qsTr("Multi-Vehicle")
                textColor:      mapPal.text
            }
        }

        FlightDisplayViewWidgets {
            id:                 flightDisplayViewWidgets
            z:                  _mapAndVideo.z + 4
            height:             availableHeight - (singleMultiSelector.visible ? singleMultiSelector.height + _toolsMargin : 0) - _toolsMargin
            anchors.left:       parent.left
            anchors.right:      altitudeSlider.visible ? altitudeSlider.left : parent.right
            anchors.bottom:     parent.bottom
            anchors.top:        singleMultiSelector.visible? singleMultiSelector.bottom : undefined
            useLightColors:     isBackgroundDark
            missionController:  _missionController
            visible:            singleVehicleView.checked && !QGroundControl.videoManager.fullScreen
        }

        //-------------------------------------------------------------------------
        //-- Loader helper for plugins to overlay elements over the fly view
        Loader {
            id:                 flyViewOverlay
            z:                  flightDisplayViewWidgets.z + 1
            visible:            !QGroundControl.videoManager.fullScreen
            height:             mainWindow.height - mainWindow.header.height
            anchors.left:       parent.left
            anchors.right:      altitudeSlider.visible ? altitudeSlider.left : parent.right
            anchors.bottom:     parent.bottom
        }

        MultiVehicleList {
            anchors.margins:            _toolsMargin
            anchors.top:                singleMultiSelector.bottom
            anchors.right:              parent.right
            anchors.bottom:             parent.bottom
            width:                      ScreenTools.defaultFontPixelWidth * 30
            visible:                    !singleVehicleView.checked && !QGroundControl.videoManager.fullScreen && QGroundControl.corePlugin.options.enableMultiVehicleList
            z:                          _mapAndVideo.z + 4
            guidedActionsController:    _guidedController
        }

        //-- Virtual Joystick
        Loader {
            id:                         virtualJoystickMultiTouch
            z:                          _mapAndVideo.z + 5
            width:                      parent.width  - (_flightVideoPipControl.width / 2)
            height:                     Math.min(mainWindow.height * 0.25, ScreenTools.defaultFontPixelWidth * 16)
            visible:                    _virtualJoystickEnabled && !QGroundControl.videoManager.fullScreen && !(activeVehicle ? activeVehicle.highLatencyLink : false)
            anchors.bottom:             _flightVideoPipControl.top
            anchors.bottomMargin:       ScreenTools.defaultFontPixelHeight * 2
            anchors.horizontalCenter:   flightDisplayViewWidgets.horizontalCenter
            source:                     "qrc:/qml/VirtualJoystick.qml"
            active:                     _virtualJoystickEnabled && !(activeVehicle ? activeVehicle.highLatencyLink : false)

            property bool useLightColors:       isBackgroundDark
            property bool autoCenterThrottle:   QGroundControl.settingsManager.appSettings.virtualJoystickAutoCenterThrottle.rawValue

            property bool _virtualJoystickEnabled: QGroundControl.settingsManager.appSettings.virtualJoystick.rawValue
        }

        //----------------------At home SkyDrones
        ToolStrip {
            visible: (activeVehicle ? activeVehicle.guidedModeSupported : true) && !QGroundControl.videoManager.fullScreen
            id: toolStripp

            anchors.leftMargin: isInstrumentRight() ? _toolsMargin : undefined
            anchors.left: isInstrumentRight() ? _mapAndVideo.left : undefined
            anchors.rightMargin: isInstrumentRight() ? undefined : ScreenTools.defaultFontPixelWidth
            anchors.right: isInstrumentRight() ? undefined : _mapAndVideo.right
            anchors.topMargin: 400
            anchors.top: parent.top
            z: _mapAndVideo.z + 4
            maxHeight: parent.height - toolStrip.y + (_flightVideo.visible ? (_flightVideo.y - parent.height) : 0)
            radius: 200

            property var _actionModel: [
                {
                    title: _guidedController.startMissionTitle,
                    text: _guidedController.startMissionMessage,
                    action: _guidedController.actionStartMission,
                    visible: _guidedController.showStartMission
                },
                {
                    title: _guidedController.continueMissionTitle,
                    text: _guidedController.continueMissionMessage,
                    action: _guidedController.actionContinueMission,
                    visible: _guidedController.showContinueMission
                },
                {
                    title: _guidedController.changeAltTitle,
                    text: _guidedController.changeAltMessage,
                    action: _guidedController.actionChangeAlt,
                    visible: _guidedController.showChangeAlt
                },
                {
                    title: _guidedController.landAbortTitle,
                    text: _guidedController.landAbortMessage,
                    action: _guidedController.actionLandAbort,
                    visible: _guidedController.showLandAbort
                }
            ]

            model: [
                {
                    name: _guidedController.rtlTitle,
                    iconSource: "/qmlimages/AtHome.svg",
                    //buttonVisible: _guidedController.showTakeoff,
                    //buttonEnabled: _guidedController.showTakeoff,
                    action: _guidedController.actionRTL
                }
            ]

            onClicked: {
                guidedActionsController.closeAll()
                var action = model[index].action
                if (action !== -1) {
                    _guidedController.confirmAction(action)
                }
            }
        }
        //---------------- code original
        ToolStrip {
            visible: (activeVehicle ? activeVehicle.guidedModeSupported : true) && !QGroundControl.videoManager.fullScreen
            id: toolStrip

            anchors.leftMargin: isInstrumentRight() ? _toolsMargin : undefined
            anchors.left: isInstrumentRight() ? _mapAndVideo.left : undefined
            anchors.rightMargin: isInstrumentRight() ? undefined : ScreenTools.defaultFontPixelWidth
            anchors.right: isInstrumentRight() ? undefined : _mapAndVideo.right
            anchors.topMargin: 150
            anchors.top: parent.top
            z: _mapAndVideo.z + 4
            maxHeight: parent.height - toolStrip.y + (_flightVideo.visible ? (_flightVideo.y - parent.height) : 0)
            radius: 600

            property var _actionModel: [
                {
                    title: _guidedController.startMissionTitle,
                    text: _guidedController.startMissionMessage,
                    action: _guidedController.actionStartMission,
                    visible: _guidedController.showStartMission
                },
                {
                    title: _guidedController.continueMissionTitle,
                    text: _guidedController.continueMissionMessage,
                    action: _guidedController.actionContinueMission,
                    visible: _guidedController.showContinueMission
                },
                {
                    title: _guidedController.changeAltTitle,
                    text: _guidedController.changeAltMessage,
                    action: _guidedController.actionChangeAlt,
                    visible: _guidedController.showChangeAlt
                },
                {
                    title: _guidedController.landAbortTitle,
                    text: _guidedController.landAbortMessage,
                    action: _guidedController.actionLandAbort,
                    visible: _guidedController.showLandAbort
                }
            ]

            model: [
                {
                    name: _guidedController.takeoffTitle,
                    iconSource: "/qmlimages/TakeOffIcon.svg",
                    action: _guidedController.actionTakeoff,
                },
            ]

            onClicked: {
                guidedActionsController.closeAll()
                var action = model[index].action
                if (action !== -1) {
                    _guidedController.confirmAction(action)
                }
            }
        }

        GuidedActionsController {
            id:                 guidedActionsController
            missionController:  _missionController
            confirmDialog:      guidedActionConfirm
            actionList:         guidedActionList
            altitudeSlider:     _altitudeSlider
            z:                  _flightVideoPipControl.z + 1

            onShowStartMissionChanged: {
                if (showStartMission) {
                    confirmAction(actionStartMission)
                }
            }

            onShowContinueMissionChanged: {
                if (showContinueMission) {
                    confirmAction(actionContinueMission)
                }
            }

            onShowLandAbortChanged: {
                if (showLandAbort) {
                    confirmAction(actionLandAbort)
                }
            }

            /// Close all dialogs
            function closeAll() {
                guidedActionConfirm.visible = false
                guidedActionList.visible    = false
                altitudeSlider.visible      = false
            }
        }

        GuidedActionConfirm {
            id:                         guidedActionConfirm
            anchors.margins:            _margins
            anchors.bottom:             parent.bottom
            anchors.bottomMargin:       20
            anchors.horizontalCenter:   parent.horizontalCenter
            guidedController:           _guidedController
            altitudeSlider:             _altitudeSlider
        }

        GuidedActionList {
            id:                         guidedActionList
            anchors.margins:            _margins
            anchors.bottom:             parent.bottom
            anchors.horizontalCenter:   parent.horizontalCenter
            guidedController:           _guidedController
        }

        //-- Altitude slider
        GuidedAltitudeSlider {
            id:                 altitudeSlider
            anchors.margins:    _margins
            anchors.right:      parent.right
            anchors.topMargin:  ScreenTools.toolbarHeight + _margins
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            anchors.bottomMargin:       20
            z:                  _guidedController.z
            radius:             ScreenTools.defaultFontPixelWidth / 2
            width:              ScreenTools.defaultFontPixelWidth * 10
            color:              qgcPal.window
            visible:            false
        }
    }
     //EDIT SKYDRONES ----------
    Item {
        id:     backgroundImage
        width:  parent.width
        height: parent.height

        Rectangle {
            id: vehicleIndicator
            color: "black" //qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1, 1, 1, 0.95) : Qt.rgba(0, 0, 0, 0.2) // 0.3
            width:  parent.width//vehicleStatusGrid.width + (ScreenTools.defaultFontPixelWidth) // 5
            height: vehicleStatusGrid.height 
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            //anchors.bottomMargin: 7
            opacity: 0.8
            
            //----------Customizado o RADAR -----SKYDRONES -----------------
            Item {
                Layout.rowSpan:         6
                Layout.column:          8
                Layout.minimumWidth:    mainIsMap ? vehicleIndicator.height * 1.25 : vehicleIndicator.height * 1.25
                Layout.fillHeight:      true
                Layout.fillWidth:       true
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 90
                anchors.left: parent.left 
                anchors.leftMargin: 1

                Rectangle {
                    height:         _outerRadius
                    radius:         _outerRadius
                    color:          qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1, 1, 1, 0.95) : Qt.rgba(0, 0, 0, 0.2) // 0.3
                    width: parent.width
                    anchors.centerIn:       parent
                    Layout.fillWidth:     false
                    //border.color:   _isSatellite ? qgcPal.mapWidgetBorderLight : qgcPal.mapWidgetBorderDark
                    
                    // Prevent all clicks from going through to lower layers
                    DeadMouseArea {
                        anchors.fill: parent
                    }

                    QGCPalette { id: qgcPal }

                    QGCAttitudeWidget {
                        id:                 attitude
                        anchors.leftMargin: _topBottomMargin
                        anchors.left:       parent.left
                        size:               _innerRadius 
                        width:              180 //----Versão Mobile          
                        height:                 180 //----Versão Mobile
                        vehicle:            activeVehicle
                        anchors.bottomMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    QGCCompassWidget {
                        id:                 compass
                        anchors.leftMargin: _topBottomMargin
                        anchors.left:       parent.left
                        size:               _innerRadius 
                        width:              180 //----Versão Mobile          
                        height:                 180 //----Versão Mobile
                        vehicle:            activeVehicle
                        anchors.bottomMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
            //  Layout
            GridLayout {
                id:                     vehicleStatusGrid
                Layout.rowSpan:         6
                Layout.column:          8
                Layout.minimumWidth:    mainIsMap ? vehicleIndicator.height * 1.25 : vehicleIndicator.height * 1.25
                Layout.fillHeight:      true
                Layout.fillWidth:       true
                //anchors.bottom: parent.bottom
                //anchors.bottomMargin: 100
                anchors.left: parent.left 
                anchors.leftMargin: 280

                //-- DISTANCE -------------------------------------SkyDrones
                Row{
                    spacing:                8
                    

                    QGCColoredImage {
                        height:                 _indicatorsHeight
                        width:                  height
                        //source:                 "/custom/img/altitude.svg"
                        fillMode:               Image.PreserveAspectFit
                        sourceSize.height:      height
                        Layout.alignment:       Qt.AlignVCenter | Qt.AlignHCenter
                        color:                  qgcPal.text

                    }
                    Text {
                        //anchors.centerIn: parent
                        text: "D"  // Substitua pelo texto que você deseja exibir
                        font.pointSize: 15//ScreenTools.defaultFontPixelHeight  // Ajuste o tamanho da fonte conforme necessário
                        color: "white"  // Ajuste a cor do texto conforme necessário
                        //font.bold: true
                        anchors.bottom: parent.bottom
                    }
                    QGCLabel {
                        text:                   activeVehicle ? ('00000' + activeVehicle.distanceToHome.value.toFixed(0)).slice(-5) + ' ' + activeVehicle.distanceToHome.units : "00000"
                        color:                   "white"
                        opacity:                0.7
                        font.pointSize:         15//ScreenTools.mediumFontPointSize
                        Layout.fillWidth:       true
                        Layout.minimumWidth:    indicatorValueWidth
                        horizontalAlignment:    firstLabel.horizontalAlignment
                        anchors.bottom:         parent.bottom
                        
                        
                    }
                }
                //-------------------------SkyDrones


                //-- 3 ALTITUDE -------------------------SkyDrones
                Row {
                    spacing: 8

                    QGCColoredImage {
                        height:                 _indicatorsHeight
                        width:                  height
                        //source:                 "/custom/img/altitude.svg"
                        fillMode:               Image.PreserveAspectFit
                        sourceSize.height:      height
                        Layout.alignment:       Qt.AlignVCenter | Qt.AlignHCenter
                        color:                  "white"//qgcPal.text

                    }
                    Text {
                        //anchors.centerIn: parent
                        text: "H"  // Substitua pelo texto que você deseja exibir
                        font.pointSize: 15//ScreenTools.defaultFontPixelHeight  // Ajuste o tamanho da fonte conforme necessário
                        color: "white"  // Ajuste a cor do texto conforme necessário
                        //font.bold: true
                        anchors.bottom: parent.bottom
                    }
                    QGCLabel {
                        id:                     altitudeTextField
                        text:                   _altitude
                        color:                   "white"
                        opacity:                0.7
                        font.pointSize:         15//ScreenTools.mediumFontPointSize
                        Layout.fillWidth:       true
                        Layout.minimumWidth:    indicatorValueWidth
                        horizontalAlignment:    firstLabel.horizontalAlignment
                        anchors.bottom: parent.bottom
                    } 
                }
                    
                //-------------------------SkyDrones


                //-- GROUND SPEED
                Row {
                    spacing: 8

                    QGCColoredImage {
                        height: _indicatorsHeight
                        width: height
                        //source: "/custom/img/horizontal_speed.svg"
                        fillMode: Image.PreserveAspectFit
                        sourceSize.height: height
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        color: qgcPal.text
                    }
                    Text {
                            //anchors.centerIn: parent
                            text: "VH"  // Substitua pelo texto que você deseja exibir
                            font.pointSize: 15//ScreenTools.defaultFontPixelHeight  // Ajuste o tamanho da fonte conforme necessário
                            color: "white"  // Ajuste a cor do texto conforme necessário
                            //font.bold: true
                            anchors.bottom: parent.bottom
                        }
                    QGCLabel {
                        text:                   activeVehicle ? activeVehicle.groundSpeed.value.toFixed(1) + ' ' + activeVehicle.groundSpeed.units : "0.0"
                        color:                   "white"
                        opacity:                0.7
                        font.pointSize:         15//ScreenTools.mediumFontPointSize
                        Layout.fillWidth:       true
                        Layout.minimumWidth:    indicatorValueWidth
                        horizontalAlignment:    firstLabel.horizontalAlignment
                        anchors.bottom:         parent.bottom
                    }
                }
                //-------------------------SkyDrones


                //-- VERTICAL SPEED //-------------------------SkyDrones
                Row {
                    spacing: 8

                    QGCColoredImage {
                        height:                 _indicatorsHeight
                        width:                  height
                        //source:                 "/custom/img/vertical_speed.svg"
                        fillMode:               Image.PreserveAspectFit
                        sourceSize.height:      height
                        Layout.alignment:       Qt.AlignVCenter | Qt.AlignHCenter
                        color:                  qgcPal.text

                    }
                    Text {
                            //anchors.centerIn: parent
                            text: "VV"  // Substitua pelo texto que você deseja exibir
                            font.pointSize: 15//ScreenTools.defaultFontPixelHeight  // Ajuste o tamanho da fonte conforme necessário
                            color: "white"  // Ajuste a cor do texto conforme necessário
                            //font.bold: true
                            anchors.bottom: parent.bottom
                        }
                    QGCLabel {
                        text:                   getVerticalSpeed()//activeVehicle ? activeVehicle.climbRate.value.toFixed(1) + ' ' + activeVehicle.climbRate.units : " 0.0"
                        color:                   "white"
                        opacity:                0.7
                        font.pointSize:         15//ScreenTools.mediumFontPointSize
                        Layout.fillWidth:       false //true
                        Layout.minimumWidth:    indicatorValueWidth
                        horizontalAlignment:    firstLabel.horizontalAlignment
                        anchors.bottom:         parent.bottom   
                    }
                }
                //-------------------------SkyDrones

                //AZIMUTE SKYDRONES ------------------- SKYDRONES 
                Row {
                    spacing: 8

                    QGCColoredImage {
                        height:                 _indicatorsHeight
                        width:                  height

                        fillMode:               Image.PreserveAspectFit
                        sourceSize.height:      height
                        Layout.alignment:       Qt.AlignVCenter | Qt.AlignHCenter
                        color:                  qgcPal.text

                    }
                    Text {
                        text: "A"  
                        font.pointSize: 15
                        color: "white"  
                        anchors.bottom: parent.bottom
                    }
                    QGCLabel {
                        text:                   _heading
                        color:                   "white"
                        opacity:                0.7
                        font.pointSize:         15//ScreenTools.mediumFontPointSize
                        Layout.fillWidth:       false //true
                        Layout.minimumWidth:    indicatorValueWidth
                        horizontalAlignment:    firstLabel.horizontalAlignment
                        anchors.bottom:         parent.bottom 
                        
                    }
                    
                }
                //-----------------------------------SKYDRONES

                //REGISTRO DE AS ----------------------SKYDRONES
                Row {
                    spacing: 8

                    property bool isActive: false
                    property bool isBlinking: false
                    property Fact fact: null

                    QGCColoredImage {
                        id: image
                        height: _indicatorsHeight
                        width: height
                        fillMode: Image.PreserveAspectFit
                        sourceSize.height: height
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    }

                    Text {
                        text: "AS"
                        font.pointSize: 15
                        color: "white"
                        anchors.bottom: parent.bottom
                        signal update()

                        MouseArea {
                            anchors.fill: parent
                            enabled: returnAltRadio.checked
                            anchors.leftMargin: _margins
                            anchors.left: returnAltRadio.right
                            anchors.baseline: returnAltRadio.baseline
                            onClicked: {
                                if (_rtlAltFact) { 
                                    var inputValue = parseFloat(altitudeTextField.text) * 100;
                                    if (inputValue >= 1000) {
                                        _rtlAltFact.value = inputValue;
                                        console.log("Altitude alterada: " + _rtlAltFact.value);
                                    } else {
                                        console.log("O valor deve ser maior ou igual a 1000.");
                                    }
                                } else {
                                    console.log("_rtlAltFact não está definido ou é null.");
                                }
                            }
                        }
                    }

                    QGCLabel {
                        id: txtAS
                        text: _rtlAltFact ? _rtlAltFact.value == 0 ? qsTr("N/A") : (_rtlAltFact.value / 100) + " m" : ""
                        opacity: 0.7
                        font.pointSize: 15
                        Layout.fillWidth: false
                        Layout.minimumWidth: indicatorValueWidth
                        horizontalAlignment: firstLabel.horizontalAlignment
                        anchors.bottom: parent.bottom
                        enabled: returnAltRadio.checked
                    }

                }
            }
        }
    }

    //Notificações SkyDrones
        Item {
            height: 400
            width: 400

            ListView {
                id:         listView
                anchors.fill: parent
                orientation: ListView.Vertical
                model: ListModel {
                    id: notificationModel
                }
                anchors.topMargin: 30
                anchors.leftMargin: 200
                spacing: 5
                delegate: Item {
                    property string notificationId: model.notificationId
                    property real initialX: 0
                    property real deltaX: 0
                    property bool swiped: false
                    width: 630
                    height: visible ? 70 : 0
                    visible: 
                        (notificationId === "gpsNotification" && activeVehicle && activeVehicle.gps.count.value < 12) || 
                        (notificationId === "altitudeRtlNotification" && activeVehicle && _rtlAltFact && _rtlAltFact.value == 0) ||
                        (notificationId === "gpsNoSignalNotification" && activeVehicle && activeVehicle.gps.count.rawValue < 1 ) ||
                        (notificationId === "inFlyNotification" && _armed == 1) ||
                        (notificationId === "delocarNotification" && _initialDownloadComplete && _armed == 0)||
                        (notificationId === "forFlyNotification" && _initialDownloadComplete && _armed == 0) ||
                        (notificationId === "lowBatNotification" && activeVehicle && activeVehicle.battery.voltage.value < 22.9) ||
                        (notificationId === "offRadio" && activeVehicle && activeVehicle.rcRSSI < 0)
                    MouseArea {
                        id: swipeArea
                        anchors.fill: parent
                        drag.target: parent
                        onReleased: {
                            if (swiped) {
                                notificationModel.remove(index);
                            } 
                        }
                        onPositionChanged: {
                            deltaX = mouse.x - initialX;
                            if (Math.abs(deltaX) > 1) {
                                parent.x += deltaX;
                                initialX = mouse.x;
                                swiped = true;
                            }
                        }
                    }
                    Image {
                        source: "/qmlimages/StatusNotify.svg"
                        anchors.fill: parent
                        fillMode: Image.Stretch
                    }
                    QGCLabel {
                        text: model.text
                        font.pixelSize: 25
                        anchors.fill: parent
                        anchors.topMargin: 15
                        anchors.leftMargin: 10
                    }
                }
            }
            function addNotification(notificationId, text) {
                var timestamp = new Date().getTime(); 
                notificationModel.append({ notificationId: notificationId, text: text, timestamp: timestamp });
            }
            Component.onCompleted: {
                addNotification("gpsNoSignalNotification", "FALHA NO SINAL GPS");
                addNotification("gpsNotification", "SINAL BAIXO DO GPS");
                addNotification("altitudeRtlNotification", "ALTURA DE SEGURANÇA NÃO DEFINIDA");
                addNotification("lowBatNotification", "BATERIA BAIXA");
                addNotification("forFlyNotification", "PRONTO PARA VOO");
                addNotification("delocarNotification", "AGUARDANDO DECOLAGEM");
                addNotification("inFlyNotification", "EM VOO");
                addNotification("offRadio", "SEM SINAL COM RÁDIO");
            }            
        }


    //---Indicador de Area 
    /* Item {
        anchors.centerIn: parent
        visible:        activeVehicle = true

        Rectangle {
            width: parent.width
            height: parent.height
            radius: width / 2 // Define um raio para tornar a máscara circular
            color: "orange" // Cor de fundo da máscara
        }
    } */
//---------------------------------------------------------------------------------------------------------------------
    











} //FLY DISPLAY VIEW --------------------
