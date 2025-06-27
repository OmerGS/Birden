use birden;

/*
DROP TABLE IF EXISTS PushSubscription;
DROP TABLE IF EXISTS Message;
DROP TABLE IF EXISTS BoardMember;
DROP TABLE IF EXISTS Announcement;
DROP TABLE IF EXISTS Settings;
DROP TABLE IF EXISTS SocialLink;
DROP TABLE IF EXISTS Document;
DROP TABLE IF EXISTS AnnualReceipt;
DROP TABLE IF EXISTS CenazeFonuHistory;
DROP TABLE IF EXISTS CenazeFonu;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS AidatHistory;
DROP TABLE IF EXISTS Aidat;
DROP TABLE IF EXISTS Session;
DROP TABLE IF EXISTS Membre;
*/

-- =====================
-- 1. Table des membres
-- =====================
CREATE TABLE Membre (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nom VARCHAR(100) NOT NULL,
  prenom VARCHAR(100) NOT NULL,
  telephone VARCHAR(15) UNIQUE NOT NULL,
  barcode VARCHAR(20) UNIQUE,
  dateNaissance DATE,
  email VARCHAR(255) UNIQUE,
  password VARCHAR(255),
  salt VARCHAR(512),
  profilePictureUrl VARCHAR(255),
  specialRole ENUM('sudo', 'admin', 'manager', 'operator', 'contributor'),
  canSendMessage BOOLEAN DEFAULT FALSE,
  statut ENUM('Aktif', 'Donduruldu', 'Düştü', 'Üye Değil') NOT NULL DEFAULT 'Aktif',
  adresseFr VARCHAR(255),
  adresseTr VARCHAR(255),
  cenazeFonu BOOLEAN NOT NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================
-- 2. Sessions (tokens de connexion)
-- =====================
CREATE TABLE Session (
  id INT AUTO_INCREMENT PRIMARY KEY,
  Membre_id INT NOT NULL,
  refresh_token VARCHAR(512) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  expired_at TIMESTAMP NULL,
  ip_address VARCHAR(45),
  device_info VARCHAR(255),
  last_login DATETIME,
  FOREIGN KEY (Membre_id) REFERENCES Membre(id)
);

-- =====================
-- 3. Cotisations (Aidat)
-- =====================
CREATE TABLE Aidat (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category VARCHAR(50) NOT NULL, -- exemple: Genç, Emekli, etc.
  year INT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  approved BOOLEAN DEFAULT FALSE,
  UNIQUE(category, year)
);

-- =====================
-- 4. Historique des cotisations dues/payées
-- =====================
CREATE TABLE AidatHistory (
  id INT AUTO_INCREMENT PRIMARY KEY,
  MembreId INT NOT NULL,
  category VARCHAR(50) NOT NULL,
  year INT NOT NULL,
  amountDue DECIMAL(10,2) NOT NULL,
  amountPaid DECIMAL(10,2) DEFAULT 0,
  lastPaymentDate TIMESTAMP NULL,
  FOREIGN KEY (MembreId) REFERENCES Membre(id),
  UNIQUE(MembreId, year)
);

-- =====================
-- 5. Paiements
-- =====================
CREATE TABLE Payment (
  id INT AUTO_INCREMENT PRIMARY KEY,
  MembreId INT NOT NULL,
  date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reason ENUM('Aidat', 'Bağış', 'Cenaze Fonu', 'Diğer') NOT NULL,
  year INT NOT NULL,
  paymentMethod ENUM('Nakit', 'Kart', 'Banka Havalesi', 'Çek', 'Diğer') NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  transactionId VARCHAR(50) UNIQUE,
  receiverId INT NOT NULL,
  FOREIGN KEY (MembreId) REFERENCES Membre(id),
  FOREIGN KEY (receiverId) REFERENCES Membre(id)
);

-- =====================
-- 6. Historique Cenaze Fonu
-- =====================
CREATE TABLE CenazeFonu (
  id INT AUTO_INCREMENT PRIMARY KEY,
  year INT NOT NULL UNIQUE,
  price DECIMAL(10,2) NOT NULL
);

CREATE TABLE CenazeFonuHistory (
  id INT AUTO_INCREMENT PRIMARY KEY,
  MembreId INT NOT NULL,
  year INT NOT NULL,
  amountPaid DECIMAL(10,2) DEFAULT 0,
  lastPaymentDate TIMESTAMP NULL,
  FOREIGN KEY (MembreId) REFERENCES Membre(id),
  UNIQUE(MembreId, year)
);

-- =====================
-- 7. Reçus annuels (attestations)
-- =====================
CREATE TABLE AnnualReceipt (
  id INT AUTO_INCREMENT PRIMARY KEY,
  MembreId INT NOT NULL,
  year INT NOT NULL,
  issuedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  issuedBy INT NOT NULL,
  notes TEXT,
  FOREIGN KEY (MembreId) REFERENCES Membre(id),
  FOREIGN KEY (issuedBy) REFERENCES Membre(id),
  UNIQUE(MembreId, year)
);

-- =====================
-- 8. Documents PDF
-- =====================
CREATE TABLE Document (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  fileUrl VARCHAR(255) NOT NULL,
  year INT,
  category ENUM('Formulaire', 'Règlement', 'AG', 'Autre') DEFAULT 'Autre',
  active BOOLEAN DEFAULT TRUE,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================
-- 9. Liens réseaux sociaux
-- =====================
CREATE TABLE SocialLink (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  icon VARCHAR(50),
  url VARCHAR(255) NOT NULL,
  active BOOLEAN DEFAULT TRUE,
  position INT DEFAULT 0,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================
-- 10. Paramètres dynamiques
-- =====================

CREATE TABLE Settings (
  id INT PRIMARY KEY AUTO_INCREMENT,
  keyName VARCHAR(100) UNIQUE NOT NULL,
  value VARCHAR(255) NOT NULL,
  description TEXT,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================
-- 11. Annonces pop-up
-- =====================
CREATE TABLE Announcement (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  startDate DATETIME NOT NULL,
  endDate DATETIME NOT NULL,
  active BOOLEAN DEFAULT TRUE,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================
-- 12. Conseil d'administration
-- =====================
CREATE TABLE BoardMember (
  id INT AUTO_INCREMENT PRIMARY KEY,
  fullName VARCHAR(255) NOT NULL,
  titleFr VARCHAR(255) NOT NULL,
  titleTr VARCHAR(255) NOT NULL,
  photoUrl VARCHAR(255),
  startYear INT NOT NULL,
  endYear INT DEFAULT NULL,
  orderIndex INT DEFAULT 0,
  active BOOLEAN DEFAULT TRUE,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =====================
-- 13. Message
-- =====================
CREATE TABLE Message (
  id INT AUTO_INCREMENT PRIMARY KEY,
  senderId INT NOT NULL,
  content TEXT,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (senderId) REFERENCES Membre(id)
);

-- =====================
-- 14. Notifications
-- =====================
CREATE TABLE PushSubscription (
  id INT AUTO_INCREMENT PRIMARY KEY,
  MembreId INT NOT NULL,
  endpoint TEXT NOT NULL,
  keyName JSON NOT NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (MembreId) REFERENCES Membre(id)
);