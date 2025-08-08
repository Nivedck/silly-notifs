import Quickshell
import QtQuick
import "batterypopover"
import "root:/config"

Scope {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: bar
            property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                bottom: true
            }
            implicitWidth: 40
            exclusiveZone: 42

            Rectangle {
                id: backgroundRect
                anchors.fill: parent
                color: Theme.background

                Workspaces {
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                        topMargin: 10
                    }
                }

                ClockWidget {
                    anchors.centerIn: parent
                }

                BatteryWidget {
                    id: battery
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                        bottomMargin: 10
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        Timer {
                            id: enterTimer
                            interval: 50
                            repeat: false
                            onTriggered: popupLoader.item.shouldShow = true
                            // onTriggered: batteryPopup.shouldShow = true
                        }

                        Timer {
                            id: leaveTimer
                            interval: 200
                            repeat: false
                            onTriggered: popupLoader.item.shouldShow = false
                            // onTriggered: batteryPopup.shouldShow = false
                        }

                        onContainsMouseChanged: {
                            popupLoader.active = true;
                            if (containsMouse) {
                                leaveTimer.stop();
                                enterTimer.start();
                            } else {
                                enterTimer.stop();
                                leaveTimer.start();
                            }
                        }
                    }
                }
            }
            LazyLoader {
                id: popupLoader
                // loading: true
                active: false
                BatteryPopover {
                    id: batteryPopup
                    popupLoaderRef: popupLoader

                    HoverHandler {
                        id: popoverHoverHandler
                        acceptedButtons: Qt.NoButton
                        cursorShape: Qt.ArrowCursor

                        onHoveredChanged: {
                            if (hovered) {
                                // Mouse entered popover
                                leaveTimer.stop();
                                enterTimer.start();
                            } else {
                                // Mouse exited popover
                                enterTimer.stop();
                                leaveTimer.start();
                            }
                        }
                    }
                }
            }
        }
    }
}
