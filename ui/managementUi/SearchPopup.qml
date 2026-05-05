import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: searchPopup

    // Call this from Main.qml: itemSearchPopup.openSearch(itemModel)
    function openSearch(sourceModel) {
        if (sourceModel !== undefined && sourceModel !== null)
            searchPopup.sourceModel = sourceModel

        searchText.text = ""
        searchPopup.open()
        searchText.forceActiveFocus()
    }

    // Your database/query results model goes here.
    // Expected roles: itemId, itemName, description, stock, qtyType, price
    property var sourceModel: []

    // Emitted when the user chooses a row.
    signal itemSelected(var itemData)

    parent: Overlay.overlay
    modal: true
    focus: true
    width: 900
    height: 420
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2) - 30
    padding: 40
    anchors.centerIn: parent
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        color: "#093C5D"
        radius: 8
        border.color: "#5DF8D8"
        border.width: 1
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Keys.onReturnPressed: searchPopup.chooseCurrentItem()
        Keys.onEnterPressed: searchPopup.chooseCurrentItem()

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: "Search Items"
                color: "white"
                font.pixelSize: 22
                font.bold: true
                Layout.fillWidth: true
            }

            Button {
                text: "X"
                onClicked: searchPopup.close()
            }
        }

        TextField {
            id: searchText
            Layout.fillWidth: true
            placeholderText: "Search by item ID, name, description, price..."
            color: "#5DF8D8"
            selectByMouse: true

            background: Rectangle {
                color: "#3B7597"
                border.color: "#cccccc"
                radius: 4
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 34
            color: "#062A42"
            radius: 3

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Label { text: "Item ID"; color: "white"; font.bold: true; Layout.preferredWidth: 110 }
                Label { text: "Item Name"; color: "white"; font.bold: true; Layout.fillWidth: true }
                Label { text: "Description"; color: "white"; font.bold: true; Layout.fillWidth: true }
                Label { text: "Stock"; color: "white"; font.bold: true; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignRight }
                Label { text: "Type"; color: "white"; font.bold: true; Layout.preferredWidth: 80 }
                Label { text: "Price"; color: "white"; font.bold: true; Layout.preferredWidth: 100; horizontalAlignment: Text.AlignRight }
            }
        }

        ListView {
            id: resultList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: filteredModel
            currentIndex: 0

            delegate: Rectangle {
                required property int index
                required property string itemId
                required property string itemName
                required property string description
                required property int stock
                required property string qtyType
                required property real price

                width: resultList.width
                height: 42
                color: ListView.isCurrentItem ? "#2E8AB8" : (mouseArea.containsMouse ? "#1E638A" : "#0D466B")
                border.color: "#2E6688"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Label { text: itemId; color: "#5DF8D8"; Layout.preferredWidth: 110; elide: Text.ElideRight }
                    Label { text: itemName; color: "white"; Layout.fillWidth: true; elide: Text.ElideRight }
                    Label { text: description; color: "#D8F7FF"; Layout.fillWidth: true; elide: Text.ElideRight }
                    Label { text: stock; color: "white"; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignRight }
                    Label { text: qtyType; color: "white"; Layout.preferredWidth: 80 }
                    Label { text: Number(price).toFixed(2); color: "white"; Layout.preferredWidth: 100; horizontalAlignment: Text.AlignRight }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: resultList.currentIndex = index
                    onDoubleClicked: chooseCurrentItem()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: filteredModel.count + " result(s)"
                color: "#D8F7FF"
                Layout.fillWidth: true
            }

            Button {
                text: "Select"
                enabled: resultList.currentIndex >= 0 && filteredModel.count > 0
                onClicked: chooseCurrentItem()
            }

            Button {
                text: "Cancel"
                onClicked: searchPopup.close()
            }
        }
    }

    // Keys.onReturnPressed: chooseCurrentItem()
    // Keys.onEnterPressed: chooseCurrentItem()

    function chooseCurrentItem() {
        if (resultList.currentIndex < 0 || filteredModel.count === 0)
            return

        var row = filteredModel.get(resultList.currentIndex)
        searchPopup.itemSelected(row)
        searchPopup.close()
    }

    ListModel {
        id: filteredModel
    }

    function rebuildFilter() {
        filteredModel.clear()

        var q = searchText.text.toLowerCase().trim()
        var count = searchPopup.sourceModel.count !== undefined
                  ? searchPopup.sourceModel.count
                  : searchPopup.sourceModel.length

        for (var i = 0; i < count; i++) {
            var row = searchPopup.sourceModel.get !== undefined
                    ? searchPopup.sourceModel.get(i)
                    : searchPopup.sourceModel[i]

            var haystack = (
                row.itemId + " " +
                row.itemName + " " +
                row.description + " " +
                row.stock + " " +
                row.qtyType + " " +
                row.price
            ).toLowerCase()

            if (q === "" || haystack.indexOf(q) !== -1)
                filteredModel.append(row)
        }

        resultList.currentIndex = filteredModel.count > 0 ? 0 : -1
    }

    onOpened: rebuildFilter()
    onSourceModelChanged: rebuildFilter()

    Connections {
        target: searchText
        function onTextChanged() {
            rebuildFilter()
        }
    }
}
