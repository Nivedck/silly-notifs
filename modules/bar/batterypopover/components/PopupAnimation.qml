import QtQuick

Item {
    id: popupAnimation

    property Item targetContainer: null
    property var popupWindow: null
    property var popupLoaderRef: null
    property bool isAnimating: false
    property bool shouldBeVisible: false // Track intended state

    signal animationFinished
    signal hideAnimationFinished

    // Entrance animation
    property alias scaleInAnimation: scaleInAnimation
    SequentialAnimation {
        id: scaleInAnimation

        onStarted: {
            isAnimating = true;
        }

        ParallelAnimation {
            NumberAnimation {
                target: targetContainer
                property: "scale"
                to: 1.0
                duration: 200
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: targetContainer
                property: "blurAmount"
                to: 0.0
                duration: 500
                easing.type: Easing.OutQuad
            }
        }

        onFinished: {
            isAnimating = false;
            // Only signal completion if we're still supposed to be visible
            if (shouldBeVisible) {
                animationFinished();
            }
        }

        onStopped: {
            isAnimating = false;
        }
    }

    // Exit animation
    property alias scaleOutAnimation: scaleOutAnimation
    SequentialAnimation {
        id: scaleOutAnimation

        onStarted: {
            isAnimating = true;
        }

        ParallelAnimation {
            NumberAnimation {
                target: targetContainer
                property: "blurAmount"
                to: 3.5
                duration: 300
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: targetContainer
                property: "scale"
                to: 0.5
                duration: 350
                easing.type: Easing.InQuad
            }
        }

        onFinished: {
            // Only hide if we're still supposed to be hidden
            if (!shouldBeVisible) {
                if (popupWindow) {
                    popupWindow.visible = false;
                }
                if (popupLoaderRef) {
                    popupLoaderRef.active = false;
                }
                hideAnimationFinished();
            }
            isAnimating = false;
        }

        onStopped: {
            isAnimating = false;
        }
    }

    // Public functions
    function show() {
        console.log("showww..................");

        if (!targetContainer) return;

        shouldBeVisible = true;

        // Stop any current animation
        if (isAnimating) {
            scaleOutAnimation.stop();
            scaleInAnimation.stop();
        }

        // Make sure popup window is visible
        if (popupWindow) {
            popupWindow.visible = true;
        }

        // If we're already at or near the target state, don't animate
        if (targetContainer.scale >= 0.95 && targetContainer.blurAmount <= 0.1) {
            isAnimating = false;
            animationFinished();
            return;
        }

        // Reset initial state for smooth transition from current state
        if (targetContainer.scale < 0.1) {
            targetContainer.scale = 0.5;
        }
        if (targetContainer.blurAmount < 0.1) {
            targetContainer.blurAmount = 2.5;
        }

        // Start entrance animation
        scaleInAnimation.start();
    }

    function hide() {
        console.log("hideee..................");

        if (!targetContainer) return;

        shouldBeVisible = false;

        // Stop any current animation
        if (isAnimating) {
            scaleInAnimation.stop();
            scaleOutAnimation.stop();
        }

        // If we're already at or near the hidden state, finish immediately
        if (targetContainer.scale <= 0.55 && targetContainer.blurAmount >= 3.0) {
            if (popupWindow) {
                popupWindow.visible = false;
            }
            if (popupLoaderRef) {
                popupLoaderRef.active = false;
            }
            isAnimating = false;
            hideAnimationFinished();
            return;
        }

        // Start exit animation
        scaleOutAnimation.start();
    }

    function initialize(container, window, loader) {
        targetContainer = container;
        popupWindow = window;
        popupLoaderRef = loader;
    }

    // Emergency stop function for immediate state changes
    function forceStop() {
        if (isAnimating) {
            scaleInAnimation.stop();
            scaleOutAnimation.stop();
            isAnimating = false;
        }
    }

    // Immediate show/hide without animation (useful for initialization)
    function showImmediate() {
        forceStop();
        shouldBeVisible = true;

        if (popupWindow) {
            popupWindow.visible = true;
        }

        if (targetContainer) {
            targetContainer.scale = 1.0;
            targetContainer.blurAmount = 0.0;
        }

        animationFinished();
    }

    function hideImmediate() {
        forceStop();
        shouldBeVisible = false;

        if (targetContainer) {
            targetContainer.scale = 0.5;
            targetContainer.blurAmount = 2.5;
        }

        if (popupWindow) {
            popupWindow.visible = false;
        }

        if (popupLoaderRef) {
            popupLoaderRef.active = false;
        }

        hideAnimationFinished();
    }
}
