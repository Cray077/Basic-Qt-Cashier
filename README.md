# QT Cashier App (Basic Overview)

## Description
This is a simple cashier (POS) application built using **Qt Quick (QML)**. It provides a user interface for entering sales transactions, including customer details, item information, and purchase data.

---

## Main Layout
The app uses an `ApplicationWindow` with a vertical layout divided into two main sections:

1. **Form Panel (Top)**
2. **Sales Table Area (Bottom)**

---

## 1. Form Panel
The top section is a styled input form (`Rectangle`) used to capture transaction details.

### Key Fields
- **Invoice No.** (auto-filled, read-only)
- **Date** (auto-generated using system date)
- **Customer Name**
- **Item ID**
- **Item Name**
- **Description**

### Item Details Section
Includes inputs for:
- Stock (SpinBox)
- Quantity Type (ComboBox: PCS, BOX, KG)
- Quantity (SpinBox)
- Price
- Discount
- Additional Description
- Subtotal (read-only)

### Actions
- **Add Button ("A")** → intended to add item to list  
- **Remove Button ("X")** → intended to remove item  

---

## 2. Sales Table Area
The bottom section is a placeholder for displaying added items.

- Currently shows a label: *"Table / sales item list goes here"*
- Planned to be replaced with a `TableView` for listing transactions

---

## UI Design Notes
- Uses `ColumnLayout` and `RowLayout` for structured alignment
- Custom color theme (blue tones with cyan text)
- Rounded rectangles and styled input backgrounds
- Read-only fields used for auto-generated values

---

## Summary
This app is a **basic POS interface prototype** that:
- Collects transaction and item data
- Organizes inputs in a structured form
- Prepares for future expansion (e.g., item table, logic, backend integration)

---

## Source
Based on: `Main.qml` :contentReference[oaicite:0]{index=0}
