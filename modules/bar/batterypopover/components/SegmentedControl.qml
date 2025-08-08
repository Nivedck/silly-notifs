import QtQuick
import "root:/config"

Item {
    id: segmentedControl

    // Public properties
    property int currentIndex: 0
    property var segments: ["Option 1", "Option 2"]
    property var dataMap: [] // Optional data mapping array
    property real segmentHeight: 36
    property real segmentRadius: 18
    property real sliderRadius: 16
    property real fontSize: 12
    property string fontFamily: "CaskaydiaCove NF"

    // Colors
    property color backgroundColor: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.1)
    property color borderColor: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.2)
    property color sliderColor: Theme.foreground
    property color activeTextColor: Theme.background
    property color inactiveTextColor: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.7)

    // Signals
    signal segmentClicked(int index)
    signal segmentChanged(int index, var data)

    // Set default height
    height: segmentHeight

    Rectangle {
        id: segmentBackground
        anchors.fill: parent
        color: backgroundColor
        border {
            width: 1
            color: borderColor
        }
        radius: segmentRadius

        // Sliding indicator
        Rectangle {
            id: slider
            width: segmentBackground.width / segmentedControl.segments.length
            height: segmentBackground.height - 4
            y: 2
            x: segmentedControl.currentIndex * (segmentBackground.width / segmentedControl.segments.length) + 2
            color: sliderColor
            radius: sliderRadius

            Behavior on x {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }
        }

        Row {
            anchors.fill: parent

            Repeater {
                model: segmentedControl.segments

                Rectangle {
                    width: segmentBackground.width / segmentedControl.segments.length
                    height: segmentBackground.height
                    color: "transparent"

                    Text {
                        text: modelData
                        anchors.centerIn: parent
                        color: segmentedControl.currentIndex === index ? activeTextColor : inactiveTextColor
                        font {
                            pixelSize: fontSize
                            family: fontFamily
                            weight: segmentedControl.currentIndex === index ? Font.DemiBold : Font.Normal
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (segmentedControl.currentIndex !== index) {
                                segmentedControl.currentIndex = index;

                                // Emit signals
                                segmentedControl.segmentClicked(index);

                                // If dataMap is provided, emit the mapped data
                                if (segmentedControl.dataMap && segmentedControl.dataMap.length > index) {
                                    segmentedControl.segmentChanged(index, segmentedControl.dataMap[index]);
                                } else {
                                    segmentedControl.segmentChanged(index, modelData);
                                }
                            }
                        }

                        onEntered: {
                            parent.scale = 1.05;
                        }

                        onExited: {
                            parent.scale = 1.0;
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }
    }

    // Public functions
    function setCurrentIndex(index) {
        if (index >= 0 && index < segments.length) {
            currentIndex = index;
        }
    }

    function getCurrentData() {
        if (dataMap && dataMap.length > currentIndex) {
            return dataMap[currentIndex];
        }
        return segments[currentIndex];
    }
}
