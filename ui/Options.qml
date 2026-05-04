import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: mainColumn

    signal backToMainMenu()

    anchors.fill: parent
    // anchors.margins: 8
    // spacing: 8

    RowLayout {
        Text {
            color: "#FFFFFF"
            text: "Made by Cray077"
            font.pixelSize: 40
        }
    }
    RowLayout {
        Text {
            color: "#FFFFFF"
            text: "This project or app is not made for commercial purpose, it was made for a job application portofolio project, so if anyone is using this app and wondering when is the next update going to release, they most likely never will unless for some reason many people are actually use this app (please don't)"
            font.pixelSize: 20
            wrapMode: Text.WordWrap
            Layout.preferredWidth: 600
        }
    }
    RowLayout {
        Text {
            color: "#FFFFFF"
            text: "Copyright 'None' @2026"
            font.pixelSize: 20
        }
    }
    RowLayout {
        Button {
            text: "back"
            width: 120
            height: 50

            onClicked: mainColumn.backToMainMenu()
        }
    }
}