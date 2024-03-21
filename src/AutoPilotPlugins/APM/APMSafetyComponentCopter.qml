/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick              2.3
import QtQuick.Controls     1.2
import QtGraphicalEffects   1.0
import QtQuick.Layouts      1.2

import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

SetupPage {
    id:             safetyPage
    pageComponent:  safetyPageComponent

    Component {
        id: safetyPageComponent

        Flow {
            id:         flowLayout
            width:      availableWidth
            spacing:    _margins

            FactPanelController { id: controller; factPanel: safetyPage.viewPanel }

            QGCPalette { id: ggcPal; colorGroupEnabled: true }

            property Fact _failsafeGCSEnable:               controller.getParameterFact(-1, "FS_GCS_ENABLE")
            property Fact _failsafeBattLowAct:              controller.getParameterFact(-1, "r.BATT_FS_LOW_ACT", false /* reportMissing */)
            property Fact _failsafeBattMah:                 controller.getParameterFact(-1, "r.BATT_LOW_MAH", false /* reportMissing */)
            property Fact _failsafeBattVoltage:             controller.getParameterFact(-1, "r.BATT_LOW_VOLT", false /* reportMissing */)
            property Fact _failsafeThrEnable:               controller.getParameterFact(-1, "FS_THR_ENABLE")
            property Fact _failsafeThrValue:                controller.getParameterFact(-1, "FS_THR_VALUE")

            property Fact _batt1Monitor:                    controller.getParameterFact(-1, "BATT_MONITOR")
            property Fact _batt2Monitor:                    controller.getParameterFact(-1, "BATT2_MONITOR", false /* reportMissing */)
            property bool _batt2MonitorAvailable:           controller.parameterExists(-1, "BATT2_MONITOR")
            property bool _batt1MonitorEnabled:             _batt2MonitorAvailable ? _batt2Monitor.rawValue !== 0 : false
            property bool _batt2MonitorEnabled:             _batt2MonitorAvailable ? _batt2Monitor.rawValue !== 0 : false
            property bool _batt1ParamsAvailable:            controller.parameterExists(-1, "BATT_CAPACITY")
            property bool _batt2ParamsAvailable:            controller.parameterExists(-1, "BATT2_CAPACITY")

            property Fact _failsafeBattCritAct:             controller.getParameterFact(-1, "BATT_FS_CRT_ACT", false /* reportMissing */)
            property Fact _failsafeBatt2LowAct:             controller.getParameterFact(-1, "BATT2_FS_LOW_ACT", false /* reportMissing */)
            property Fact _failsafeBatt2CritAct:            controller.getParameterFact(-1, "BATT2_FS_CRT_ACT", false /* reportMissing */)
            property Fact _failsafeBatt2Mah:                controller.getParameterFact(-1, "BATT2_LOW_MAH", false /* reportMissing */)
            property Fact _failsafeBatt2Voltage:            controller.getParameterFact(-1, "BATT2_LOW_VOLT", false /* reportMissing */)

            property Fact _fenceAction: controller.getParameterFact(-1, "FENCE_ACTION")
            property Fact _fenceAltMax: controller.getParameterFact(-1, "FENCE_ALT_MAX")
            property Fact _fenceEnable: controller.getParameterFact(-1, "FENCE_ENABLE")
            property Fact _fenceMargin: controller.getParameterFact(-1, "FENCE_MARGIN")
            property Fact _fenceRadius: controller.getParameterFact(-1, "FENCE_RADIUS")
            property Fact _fenceType:   controller.getParameterFact(-1, "FENCE_TYPE")

            property Fact _landSpeedFact:   controller.getParameterFact(-1, "LAND_SPEED")
            property Fact _rtlAltFact:      controller.getParameterFact(-1, "RTL_ALT")
            property Fact _rtlLoitTimeFact: controller.getParameterFact(-1, "RTL_LOIT_TIME")
            property Fact _rtlAltFinalFact: controller.getParameterFact(-1, "RTL_ALT_FINAL")

            property Fact _armingCheck: controller.getParameterFact(-1, "ARMING_CHECK")

            property real _margins:     ScreenTools.defaultFontPixelHeight
            property bool _showIcon:    !ScreenTools.isTinyScreen

            ExclusiveGroup { id: fenceActionRadioGroup }
            ExclusiveGroup { id: landLoiterRadioGroup }
            ExclusiveGroup { id: returnAltRadioGroup }

            Column {
                spacing: _margins / 2

                QGCLabel {
                    id:             rtlLabel
                    text:           qsTr("Return to Launch")
                    font.family:    ScreenTools.demiboldFontFamily
                }

                Rectangle {
                    id:     rtlSettings
                    width:  rltAltFinalField.x + rltAltFinalField.width + _margins
                    height: rltAltFinalField.y + rltAltFinalField.height + _margins
                    color:  ggcPal.windowShade

                    Image {
                        id:                 icon
                        anchors.margins:    _margins
                        anchors.left:       parent.left
                        anchors.top:        parent.top
                        height:             ScreenTools.defaultFontPixelWidth * 20
                        width:              ScreenTools.defaultFontPixelWidth * 20
                        sourceSize.width:   width
                        mipmap:             true
                        fillMode:           Image.PreserveAspectFit
                        visible:            false
                        source:             "/qmlimages/ReturnToHomeAltitude.svg"
                    }

                    ColorOverlay {
                        anchors.fill:   icon
                        source:         icon
                        color:          ggcPal.text
                        visible:        _showIcon
                    }

                    QGCRadioButton {
                        id:                 returnAtCurrentRadio
                        anchors.margins:    _margins
                        anchors.left:       _showIcon ? icon.right : parent.left
                        anchors.top:        parent.top
                        text:               qsTr("Return at current altitude")
                        checked:            _rtlAltFact.value == 0
                        exclusiveGroup:     returnAltRadioGroup

                        onClicked: _rtlAltFact.value = 0
                    }

                    QGCRadioButton {
                        id:                 returnAltRadio
                        anchors.topMargin:  _margins
                        anchors.left:       returnAtCurrentRadio.left
                        anchors.top:        returnAtCurrentRadio.bottom
                        text:               qsTr("Return at specified altitude:")
                        exclusiveGroup:     returnAltRadioGroup
                        checked:            _rtlAltFact.value != 0

                        onClicked: _rtlAltFact.value = 1500
                    }

                    FactTextField {
                        id:                 rltAltField
                        anchors.leftMargin: _margins
                        anchors.left:       returnAltRadio.right
                        anchors.baseline:   returnAltRadio.baseline
                        fact:               _rtlAltFact
                        showUnits:          true
                        enabled:            returnAltRadio.checked
                        onCompleted: {
                            // Connect to a function that updates rtlAltField.value
                            inputValue.value = _rtlAltFact.value;
                        }
                        Connections {
                            target: mouseArea // mouseArea é o ID do MouseArea onde você definiu o sinal
                            onUpdateAltitude: {
                                console.log("Valor atual do Fact:", _rtlAltFact.value);
                                console.log("Novo valor recebido do MouseArea:", value);
                                mouseArea.value = value; // Atualiza o valor do FactTextField
                            }
                        }
                    }

                    QGCCheckBox {
                        id:                 homeLoiterCheckbox
                        anchors.left:       returnAtCurrentRadio.left
                        anchors.baseline:   landDelayField.baseline
                        checked:            _rtlLoitTimeFact.value > 0
                        text:               qsTr("Loiter above Home for:")

                        onClicked: _rtlLoitTimeFact.value = (checked ? 60 : 0)
                    }

                    FactTextField {
                        id:                 landDelayField
                        anchors.topMargin:  _margins * 1.5
                        anchors.left:       rltAltField.left
                        anchors.top:        rltAltField.bottom
                        fact:               _rtlLoitTimeFact
                        showUnits:          true
                        enabled:            homeLoiterCheckbox.checked === true
                    }

                    QGCRadioButton {
                        id:                 landRadio
                        anchors.left:       returnAtCurrentRadio.left
                        anchors.baseline:   landSpeedField.baseline
                        text:               qsTr("Land with descent speed:")
                        checked:            _rtlAltFinalFact.value == 0
                        exclusiveGroup:     landLoiterRadioGroup

                        onClicked: _rtlAltFinalFact.value = 0
                    }

                    FactTextField {
                        id:                 landSpeedField
                        anchors.topMargin:  _margins * 1.5
                        anchors.top:        landDelayField.bottom
                        anchors.left:       rltAltField.left
                        fact:               _landSpeedFact
                        showUnits:          true
                        enabled:            landRadio.checked
                    }

                    QGCRadioButton {
                        id:                 finalLoiterRadio
                        anchors.left:       returnAtCurrentRadio.left
                        anchors.baseline:   rltAltFinalField.baseline
                        text:               qsTr("Final loiter altitude:")
                        exclusiveGroup:     landLoiterRadioGroup

                        onClicked: _rtlAltFinalFact.value = _rtlAltFact.value
                    }

                    FactTextField {
                        id:                 rltAltFinalField
                        anchors.topMargin:  _margins / 2
                        anchors.left:       rltAltField.left
                        anchors.top:        landSpeedField.bottom
                        fact:               _rtlAltFinalFact
                        enabled:            finalLoiterRadio.checked
                        showUnits:          true
                    }
                } // Rectangle - RTL Settings
            } // Column - RTL Settings

            
        } // Flow
    } // Component - safetyPageComponent
} // SetupView
