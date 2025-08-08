/*
 *  Time.qml
 *
 *  A Singleton to provide continuously updated time values to the UI.
 */
pragma Singleton

import QtQml
import QtQuick
import Quickshell

Singleton {
    id: root

    // --- Private Clock Source ---
    // This clock object ticks once per minute and drives all the updates.
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // --- Public Time Properties ---
    // These are standard properties, not readonly. They create bindings that
    // automatically update whenever 'clock.date' changes.

    // Note: The format "h AP mm" is unusual. "h:mm AP" is more standard.
    // Using "h:mm" and "AP" separately is often more flexible.
    // property string timeFull: Qt.formatDateTime(clock.date, "h:mm") // e.g., "5:37"
    property string ampm: Qt.formatDateTime(clock.date, "AP")     // e.g., "PM"
    property string hours: parseInt(Qt.formatDateTime(clock.date, "h AP"))      // e.g., "5"
    property string minutes: Qt.formatDateTime(clock.date, "mm")    // e.g., "37"

}
