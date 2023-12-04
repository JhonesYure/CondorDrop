/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2
import QtQuick.Layouts          1.2

import QGroundControl               1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ArduPilot     1.0

SetupPage {
    id:             sensorsPage
    pageComponent:  sensorsPageComponent

    Component {
        id:             sensorsPageComponent

        Item {
            width:  availableWidth
            height: availableHeight

            // Help text which is shown both in the status text area prior to pressing a cal button and in the
            // pre-calibration dialog.

            readonly property string orientationHelpSet:    qsTr("Se montado na direção do vôo, selecione Nenhum.")
            readonly property string orientationHelpCal:    qsTr("Antes de calibrar, certifique-se de que as configurações de rotação estejam corretas. ") + orientationHelpSet
            readonly property string compassRotationText:   qsTr("Se a bússola ou módulo GPS estiver montado na direção do vôo, deixe o valor padrão (Nenhum)")

            readonly property string compassHelp:   qsTr("Para a calibração da bússola, você precisará girar o veículo em várias posições.")
            readonly property string gyroHelp:      qsTr("Para a calibração do giroscópio você precisará colocar seu veículo em uma superfície e deixá-lo imóvel.")
            readonly property string accelHelp:     qsTr("Para a calibração do acelerômetro, você precisará colocar o veículo em todos os seis lados em uma superfície perfeitamente nivelada e mantê-lo imóvel em cada orientação por alguns segundos.")
            readonly property string levelHelp:     qsTr("Para nivelar o horizonte é necessário colocar o veículo na posição de vôo nivelado e pressionar OK.")

            readonly property string statusTextAreaDefaultText: qsTr("Inicie as etapas de calibração individuais clicando em um dos botões à esquerda.")

            // Used to pass help text to the preCalibrationDialog dialog
            property string preCalibrationDialogHelp

            property string _postCalibrationDialogText
            property var    _postCalibrationDialogParams

            readonly property string _badCompassCalText: qsTr("A calibração da Bússola %1 parece ser ruim.") +
                                                         qsTr("Verifique a posição da bússola no seu veículo e refaça a calibração.")

            readonly property int sideBarH1PointSize:  ScreenTools.mediumFontPointSize
            readonly property int mainTextH1PointSize: ScreenTools.mediumFontPointSize // Seems to be unused

            readonly property int rotationColumnWidth: 250

            property Fact noFact: Fact { }

            property bool accelCalNeeded:                   controller.accelSetupNeeded
            property bool compassCalNeeded:                 controller.compassSetupNeeded

            property Fact boardRot:                         controller.getParameterFact(-1, "AHRS_ORIENTATION")

            readonly property int _calTypeCompass:  1   ///< Calibrate compass
            readonly property int _calTypeAccel:    2   ///< Calibrate accel
            readonly property int _calTypeSet:      3   ///< Set orientations only
            readonly property int _buttonWidth:     ScreenTools.defaultFontPixelWidth * 15

            property bool   _orientationsDialogShowCompass: true
            property string _orientationDialogHelp:         orientationHelpSet
            property int    _orientationDialogCalType
            property real   _margins:                       ScreenTools.defaultFontPixelHeight / 2
            property bool   _compassAutoRotAvailable:       controller.parameterExists(-1, "COMPASS_AUTO_ROT")
            property Fact   _compassAutoRotFact:            controller.getParameterFact(-1, "COMPASS_AUTO_ROT", false /* reportMissing */)
            property bool   _compassAutoRot:                _compassAutoRotAvailable ? _compassAutoRotFact.rawValue == 2 : false

            function showOrientationsDialog(calType) {
                var dialogTitle
                var buttons = StandardButton.Ok

                _orientationDialogCalType = calType
                switch (calType) {
                case _calTypeCompass:
                    _orientationsDialogShowCompass = true
                    _orientationDialogHelp = orientationHelpCal
                    dialogTitle = qsTr("Calibrar Bússola")
                    buttons |= StandardButton.Cancel
                    break
                case _calTypeAccel:
                    _orientationsDialogShowCompass = false
                    _orientationDialogHelp = orientationHelpCal
                    dialogTitle = qsTr("Calibrar Acelerômetro")
                    buttons |= StandardButton.Cancel
                    break
                case _calTypeSet:
                    _orientationsDialogShowCompass = true
                    _orientationDialogHelp = orientationHelpSet
                    dialogTitle = qsTr("Sensor Settings")
                    break
                }

                mainWindow.showComponentDialog(orientationsDialogComponent, dialogTitle, mainWindow.showDialogDefaultWidth, buttons)
            }

            APMSensorParams {
                id:                     sensorParams
                factPanelController:    controller
            }

            APMSensorsComponentController {
                id:                         controller
                statusLog:                  statusTextArea
                progressBar:                progressBar
                nextButton:                 nextButton
                cancelButton:               cancelButton
                orientationCalAreaHelpText: orientationCalAreaHelpText

                property var rgCompassCalFitness: [ controller.compass1CalFitness, controller.compass2CalFitness, controller.compass3CalFitness ]

                onResetStatusTextArea: statusLog.text = statusTextAreaDefaultText

                onWaitingForCancelChanged: {
                    if (controller.waitingForCancel) {
                        mainWindow.showComponentDialog(waitForCancelDialogComponent, qsTr("Cancelar Calibração "), mainWindow.showDialogDefaultWidth, 0)
                    }
                }

                onCalibrationComplete: {
                    switch (calType) {
                    case APMSensorsComponentController.CalTypeAccel:
                        mainWindow.showComponentDialog(postCalibrationComponent, qsTr("Calibração do Acelerômetro Completo"), mainWindow.showDialogDefaultWidth, StandardButton.Ok)
                        break
                    case APMSensorsComponentController.CalTypeOffboardCompass:
                        mainWindow.showComponentDialog(postCalibrationComponent, qsTr("Calibração da Bússola Completa"), mainWindow.showDialogDefaultWidth, StandardButton.Ok)
                        break
                    case APMSensorsComponentController.CalTypeOnboardCompass:
                        mainWindow.showComponentDialog(postOnboardCompassCalibrationComponent, qsTr("Calibração Completa"), mainWindow.showDialogDefaultWidth, StandardButton.Ok)
                        break
                    }
                }

                onSetAllCalButtonsEnabled: {
                    buttonColumn.enabled = enabled
                }
            }

            Component.onCompleted: {
                var usingUDP = controller.usingUDPLink()
                var isSub = QGroundControl.multiVehicleManager.activeVehicle.sub;
                if (usingUDP && !isSub) {
                    mainWindow.showMessageDialog(qsTr("Calibração do Sensor"), qsTr("A calibração do sensor através de uma conexão WiFi pode não ser confiável. Se você tiver problemas, tente usar uma conexão USB direta."))
                }
            }

            QGCPalette { id: qgcPal; colorGroupEnabled: true }

            Component {
                id: waitForCancelDialogComponent

                QGCViewMessage {
                    message: qsTr("Aguardando a resposta do Veículo para Cancelar. Isso pode demorar alguns segundos.")

                    Connections {
                        target: controller

                        onWaitingForCancelChanged: {
                            if (!controller.waitingForCancel) {
                                hideDialog()
                            }
                        }
                    }
                }
            }

            Component {
                id: singleCompassOnboardResultsComponent

                Column {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    spacing:        Math.round(ScreenTools.defaultFontPixelHeight / 2)
                    visible:        sensorParams.rgCompassAvailable[index] && sensorParams.rgCompassUseFact[index].value

                    property real greenMaxThreshold:   8 * (sensorParams.rgCompassExternal[index] ? 1 : 2)
                    property real yellowMaxThreshold:  15 * (sensorParams.rgCompassExternal[index] ? 1 : 2)
                    property real fitnessRange:        25 * (sensorParams.rgCompassExternal[index] ? 1 : 2)

                    Item {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        height:         ScreenTools.defaultFontPixelHeight

                        Row {
                            id:             fitnessRow
                            anchors.fill:   parent

                            Rectangle {
                                width:  parent.width * (greenMaxThreshold / fitnessRange)
                                height: parent.height
                                color:  "green"
                            }
                            Rectangle {
                                width:  parent.width * ((yellowMaxThreshold - greenMaxThreshold) / fitnessRange)
                                height: parent.height
                                color:  "yellow"
                            }
                            Rectangle {
                                width:  parent.width * ((fitnessRange - yellowMaxThreshold) / fitnessRange)
                                height: parent.height
                                color:  "red"
                            }
                        }

                        Rectangle {
                            height:                 fitnessRow.height * 0.66
                            width:                  height
                            anchors.verticalCenter: fitnessRow.verticalCenter
                            x:                      (fitnessRow.width * (Math.min(Math.max(controller.rgCompassCalFitness[index], 0.0), fitnessRange) / fitnessRange)) - (width / 2)
                            radius:                 height / 2
                            color:                  "white"
                            border.color:           "black"
                        }
                    }

                    Column {
                        anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 2
                        anchors.left:       parent.left
                        anchors.right:      parent.right
                        spacing:            Math.round(ScreenTools.defaultFontPixelHeight / 4)

                        QGCLabel {
                            text: qsTr("Bússola ") + (index+1) + " " +
                                  (sensorParams.rgCompassPrimary[index] ? qsTr("(primario") : qsTr("(secondario")) +
                                  (sensorParams.rgCompassExternalParamAvailable[index] ?
                                       (sensorParams.rgCompassExternal[index] ? qsTr(", externo") : qsTr(", interno" )) :
                                       "") +
                                  ")"
                        }

                        FactCheckBox {
                            text:       qsTr("Usar Bússola")
                            fact:       sensorParams.rgCompassUseFact[index]
                            visible:    sensorParams.rgCompassUseParamAvailable[index] && !sensorParams.rgCompassPrimary[index]
                        }
                    }
                }
            }

            Component {
                id: postOnboardCompassCalibrationComponent

                QGCViewDialog {
                    Column {
                        anchors.margins:    ScreenTools.defaultFontPixelWidth
                        anchors.left:       parent.left
                        anchors.right:      parent.right
                        spacing:            ScreenTools.defaultFontPixelHeight

                        Repeater {
                            model:      3
                            delegate:   singleCompassOnboardResultsComponent
                        }

                        QGCLabel {
                            anchors.left:   parent.left
                            anchors.right:  parent.right
                            wrapMode:       Text.WordWrap
                            text:           qsTr("Nas barras indicadoras é mostrada a qualidade da calibração de cada bússola.\n\n") +
                                            qsTr("- Verde indica uma bússola funcionando bem.\n") +
                                            qsTr("- Amarelo indica uma bússola ou calibração questionável.\n") +
                                            qsTr("- Vermelho indica uma bússola que não deve ser usada.\n\n") +
                                            qsTr("VOCÊ DEVE REINICIAR SEU VEÍCULO APÓS CADA CALIBRAÇÃO.")
                        }

                        QGCButton {
                            text:       qsTr("Reiniciar Drone")
                            onClicked: {
                                controller.vehicle.rebootVehicle()
                                hideDialog()
                            }
                        }
                    }
                }
            }

            Component {
                id: postCalibrationComponent

                QGCViewDialog {
                    Column {
                        anchors.margins:    ScreenTools.defaultFontPixelWidth
                        anchors.left:       parent.left
                        anchors.right:      parent.right
                        spacing:            ScreenTools.defaultFontPixelHeight

                        QGCLabel {
                            anchors.left:   parent.left
                            anchors.right:  parent.right
                            wrapMode:       Text.WordWrap
                            text:           qsTr("VOCÊ DEVE REINICIALIZAR SEU VEÍCULO APÓS CADA CALIBRAÇÃO.")
                        }

                        QGCButton {
                            text:       qsTr("Reiniciar Drone")
                            onClicked: {
                                controller.vehicle.rebootVehicle()
                                hideDialog()
                            }
                       }
                    }
                }
            }

            Component {
                id: singleCompassSettingsComponent

                Column {
                    spacing: Math.round(ScreenTools.defaultFontPixelHeight / 2)
                    visible: sensorParams.rgCompassAvailable[index]

                    QGCLabel {
                        text: qsTr("Bússola ") + (index+1) + " " +
                              (sensorParams.rgCompassPrimary[index] ? qsTr("(primario") :qsTr( "(secondario")) +
                              (sensorParams.rgCompassExternalParamAvailable[index] ?
                                   (sensorParams.rgCompassExternal[index] ? qsTr(", externo") : qsTr(", interno") ) :
                                   "") +
                              ")"
                    }

                    Column {
                        anchors.margins:    ScreenTools.defaultFontPixelWidth * 2
                        anchors.left:       parent.left
                        spacing:            Math.round(ScreenTools.defaultFontPixelHeight / 4)

                        FactCheckBox {
                            text:       qsTr("Usar Bússola")
                            fact:       sensorParams.rgCompassUseFact[index]
                            visible:    sensorParams.rgCompassUseParamAvailable[index] && !sensorParams.rgCompassPrimary[index]
                        }

                        Column {
                            visible: !_compassAutoRot && sensorParams.rgCompassExternal[index] && sensorParams.rgCompassRotParamAvailable[index]

                            QGCLabel { text: qsTr("Orientação:") }

                            FactComboBox {
                                width:      rotationColumnWidth
                                indexModel: false
                                fact:       sensorParams.rgCompassRotFact[index]
                            }
                        }
                    }
                }
            }

            Component {
                id: orientationsDialogComponent

                QGCViewDialog {
                    id: orientationsDialog

                    function accept() {
                        if (_orientationDialogCalType == _calTypeAccel) {
                            controller.calibrateAccel()
                        } else if (_orientationDialogCalType == _calTypeCompass) {
                            controller.calibrateCompass()
                        }
                        orientationsDialog.hideDialog()
                    }

                    QGCFlickable {
                        anchors.fill:   parent
                        contentHeight:  columnLayout.height
                        clip:           true

                        Column {
                            id:                 columnLayout
                            anchors.margins:    ScreenTools.defaultFontPixelWidth
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            anchors.top:        parent.top
                            spacing:            ScreenTools.defaultFontPixelHeight

                            QGCLabel {
                                width:      parent.width
                                wrapMode:   Text.WordWrap
                                text:       _orientationDialogHelp
                            }

                            Column {
                                QGCLabel { text: qsTr("Rotação do piloto automático:") }

                                FactComboBox {
                                    width:      rotationColumnWidth
                                    indexModel: false
                                    fact:       boardRot
                                }
                            }

                            Repeater {
                                model:      _orientationsDialogShowCompass ? 3 : 0
                                delegate:   singleCompassSettingsComponent
                            }
                        } // Column
                    } // QGCFlickable
                } // QGCViewDialog
            } // Component - orientationsDialogComponent

            Component {
                id: compassMotDialogComponent

                QGCViewDialog {
                    id: compassMotDialog

                    function accept() {
                        controller.calibrateMotorInterference()
                        compassMotDialog.hideDialog()
                    }

                    QGCFlickable {
                        anchors.fill:   parent
                        contentHeight:  columnLayout.height
                        clip:           true

                        Column {
                            id:                 columnLayout
                            anchors.margins:    ScreenTools.defaultFontPixelWidth
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            anchors.top:        parent.top
                            spacing:            ScreenTools.defaultFontPixelHeight

                            QGCLabel {
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                wrapMode:       Text.WordWrap
                                text:           qsTr("Isto é recomendado para veículos que possuem apenas uma bússola interna e em veículos onde há interferência significativa na bússola proveniente de motores, fios de alimentação, etc. ") +
                                                qsTr("O CompassMot só funciona bem se você tiver um monitor de corrente da bateria porque a interferência magnética é linear com a corrente consumida. ") +
                                                qsTr("É tecnicamente possível configurar o CompassMot usando acelerador, mas isso não é recomendado.")
                            }

                            QGCLabel {
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                wrapMode:       Text.WordWrap
                                text:           qsTr("Desconecte seus adereços, vire-os e gire-os em uma posição ao redor do quadro.") +
                                                qsTr("Nesta configuração eles devem empurrar o helicóptero para o chão quando o acelerador for aumentado.")
                            }

                            QGCLabel {
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                wrapMode:       Text.WordWrap
                                text:           qsTr("Prenda o helicóptero (talvez com fita adesiva) para que ele não se mova.")
                            }

                            QGCLabel {
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                wrapMode:       Text.WordWrap
                                text:           qsTr("Ligue o transmissor e mantenha o acelerador em zero.")
                            }

                            QGCLabel {
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                wrapMode:       Text.WordWrap
                                text:           qsTr("Clique em Ok para iniciar a calibração do CompassMot.")
                            }
                        } // Column
                    } // QGCFlickable
                } // QGCViewDialog
            } // Component - compassMotDialogComponent

            Component {
                id: levelHorizonDialogComponent

                QGCViewDialog {
                    id: levelHorizonDialog

                    function accept() {
                        controller.levelHorizon()
                        levelHorizonDialog.hideDialog()
                    }

                    QGCLabel {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        wrapMode:       Text.WordWrap
                        text:           qsTr("Para nivelar o horizonte você precisa colocar o veículo em posição de vôo nivelado e pressionar OK.")
                    }
                } // QGCViewDialog
            } // Component - levelHorizonDialogComponent

            Component {
                id: calibratePressureDialogComponent

                QGCViewDialog {
                    id: calibratePressureDialog

                    function accept() {
                        controller.calibratePressure()
                        calibratePressureDialog.hideDialog()
                    }

                    QGCLabel {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        wrapMode:       Text.WordWrap
                        text:           _helpText

                        readonly property string _altText:      activeVehicle.sub ? qsTr("profundidade") : qsTr("altitude")
                        readonly property string _helpText:     qsTr("A calibração de pressão definirá %1 como zero na leitura de pressão atual. %2").arg(_altText).arg(_helpTextFW)
                        readonly property string _helpTextFW:   activeVehicle.fixedWing ? qsTr("Para calibrar o sensor de velocidade no ar, proteja-o do vento. Não toque no sensor nem obstrua nenhum orifício durante a calibração.") : ""
                    }
                } // QGCViewDialog
            } // Component - calibratePressureDialogComponent

            QGCFlickable {
                id:             buttonFlickable
                anchors.left:   parent.left
                anchors.top:    parent.top
                anchors.bottom: parent.bottom
                width:          _buttonWidth
                contentHeight:  nextCancelColumn.y + nextCancelColumn.height + _margins

                // Calibration button column - Calibratin buttons are kept in a separate column from Next/Cancel buttons
                // so we can enable/disable them all as a group
                Column {
                    id:                 buttonColumn
                    spacing:            _margins
                    Layout.alignment:   Qt.AlignLeft | Qt.AlignTop

                    IndicatorButton {
                        width:          _buttonWidth
                        text:           qsTr("Acelerômetro")
                        indicatorGreen: !accelCalNeeded

                        onClicked: showOrientationsDialog(_calTypeAccel)
                    }

                    IndicatorButton {
                        width:          _buttonWidth
                        text:           qsTr("Bússola")
                        indicatorGreen: !compassCalNeeded

                        onClicked: {
                            if (controller.accelSetupNeeded) {
                                mainWindow.showMessageDialog(qsTr("Calibrar Bússola"), qsTr("O acelerômetro deve ser calibrado antes da bússola."))
                            } else {
                                showOrientationsDialog(_calTypeCompass)
                            }
                        }
                    }

                    /*  QGCButton {
                        width:  _buttonWidth
                        text:   _levelHorizonText

                        readonly property string _levelHorizonText: qsTr("Level Horizon")

                        onClicked: {
                            if (controller.accelSetupNeeded) {
                                mainWindow.showMessageDialog(_levelHorizonText, qsTr("Accelerometer must be calibrated prior to Level Horizon."))
                            } else {
                                mainWindow.showComponentDialog(levelHorizonDialogComponent, _levelHorizonText, mainWindow.showDialogDefaultWidth, StandardButton.Cancel | StandardButton.Ok)
                            }
                        }
                    } */

                    /* QGCButton {
                        width:      _buttonWidth
                        text:       _calibratePressureText
                        onClicked:  mainWindow.showComponentDialog(calibratePressureDialogComponent, _calibratePressureText, mainWindow.showDialogDefaultWidth, StandardButton.Cancel | StandardButton.Ok)

                        readonly property string _calibratePressureText: activeVehicle.fixedWing ? qsTr("Cal Baro/Airspeed") : qsTr("Calibrate Pressure")
                    } */

                    /* QGCButton {
                        width:      _buttonWidth
                        text:       qsTr("CompassMot")
                        visible:    activeVehicle ? activeVehicle.supportsMotorInterference : false

                        onClicked:  mainWindow.showComponentDialog(compassMotDialogComponent, qsTr("CompassMot - Compass Motor Interference Calibration"), mainWindow.showDialogFullWidth, StandardButton.Cancel | StandardButton.Ok)
                    } */

                    /* QGCButton {
                        width:      _buttonWidth
                        text:       qsTr("Sensor Settings")
                        onClicked:  showOrientationsDialog(_calTypeSet)
                    } */
                } // Column - Cal Buttons

                Column {
                    id:                 nextCancelColumn
                    anchors.topMargin:  buttonColumn.spacing
                    anchors.top:        buttonColumn.bottom
                    anchors.left:       buttonColumn.left
                    spacing:            buttonColumn.spacing

                    QGCButton {
                        id:         nextButton
                        width:      _buttonWidth
                        text:       qsTr("Próximo")
                        enabled:    false
                        onClicked:  controller.nextClicked()
                    }

                    QGCButton {
                        id:         cancelButton
                        width:      _buttonWidth
                        text:       qsTr("Cancelar")
                        enabled:    false
                        onClicked:  controller.cancelCalibration()
                    }
                }
            } // QGCFlickable - buttons

            /// Right column - cal area
            Column {
                anchors.leftMargin: _margins
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                anchors.left:       buttonFlickable.right
                anchors.right:      parent.right

                ProgressBar {
                    id:             progressBar
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                }

                Item { height: ScreenTools.defaultFontPixelHeight; width: 10 } // spacer

                Item {
                    id:     centerPanel
                    width:  parent.width
                    height: parent.height - y

                    TextArea {
                        id:             statusTextArea
                        anchors.fill:   parent
                        readOnly:       true
                        frameVisible:   false
                        text:           statusTextAreaDefaultText

                        style: TextAreaStyle {
                            textColor:          qgcPal.text
                            backgroundColor:    qgcPal.windowShade
                        }
                    }

                    Rectangle {
                        id:             orientationCalArea
                        anchors.fill:   parent
                        visible:        controller.showOrientationCalArea
                        color:          qgcPal.windowShade

                        QGCLabel {
                            id:                 orientationCalAreaHelpText
                            anchors.margins:    ScreenTools.defaultFontPixelWidth
                            anchors.top:        orientationCalArea.top
                            anchors.left:       orientationCalArea.left
                            width:              parent.width
                            wrapMode:           Text.WordWrap
                            font.pointSize:     ScreenTools.mediumFontPointSize
                        }

                        Flow {
                            anchors.topMargin:  ScreenTools.defaultFontPixelWidth
                            anchors.top:        orientationCalAreaHelpText.bottom
                            anchors.bottom:     parent.bottom
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            spacing:            ScreenTools.defaultFontPixelWidth

                            property real indicatorWidth:   (width / 3) - (spacing * 2)
                            property real indicatorHeight:  (height / 2) - spacing

                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalDownSideVisible
                                calValid:           controller.orientationCalDownSideDone
                                calInProgress:      controller.orientationCalDownSideInProgress
                                calInProgressText:  controller.orientationCalDownSideRotate ? qsTr("Rotate") : qsTr("Hold Still")
                                imageSource:        "qrc:///qmlimages/VehicleDown.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalLeftSideVisible
                                calValid:           controller.orientationCalLeftSideDone
                                calInProgress:      controller.orientationCalLeftSideInProgress
                                calInProgressText:  controller.orientationCalLeftSideRotate ? qsTr("Rotate") : qsTr("Hold Still")
                                imageSource:        "qrc:///qmlimages/VehicleLeft.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalRightSideVisible
                                calValid:           controller.orientationCalRightSideDone
                                calInProgress:      controller.orientationCalRightSideInProgress
                                calInProgressText:  controller.orientationCalRightSideRotate ? qsTr("Rotate") : qsTr("Hold Still")
                                imageSource:        "qrc:///qmlimages/VehicleRight.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalNoseDownSideVisible
                                calValid:           controller.orientationCalNoseDownSideDone
                                calInProgress:      controller.orientationCalNoseDownSideInProgress
                                calInProgressText:  controller.orientationCalNoseDownSideRotate ? qsTr("Rotate") : qsTr("Hold Still")
                                imageSource:        "qrc:///qmlimages/VehicleNoseDown.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalTailDownSideVisible
                                calValid:           controller.orientationCalTailDownSideDone
                                calInProgress:      controller.orientationCalTailDownSideInProgress
                                calInProgressText:  controller.orientationCalTailDownSideRotate ? qsTr("Rotate") : qsTr("Hold Still")
                                imageSource:        "qrc:///qmlimages/VehicleTailDown.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalUpsideDownSideVisible
                                calValid:           controller.orientationCalUpsideDownSideDone
                                calInProgress:      controller.orientationCalUpsideDownSideInProgress
                                calInProgressText:  controller.orientationCalUpsideDownSideRotate ? qsTr("Rotate") : qsTr("Hold Still")
                                imageSource:        "qrc:///qmlimages/VehicleUpsideDown.png"
                            }
                        }
                    }
                } // Item - Cal display area
            } // Column - cal display
        } // Row
    } // Component - sensorsPageComponent
} // SetupPage
