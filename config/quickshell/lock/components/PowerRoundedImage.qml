

import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property url source: ""
    property real cornerRadius: width / 2

    property bool imageReady: image.status === Image.Ready

    Image {
        id: image

        anchors.fill: parent
        source: root.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: true

        visible: false
    }

    Rectangle {
        id: mask

        anchors.fill: parent
        radius: root.cornerRadius
        color: "white"

        visible: false
        antialiasing: true
    }

    OpacityMask {
        anchors.fill: parent

        source: image
        maskSource: mask

        cached: true
        visible: root.imageReady
    }
}
