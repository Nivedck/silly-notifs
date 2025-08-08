import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets

import QtMultimedia

import "root:/config"

PanelWindow {
    id: window
    width: Screen.width
    height: Screen.height

    anchors {
        top: true
        right: true
    }

    color: "transparent"
    visible: notificationModel.count > 0
    mask: Region {
        item: interactiveMask
    }
    Timer {
        id: timer
    }

    property var notificationAssets: [
        {
            image: "root:/assets/suraj.png",
            sound: "root:/assets/wilhelm-scream.wav"
        },
        {
            image: "root:/assets/damu.png",
            sound: "root:/assets/jagathi.wav"
        },
        {
            image: "root:/assets/spidy.png",
            sound: "root:/assets/kollunne.wav"
        }
    ]

    function delay(delayTime, cb) {
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(cb);
        timer.start();
    }

    NotificationServer {
        id: server
        onNotification: notif => {
            notificationModel.append({
                summary: notif.summary,
                body: notif.body,
                appName: notif.appName,
                appIcon: notif.appIcon,
                expireTimeout: notif.expireTimeout > 0 ? notif.expireTimeout : 5000,
                id: Math.random()
            });
        }
    }

    ListModel {
        id: notificationModel
    }

    Rectangle {
        id: interactiveMask

        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        color: "transparent"
        implicitWidth: 400
        implicitHeight: Math.max(listView.contentHeight + 10, parent.height)
    }

    ListView {
        id: listView
        width: parent.width
        height: parent.height
        anchors {
            topMargin: 20
            right: parent.right
            top: parent.top
            rightMargin: 10
        }

        model: notificationModel
        delegate: notificationDelegate
        spacing: 25
        clip: false
        verticalLayoutDirection: ListView.TopToBottom
        interactive: false

        add: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.OutQuad
            }
        }
        remove: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 250
                easing.type: Easing.InQuad
            }
        }
        displaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 300
                easing.type: Easing.OutQuad
            }
        }
        removeDisplaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 300
                easing.type: Easing.OutQuad
            }
        }
    }

    Component {
        id: notificationDelegate

        Item {
            id: notificationItem
            width: 400
            implicitHeight: Math.max(80, contentContainer.implicitHeight + 20)
            anchors.right: parent.right
            anchors.rightMargin: 10

            property var selectedAsset: notificationAssets[Math.floor(Math.random() * notificationAssets.length)]

            Item {
                id: container
                width: parent.width
                height: parent.height
                property real blurAmount: 2.5
                transformOrigin: Item.Center
                scale: 0.3
                rotation: 0

                Image {
                    id: notificationImage
                    width: 200
                    height: 200
                    anchors.top: parent.top
                    anchors.right: parent.right

                    source: selectedAsset.image
                    fillMode: Image.PreserveAspectFit

                    anchors.topMargin: -50
                    anchors.rightMargin: -200
                }

                SoundEffect {
                    id: dismissSound
                    source: selectedAsset.sound
                }

                Rectangle {
                    id: backgroundBox
                    anchors.fill: parent
                    color: "transparent"

                    Image {
                        id: backgroud
                        width: parent.width
                        anchors.centerIn: parent

                        source: "root:/assets/wood-board2.png"
                        fillMode: Image.PreserveAspectFit
                    }

                    Row {
                        id: contentContainer
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 12

                        IconImage {
                            id: appIcon
                            width: 48
                            height: 48
                            anchors.verticalCenter: parent.verticalCenter
                            source: model.appIcon ? Quickshell.iconPath(model.appIcon) : ""

                            Rectangle {
                                anchors.fill: parent
                                color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.2)
                                radius: 8
                                visible: appIcon.status !== Image.Ready

                                Text {
                                    anchors.centerIn: parent
                                    text: model.appName ? model.appName.charAt(0).toUpperCase() : "N"
                                    color: "black"
                                    font.pixelSize: 20
                                    font.weight: Font.Bold
                                }
                            }
                        }

                        Column {
                            id: textColumn
                            width: parent.width - appIcon.width - parent.spacing
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6

                            Text {
                                id: summaryText
                                width: parent.width
                                text: model.summary || ""
                                color: "black"
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                font {
                                    pixelSize: 15
                                    weight: Font.Bold
                                    family: "CaskaydiaCove NF"
                                }
                            }

                            Text {
                                id: bodyText
                                width: parent.width
                                text: model.body || ""
                                color: Qt.rgba(0, 0, 0, 0.8)
                                wrapMode: Text.WordWrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                font {
                                    pixelSize: 13
                                    family: "CaskaydiaCove NF"
                                }
                            }
                        }
                    }
                }

                SequentialAnimation {
                    id: scaleAnimation
                    ParallelAnimation {
                        NumberAnimation {
                            target: container
                            property: "scale"
                            to: 1.0
                            duration: 0
                            easing.type: Easing.OutQuad
                        }
                    }
                }

                SequentialAnimation {
                    id: exitAnimation
                    ParallelAnimation {
                        NumberAnimation {
                            target: container
                            property: "scale"
                            to: 0.0
                            duration: 0
                            easing.type: Easing.InQuad
                        }
                        NumberAnimation {
                            target: container
                            property: "rotation"
                            to: 0
                            duration: 300
                            easing.type: Easing.OutQuad
                        }
                    }
                    onFinished: {
                        if (model.index >= 0 && model.index < notificationModel.count)
                            notificationModel.remove(model.index);
                    }
                }

                ParallelAnimation {
                    id: fallWithDrift
                    NumberAnimation {
                        target: container
                        property: "y"
                        to: window.height + container.height
                        duration: 600
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        target: container
                        property: "x"
                        to: container.x + mouseArea.driftX / 2
                        duration: 600
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: container
                        property: "rotation"
                        to: container.rotation * 2
                        duration: 600
                        easing.type: Easing.OutQuad
                    }
                    onFinished: exitAnimation.start
                }
            }

            Timer {
                id: expireTimer
                interval: model.expireTimeout
                running: true
                onTriggered: exitAnimation.start
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                property point pressPoint
                property bool wasDragged: false
                property real driftX: 0

                onPressed: mouse => {
                    pressPoint = Qt.point(mouse.x, mouse.y);
                    wasDragged = false;
                }
                onPositionChanged: mouse => {
                    if (Math.abs(mouse.y - pressPoint.y) > 5 || Math.abs(mouse.x - pressPoint.x) > 5) {
                        wasDragged = true;
                        container.x += mouse.x - pressPoint.x;
                        container.y += mouse.y - pressPoint.y;
                        container.rotation = (container.x - notificationItem.x) * 0.1 + 180;
                        pressPoint = Qt.point(mouse.x, mouse.y);
                    }
                }
                onReleased: mouse => {
                    if (wasDragged) {
                        driftX = container.x - notificationItem.x;
                        fallWithDrift.start();
                        dismissSound.play();
                        delay(3000, function () {
                            exitAnimation.start();
                        });
                    } else {
                        container.rotation = 0;
                    }
                }
                onClicked: mouse => {
                    if (!wasDragged)
                        exitAnimation.start();
                }
            }

            Component.onCompleted: scaleAnimation.restart()
        }
    }
}
