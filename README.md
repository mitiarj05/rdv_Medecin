# 🏥 RDV Medical - Plateforme de Gestion de Rendez-vous Médicaux

![Java](https://img.shields.io/badge/Java-17-orange)
![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-10-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue)
![Render](https://img.shields.io/badge/Render-Deployed-green)

## 📋 Description

**RDV Medical** est une application web complète de gestion de rendez-vous médicaux. Elle permet aux patients de prendre des rendez-vous en ligne, aux médecins de gérer leur agenda et aux administrateurs de superviser l'ensemble de la plateforme.

### ✨ Fonctionnalités principales

| Rôle | Fonctionnalités |
|------|-----------------|
| 👤 **Patient** | • Prendre un rendez-vous<br>• Consulter son historique<br>• Calendrier personnel<br>• Gérer son profil |
| 👨‍⚕️ **Médecin** | • Dashboard avec statistiques<br>• Gestion des rendez-vous<br>• Liste des patients<br>• Calendrier des consultations |
| 👑 **Admin** | • Gestion des médecins (CRUD)<br>• Gestion des patients (CRUD)<br>• Supervision des rendez-vous<br>• Statistiques globales |

### 🎯 Fonctionnalités transverses

- 🔐 **Authentification sécurisée** (mots de passe hashés avec BCrypt)
- 📧 **Notifications email automatiques** (confirmation/annulation)
- 📅 **Calendrier interactif** avec vue mois/jour
- 📊 **Tableaux de bord** avec indicateurs clés
- 🏆 **Classements** (Top 5 médecins, Top 5 patients)
- 🎨 **Thème clair/sombre**
- 📱 **Interface responsive** (mobile/tablette/desktop)

---

## 🛠 Stack Technique

| Catégorie | Technologies |
|-----------|--------------|
| **Backend** | Java 17, Jakarta Servlet API 6.0, JSP/JSTL |
| **Base de données** | PostgreSQL, HikariCP (pool de connexions) |
| **Email** | Mailjet API (200 emails/jour gratuit) |
| **Sécurité** | BCrypt (hashage mots de passe) |
| **Déploiement** | Render.com (CI/CD depuis GitHub) |
| **Build** | Maven, Docker |

---

## 🚀 Démo en ligne

🔗 **URL du site** : [https://rdv-medical-urrr.onrender.com](https://rdv-medical-urrr.onrender.com)

### 👥 Comptes de démonstration

| Rôle | Email | Mot de passe |
|------|-------|--------------|
| 👤 Patient | `demo@patient.com` | `demo123` |
| 👨‍⚕️ Médecin | `demo@medecin.com` | `demo123` |
| 👑 Administrateur | `admin@rdv.com` | `admin123` |

> ⚠️ Ces comptes sont publics. Merci de ne pas modifier les données sensibles.

---

## 📸 Captures d'écran

### Dashboard Médecin
![Dashboard Médecin](https://via.placeholder.com/800x400?text=Dashboard+Medecin)

### Calendrier des rendez-vous
![Calendrier](https://via.placeholder.com/800x400?text=Calendrier)

### Prise de rendez-vous
![Prise RDV](https://via.placeholder.com/800x400?text=Prise+RDV)

### Interface Admin
![Admin](https://via.placeholder.com/800x400?text=Admin+Panel)

> *(Remplace les placeholders par tes propres captures d'écran)*

---

## 📦 Installation locale

### Prérequis

- Java 17+
- PostgreSQL 16+
- Maven 3.9+
- Tomcat 10.1+

### Étapes d'installation

1. **Cloner le projet**
```bash
git clone https://github.com/mitiarj05/rdv_Medecin.git
cd rdv_Medecin
