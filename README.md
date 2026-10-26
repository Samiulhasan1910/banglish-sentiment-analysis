<div align="center">

# ♻️ EcoCycle

### A Sustainable Marketplace for Reuse, Resale, Donation & Recycling

![PHP](https://img.shields.io/badge/PHP-8.2-777BB4?logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-MariaDB-4479A1?logo=mysql&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-MVC-2ea44f)
![XAMPP](https://img.shields.io/badge/Server-XAMPP-FB7A24?logo=xampp&logoColor=white)
![Course](https://img.shields.io/badge/CSC%203215-Web%20Technologies-blue)

**A group project built with PHP (MVC), MySQL, HTML, CSS and JavaScript for the Web Technologies course at AIUB**

[About](#-about-the-project) •
[Features](#-features) •
[Installation](#-installation) •
[Project Structure](#%EF%B8%8F-project-structure) •
[Team](#-academic-information)

</div>

---

## 📖 About The Project

Each year, many usable household and office items are thrown away because there is no simple way to sell,
donate or recycle them nearby. At the same time, people, NGOs and recycling agents are looking for exactly
these items.

**EcoCycle** connects them. Users post an item **for sale** or **for donation**, others search and filter items
in their area, make offers or requests, and the item reaches its new owner through a built-in **delivery
workflow**. NGOs can claim donations, delivery men handle pickups, and an admin panel keeps everything running.

### 🎯 Project Objectives

- Combine **resale, donation and recycling** in one localized platform
- Support four roles: **User, NGO, Delivery Man, Admin**
- Track every item from *"not needed anymore"* to *"reused, donated or delivered"*
- Apply the **MVC architecture** with a front controller and router in plain PHP

### 🔍 Background Study

| Existing solution | What is missing |
|---|---|
| General marketplaces (Facebook Marketplace, classified ads) | No donation / recycling flow, no link to verified organizations |
| Donation-only platforms | No resale or recycling |
| Municipal / informal recycling | Not connected to an online request & delivery system |

EcoCycle brings all three streams together with role-based access and a tracked delivery lifecycle.

---

## ✨ Features

### 👤 User
- Register and log in (with "remember my email")
- **Post items** for *Sell* (price + Bkash / Nagad number) or *Donate* (optionally to a chosen NGO)
- **Browse & live search** items and wanted posts by keyword, category and location
- **Request donated items**; the owner accepts or rejects from notifications
- **Buy items** through a simulated Bkash / Nagad payment
- **Wanted posts**: ask for an item; other users send offers with a picture and price
- Accept an offer → pay → a delivery job opens automatically
- **Delivery tracking**: see the assigned delivery man and accept / reject the delivery charge
- Transaction history, notifications and profile management

### 🏢 NGO
- Dashboard with donation statistics and recent notifications
- Accept or reject donations sent to the NGO
- Request public donations from donors
- Create the NGO's own donation posts
- Assign accepted donations to available delivery men and follow pickup status
- Accept / reject delivery charges, manage the NGO profile

### 🚚 Delivery Man
- Dashboard with open jobs; accept or reject a job
- Propose a delivery charge to the receiver
- Update progress: **Arrived at Pickup → Picked Up → Completed**
- Set availability (Available / Busy / Offline)
- Delivery history with status filter and an earnings summary

### 🛡️ Admin
- Dashboard with platform-wide counts and recent activity
- **User management**: search, edit, delete
- **NGO verification**: approve / reject, download verification documents
- **Delivery staff management**: approve, block / unblock, set availability, add staff
- **Item / post moderation**: approve, reject, change status, delete
- **Request monitoring**: approve, reject, assign delivery staff, cancel

### 🔐 Security
- All database queries use **prepared statements** (no SQL injection)
- Passwords stored with `password_hash()`; old plain-text passwords are upgraded on login
- **CSRF tokens** on delivery and charge actions
- Role-based access checks in every controller
- `app/`, `config/` and `database/` are blocked from the browser; PHP cannot run inside `uploads/`

---

## 🛠️ Technologies Used

| Component | Technology |
|---|---|
| Backend | PHP 8.2 (custom MVC, no framework) |
| Database | MySQL / MariaDB (mysqli, prepared statements) |
| Frontend | HTML5, CSS3, JavaScript (AJAX for login, register and live search) |
| Icons | Font Awesome |
| Server | Apache via XAMPP |
| Tools | VS Code, phpMyAdmin, Git & GitHub |

---

## 📋 Requirements

- **XAMPP** (Apache + MySQL) with **PHP 8.1 or newer**
- Apache `mod_rewrite` and `AllowOverride All` (both are on in a default XAMPP install)
- A modern web browser

---

## 🚀 Installation

### Step 1: Clone the repository

Clone it into XAMPP's `htdocs` folder:

```bash
cd /Applications/XAMPP/xamppfiles/htdocs      # macOS
# cd C:\xampp\htdocs                          # Windows
git clone https://github.com/Samiulhasan1910/EcoRecycle.git ecocycle
```

### Step 2: Start XAMPP

Open the XAMPP Control Panel and start **Apache** and **MySQL**.

### Step 3: Import the database

1. Open `http://localhost/phpmyadmin`
2. Create a database named **`project`**
3. Select it → **Import** → choose `database/ecocycle.sql` → **Go**

### Step 4: Check the database settings

Edit `config/config.php` if your MySQL user or password is different:

```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'project');
```

### Step 5: Open the website

```
http://localhost/ecocycle/
```

### 🔑 Demo Login

| Role | Email | Password |
|---|---|---|
| Admin | `admin@ecocycle.com` | `admin123` |

Register new accounts for the other roles. NGO and Delivery Man accounts need **admin approval** before they can log in.

---

## 🏗️ Project Structure

```
ecocycle/
├── index.php                  # Front controller: every request starts here
├── .htaccess                  # Blocks app/, config/, database/
├── config/
│   ├── config.php             # Database credentials, default route
│   └── routes.php             # URL → Controller@method table
├── app/
│   ├── core/
│   │   ├── Router.php         # Reads ?url= and calls the controller
│   │   ├── Controller.php     # view(), json(), access guards
│   │   ├── Model.php          # Prepared-statement helpers, transactions
│   │   ├── Database.php       # Shared mysqli connection
│   │   └── helpers.php        # url(), redirect(), e(), csrf_token() ...
│   ├── controllers/           # 12 controllers (Auth, Item, Ngo, Delivery, Admin ...)
│   ├── models/                # 13 models: all SQL lives here
│   └── views/                 # HTML templates only
│       ├── layouts/           # Shared header and sidebars
│       ├── auth/  user/  items/  requests/  wanted/  offers/
│       └── ngo/   delivery/  admin/  errors/
├── assets/css/                # style.css, style_delivery.css, ngo_sidebar.css
├── uploads/                   # Item and offer images
└── database/ecocycle.sql      # Database dump
```

---

## 🧩 How MVC Works Here

Every page is opened through `index.php` with a route, for example `index.php?url=items/sell`.

```
Browser ──► index.php ──► Router ──► Controller ──► Model ──► MySQL
                                         │
                                         └──► View (HTML) ──► Browser
```

Example: **My Sell Items** page

| Layer | File | Job |
|---|---|---|
| Route | `config/routes.php` | `'items/sell' => 'ItemController@sell'` |
| Controller | `app/controllers/ItemController.php` | Checks login, asks the model for data, picks the view |
| Model | `app/models/Item.php` | `SELECT * FROM items WHERE user_id = ? AND type = ?` |
| View | `app/views/items/sell.php` | Shows the items as cards |

### Main Routes

| Module | Routes |
|---|---|
| Auth | `auth/login`, `auth/register`, `auth/logout` |
| User | `dashboard`, `profile`, `notifications` |
| Items | `items/create`, `items/mine`, `items/browse`, `items/view`, `items/edit` |
| Requests & Payment | `requests/mine`, `transactions`, `payment` |
| Wanted & Offers | `wanted/create`, `wanted/view`, `offers/create`, `offers/view` |
| NGO | `ngo/dashboard`, `ngo/donation-requests`, `ngo/accepted-donations`, `ngo/pickups` |
| Delivery | `delivery/dashboard`, `delivery/jobs`, `delivery/history`, `delivery/track` |
| Admin | `admin/dashboard`, `admin/users`, `admin/ngos`, `admin/delivery-men`, `admin/items`, `admin/requests` |

The full list is in [`config/routes.php`](config/routes.php).

### Adding a New Page

1. Add a route: `'items/report' => 'ItemController@report'`
2. Add the method to the controller and load data with `$this->model('Item')`
3. Render it: `$this->view('items/report', ['rows' => $rows])`
4. Link to it with `<?php echo url('items/report'); ?>`

---

## 🔄 Item Lifecycle

```
Sell:     Post item ──► Buyer pays ──► Item "Sold" ──► Delivery job opens ──► Delivered
Donate:   Post item ──► User / NGO requests ──► Owner accepts ──► Delivery job opens ──► Delivered
Wanted:   Post wanted ──► Others send offers ──► Accept offer ──► Pay ──► Delivered

Delivery: Open ──► Accepted ──► Charge proposed ──► Charge accepted
               ──► Arrived at pickup ──► Picked up ──► Completed
```

---

## 🎓 Academic Information

### Course Details

| | |
|---|---|
| **University** | American International University-Bangladesh (AIUB) |
| **Faculty** | Faculty of Science and Technology |
| **Department** | Department of Computer Science |
| **Course** | CSC 3215: Web Technologies |
| **Semester** | Summer 2025-26 |
| **Section** | Y |
| **Group** | 02 |

### Project Team

| SL | Name | Student ID | Role | GitHub |
|---|---|---|---|---|
| 1 | Sadia Ahmed | 23-55053-3 | Group Leader | [@sadiaahmed9735](https://github.com/sadiaahmed9735) |
| 2 | Orpyta Karmokar Aupy | 23-55051-3 | Member | — |
| 3 | Samiul Hasan | 23-55331-3 | Member | [@Samiulhasan1910](https://github.com/Samiulhasan1910) |
| 4 | Mahomuda Patowary | 23-51156-1 | Member | — |
| 5 | Md. Borhan Hosen | 22-48260-2 | Member | — |

**Course Teacher:** Tofayet Sultan

> 📌 Team repository: [sadiaahmed9735/EcoCycle](https://github.com/sadiaahmed9735/EcoCycle)

---

## 🐛 Known Limitations

- Payments are **simulated** (no real Bkash / Nagad gateway)
- No email verification or password reset yet
- URLs use the `index.php?url=...` format (no pretty URLs)
- Built and tested on XAMPP only

## 🔮 Future Enhancements

- Real payment gateway integration
- Email verification and password reset
- Map-based pickup locations
- Ratings and reviews for users and delivery men
- Recycling-center role with drop-off points
- Mobile-friendly design and a mobile app

---

## 📄 License

This project was created for educational purposes as part of the **CSC 3215: Web Technologies** course at AIUB.
Feel free to use it for learning with proper attribution.

<div align="center">

⭐ If you found this project helpful, please give it a star! ⭐

Made with ❤️ by Group 02

</div>
