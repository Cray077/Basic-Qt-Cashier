import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Qt.labs.qmlmodels

ColumnLayout {
    id: mainColumn

    signal backToMainMenu()

    Connections {
        target: databaseManager

        function onDatabaseError(message) {
            console.log("DATABASE ERROR:", message)
        }
    }

    anchors.fill: parent
    anchors.margins: 8
    spacing: 8

    ListModel {
        id: itemModel
    }

    ListModel {
        id: customerModel
    }

    function loadItems() {
        itemModel.clear()

        if (typeof databaseManager === "undefined" || databaseManager === null) {
            console.log("databaseManager is not available")
            return
        }

        var items = databaseManager.getItems()

        for (var i = 0; i < items.length; i++) {
            itemModel.append(items[i])
        }
    }

    function loadCustomers() {
        customerModel.clear()

        if (typeof databaseManager === "undefined" || databaseManager === null) {
            console.log("databaseManager is not available")
            return
        }

        var customers = databaseManager.getCustomers()

        for (var i = 0; i < customers.length; i++) {
            customerModel.append(customers[i])
        }
    }

    function pad(value, size) {
        var text = String(value)
        while (text.length < size)
            text = "0" + text
        return text
    }

    function generateInvoiceNo() {
        var now = new Date()
        var yyyy = now.getFullYear()
        var mm = pad(now.getMonth() + 1, 2)
        var dd = pad(now.getDate(), 2)
        var hh = pad(now.getHours(), 2)
        var mi = pad(now.getMinutes(), 2)
        var ss = pad(now.getSeconds(), 2)
        var ms = pad(now.getMilliseconds(), 3)
        return "INV-" + yyyy + mm + dd + "-" + hh + mi + ss + ms
    }

    function resetInvoiceHeader() {
        invoiceNoField.text = generateInvoiceNo()
        dateField.text = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
        customerNameField.text = ""
    }

    function toNumber(value) {
        var n = Number(value)
        return isNaN(n) ? 0 : n
    }

    function calculateLineSubtotal() {
        var price = toNumber(priceField.text)
        var qty = toNumber(qtyField.text)
        var disc = toNumber(discountField.text)
        var subtotal = (price * qty) - disc

        if (subtotal < 0)
            subtotal = 0

        subTotalField.text = subtotal.toFixed(2)
    }

    function clearItemFields() {
        itemIdField.text = ""
        itemNameField.text = ""
        descField.text = ""
        stockField.text = ""
        qtyTypeField.text = ""
        qtyField.text = "1"
        priceField.text = "0"
        discountField.text = "0"
        addedDescriptionField.text = ""
        subTotalField.text = "0"
    }

    function addCurrentItemToCart() {
        if (itemIdField.text.trim() === "" || itemNameField.text.trim() === "") {
            console.log("Select an item first")
            return
        }

        calculateLineSubtotal()

        salesModel.appendRow({
            itemId: itemIdField.text,
            itemName: itemNameField.text,
            price: Number(priceField.text).toFixed(2),
            discount: Number(discountField.text).toFixed(2),
            qty: qtyField.text,
            qtyType: qtyTypeField.text,
            subtotal: Number(subTotalField.text).toFixed(2),
            description: addedDescriptionField.text.trim() !== "" ? addedDescriptionField.text : descField.text
        })

        updateTotals()
        clearItemFields()
        itemIdField.forceActiveFocus()
    }

    function updateTotals() {
        var total = 0

        for (var i = 0; i < salesModel.rowCount; i++) {
            var row = salesModel.getRow(i)
            total += toNumber(row.subtotal)
        }

        var tax = toNumber(taxField.text)
        var discount = toNumber(totalDiscountField.text)
        var finalTotal = total + tax - discount

        if (finalTotal < 0)
            finalTotal = 0

        var cash = toNumber(cashField.text)
        var debt = finalTotal - cash

        totalField.text = total.toFixed(2)
        finalTotalField.text = finalTotal.toFixed(2)
        debtField.text = debt > 0 ? debt.toFixed(2) : "0.00"
    }

    function cartModelToArray() {
        var items = []

        for (var i = 0; i < salesModel.rowCount; i++) {
            var row = salesModel.getRow(i)
            items.push({
                itemId: row.itemId,
                itemName: row.itemName,
                description: row.description,
                qtyType: row.qtyType !== undefined ? row.qtyType : qtyTypeField.text,
                qty: toNumber(row.qty),
                price: toNumber(row.price),
                discount: toNumber(row.discount),
                subtotal: toNumber(row.subtotal)
            })
        }

        return items
    }

    function checkout() {
        if (salesModel.rowCount === 0) {
            console.log("Cart is empty")
            return
        }

        if (typeof databaseManager === "undefined" || databaseManager === null) {
            console.log("databaseManager is not available")
            return
        }

        updateTotals()

        var ok = databaseManager.addTransaction(
                    invoiceNoField.text,
                    dateField.text,
                    customerNameField.text,
                    toNumber(totalField.text),
                    toNumber(taxField.text),
                    toNumber(totalDiscountField.text),
                    toNumber(finalTotalField.text),
                    toNumber(cashField.text),
                    toNumber(debtField.text),
                    cartModelToArray())

        if (!ok) {
            console.log("Checkout failed")
            return
        }

        console.log("Checkout saved. Invoice:", invoiceNoField.text)

        salesModel.clear()
        clearItemFields()
        taxField.text = "0"
        totalDiscountField.text = "0"
        cashField.text = "0"
        updateTotals()
        resetInvoiceHeader()
        loadItems()
    }

    Component.onCompleted: {
        loadItems()
        loadCustomers()
        resetInvoiceHeader()
        clearItemFields()
    }

    SearchPopup {
        id: itemSearchPopup
        sourceModel: itemModel

        onItemSelected: function(item) {
            itemIdField.text = item.itemId
            itemNameField.text = item.itemName
            descField.text = item.description
            stockField.text = item.stock
            qtyTypeField.text = item.qtyType
            qtyField.text = "1"
            priceField.text = item.price !== undefined ? item.price : item.sellPrice
            discountField.text = "0"
            addedDescriptionField.text = ""
            calculateLineSubtotal()
            qtyField.forceActiveFocus()
        }
    }

    Popup {
        id: customerSearchPopup
        parent: Overlay.overlay
        modal: true
        focus: true
        width: 780
        height: 480
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        padding: 18
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#093C5D"
            radius: 8
            border.color: "#5DF8D8"
            border.width: 1
        }

        function chooseCustomer() {
            if (customerResultList.currentIndex < 0 || customerFilteredModel.count === 0)
                return

            var customer = customerFilteredModel.get(customerResultList.currentIndex)
            customerNameField.text = customer.name
            customerSearchPopup.close()
        }

        function rebuildCustomerFilter() {
            customerFilteredModel.clear()

            var q = customerSearchText.text.toLowerCase().trim()

            for (var i = 0; i < customerModel.count; i++) {
                var row = customerModel.get(i)
                var haystack = (row.id + " " + row.name + " " + row.company + " " + row.phone + " " + row.email + " " + row.address).toLowerCase()

                if (q === "" || haystack.indexOf(q) !== -1)
                    customerFilteredModel.append(row)
            }

            customerResultList.currentIndex = customerFilteredModel.count > 0 ? 0 : -1
        }

        onOpened: {
            customerSearchText.text = ""
            rebuildCustomerFilter()
            customerSearchText.forceActiveFocus()
        }

        contentItem: ColumnLayout {
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Label { text: "Search Customer"; color: "white"; font.pixelSize: 22; font.bold: true; Layout.fillWidth: true }
                Button { text: "X"; onClicked: customerSearchPopup.close() }
            }

            TextField {
                id: customerSearchText
                Layout.fillWidth: true
                placeholderText: "Search by name, company, phone, email, address..."
                color: "#5DF8D8"
                selectByMouse: true
                onTextChanged: customerSearchPopup.rebuildCustomerFilter()
                background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 4 }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 34
                color: "#062A42"
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8
                    Label { text: "Name"; color: "white"; font.bold: true; Layout.preferredWidth: 180 }
                    Label { text: "Company"; color: "white"; font.bold: true; Layout.preferredWidth: 160 }
                    Label { text: "Phone"; color: "white"; font.bold: true; Layout.preferredWidth: 130 }
                    Label { text: "Email"; color: "white"; font.bold: true; Layout.fillWidth: true }
                }
            }

            ListView {
                id: customerResultList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: ListModel { id: customerFilteredModel }
                currentIndex: 0

                delegate: Rectangle {
                    required property int index
                    required property string name
                    required property string company
                    required property string phone
                    required property string email

                    width: customerResultList.width
                    height: 42
                    color: ListView.isCurrentItem ? "#2E8AB8" : (customerMouse.containsMouse ? "#1E638A" : "#0D466B")
                    border.color: "#2E6688"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8
                        Label { text: name; color: "#5DF8D8"; Layout.preferredWidth: 180; elide: Text.ElideRight }
                        Label { text: company; color: "white"; Layout.preferredWidth: 160; elide: Text.ElideRight }
                        Label { text: phone; color: "white"; Layout.preferredWidth: 130; elide: Text.ElideRight }
                        Label { text: email; color: "#D8F7FF"; Layout.fillWidth: true; elide: Text.ElideRight }
                    }

                    MouseArea {
                        id: customerMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: customerResultList.currentIndex = index
                        onDoubleClicked: customerSearchPopup.chooseCustomer()
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Label { text: customerFilteredModel.count + " result(s)"; color: "#D8F7FF"; Layout.fillWidth: true }
                Button { text: "Select"; enabled: customerResultList.currentIndex >= 0 && customerFilteredModel.count > 0; onClicked: customerSearchPopup.chooseCustomer() }
                Button { text: "Cancel"; onClicked: customerSearchPopup.close() }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true

        Button {
            text: "< Back"
            Layout.alignment: Qt.AlignLeft

            onClicked: backToMainMenu()

            background: Rectangle {
                color: "#3B7597"
                radius: 4
            }

            contentItem: Text {
                text: "< Back"
                color: "#5DF8D8"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Item { Layout.fillWidth: true } // spacer

        Label {
            text: "Cashier"
            font.pixelSize: 20
            color: "white"
            Layout.alignment: Qt.AlignRight
        }
    }

    Rectangle {
        id: formPanel
        Layout.fillWidth: true
        Layout.preferredHeight: 300
        color: "#093C5D"
        radius: 4

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 10

            RowLayout {
                Label { text: "Invoice No."; Layout.preferredWidth: 120 }

                TextField {
                    id: invoiceNoField
                    Layout.preferredWidth: 320
                    readOnly: true
                    text: generateInvoiceNo()
                    color: "#5DF8D8"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }

                Label { text: "Date"; Layout.preferredWidth: 60 }

                TextField {
                    id: dateField
                    Layout.preferredWidth: 220
                    readOnly: true
                    text: Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
                    color: "#5DF8D8"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }
            }

            RowLayout {
                Label { text: "Customer name"; Layout.preferredWidth: 120 }

                TextField {
                    id: customerNameField
                    Layout.preferredWidth: 320
                    color: "#5DF8D8"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }

                Button {
                    text: "Search Customer"
                    onClicked: {
                        loadCustomers()
                        customerSearchPopup.open()
                    }
                }
            }

            RowLayout {
                Label { text: "Item ID"; Layout.preferredWidth: 120 }

                TextField {
                    id: itemIdField
                    Layout.preferredWidth: 320
                    color: "#5DF8D8"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }

                Button {
                    text: "Search"
                    onClicked: itemSearchPopup.openSearch(itemModel)
                }
            }

            RowLayout {
                Label { text: "Item Name"; Layout.preferredWidth: 120 }

                TextField {
                    id: itemNameField
                    Layout.preferredWidth: 400
                    color: "#5DF8D8"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }
            }

            RowLayout {
                Label { text: "Desc"; Layout.preferredWidth: 120 }

                TextField {
                    id: descField
                    Layout.preferredWidth: 400
                    color: "#5DF8D8"
                    background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                }
            }

            RowLayout {
                spacing: 20

                ColumnLayout {
                    Label { text: "Stock"; Layout.alignment: Qt.AlignHCenter }
                    TextField {
                        id: stockField
                        Layout.preferredWidth: 45
                        readOnly: true
                        color: "#5DF8D8"
                        background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                    }
                }

                ColumnLayout {
                    Label { text: "Qty Type"; Layout.alignment: Qt.AlignHCenter }
                    TextField {
                        id: qtyTypeField
                        Layout.preferredWidth: 70
                        readOnly: true
                        color: "#5DF8D8"
                        background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                    }
                }

                ColumnLayout {
                    Label { text: "Qty"; Layout.alignment: Qt.AlignHCenter }
                    TextField {
                        id: qtyField
                        Layout.preferredWidth: 70
                        text: "1"
                        color: "#5DF8D8"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onTextChanged: calculateLineSubtotal()
                        background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                    }
                }

                ColumnLayout {
                    Label { text: "Price"; Layout.alignment: Qt.AlignHCenter }
                    TextField {
                        id: priceField
                        Layout.preferredWidth: 120
                        color: "#5DF8D8"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onTextChanged: calculateLineSubtotal()
                        background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                    }
                }

                ColumnLayout {
                    Label { text: "Disc"; Layout.alignment: Qt.AlignHCenter }
                    TextField {
                        id: discountField
                        Layout.preferredWidth: 90
                        text: "0"
                        color: "#5DF8D8"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onTextChanged: calculateLineSubtotal()
                        background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                    }
                }

                ColumnLayout {
                    Label { text: "Added Description"; Layout.alignment: Qt.AlignHCenter }
                    TextField {
                        id: addedDescriptionField
                        Layout.preferredWidth: 280
                        color: "#5DF8D8"
                        background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                    }
                }

                ColumnLayout {
                    Label { text: "Sub Total"; Layout.alignment: Qt.AlignHCenter }
                    TextField {
                        id: subTotalField
                        Layout.preferredWidth: 200
                        readOnly: true
                        text: "0"
                        color: "#5DF8D8"
                        background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                    }
                }

                Button {
                    text: "Add"
                    Layout.alignment: Qt.AlignBottom
                    onClicked: addCurrentItemToCart()
                }

                Button {
                    text: "Clear"
                    Layout.alignment: Qt.AlignBottom
                    onClicked: clearItemFields()
                }
            }
        }
    }

    Rectangle {
        id: saleTable
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "white"
        border.color: "#cccccc"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Row {
                Layout.fillWidth: true
                height: 36

                Repeater {
                    model: ["Item ID", "Item Name", "Price", "Discount", "Qty", "Type", "Subtotal", "Description"]

                    Rectangle {
                        width: tableView.width / 7
                        height: 36
                        color: "#093C5D"
                        border.color: "#cccccc"

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: "white"
                            font.bold: true
                        }
                    }
                }
            }

            TableView {
                id: tableView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                columnSpacing: 0
                rowSpacing: 0

                model: TableModel {
                    id: salesModel

                    TableModelColumn { display: "itemId" }
                    TableModelColumn { display: "itemName" }
                    TableModelColumn { display: "price" }
                    TableModelColumn { display: "discount" }
                    TableModelColumn { display: "qty" }
                    TableModelColumn { display: "qtyType" }
                    TableModelColumn { display: "subtotal" }
                    TableModelColumn { display: "description" }

                    rows: []
                }

                delegate: Rectangle {
                    implicitWidth: tableView.width / 8
                    implicitHeight: 28
                    border.color: "#dddddd"
                    color: row % 2 === 0 ? "#ffffff" : "#f2f2f2"

                    Text {
                        anchors.fill: parent
                        anchors.margins: 8
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        color: "black"
                        text: model.display
                    }
                }
            }
        }
    }

    Rectangle {
        id: bottomPanel
        Layout.fillWidth: true
        Layout.preferredHeight: 150
        color: "#093C5D"
        radius: 4

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 24

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Label { text: "Total"; color: "white"; Layout.preferredWidth: 90 }
                    TextField {
                        id: totalField
                        Layout.fillWidth: true
                        readOnly: true
                        text: "0"
                        color: "#5DF8D8"
                        background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                    }
                }

                RowLayout {
                    Label { text: "Tax / PPN"; color: "white"; Layout.preferredWidth: 90 }
                    TextField {
                        id: taxField
                        Layout.fillWidth: true
                        text: "0"
                        color: "#5DF8D8"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onTextChanged: updateTotals()
                        background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                    }
                }

                RowLayout {
                    Label { text: "Discount"; color: "white"; Layout.preferredWidth: 90 }
                    TextField {
                        id: totalDiscountField
                        Layout.fillWidth: true
                        text: "0"
                        color: "#5DF8D8"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onTextChanged: updateTotals()
                        background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Label { text: "Final Total"; color: "white"; Layout.preferredWidth: 90 }
                    TextField {
                        id: finalTotalField
                        Layout.fillWidth: true
                        readOnly: true
                        text: "0"
                        color: "#5DF8D8"
                        background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                    }
                }

                RowLayout {
                    Label { text: "Cash"; color: "white"; Layout.preferredWidth: 90 }
                    TextField {
                        id: cashField
                        Layout.fillWidth: true
                        text: "0"
                        color: "#5DF8D8"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onTextChanged: updateTotals()
                        background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                    }
                }

                RowLayout {
                    Label { text: "Debt"; color: "white"; Layout.preferredWidth: 90 }
                    TextField {
                        id: debtField
                        Layout.fillWidth: true
                        readOnly: true
                        text: "0"
                        color: "#5DF8D8"
                        background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                    }
                }

                RowLayout {
                    Label { text: "Due Date"; color: "white"; Layout.preferredWidth: 90 }
                    TextField {
                        id: dueDateField
                        Layout.fillWidth: true
                        text: Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
                        color: "#5DF8D8"
                        background: Rectangle { color: "#3B7597"; border.color: "#cccccc"; radius: 3 }
                    }
                }
            }

            GridLayout {
                Layout.preferredWidth: 520
                Layout.fillHeight: true
                columns: 2
                rowSpacing: 12
                columnSpacing: 12

                Button {
                    id: backButton
                    text: "Back"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onClicked: backToMainMenu()

                    background: Rectangle {
                        radius: 10
                        color: backButton.pressed ? "#093C5D" : "#3B7597"
                    }

                    contentItem: Text {
                        text: backButton.text
                        color: "#5DF8D8"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    id: searchItemButton
                    text: "Search Item"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onClicked: itemSearchPopup.openSearch(itemModel)

                    background: Rectangle {
                        radius: 10
                        color: searchItemButton.pressed ? "#093C5D" : "#3B7597"
                    }

                    contentItem: Text {
                        text: searchItemButton.text
                        color: "#5DF8D8"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    id: customerButton
                    text: "Customer"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onClicked: {
                        loadCustomers()
                        customerSearchPopup.open()
                    }

                    background: Rectangle {
                        radius: 10
                        color: customerButton.pressed ? "#093C5D" : "#3B7597"
                    }

                    contentItem: Text {
                        text: customerButton.text
                        color: "#5DF8D8"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    id: addItemButton
                    text: "Add Item"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onClicked: addCurrentItemToCart()

                    background: Rectangle {
                        radius: 10
                        color: addItemButton.pressed ? "#093C5D" : "#3B7597"
                    }

                    contentItem: Text {
                        text: addItemButton.text
                        color: "#5DF8D8"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    id: clearItemButton
                    text: "Clear Item"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onClicked: clearItemFields()

                    background: Rectangle {
                        radius: 10
                        color: clearItemButton.pressed ? "#093C5D" : "#3B7597"
                    }

                    contentItem: Text {
                        text: clearItemButton.text
                        color: "#5DF8D8"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    id: cancelButton
                    text: "Cancel"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onClicked: {
                        salesModel.clear()
                        clearItemFields()
                        taxField.text = "0"
                        totalDiscountField.text = "0"
                        cashField.text = "0"
                        updateTotals()
                    }

                    background: Rectangle {
                        radius: 10
                        color: cancelButton.pressed ? "#093C5D" : "#3B7597"
                    }

                    contentItem: Text {
                        text: cancelButton.text
                        color: "#5DF8D8"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    id: newInvoiceButton
                    text: "New Invoice"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onClicked: {
                        salesModel.clear()
                        clearItemFields()
                        taxField.text = "0"
                        totalDiscountField.text = "0"
                        cashField.text = "0"
                        updateTotals()
                        resetInvoiceHeader()
                    }

                    background: Rectangle {
                        radius: 10
                        color: newInvoiceButton.pressed ? "#093C5D" : "#3B7597"
                    }

                    contentItem: Text {
                        text: newInvoiceButton.text
                        color: "#5DF8D8"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    id: doneButton
                    text: "Done"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    onClicked: checkout()

                    background: Rectangle {
                        radius: 10
                        color: doneButton.pressed ? "#093C5D" : "#3B7597"
                    }

                    contentItem: Text {
                        text: doneButton.text
                        color: "#5DF8D8"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
