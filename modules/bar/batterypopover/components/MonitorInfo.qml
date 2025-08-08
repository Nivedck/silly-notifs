import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: monitorInfo

    // Public properties
    property var monitor: null
    property var availableRates: []

    // Signals
    signal refreshRateChanged(int newRate)

    // Timer to delay the refresh call, giving Hyprland time to apply the change
    Timer {
        id: refreshTimer
        interval: 1000
        repeat: false
        onTriggered: {
            console.log("Refreshing monitor info from Hyprland...");
            Hyprland.refreshMonitors();
            // Update our monitor reference after refresh
            monitor = Hyprland.focusedMonitor;
            parseAvailableRates();
        }
    }

    // Process for hyprctl commands
    Process {
        id: hyprctlProcess
        running: false

        function setRefreshRate(monitorName, resolution, rate) {
            command = ["hyprctl", "keyword", "monitor", `${monitorName},${resolution}@${rate},auto,1.0`];
            running = true;
        }

        stdout: StdioCollector {
            onStreamFinished: {
                console.log("hyprctl keyword output:", this.text);
                if (this.text.includes("ok")) {
                    console.log("Monitor refresh rate changed successfully");
                }
                refreshTimer.start();
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text) {
                    console.log("hyprctl keyword error:", this.text);
                }
            }
        }
    }

    // Monitor management - Direct access to Hyprland instance
    Connections {
        target: Hyprland

        function onFocusedMonitorChanged() {
            console.log("Focused monitor changed, parsing available rates...");
            refreshTimer.start();
        }
    }

    Component.onCompleted: {
        console.log("Initializing monitor info component...");
        // Load UI before refreshing the Monitor, because it takes a lot of time
        monitor = Hyprland.focusedMonitor;
        parseAvailableRates();
        // Load actual refreshed Monitor info
        refreshTimer.start();
    }

    // Public functions
    function parseAvailableRates() {
        monitor = Hyprland.focusedMonitor; // Temporary
        if (!monitor || !monitor.lastIpcObject || !monitor.lastIpcObject.availableModes) {
            console.log("No monitor data available to parse.");
            availableRates = [];
            return;
        }

        const modes = monitor.lastIpcObject.availableModes;
        const rateSet = new Set();

        for (const mode of modes) {
            const rateString = mode.split('@')[1];
            if (rateString) {
                const rate = Math.round(parseFloat(rateString));
                rateSet.add(rate);
            }
        }

        const sortedRates = Array.from(rateSet).sort((a, b) => a - b);
        availableRates = sortedRates;
        console.log("Found available rates:", JSON.stringify(availableRates));
    }

    function setRefreshRate(newRate) {
        if (!monitor) {
            console.log("Cannot set rate: No focused monitor.");
            return;
        }

        const monitorName = monitor.name;
        const resolution = `${monitor.width}x${monitor.height}`;

        console.log(`Setting ${monitorName} to ${resolution}@${newRate}Hz`);

        // Use hyprctl keyword - this is the correct way for runtime changes
        hyprctlProcess.setRefreshRate(monitorName, resolution, newRate);

        // Emit signal for external components
        refreshRateChanged(newRate);
    }

    function refresh() {
        refreshTimer.start();
    }
}
