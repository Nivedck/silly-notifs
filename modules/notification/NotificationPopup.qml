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
}
