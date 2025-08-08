import QtQuick
import Quickshell
import Quickshell.Hyprland
import "root:/config"

Item {
    id: workspaces
    height: workspacesColumn.childrenRect.height + 8.5
    width: parent.width - 10

    Rectangle {
        height: parent.height
        width: parent.width
        color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.2)
        border.color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.3)
        anchors.horizontalCenter: parent.horizontalCenter
        radius: parent.width / 2

        Column {
            id: workspacesColumn
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 4.5
            spacing: 4

            Repeater {
                model: Hyprland.workspaces
                Rectangle {
                    width: 22
                    height: 22
                    radius: 11
                    color: modelData.active ? Theme.foreground : Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.3)

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("workspace " + modelData.id)
                    }

                    Text {
                        id: number
                        visible: modelData.active
                        text: modelData.id
                        color: Theme.background
                        anchors.centerIn: parent
                        font {
                            pixelSize: 13
                            weight: 700
                            family: "CaskaydiaCove NF"
                        }
                    }
                }
            }
        }
    }
}
