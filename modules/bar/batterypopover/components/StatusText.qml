// components/StatusText.qml
import QtQuick
import Quickshell.Services.UPower

Text {
    id: root

    property string batteryMode: "Unknown"

    function formatSeconds(s: int, fallback: string): string {
        if (s <= 0)
            return fallback;
        const day = Math.floor(s / 86400);
        const hr = Math.floor((s % 86400) / 3600);
        const min = Math.floor((s % 3600) / 60);
        let comps = [];
        if (day > 0)
            comps.push(`${day} day${day !== 1 ? 's' : ''}`);
        if (hr > 0)
            comps.push(`${hr}h`);
        if (min > 0 || comps.length === 0)
            comps.push(`${min}m`);
        return comps.join(" ");
    }

    text: {
        if (!UPower.displayDevice.isLaptopBattery) {
            return qsTr("TLP Mode: %1").arg(root.batteryMode);
        }
        if (UPower.displayDevice.percentage === 100 && !UPower.onBattery) {
            return qsTr("Fully charged");
        }
        if (UPower.onBattery) {
            const timeText = formatSeconds(UPower.displayDevice.timeToEmpty, "Calculating...");
            return timeText === "Calculating..." ? timeText : qsTr("%1 remaining").arg(timeText);
        } else {
            const timeText = formatSeconds(UPower.displayDevice.timeToFull, "Fully charged!");
            return timeText === "Fully charged!" ? timeText : qsTr("%1 until full").arg(timeText);
        }
    }

    color: "#fff"
    font {
        pixelSize: 14
        family: "CaskaydiaCove NF"
    }
    anchors.horizontalCenter: parent.horizontalCenter
}
