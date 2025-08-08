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
    
        // Navigation functions
        function navigateUp() {
            var visibleItems = getVisibleItems();
            if (visibleItems.length === 0)
                return;

            var currentIndex = appListView.currentIndex;
            var visibleIndex = visibleItems.indexOf(currentIndex);

            if (visibleIndex > 0) {
                appListView.currentIndex = visibleItems[visibleIndex - 1];
            } else {
                appListView.currentIndex = visibleItems[visibleItems.length - 1];
            }
            appListView.positionViewAtIndex(appListView.currentIndex, ListView.Contain);
        }

        function navigateDown() {
            var visibleItems = getVisibleItems();
            if (visibleItems.length === 0)
                return;

            var currentIndex = appListView.currentIndex;
            var visibleIndex = visibleItems.indexOf(currentIndex);

            if (visibleIndex < visibleItems.length - 1 && visibleIndex !== -1) {
                appListView.currentIndex = visibleItems[visibleIndex + 1];
            } else {
                appListView.currentIndex = visibleItems[0];
            }
            appListView.positionViewAtIndex(appListView.currentIndex, ListView.Contain);
        }

        function getVisibleItemsFromDelegates() {
            var visibleItems = [];

            // Try to get visible items by checking delegates directly
            for (var i = 0; i < 100; i++) {
                // Reasonable upper limit
                var item = appListView.itemAtIndex(i);
                if (!item)
                    break;

                if (item.shouldShow) {
                    visibleItems.push(i);
                }
            }
            return visibleItems;
        }

        function getVisibleItems() {
            var visibleItems = [];
            var model = appListView.model;

            if (!model) {
                return visibleItems;
            }

            var modelCount = model.rowCount();

            for (var i = 0; i < modelCount; i++) {
                var app = model.values[i];

                if (!app) {
                    continue;
                }

                var shouldShow = false;
                if (searchInput.text.length === 0) {
                    shouldShow = true;
                } else {
                    const searchText = searchInput.text.toLowerCase();
                    const appName = (app.name || "").toLowerCase();
                    const appComment = (app.comment || "").toLowerCase();
                    const genericName = (app.genericName || "").toLowerCase();
                    shouldShow = appName.includes(searchText) || appComment.includes(searchText) || genericName.includes(searchText);
                }

                if (shouldShow) {
                    visibleItems.push(i);
                }
            }
            return visibleItems;
        }

        function executeCurrentItem() {
            if (appListView.currentIndex >= 0) {
                var model = appListView.model;
                var currentItem = model.values[appListView.currentIndex];
                currentItem.execute();
                // appLauncher.visible = false;
                searchInput.text = "";
                appLauncher.shouldShow = !appLauncher.shouldShow;
                popupAnimationManager.hide();
            }
        }

        // Update current index when search changes
        function updateCurrentIndex() {
            var visibleItems = getVisibleItems();
            if (visibleItems.length > 0) {
                // Set to first visible item if current is not visible
                if (visibleItems.indexOf(appListView.currentIndex) === -1) {
                    appListView.currentIndex = visibleItems[0];
                }
            } else {
                // No visible items, set index to -1
                appListView.currentIndex = -1;
            }
        }

        PopupAnimation {
            id: popupAnimationManager

            targetContainer: container
            popupWindow: appLauncher
            // popupLoaderRef: popupLoaderRef
        }

        Rectangle {
            id: container

            property real blurAmount: 2.5
            scale: 0.5
            transformOrigin: Item.Bottom

            anchors.fill: parent
            color: Theme.background
            border {
                property real gray: (Theme.foreground.r + Theme.foreground.g + Theme.foreground.b) / 10
                // property real white: (Theme.background.r + Theme.background.g + Theme.background.b) / 2
                width: 2
                // color: Qt.rgba(white, white, white, 1.0)
                color: Qt.rgba(gray, gray, gray, 1.0)
            }
            radius: 20
            clip: true
            focus: true

            anchors {
                topMargin: 30
                leftMargin: 30
                rightMargin: 30
            }

            Keys.onPressed: function (event) {
                // Forward all key events to the window's handler
                appLauncher.Keys.pressed(event);
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                TextInput {
                    id: searchInput

                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    Layout.topMargin: 12
                    Layout.bottomMargin: 10

                    font.pixelSize: 16
                    color: "white"
                    focus: true
                    activeFocusOnTab: true

                    padding: {
                        top: 5.0;
                        bottom: 5.0;
                        left: 10.0;
                        right: 10.0;
                    }

                    onTextChanged: {
                        console.log("Search text changed:", text);
                        appLauncher.updateCurrentIndex();
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -2
                        color: "transparent"
                        // border.color: Qt.rgba(Theme.foreground.r, Theme.foreground.b, Theme.foreground.b, 0.2)
                        // border.width: 1
                        radius: 15
                        z: -1
                        Text {
                            text: searchInput.text.length > 0 ? "" : "Search Apps..."
                            font.pixelSize: 16
                            color: "#888"
                            anchors.verticalCenter: parent.verticalCenter  // ← Vertically center only
                            anchors.left: parent.left
                            anchors.leftMargin: 12  // optional padding
                        }
                    }

                    Keys.onPressed: function (event) {

                        // Method 1: Use Object.getOwnPropertyNames() to see all properties
                        // console.log("=== All Properties ===");
                        // var properties = Object.getOwnPropertyNames(appLauncher);
                        // for (var i = 0; i < properties.length; i++) {
                        //     console.log("Property:", properties[i]);
                        // }

                        console.log("Search input key pressed:", event.key, event.text);
                        if (event.key === Qt.Key_Up) {
                            appLauncher.navigateUp();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down) {
                            appLauncher.navigateDown();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            appLauncher.executeCurrentItem();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            if (searchInput.text.length > 0) {
                                searchInput.text = "";
                                event.accepted = true;
                            } else {
                                // appLauncher.visible = false;
                                appLauncher.shouldShow = !appLauncher.shouldShow;
                                popupAnimationManager.hide();
                                event.accepted = true;
                            }
                        } else if (event.key === Qt.Key_Tab) {
                            appLauncher.navigateDown();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Backtab) {
                            appLauncher.navigateUp();
                            event.accepted = true;
                        }
                    // Let other keys pass through
                    }
                }

                // Application List
                ListView {
                    id: appListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: DesktopEntries.applications
                    focus: false // Don't steal focus from search input
                    currentIndex: 0

                    // Ensure current index is visible when it changes
                    onCurrentIndexChanged: {
                        if (currentIndex >= 0) {
                            positionViewAtIndex(currentIndex, ListView.Contain);
                        }
                    }

                    delegate: MouseArea {
                        id: mouseArea
                        width: appLauncher.width - 60
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: {
                            clickAnimation.start();
                            modelData.execute();
                        }

                        // Set as current item on hover
                        onEntered: {
                            if (shouldShow) {
                                appListView.currentIndex = index;
                            }
                        }

                        property bool shouldShow: {
                            if (searchInput.text.length === 0)
                                return true;
                            const searchText = searchInput.text.toLowerCase();
                            const appName = modelData.name.toLowerCase();
                            const appComment = (modelData.comment || "").toLowerCase();
                            const genericName = (modelData.genericName || "").toLowerCase();
                            return appName.includes(searchText) || appComment.includes(searchText) || genericName.includes(searchText);
                        }

                        height: shouldShow ? 60 : 0
                        property real childBlurAmount: shouldShow ? 0 : 2.5
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            blurEnabled: true
                            blur: childBlurAmount
                            blurMax: 32
                        }

                        Behavior on height {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.OutQuad
                            }
                        }
                        Behavior on childBlurAmount {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.OutQuad
                            }
                        }

                        // Smooth opacity animation
                        opacity: shouldShow ? 1.0 : 0.0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.OutQuad
                            }
                        }

                        // Entrance animation for items
                        property real itemScale: shouldShow ? 1.0 : 0.8
                        transform: Scale {
                            xScale: itemScale
                            yScale: itemScale
                            origin.x: mouseArea.width / 2
                            origin.y: mouseArea.height / 2
                        }

                        Behavior on itemScale {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.OutBack
                            }
                        }

                        // Click animation
                        SequentialAnimation {
                            id: clickAnimation
                            NumberAnimation {
                                target: mouseArea
                                property: "itemScale"
                                from: 1.0
                                to: 0.95
                                duration: 80
                                easing.type: Easing.OutQuad
                            }
                            NumberAnimation {
                                target: mouseArea
                                property: "itemScale"
                                from: 0.95
                                to: 1.0
                                duration: 80
                                easing.type: Easing.OutQuad
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: (appListView.currentIndex === index && shouldShow) ? Theme.foreground : (mouseArea.containsMouse ? Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.02) : "transparent")

                            border.color: (appListView.currentIndex === index && shouldShow) ? Theme.foreground : (mouseArea.containsMouse ? Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.1) : "transparent")

                            border.width: 2
                            radius: 15
                            anchors.leftMargin: 5
                            anchors.rightMargin: 5

                            // Smooth color transitions
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                    easing.type: Easing.OutQuad
                                }
                            }
                            Behavior on border.color {
                                ColorAnimation {
                                    duration: 150
                                    easing.type: Easing.OutQuad
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 12

                                IconImage {
                                    id: icon
                                    source: Quickshell.iconPath(modelData?.icon, "gnome-warning")
                                    implicitSize: 40
                                    asynchronous: true
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 2

                                    Text {
                                        text: modelData.name
                                        font.bold: true
                                        font.pixelSize: 14
                                        color: (appListView.currentIndex === index && shouldShow) ? Theme.background : Theme.foreground
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: modelData.comment || modelData.genericName
                                        font.pixelSize: 12
                                        color: (appListView.currentIndex === index && shouldShow) ? Theme.background : Theme.foreground
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        opacity: 0.6
                                    }
                                }
                            }
                        }
                    }

                    ScrollIndicator.vertical: ScrollIndicator {}
                }
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: container.blurAmount
                blurMax: 32
            }
        }

        IpcHandler {
            target: "appLauncher"

            function toggle(): void {
                // appLauncher.visible = !appLauncher.visible;
                appLauncher.shouldShow = !appLauncher.shouldShow;
                if (appLauncher.shouldShow) {
                    popupAnimationManager.show();
                } else {
                    popupAnimationManager.hide();
                }
            }
            function focus(): void {
                searchInput.forceActiveFocus();
                // appLauncher.acti
                console.log("hello");
            }
        }

        Connections {
            target: Qt.application
            function onStateChanged() {
                console.log("App state changed:", Qt.application.state);
                if (Qt.application.state !== Qt.ApplicationActive && appLauncher.shouldShow) {
                    Qt.callLater(function () {
                        appLauncher.shouldShow = false;
                        popupAnimationManager.hide();
                    });
                }
            }
        }
    }
}
