# QT Cashier App

A basic Point of Sale (POS) / cashier interface built using **Qt Quick (QML)**.  
This project focuses on a clean UI layout for handling sales transactions.

---

## Features

- Auto-generated **Invoice Number** and **Date**
- Input for:
  - Customer name
  - Item ID, name, and description
- Item transaction controls:
  - Stock and quantity (SpinBox)
  - Quantity type (PCS, BOX, KG)
  - Price and discount
  - Additional description
- Auto-calculated **Subtotal** (UI placeholder)
- Buttons for:
  - Adding items
  - Removing items
- Placeholder for **sales item table**

---

## UI Layout

### 1. Form Panel (Top)
- Handles all transaction and item input
- Organized using `RowLayout` and `ColumnLayout`
- Styled with a custom blue theme

### 2. Sales Table (Bottom)
- Currently a placeholder
- Intended to be replaced with a `TableView` to display added items

---

## Tech Stack

- **Qt Quick (QML)**
- Qt Quick Controls
- Layouts module

---

## Project Status

⚠️ This is a **UI prototype**:
- No backend logic yet
- No database integration
- Table functionality not implemented

---

## Future Improvements

- Implement item list (`TableView`)
- Add calculation logic (subtotal, totals, taxes)
- Connect to database (inventory & sales)
- Improve validation and UX

---

## Source

Main UI file: `Main.qml` :contentReference[oaicite:0]{index=0}
