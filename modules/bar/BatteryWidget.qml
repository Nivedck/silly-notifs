import QtQuick
import QtQuick.Effects
import Quickshell.Services.UPower
import "root:/config"

Item {
    id: batterywidget
    implicitWidth: 30
    implicitHeight: 20

    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: battery ? battery.isLaptopBattery : false
    readonly property bool isCharging: !UPower.onBattery
    readonly property int percentage: battery ? Math.round(battery.percentage * 100) : 0

    visible: batterywidget.hasBattery

    Item {
        id: container
        anchors.fill: parent

        property real blurAmount: 0.0

        Rectangle {
            id: backgroundBox
            anchors.fill: parent
            radius: height / 2
            color: batterywidget.isCharging ? "#bbd96a" : Theme.foreground

            onColorChanged: {
                scaleAnimation.restart();
            }
        }

        Text {
            id: batteryText
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Theme.background
            font.pixelSize: 15
            font.weight: 700
            font.family: "CaskaydiaCove NF"
            // font.family: "Adwaita Sans"
            text: batterywidget.percentage
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: container.blurAmount
            blurMax: 32
        }

        SequentialAnimation {
            id: scaleAnimation
            ParallelAnimation {
                NumberAnimation {
                    target: container
                    property: "scale"
                    to: 0.3
                    duration: 250
                    easing.type: Easing.InQuad
                }
                NumberAnimation {
                    target: container
                    property: "blurAmount"
                    to: 2.5
                    duration: 250
                    easing.type: Easing.InQuad
                }
            }
            ParallelAnimation {
                NumberAnimation {
                    target: container
                    property: "scale"
                    to: 1.0
                    duration: 300
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: container
                    property: "blurAmount"
                    to: 0.0
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }
        }
    }
}
