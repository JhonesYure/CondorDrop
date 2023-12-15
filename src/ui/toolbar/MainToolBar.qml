/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

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

Item {
    id: toolBar
    anchors.fill:                           parent
    property string sectionTitle:           qsTr("Fly")
    property bool   inPlanView:             planViewLoader.visible
    property bool   inFlyView:              rootBackground.visible
    property color  menuSeparatorColor:     qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0,0,0,0.25) : Qt.rgba(1,1,1,0.25)
    property bool _armed:           activeVehicle ? activeVehicle.armed : false

    Component.onCompleted: {
        //-- TODO: Get this from the actual state
        flyButton.checked = true
    }
    //------------------------
        function getPositionForBatteryPercentage() {
            if (activeVehicle && activeVehicle.battery.voltage.value !== -1) {
                var batteryVoltage = activeVehicle.battery.voltage.value;
                var minVoltage = 21.9;
                var maxVoltage = 26.1;

                var position = (batteryVoltage - minVoltage) / (maxVoltage - minVoltage);

                position = Math.max(0, Math.min(1, position));

                return position;
            }
            return 0;
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

    /// Bottom single pixel divider
    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         1
        color:          "black"
        visible:        qgcPal.globalTheme === QGCPalette.Light
    }
    //-- Setup can be invoked from c++ side
    Connections {
        target: setupWindow
        onVisibleChanged: {
            if (setupWindow.visible) {
                buttonRow.clearAllChecks()
                setupButton.checked = true
            }
        }
    }

    QGCFlickable {
        anchors.fill:       parent
        contentWidth:       toolbarRow.width
        flickableDirection: Flickable.HorizontalFlick

        RowLayout {
            id:                     toolbarRow
            anchors.bottomMargin:   1
            anchors.top:            parent.top
            anchors.bottom:         parent.bottom
            spacing:                ScreenTools.defaultFontPixelWidth / 2

            // Important Note: Toolbar buttons must manage their checked state manually in order to support
            // view switch prevention. There doesn't seem to be a way to make this work if they are in a
            // ButtonGroup.

            //---------------------------------------------
            // Toolbar Row
            RowLayout {
                id:                 buttonRow
                Layout.fillHeight:  true
                spacing:            620
                height:             80
                //anchors.rightMargin: 80
                function clearAllChecks() {
                    for (var i=0; i<buttonRow.children.length; i++) {
                        if (buttonRow.children[i].toString().startsWith("QGCToolBarButton")) {
                            buttonRow.children[i].checked = false
                        }
                    }
                }

                QGCToolBarButton {
                    id:                 settingsButton
                    //anchors.leftMargin:     40
                    
                    Image {
                        id:                     _icon
                        //height:                 _rootButton.height 
                        height:                 100
                        width:                  100//ScreenTools.defaultFontPixelWidth * 10
                        smooth:                 true
                        mipmap:                 true
                        antialiasing:           true
                        //fillMode:               Image.PreserveAspectFit
                        source:                  "/qmlimages/LogoDrop" /* qgcPal.globalTheme === QGCPalette.Light ? "/res/QGCLogoBlack" : */
                        sourceSize.height:      height 
                        anchors.verticalCenter: parent.verticalCenter 
                    }
                    
                    QGCMouseArea {
                        fillItem: parent
                        onClicked: {
                            if (!_armed) {
                                //mainWindow.armVehicle();
                                // Se o veículo não estiver armado, permita a abertura/fechamento do menu
                                if (drawer.visible) {
                                    drawer.close();
                                } else {
                                    drawer.open();
                                }
                            }
                        }
                    }
                }
                
                

                Drawer {
                    id:                                 drawer
                    y:                                  header.height
                    height:                             mainWindow.height - header.height
                    width:                              innerLayout.width + (_margins * 2)
                    closePolicy:                        Popup.CloseOnEscape | Popup.CloseOnPressOutside
                    background: Rectangle {
                        color:                          qgcPal.window
                        ///opacity:                        0.8
                    } 
                    ButtonGroup {
                        id:                             buttonGroup
                        buttons:                        buttons.children
                    }
                    ColumnLayout{
                        id:                             buttons
                        spacing:                        0
                        anchors.top:                    parent.top
                        anchors.left:                   parent.left
                        anchors.right:                  parent.right

                        //-------------- FLY 
                        Rectangle{
                            Layout.alignment:           Qt.AlignVCenter
                            width:                      parent.width
                            height:                     1
                            color:                      menuSeparatorColor
                        }
                        QGCToolBarButton {
                            id:                 flyButton
                            Layout.fillWidth:           true
                            spacing:                    1
                            icon.source:        "/res/QGCLogoWhite"
                            text:               qsTr("Voltar")
                            onClicked: {
                                if (mainWindow.preventViewSwitch()) {
                                    return
                                }
                                buttonRow.clearAllChecks()
                                checked = true
                                mainWindow.showFlyView()

                                // Easter Egg mechanism
                                _clickCount++
                                eggTimer.restart()
                                if (_clickCount == 5) {
                                    if(!QGroundControl.corePlugin.showAdvancedUI) {
                                        advancedModeConfirmation.open()
                                    } else {
                                        QGroundControl.corePlugin.showAdvancedUI = false
                                    }
                                } else if (_clickCount == 7) {
                                    QGroundControl.corePlugin.showTouchAreas = !QGroundControl.corePlugin.showTouchAreas
                                }
                            }

                            property int _clickCount: 0

                            Timer {
                                id:             eggTimer
                                interval:       1000
                                repeat:         false
                                onTriggered:    parent._clickCount = 0
                            }

                            MessageDialog {
                                id:                 advancedModeConfirmation
                                title:              qsTr("Advanced Mode")
                                text:               QGroundControl.corePlugin.showAdvancedUIMessage
                                standardButtons:    StandardButton.Yes | StandardButton.No
                                onYes: {
                                    QGroundControl.corePlugin.showAdvancedUI = true
                                    advancedModeConfirmation.close()
                                }
                            }
                        }

                        //------------ CONFIGURAÇÕES GERAIS
                        Rectangle{
                            Layout.alignment:           Qt.AlignVCenter
                            width:                      parent.width
                            height:                     1
                            color:                      menuSeparatorColor
                        }
                        QGCToolBarButton {
                            id:                 configButton
                            Layout.fillWidth:           true
                            spacing:                    1
                            text:               qsTr("Configuração do Aplicativo")
                            icon.source:        "/qmlimages/Gears.svg"
                            onClicked: {
                                if (mainWindow.preventViewSwitch()) {
                                        return
                                    }
                                    buttonRow.clearAllChecks()
                                    checked = true
                                    mainWindow.showSettingsView()
                                }
                        }

                        //------------- VEHICLE SETUP
                        Rectangle{
                            Layout.alignment:           Qt.AlignVCenter
                            width:                      parent.width
                            height:                     1
                            color:                      menuSeparatorColor
                        }
                        QGCToolBarButton {
                            id:                 setupButton
                            Layout.fillWidth:           true
                            spacing:                    1
                            icon.source:        "/qmlimages/Quad.svg"
                            text:               qsTr("Configuração do Drone")
                            onClicked: {
                                if (mainWindow.preventViewSwitch()) {
                                    return
                                }
                                buttonRow.clearAllChecks()
                                checked = true
                                mainWindow.showSetupView()
                            }
                        }

                        //----------- ANALYZE
                        Rectangle{
                            Layout.alignment:           Qt.AlignVCenter
                            width:                      parent.width
                            height:                     1
                            color:                      menuSeparatorColor
                        }
                        QGCToolBarButton {
                            id:                 analyzeButton
                            Layout.fillWidth:           true
                            spacing:                    1
                            icon.source:        "/qmlimages/Analyze.svg"
                            text:               qsTr("Ferramenta de Análise")
                            visible:            QGroundControl.corePlugin.showAdvancedUI
                            onClicked: {
                                if (mainWindow.preventViewSwitch()) {
                                    return
                                }
                                buttonRow.clearAllChecks()
                                checked = true
                                mainWindow.showAnalyzeView()
                            }
                        }

                        
                        Rectangle{
                            Layout.alignment:           Qt.AlignVCenter
                            width:                      parent.width
                            height:                     1
                            color:                      menuSeparatorColor
                        }
                        /* QGCToolBarButton {
                            id:                 planButton
                            Layout.fillHeight:  true
                            icon.source:        "/qmlimages/Plan.svg"
                            onClicked: {
                                if (mainWindow) {
                                    return
                                }
                                buttonRow.clearAllChecks()
                                checked = true
                                mainWindow.showHelpSettings()
                            }
                        } */
                    }
                }

                Item {
                    Layout.fillHeight:  true
                    width:              ScreenTools.defaultFontPixelWidth / 2
                    visible:            activeVehicle
                }

                Item {
                    id:         notificationIndicator
                    y:          20
                    visible:    true
                    anchors.left: parent.left
                    anchors.leftMargin: 220

                    Text {
                        id: textIndicator
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        
                        font.pointSize: 15
                        font.bold: true
                        color: "white"
                        text: activeVehicle ? "CONECTADO" : "DESCONECTADO"
                    }

                    
                    property bool activeVehicle: false

                    Component.onCompleted: {
                        yourObject.activeVehicleChanged.connect(function() {
                            textIndicator.text = yourObject.activeVehicle ? "DESCONECTADO" : "DISPARO EFETUADO COM SUCESSO";
                        });
                    }
                }

                Item {
                    id:         modeIndicatorFlight
                    y:          20
                    anchors.left: parent.left
                    anchors.leftMargin: 700
                    anchors.topMargin: 10

                    QGCComboBox {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.bottom: parent.bottom
                        //anchors.top: parent.top
                        alternateText:          _activeVehicle ? _activeVehicle.flightMode : ""
                        //model:                  _flightModes
                        font.pointSize:             20//ScreenTools.mediumFontPointSize
                        //currentIndex:           -1
                        //sizeToContents:         true

                        //property bool showIndicator: true

                        property var _activeVehicle:    QGroundControl.multiVehicleManager.activeVehicle
                        property var _flightModes:      _activeVehicle ? _activeVehicle.flightModes : [ ]

                        onActivated: {
                            _activeVehicle.flightMode = _flightModes[index]
                            currentIndex = -1
                        }
                    }

                    property var _activeVehicle:    QGroundControl.multiVehicleManager.activeVehicle
                    property var _flightModes:      _activeVehicle ? _activeVehicle.flightModes : [ ]
                    property bool activeVehicle: false
                }

                Item {
                    Layout.fillHeight:  true
                    width:              ScreenTools.defaultFontPixelWidth / 2
                    visible:            activeVehicle
                }
            }
            /* Item{
                anchors.rightMargin: 100
                Image{
                    source: "/qmlimages/RedStatus.svg"
                }
            } */
            /* MainStatusIndicator {
                Layout.preferredHeight: viewButtonRow.height
                visible:                true //currentToolbar === flyViewToolbar
            } */

            RowLayout{
                spacing: 180
                y:       10
                Loader {
                    id:                 toolbarIndicators
                    Layout.fillHeight:  true
                    
                    source:             "/toolbar/MainToolBarIndicators.qml"
                    visible:            activeVehicle && !communicationLost
                }
            }
            
        }
    }

    //-------------------------------------------------------------------------
    //-- Branding Logo
    /* Image {
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        //anchors.margins:        ScreenTools.defaultFontPixelHeight * 1.66
        visible:                activeVehicle && !communicationLost && x > (toolbarRow.x + toolbarRow.width + ScreenTools.defaultFontPixelWidth)
        fillMode:               Image.PreserveAspectFit
        source:                 _outdoorPalette ? _brandImageOutdoor : _brandImageIndoor
        mipmap:                 true

        property bool   _outdoorPalette:        qgcPal.globalTheme === QGCPalette.Light
        property bool   _corePluginBranding:    QGroundControl.corePlugin.brandImageIndoor.length != 0
        property string _userBrandImageIndoor:  QGroundControl.settingsManager.brandImageSettings.userBrandImageIndoor.value
        property string _userBrandImageOutdoor: QGroundControl.settingsManager.brandImageSettings.userBrandImageOutdoor.value
        property bool   _userBrandingIndoor:    _userBrandImageIndoor.length != 0
        property bool   _userBrandingOutdoor:   _userBrandImageOutdoor.length != 0
        property string _brandImageIndoor:      _userBrandingIndoor ?
                                                    _userBrandImageIndoor : (_userBrandingOutdoor ?
                                                        _userBrandImageOutdoor : (_corePluginBranding ?
                                                            QGroundControl.corePlugin.brandImageIndoor : (activeVehicle ?
                                                                activeVehicle.brandImageIndoor : ""
                                                            )
                                                        )
                                                    )
        property string _brandImageOutdoor:     _userBrandingOutdoor ?
                                                    _userBrandImageOutdoor : (_userBrandingIndoor ?
                                                        _userBrandImageIndoor : (_corePluginBranding ?
                                                            QGroundControl.corePlugin.brandImageOutdoor : (activeVehicle ?
                                                                activeVehicle.brandImageOutdoor : ""
                                                            )
                                                        )
                                                    )
    } */

    // Small parameter download progress bar
    Rectangle {
        anchors.bottom: parent.bottom
        height:         toolBar.height * 0.05
        width:          activeVehicle ? activeVehicle.parameterManager.loadProgress * parent.width : 0
        color:          qgcPal.colorGreen
        visible:        !largeProgressBar.visible

    }

    // Large parameter download progress bar
    Rectangle {
        id:             largeProgressBar
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height:         parent.height
        color:          qgcPal.window
        visible:        _showLargeProgress

        property bool _initialDownloadComplete: activeVehicle ? activeVehicle.parameterManager.parametersReady : true
        property bool _userHide:                false
        property bool _showLargeProgress:       !_initialDownloadComplete && !_userHide && qgcPal.globalTheme === QGCPalette.Light

        Connections {
            target:                 QGroundControl.multiVehicleManager
            onActiveVehicleChanged: largeProgressBar._userHide = false
        }

        Rectangle {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width:          activeVehicle ? activeVehicle.parameterManager.loadProgress * parent.width : 0
            color:          qgcPal.colorGreen
        }

        QGCLabel {
            anchors.centerIn:   parent
            text:               qsTr("Downloading Parameters")
            font.pointSize:     ScreenTools.largeFontPointSize
        }

        QGCLabel {
            anchors.margins:    _margin
            anchors.right:      parent.right
            anchors.bottom:     parent.bottom
            text:               qsTr("Click anywhere to hide")

            property real _margin: ScreenTools.defaultFontPixelWidth / 2
        }

        MouseArea {
            anchors.fill:   parent
            onClicked:      largeProgressBar._userHide = true
        }
    }


    //-------------------------------------------------------------------------
    //-- Waiting for a vehicle
    QGCLabel {
        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter
        text:                   qsTr("Esperando Conectar com Drone")
        font.pointSize:         ScreenTools.mediumFontPointSize
        font.family:            ScreenTools.demiboldFontFamily
        color:                  qgcPal.colorRed
        visible:                !activeVehicle
    }


     //EDIT SKYDRONES FLY TIME----------
    Item {
        width: 1200
        height: 10
        anchors {
            left: parent.left
            leftMargin: 630
            top: parent.top
            topMargin: 88
        }
        Rectangle {
            width: parent.width * 0.75 // 30% em amarelo
            height: 10//parent.height
            color: "#FFDA24"
            anchors.centerIn: parent
            /* Rectangle {
                width: 20
                height: 20
                radius: 10
                color: "#CF0000" // Cor inicial da bolinha
                anchors.verticalCenter: parent.verticalCenter
                //anchors.left: parent.left
            } */
        }
        Rectangle {
            width: parent.width * 0.15 // 20% em vermelho
            height: 10//parent.height
            color: "#CF0000"
            //radius: 5
        }
        Rectangle {
            width: parent.width * 0.5 // 50% em verde
            height: 10//parent.height
            color: "#00B91A"
            anchors.right: parent.right
            Rectangle {
                width: 20
                height: 20
                radius:10
                color: "#FFDA24" // Cor inicial da bolinha
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        /* Image {
            source: "/res/StatusBattery"
            //width: 1200
            //height: 30
            fillMode: Image.PreserveAspectCrop
        } */
        Rectangle {
            id:                     testIndicator
            //color:                  qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1,1,1,0.95) : Qt.rgba(0,0,0,0.2)//0.3
            width:                  testStatusGrid.width  + (ScreenTools.defaultFontPixelWidth  )//5
            height:                 25//testStatusGrid.height + (ScreenTools.defaultFontPixelHeight )//1.5
            radius:                 18
            //x:                      Math.round((mainWindow.width  - width) )//0.5
            //y:                      Math.round((mainWindow.height - height) )//0.5
            //anchors.top:            parent.top//battTimeLoader.top
            //anchors.topMargin:      ScreenTools.defaultFontPixelHeight * (_airspaceIndicatorVisible  ? 3 : 1.3)//
            //anchors.horizontalCenter: parent.horizontalCenter
            //anchors.topMargin: 58
            //anchors.leftMargin: 600
            //anchors.left:           vehicleIndicator.left
            //anchors.leftMargin:     ScreenTools.defaultFontPixelWidth  * 80
            anchors {
                right: parent.right
                rightMargin: 0 // Altere esta margem para 0 para alinhar à direita
                verticalCenter: parent.verticalCenter
            }
            //  Layout
            GridLayout {
                id:                     testStatusGrid
                columnSpacing:          ScreenTools.defaultFontPixelWidth  * 2
                rowSpacing:             ScreenTools.defaultFontPixelHeight * 0.5
                columns:                10
                anchors.centerIn:       parent
                Layout.fillWidth:       false
                
                //-- 8 Chronometer
                QGCColoredImage {
                    height:                 _indicatorsHeight
                    width:                  height
                    fillMode:               Image.PreserveAspectFit
                    sourceSize.height:      height
                    Layout.alignment:       Qt.AlignVCenter | Qt.AlignHCenter
                    color:                  qgcPal.text
                }
                QGCLabel {
                    text: {
                        if (activeVehicle)
                            return secondsToMMSS(activeVehicle.getFact("flightTime").value)
                        return "00:00"
                    }
                    color: _indicatorsColor
                    font.pointSize: 7
                    Layout.fillWidth: true
                    Layout.minimumWidth: indicatorValueWidth
                    horizontalAlignment: firstLabel.horizontalAlignment
                }
                
            }
        }
        //-------------------------
        Rectangle {
            id: batteryBall
            width: 20
            height: 20
            radius: width / 2
            //color: getColorForBatteryPercentage() // Cor da bolinha com base na voltagem
            anchors.verticalCenter: parent.verticalCenter
            x: getPositionForBatteryPercentage() * (parent.width - width)
            Rectangle {
                width: 20
                height: 20
                radius: width / 2
                color: "yellow" // Cor inicial da bolinha
                anchors.verticalCenter: parent.verticalCenter
            }
            Behavior on x {
                NumberAnimation {
                    duration: 3000 // Ajuste a velocidade da animação conforme necessário
                }
            }
            Text {
                anchors.centerIn: parent
                text: "H" // Substitua "A" pela letra desejada
                font.pixelSize: 15 // Ajuste o tamanho da fonte conforme necessário
                color: "black" // Cor do texto
            }
        }
        
    }


    //-------------------------------------------------------------------------
    //-- Connection Status
    Row {
        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.right:          parent.right
        layoutDirection:        Qt.RightToLeft
        spacing:                ScreenTools.defaultFontPixelWidth
        visible:                activeVehicle && communicationLost

        QGCButton {
            id:                     disconnectButton
            anchors.verticalCenter: parent.verticalCenter
            text:                   qsTr("Desconectado")
            primary:                true
            onClicked:              activeVehicle.disconnectInactiveVehicle()
        }

        QGCLabel {
            id:                     connectionLost
            anchors.verticalCenter: parent.verticalCenter
            text:                   qsTr("Perda de Sinal")
            font.pointSize:         ScreenTools.largeFontPointSize
            font.family:            ScreenTools.demiboldFontFamily
            color:                  qgcPal.colorRed
        }
    }

}
