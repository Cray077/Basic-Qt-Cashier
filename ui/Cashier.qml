import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: mainColumn

    signal backToMainMenu()

    anchors.fill: parent
    anchors.margins: 8
    spacing: 8

    Rectangle {
        id: formPanel
        Layout.fillWidth: true
        Layout.preferredHeight: 270
        color: "#093C5D"
        radius: 4

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 10

            RowLayout {
                // spacing: 40

                Label {
                    text: "Invoice No."
                    Layout.preferredWidth: 120

                }

                TextField {
                    Layout.preferredWidth: 320
                    readOnly: true
                    text: "INV-0001"
                    color: "#5DF8D8"

                    background: Rectangle {
                        color: "#3B7597"
                        border.color: "#cccccc"
                        radius: 3
                    }
                }

                Label {
                    text: "Date"
                    Layout.preferredWidth: 60
                }

                TextField {
                    Layout.preferredWidth: 220
                    readOnly: true
                    text: Qt.formatDate(new Date(), "yyyy-MM-dd")
                    color: "#5DF8D8"

                    background: Rectangle {
                        color: "#3B7597"
                        border.color: "#cccccc"
                        radius: 3
                    }
                }
            }

            RowLayout {

                Label {
                    text: "Customer name"
                    Layout.preferredWidth: 120
                }

                TextField {
                    Layout.preferredWidth: 320
                    color: "#5DF8D8"

                    background: Rectangle {
                        color: "#3B7597"
                        border.color: "#cccccc"
                        radius: 3
                    }}
            }

            RowLayout {

                Label {
                    text: "Item ID"
                    Layout.preferredWidth: 120
                }
                TextField {
                    Layout.preferredWidth: 320
                    color: "#5DF8D8"

                    background: Rectangle {
                        color: "#3B7597"
                        border.color: "#cccccc"
                        radius: 3
                    }
                }
            }

            RowLayout {

                Label {
                    text: "Item Name"
                    Layout.preferredWidth: 120
                }
                TextField {
                    Layout.preferredWidth: 400
                    color: "#5DF8D8"

                    background: Rectangle {
                        color: "#3B7597"
                        border.color: "#cccccc"
                        radius: 3
                    }
                }
            }

            RowLayout {

                Label {
                    text: "Desc"
                    Layout.preferredWidth: 120
                }
                TextField {
                    // Layout.fillWidth: true
                    Layout.preferredWidth: 400
                    color: "#5DF8D8"

                    background: Rectangle {
                        color: "#3B7597"
                        border.color: "#cccccc"
                        radius: 3
                    }
                }
            }

            RowLayout {
                spacing: 20

                ColumnLayout {
                    Label {
                        text: "Stock"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    TextField {
                        Layout.preferredWidth: 45
                        color: "#5DF8D8"

                        background: Rectangle {
                            color: "#3B7597"
                            border.color: "#cccccc"
                            radius: 3
                        }
                    }
                }

                ColumnLayout {
                    Label {
                        text: "Qty Type"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    TextField {
                        Layout.preferredWidth: 70
                        color: "#5DF8D8"

                        background: Rectangle {
                            color: "#3B7597"
                            border.color: "#cccccc"
                            radius: 3
                        }
                    }
                }

                ColumnLayout {
                    Label {
                        text: "Qty"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    TextField {
                        Layout.preferredWidth: 70
                        color: "#5DF8D8"

                        background: Rectangle {
                            color: "#3B7597"
                            border.color: "#cccccc"
                            radius: 3
                        }
                    }
                }

                ColumnLayout {
                    Label { text: "Price"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    TextField {
                        Layout.preferredWidth: 120
                        color: "#5DF8D8"

                        background: Rectangle {
                            color: "#3B7597"
                            border.color: "#cccccc"
                            radius: 3
                        }
                    }
                }

                ColumnLayout {
                    Label {
                        text: "Disc"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    TextField {
                        Layout.preferredWidth: 90
                        color: "#5DF8D8"

                        background: Rectangle {
                            color: "#3B7597"
                            border.color: "#cccccc"
                            radius: 3
                        }
                    }
                }

                ColumnLayout {
                    Label {
                        text: "Added Description"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    TextField {
                        Layout.preferredWidth: 280
                        color: "#5DF8D8"

                        background: Rectangle {
                            color: "#3B7597"
                            border.color: "#cccccc"
                            radius: 3
                        }
                    }
                }

                ColumnLayout {
                    Label {
                        text: "Sub Total"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    TextField {
                        Layout.preferredWidth: 200
                        readOnly: true
                        color: "#5DF8D8"

                        background: Rectangle {
                            color: "#3B7597"
                            border.color: "#cccccc"
                            radius: 3
                        }
                    }
                }

                Button {
                    text: "Add"
                    Layout.alignment: Qt.AlignBottom

                    onClicked: mainColumn.backToMainMenu()
                }

                Button {
                    text: "EEE"
                    Layout.alignment: Qt.AlignBottom
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "white"
        border.color: "#cccccc"

        // Later: replace with TableView
        Label {
            anchors.centerIn: parent
            text: "Table / sales item list goes here"
            color: "#777"
        }
    }
}