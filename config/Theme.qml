/*
 *  config/Theme.qml
 *
 *  A Singleton to provide pywal colors to the application.
 *  It reads the colors from ~/.cache/wal/colors.json and exposes
 *  them as properties. If the file is not found, it uses basic
 *  unstyled defaults to prevent application errors.
 */
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // --- Theme Properties ---
    // These properties are initialized with basic defaults. They are intended
    // to be overwritten by the loadPywalColors() function. If the pywal
    // file is not found, these basic values will be used.
    property color background: "black"
    property color foreground: "white"
    property real barAlpha: 0.85 // Default transparency for the bar

    // Initialize the color array with placeholders to prevent binding errors.
    property var colors: ["#ffffff", "#ffffff", "#ffffff", "#ffffff", "#ffffff", "#ffffff", "#ffffff", "#ffffff", "#ffffff", "#ffffff", "#ffffff", "#ffffff", "#ffffff", "#ffffff", "#ffffff", "#ffffff"]

    // Helper function to apply transparency to a color
    function transparent(baseColor, alpha) {
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, alpha);
    }

    // This block is executed once the Singleton is fully created.
    Component.onCompleted: {
        loadPywalColors();
    }

    // --- Pywal Loader ---
    function loadPywalColors() {
        // Use Quickshell to reliably find the user's cache directory.
        const cacheDir = Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache");
        const pywalFile = "file://" + cacheDir + "/wal/colors.json";

        const xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE) {
                return;
            }

            // For local files, a status of 0 or 200 indicates success.
            if (xhr.status === 200 || xhr.status === 0) {
                try {
                    const pywalData = JSON.parse(xhr.responseText);

                    if (pywalData.special && pywalData.colors) {
                        // Successfully parsed, so update the theme properties.
                        root.background = pywalData.special.background;
                        root.foreground = pywalData.special.foreground;

                        // Overwrite the placeholder array with pywal colors.
                        let newColors = [];
                        for (let i = 0; i < 16; i++) {
                            newColors.push(pywalData.colors["color" + i]);
                        }
                        root.colors = newColors;

                        console.log("Successfully loaded pywal theme.");
                    }
                } catch (e) {
                    console.error("Failed to parse pywal colors.json:", e);
                    console.warn("Using basic default colors as a fallback.");
                }
            } else {
                // This will be logged if colors.json doesn't exist.
                console.warn("Could not load pywal colors.json. Using basic default colors.");
            }
        };
        xhr.open("GET", pywalFile);
        xhr.send();
    }
}
