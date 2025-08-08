import QtQuick
import QtQuick.Effects
import Quickshell
import "root:/config"
import Quickshell.Services.UPower

import "./components" as Components

PopupWindow {
    id: batteryPopup
    anchor.window: bar
    anchor.rect.x: bar.width
    anchor.rect.y: bar.height
    implicitWidth: 310
    implicitHeight: 250
    visible: false
    color: "transparent"

    property bool shouldShow: false

    // LazyLoader
    property var popupLoaderRef

    // Process Manager
    Components.ProcessManager {
        id: processManager

        onCurrentGovernorUpdated: function (governor) {
            updateSegmentIndex();
        }

        onAvailableGovernorsUpdated: function (governors) {
            updateSegmentOptions();
        }

        onGovernorSetSuccessfully: function () {
            console.log("Governor changed successfully");
        }

        onGovernorSetFailed: function (error) {
            console.log("Failed to change governor:", error);
        }
    }

    Components.PopupAnimation {
        id: popupAnimationManager

        targetContainer: container
        popupWindow: batteryPopup
        popupLoaderRef: popupLoaderRef
    }

    // Monitor Info Component
    Components.MonitorInfo {
        id: monitorInfo

        onRefreshRateChanged: function (newRate) {
            console.log("Monitor refresh rate changed to:", newRate);
        }
    }

    Connections {
        target: UPower
        function onOnBatteryChanged() {
            console.log("AC/DC changed!");
            processManager.refreshCurrentGovernor();
        }
    }

    function updateSegmentIndex() {
        const governorMap = {
            "powersave": 0,
            "performance": 1,
            "ondemand": 0,
            "conservative": 0,
            "schedutil": 0
        };

        cpuGovernorControl.setCurrentIndex(governorMap[processManager.currentGovernor] || 0);
    }

    function updateSegmentOptions() {
        const hasPerformance = processManager.availableGovernors.includes("performance");
        const hasPowersave = processManager.availableGovernors.includes("powersave");

        if (hasPerformance && hasPowersave) {
            cpuGovernorControl.segments = ["Power Saver", "Performance"];
            cpuGovernorControl.dataMap = ["powersave", "performance"];
        } else {
            cpuGovernorControl.segments = processManager.availableGovernors.slice(0, 2);
            cpuGovernorControl.dataMap = processManager.availableGovernors.slice(0, 2);
        }
    }

    Item {
        id: container
        anchors.fill: parent
        property real blurAmount: 2.5
        scale: 0.5
        transformOrigin: Item.BottomLeft

        Rectangle {
            id: backgroundBox
            anchors.fill: parent
            color: Theme.background
            border {
                width: 2
                color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.3)
            }
            anchors {
                topMargin: 30
                rightMargin: 30
            }
            radius: 15

            Column {
                anchors.centerIn: parent
                spacing: 15

                // Shows Status of Battery
                Components.StatusText {}

                // CPU Governor - Using the separated component
                Components.SegmentedControl {
                    id: cpuGovernorControl
                    width: 240
                    height: 36
                    anchors.horizontalCenter: parent.horizontalCenter

                    segments: ["Power Saver", "Performance"]
                    dataMap: ["powersave", "performance"]

                    onSegmentChanged: function (index, data) {
                        console.log("Setting governor to:", data);
                        processManager.setGovernor(data);
                    }
                }

                // Monitor refresh rate control - Now using the separated component
                Column {
                    spacing: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: monitorInfo.monitor && monitorInfo.monitor.lastIpcObject && monitorInfo.availableRates.length > 0

                    Text {
                        text: `${monitorInfo.monitor ? monitorInfo.monitor.name : "N/A"} - ${monitorInfo.monitor && monitorInfo.monitor.lastIpcObject ? Math.round(monitorInfo.monitor.lastIpcObject.refreshRate) : 0}Hz`
                        color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.8)
                        font {
                            pixelSize: 11
                            family: "CaskaydiaCove NF"
                        }
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    // Monitor refresh rate segmented control
                    Components.SegmentedControl {
                        id: monitorRateControl
                        width: 240
                        height: 30
                        anchors.horizontalCenter: parent.horizontalCenter

                        segments: monitorInfo.availableRates.map(rate => `${rate}Hz`)
                        dataMap: monitorInfo.availableRates
                        fontSize: 10
                        segmentRadius: 15
                        sliderRadius: 13

                        currentIndex: {
                            if (!monitorInfo.monitor || !monitorInfo.monitor.lastIpcObject || monitorInfo.availableRates.length === 0)
                                return 0;
                            const currentRate = Math.round(monitorInfo.monitor.lastIpcObject.refreshRate);
                            return Math.max(0, monitorInfo.availableRates.indexOf(currentRate));
                        }

                        onSegmentChanged: function (index, data) {
                            monitorInfo.setRefreshRate(data);
                        }
                    }
                }

                // Additional action buttons
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    Components.ActionButton {
                        text: "Settings"
                        onClicked: {
                            console.log("Settings clicked");
                        }
                    }

                    Components.ActionButton {
                        text: "Refresh"
                        onClicked: {
                            processManager.refreshAll();
                            monitorInfo.refresh();
                        }
                    }
                }
            }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: container.blurAmount
            blurMax: 32
        }
    }

    onShouldShowChanged: {
        if (shouldShow) {
            popupAnimationManager.show();
        } else {
            popupAnimationManager.hide();
        }
    }
}
