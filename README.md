# 🏥 RDV Medical - Plateforme de Gestion de Rendez-vous Médicaux

![Java](https://img.shields.io/badge/Java-17-orange)
![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-10-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue)
![Render](https://img.shields.io/badge/Render-Deployed-green)

## 📋 Description

**RDV Medical** est une application web complète de gestion de rendez-vous médicaux. Elle permet aux patients de prendre des rendez-vous en ligne, aux médecins de gérer leur agenda et aux administrateurs de superviser l'ensemble de la plateforme.

## 🚀 Démo en ligne

🔗 **URL du site** : [https://rdv-medical-urrr.onrender.com](https://rdv-medical-urrr.onrender.com)

### 👥 Comptes de démonstration

| Rôle | Email | Mot de passe |
|------|-------|--------------|
| 👤 Patient | `demo@patient.com` | `demo123` |
| 👨‍⚕️ Médecin | `demo@medecin.com` | `demo123` |
| 👑 Administrateur | `admin@rdv.com` | `admin123` |

---

## 📸 Captures d'écran

### 🔐 Page de connexion
![Page de connexion](file:///D:/ENI/L3/JSP/rdv_Medecin/src/main/webapp/images/screenshots/login.png)

### 👤 Dashboard Patient
![Dashboard Patient](https://raw.githubusercontent.com/mitiarj05/rdv_Medecin/main/src/main/webapp/images/screenshots/dashboard-patient.png)

### 📅 Calendrier Patient
![Calendrier Patient](https://raw.githubusercontent.com/mitiarj05/rdv_Medecin/main/src/main/webapp/images/screenshots/calendar-patient.png)

### 📝 Formulaire de prise de rendez-vous
![Formulaire RDV](https://raw.githubusercontent.com/mitiarj05/rdv_Medecin/main/src/main/webapp/images/screenshots/rdv.png)

### 👨‍⚕️ Dashboard Médecin
![Dashboard Médecin](https://raw.githubusercontent.com/mitiarj05/rdv_Medecin/main/src/main/webapp/images/screenshots/dashboard-medecin.png)

### 🏆 Top 5 Médecins
![Top 5 Médecins](https://raw.githubusercontent.com/mitiarj05/rdv_Medecin/main/src/main/webapp/images/screenshots/top5.png)

### 👑 Dashboard Administrateur
![Dashboard Admin](https://raw.githubusercontent.com/mitiarj05/rdv_Medecin/main/src/main/webapp/images/screenshots/dashboard-admin.png)

### 📋 Liste des rendez-vous
![Liste RDV](https://raw.githubusercontent.com/mitiarj05/rdv_Medecin/main/src/main/webapp/images/screenshots/listerdv.png)

### 👥 Gestion des patients (Admin)
![Gestion Patients](https://raw.githubusercontent.com/mitiarj05/rdv_Medecin/main/src/main/webapp/images/screenshots/gestionpatient.png)

---

## ✨ Fonctionnalités principales

### 👤 Patient
- 🔍 Rechercher un médecin par spécialité ou par nom
- 📅 Prendre un rendez-vous
- 📋 Consulter son historique de rendez-vous
- 🗓️ Calendrier personnel
- ✏️ Gérer son profil
- 🏆 Voir le Top 5 des médecins

### 👨‍⚕️ Médecin
- 📊 Dashboard avec statistiques (RDV du jour/semaine, revenus)
- 📋 Gérer ses rendez-vous (modifier/annuler)
- 👥 Voir la liste de ses patients
- 🗓️ Calendrier des consultations
- ✏️ Gérer son profil
- 🏆 Voir le classement des médecins

### 👑 Administrateur
- 👨‍⚕️ Gestion complète des médecins (CRUD)
- 👤 Gestion complète des patients (CRUD)
- 📋 Supervision de tous les rendez-vous
- 📊 Statistiques globales
- 🏆 Top 5 médecins et Top 5 patients
- 🗓️ Calendrier général

### 🌟 Fonctionnalités transverses
- 🔐 Authentification sécurisée (BCrypt)
- 📧 Notifications email automatiques (Mailjet)
- 🌓 Thème clair/sombre
- 📱 Interface responsive (mobile/tablette/desktop)

---

## 🛠 Stack Technique

| Catégorie | Technologies |
|-----------|--------------|
| **Backend** | Java 17, Jakarta Servlet API 6.0, JSP/JSTL |
| **Base de données** | PostgreSQL 16, HikariCP (pool de connexions) |
| **Email** | Mailjet API (200 emails/jour gratuit) |
| **Sécurité** | BCrypt (hashage mots de passe) |
| **Déploiement** | Render.com (CI/CD depuis GitHub) |
| **Build** | Maven, Docker |
| **Frontend** | HTML5, CSS3, JavaScript, Font Awesome |

---

## 📦 Installation locale

### Prérequis
- Java 17+
- PostgreSQL 16+
- Maven 3.9+
- Tomcat 10.1+

### Étapes

1. **Cloner le projet**
```bash
git clone https://github.com/mitiarj05/rdv_Medecin.git
cd rdv_Medecin
