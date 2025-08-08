import QtQuick
import Quickshell.Io

QtObject {
    id: processManager

    // Properties for state management
    property string batteryMode: "Unknown"
    property string currentGovernor: "Unknown"
    property var availableGovernors: []

    // Signals for external communication
    signal batteryModeUpdated(string mode)
    signal currentGovernorUpdated(string governor)
    signal availableGovernorsUpdated(var governors)
    signal governorSetSuccessfully
    signal governorSetFailed(string error)

    // TLP Status Process
    property Process tlpStatusProcess: Process {
        id: tlpStatusProcess
        running: false
        command: ["sh", "-c", "tlp-stat -s | grep 'Mode' | awk '{print $3}'"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text) {
                    batteryMode = this.text.trim();
                    console.log("TLP Mode:", batteryMode);
                    processManager.batteryModeUpdated(batteryMode);
                } else {
                    console.log("Failed to get TLP mode");
                }
            }
        }
    }

    // Current Governor Process
    property Process governorProcess: Process {
        id: governorProcess
        running: false
        command: ["sh", "-c", "cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text) {
                    currentGovernor = this.text.trim();
                    console.log("Current governor:", currentGovernor);
                    processManager.currentGovernorUpdated(currentGovernor);
                } else {
                    console.log("Failed to get current governor: No output");
                }
            }
        }
    }

    // Available Governors Process
    property Process availableGovernorsProcess: Process {
        id: availableGovernorsProcess
        running: false
        command: ["sh", "-c", "cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text) {
                    availableGovernors = this.text.trim().split(" ");
                    console.log("Available governors:", availableGovernors);
                    processManager.availableGovernorsUpdated(availableGovernors);
                } else {
                    console.log("Failed to get available governors: No output");
                }
            }
        }
    }

    // Set Governor Process
    property Process setGovernorProcess: Process {
        id: setGovernorProcess
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                console.log("Governor set successfully");
                processManager.governorSetSuccessfully();
                // Refresh current governor after successful change
                refreshCurrentGovernor();
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text) {
                    console.log("Governor change failed:", this.text);
                    processManager.governorSetFailed(this.text);
                }
            }
        }
    }

    // Public methods
    function refreshTlpStatus() {
        tlpStatusProcess.running = true;
    }

    function refreshCurrentGovernor() {
        governorProcess.running = true;
    }

    function refreshAvailableGovernors() {
        availableGovernorsProcess.running = true;
    }

    function setGovernor(governor) {
        setGovernorProcess.command = ["sh", "-c", `governor-control ${governor}`];
        setGovernorProcess.running = true;
    }

    function refreshAll() {
        refreshTlpStatus();
        refreshCurrentGovernor();
        refreshAvailableGovernors();
    }

    // Initialize on component creation
    Component.onCompleted: {
        refreshAll();
    }
}
