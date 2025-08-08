import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import "root:/config"
import "root:/modules/bar/batterypopover/components"
import QtQuick.Effects

Loader {
    PanelWindow {
        id: appLauncher
        implicitWidth: 420
        implicitHeight: 450
        color: "transparent"
        visible: false

        anchors {
            bottom: true
        }
        margins {
            bottom: 10
        }
        exclusionMode: ExclusionMode.Ignore
        focusable: true

        property bool shouldShow: false

        // Request focus for the window when it appears
        Component.onCompleted: {
            // TODO TO CHECK DONT FOREGET!!!!!!!!!!!!!!!!!!!
            // appLauncher.forceActiveFocus();
            searchInput.forceActiveFocus();
            // Initialize the selection
            Qt.callLater(function () {
                appLauncher.updateCurrentIndex();
            });

            // Method 1: Use Object.getOwnPropertyNames() to see all properties
            // console.log("=== All Properties ===");
            // var properties = Object.getOwnPropertyNames(appLauncher);
            // for (var i = 0; i < properties.length; i++) {
            //     console.log("Property:", properties[i]);
            // }
            //
            console.log("app launcher initialized...............");
        }

        // Global key handling for the window
        Keys.onPressed: function (event) {
            console.log("Window key pressed:", event.key, event.text);
            if (event.key === Qt.Key_Escape) {
                // appLauncher.close();
                appLauncher.shouldShow = !appLauncher.shouldShow;
                popupAnimationManager.hide();
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                navigateUp();
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                navigateDown();
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                executeCurrentItem();
                event.accepted = true;
            } else if (event.key === Qt.Key_Tab) {
                navigateDown();
                event.accepted = true;
            } else if (event.key === Qt.Key_Backtab) {
                navigateUp();
                event.accepted = true;
            } else if (event.text.length > 0 && event.key !== Qt.Key_Backspace && event.key !== Qt.Key_Delete) {
                // Forward typing to search input
                searchInput.forceActiveFocus();
                searchInput.text += event.text;
                event.accepted = true;
            }
        }