// components/ActionButton.qml
import QtQuick
import "root:/config"

Rectangle {
    id: button
    width: 60
    height: 24
    color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.15)
    border {
        width: 1
        color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.3)
    }
    radius: 12

    property alias text: label.text
    signal clicked

    Text {
        id: label
        anchors.centerIn: parent
        color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.8)
        font {
            pixelSize: 10
            family: "CaskaydiaCove NF"
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: button.clicked()

        onEntered: {
            parent.color = Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.25);
        }

        onExited: {
            parent.color = Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.15);
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }
}
