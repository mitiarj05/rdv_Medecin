<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RDV Medical</title>
    <style>
        /* ===== VARIABLES CSS (thème clair par défaut) ===== */
        :root {
            --bg-primary: #f0f4f8;
            --bg-card: #ffffff;
            --bg-sidebar: #ffffff;
            --bg-header: linear-gradient(135deg, #1a73e8 0%, #0d47a1 100%);
            --text-primary: #333333;
            --text-secondary: #666666;
            --text-muted: #888888;
            --border-color: #e8f0fe;
            --border-light: #f0f4f8;
            --shadow-color: rgba(0,0,0,0.08);
            --shadow-hover: rgba(0,0,0,0.15);
            --hover-bg: #e8f0fe;
            --btn-primary: #1a73e8;
            --btn-success: #34a853;
            --btn-danger: #ea4335;
            --btn-warning: #fbbc04;
            --btn-secondary: #6c757d;
            --badge-success-bg: #e6f4ea;
            --badge-success-text: #137333;
            --badge-danger-bg: #fce8e6;
            --badge-danger-text: #c5221f;
            --input-border: #dddddd;
            --input-focus: #1a73e8;
            --alert-danger-bg: #fce8e6;
            --alert-danger-text: #c5221f;
            --alert-success-bg: #e6f4ea;
            --alert-success-text: #137333;
            --sidebar-header-bg: linear-gradient(135deg, #1a73e8, #0d47a1);
            --skeleton-base: #e0e0e0;
            --skeleton-highlight: #f0f0f0;
        }

        /* ===== THÈME SOMBRE ===== */
        body.dark-mode {
            --bg-primary: #1a1a2e;
            --bg-card: #16213e;
            --bg-sidebar: #0f0f23;
            --bg-header: linear-gradient(135deg, #0d47a1 0%, #061b3a 100%);
            --text-primary: #eeeeee;
            --text-secondary: #aaaaaa;
            --text-muted: #777777;
            --border-color: #0f3460;
            --border-light: #1a1a3e;
            --shadow-color: rgba(0,0,0,0.3);
            --shadow-hover: rgba(0,0,0,0.4);
            --hover-bg: #1a2744;
            --btn-primary: #0d47a1;
            --btn-success: #1b8c4a;
            --btn-danger: #c62828;
            --btn-warning: #e6a800;
            --btn-secondary: #4a5568;
            --badge-success-bg: #1a3a2a;
            --badge-success-text: #4ade80;
            --badge-danger-bg: #3a1a1a;
            --badge-danger-text: #f87171;
            --input-border: #2a2a4a;
            --input-focus: #1a73e8;
            --alert-danger-bg: #2a1a1a;
            --alert-danger-text: #f87171;
            --alert-success-bg: #1a2a1a;
            --alert-success-text: #4ade80;
            --sidebar-header-bg: linear-gradient(135deg, #0d47a1, #061b3a);
            --skeleton-base: #2a2a4a;
            --skeleton-highlight: #3a3a5a;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            overflow-x: hidden;
            transition: background 0.3s ease, color 0.3s ease;
        }

        /* ===== SKELETON LOADER ===== */
        .skeleton {
            background: linear-gradient(90deg, var(--skeleton-base) 25%, var(--skeleton-highlight) 50%, var(--skeleton-base) 75%);
            background-size: 200% 100%;
            animation: skeletonLoading 0.8s infinite ease-in-out;
            border-radius: 8px;
        }

        @keyframes skeletonLoading {
            0% { background-position: 200% 0; }
            100% { background-position: -200% 0; }
        }

        .skeleton-text {
            height: 16px;
            margin: 8px 0;
            border-radius: 4px;
        }

        .skeleton-title {
            height: 24px;
            width: 60%;
            border-radius: 6px;
        }

        .skeleton-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
        }

        .skeleton-card {
            padding: 20px;
            background: var(--bg-card);
            border-radius: 12px;
            margin-bottom: 20px;
        }

        .skeleton-stat {
            height: 80px;
            width: 100%;
            border-radius: 12px;
        }

        .content-loaded {
            display: block;
        }

        .skeleton-container {
            display: none;
        }

        body.loading .content-loaded {
            display: none;
        }

        body.loading .skeleton-container {
            display: block;
        }

        /* ===== LAYOUT PRINCIPAL FLEXBOX ===== */
        .app-wrapper {
            display: flex;
            min-height: 100vh;
            width: 100%;
        }

        /* ===== SIDEBAR ===== */
        .sidebar {
            width: 280px;
            background: var(--bg-sidebar);
            box-shadow: 2px 0 20px var(--shadow-color);
            transition: all 0.3s ease-in-out;
            display: flex;
            flex-direction: column;
            position: relative;
            z-index: 100;
            flex-shrink: 0;
            overflow-x: hidden;
            margin-left: -280px;
        }

        .sidebar.visible {
            margin-left: 0;
        }

        .sidebar-header {
            padding: 25px 20px;
            background: var(--sidebar-header-bg);
            color: white;
            text-align: center;
            transition: all 0.3s ease;
        }

        .sidebar-header h3 {
            font-size: 18px;
        }

        .sidebar-header p {
            font-size: 11px;
            opacity: 0.85;
            margin-top: 5px;
        }

        .sidebar-nav {
            flex: 1;
            padding: 20px 0;
        }

        .sidebar-link {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 12px 20px;
            color: var(--text-primary);
            text-decoration: none;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            border-left: 4px solid transparent;
            white-space: nowrap;
            position: relative;
            overflow: hidden;
        }

        .sidebar-link::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            width: 0;
            height: 100%;
            background: var(--hover-bg);
            transition: width 0.3s ease;
            z-index: -1;
        }

        .sidebar-link:hover::before {
            width: 100%;
        }

        .sidebar-link:hover {
            border-left-color: #1a73e8;
        }

        .sidebar-icon {
            font-size: 22px;
            width: 30px;
            text-align: center;
            flex-shrink: 0;
            transition: transform 0.2s ease;
        }

        .sidebar-link:hover .sidebar-icon {
            transform: scale(1.1) rotate(3deg);
        }

        .sidebar-text {
            font-size: 14px;
            font-weight: 500;
        }

        .sidebar-divider {
            height: 1px;
            background: var(--border-color);
            margin: 15px 20px;
        }

        /* ===== CONTENU PRINCIPAL ===== */
        .main-content {
            flex: 1;
            transition: margin-left 0.3s ease-in-out;
            background: var(--bg-primary);
            min-height: 100vh;
            overflow-x: auto;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .card, .stat-card {
            animation: fadeInUp 0.2s ease-out forwards;
        }

        /* ===== HEADER ===== */
        .content-header {
            background: var(--bg-header);
            color: white;
            padding: 20px 30px;
            margin-bottom: 30px;
            box-shadow: 0 4px 20px var(--shadow-color);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
        }

        .header-left {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .menu-toggle-btn {
            background: rgba(255,255,255,0.2);
            border: none;
            color: white;
            font-size: 28px;
            cursor: pointer;
            width: 48px;
            height: 48px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
        }

        .menu-toggle-btn:hover {
            background: rgba(255,255,255,0.3);
            transform: scale(1.05) rotate(90deg);
        }

        .dark-mode-toggle {
            background: rgba(255,255,255,0.2);
            border: none;
            color: white;
            font-size: 22px;
            cursor: pointer;
            width: 48px;
            height: 48px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
            margin-left: 10px;
        }

        .dark-mode-toggle:hover {
            background: rgba(255,255,255,0.3);
            transform: scale(1.05) rotate(15deg);
        }

        .header-actions {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .logo h1 {
            font-size: 24px;
            font-weight: 700;
            transition: transform 0.2s;
        }

        .logo h1:hover {
            transform: scale(1.02);
        }

        .logo p {
            font-size: 12px;
            opacity: 0.85;
            margin-top: 4px;
        }

        .header-right {
            text-align: right;
        }

        .user-name {
            font-size: 16px;
            font-weight: 500;
            margin-bottom: 5px;
        }

        .date-area {
            font-size: 12px;
            opacity: 0.85;
        }

        /* ===== CONTAINER ===== */
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 25px 40px;
        }

        /* ===== CARTES ===== */
        .card {
            background: var(--bg-card);
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 2px 12px var(--shadow-color);
            margin-bottom: 20px;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px var(--shadow-hover);
        }

        .card-title {
            font-size: 20px;
            font-weight: 600;
            color: #1a73e8;
            margin-bottom: 20px;
            padding-bottom: 12px;
            border-bottom: 2px solid var(--border-color);
            transition: border-color 0.3s ease;
        }

        .stat-card {
            background: var(--bg-card);
            border-radius: 12px;
            padding: 24px;
            text-align: center;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #1a73e8, #34a853);
            transform: scaleX(0);
            transform-origin: left;
            transition: transform 0.3s ease;
        }

        .stat-card:hover::before {
            transform: scaleX(1);
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px var(--shadow-hover);
        }

        .stat-card .stat-icon {
            font-size: 40px;
            margin-bottom: 10px;
            transition: transform 0.2s ease;
        }

        .stat-card:hover .stat-icon {
            transform: scale(1.05);
        }

        .stat-card .stat-number {
            font-size: 32px;
            font-weight: bold;
            color: #1a73e8;
            transition: all 0.2s ease;
        }

        .stat-card:hover .stat-number {
            transform: scale(1.02);
        }

        .stat-card .stat-label {
            font-size: 13px;
            color: var(--text-secondary);
            margin-top: 5px;
        }

        /* ===== BOUTONS ===== */
        .btn {
            display: inline-block;
            padding: 9px 18px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            text-decoration: none;
            border: none;
            cursor: pointer;
            transition: all 0.15s ease;
            position: relative;
            overflow: hidden;
        }

        .btn::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255,255,255,0.3);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: width 0.3s, height 0.3s;
        }

        .btn:active::after {
            width: 200px;
            height: 200px;
        }

        .btn:hover {
            transform: translateY(-2px);
            filter: brightness(1.05);
        }

        .btn:active {
            transform: translateY(1px);
        }

        .btn-primary { background: var(--btn-primary); color: white; }
        .btn-success { background: var(--btn-success); color: white; }
        .btn-danger { background: var(--btn-danger); color: white; }
        .btn-warning { background: var(--btn-warning); color: #333; }
        .btn-secondary { background: var(--btn-secondary); color: white; }

        /* ===== TABLEAUX ===== */
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }
        th {
            background: var(--hover-bg);
            color: #1a73e8;
            padding: 12px 14px;
            text-align: left;
            font-weight: 600;
        }
        td {
            padding: 11px 14px;
            border-bottom: 1px solid var(--border-light);
            transition: all 0.15s ease;
        }
        tr:hover td {
            background: var(--hover-bg);
        }

        /* ===== FORMULAIRES ===== */
        .form-group {
            margin-bottom: 16px;
        }
        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-secondary);
            margin-bottom: 6px;
            transition: color 0.3s ease;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid var(--input-border);
            border-radius: 8px;
            font-size: 14px;
            background: var(--bg-card);
            color: var(--text-primary);
            transition: all 0.2s ease;
        }
        .form-group input:focus, .form-group select:focus {
            outline: none;
            border-color: var(--input-focus);
            box-shadow: 0 0 0 3px rgba(26,115,232,0.2);
        }

        /* ===== ALERTES ===== */
        .alert {
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 16px;
            font-size: 14px;
            animation: fadeInUp 0.2s ease-out;
        }
        .alert-danger {
            background: var(--alert-danger-bg);
            color: var(--alert-danger-text);
            border-left: 4px solid #ea4335;
        }
        .alert-success {
            background: var(--alert-success-bg);
            color: var(--alert-success-text);
            border-left: 4px solid #34a853;
        }

        /* ===== BADGES ===== */
        .badge {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            transition: all 0.15s ease;
        }
        .badge-success { background: var(--badge-success-bg); color: var(--badge-success-text); }
        .badge-danger { background: var(--badge-danger-bg); color: var(--badge-danger-text); }

        /* ===== TOP 5 MÉDECINS ===== */
        .top5-card {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 16px;
            border-radius: 12px;
            margin-bottom: 12px;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            cursor: pointer;
        }

        .top5-card:hover {
            transform: translateX(5px);
            box-shadow: 0 5px 15px var(--shadow-hover);
        }

        .medal {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 22px;
            flex-shrink: 0;
            transition: transform 0.2s ease;
        }

        .top5-card:hover .medal {
            transform: scale(1.05) rotate(3deg);
        }

        /* ===== LOADER PLEIN ÉCRAN ===== */
        .fullscreen-loader {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: var(--bg-primary);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            transition: opacity 0.2s ease, visibility 0.2s ease;
        }

        .fullscreen-loader.hidden {
            opacity: 0;
            visibility: hidden;
        }

        .loader-spinner {
            width: 40px;
            height: 40px;
            border: 3px solid var(--border-color);
            border-top-color: #1a73e8;
            border-radius: 50%;
            animation: spin 0.5s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* ===== RESPONSIVE ===== */
        @media (max-width: 768px) {
            .sidebar {
                position: fixed;
                top: 0;
                left: 0;
                height: 100vh;
                z-index: 1000;
                margin-left: -280px;
            }
            .sidebar.visible {
                margin-left: 0;
            }
            .container {
                padding: 0 15px 30px;
            }
            .content-header {
                padding: 15px 20px;
            }
            .logo h1 {
                font-size: 18px;
            }
            .logo p {
                display: none;
            }
            .menu-toggle-btn, .dark-mode-toggle {
                width: 42px;
                height: 42px;
                font-size: 20px;
            }
        }
    </style>
</head>
<body>

<!-- Fullscreen Loader -->
<div class="fullscreen-loader" id="fullscreenLoader">
    <div class="loader-spinner"></div>
</div>

<div class="app-wrapper">

    <!-- SIDEBAR -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <h3>🏥 RDV Medical</h3>
            <p>Plateforme médicale</p>
        </div>

        <div class="sidebar-nav">
            <c:choose>
                <c:when test="${sessionScope.role == 'patient'}">
                    <a href="${pageContext.request.contextPath}/patient?action=dashboard" class="sidebar-link">
                        <span class="sidebar-icon">🏠</span>
                        <span class="sidebar-text">Dashboard</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/search" class="sidebar-link">
                        <span class="sidebar-icon">🔍</span>
                        <span class="sidebar-text">Trouver un médecin</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/rdv?action=liste" class="sidebar-link">
                        <span class="sidebar-icon">📋</span>
                        <span class="sidebar-text">Mes rendez-vous</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/calendar" class="sidebar-link">
                        <span class="sidebar-icon">📅</span>
                        <span class="sidebar-text">Calendrier</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/patient?action=top5" class="sidebar-link">
                        <span class="sidebar-icon">🏆</span>
                        <span class="sidebar-text">Top 5 médecins</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/patient?action=edit&id=${sessionScope.idUtilisateur}" class="sidebar-link">
                        <span class="sidebar-icon">👤</span>
                        <span class="sidebar-text">Mon profil</span>
                    </a>
                </c:when>
                
                <c:when test="${sessionScope.role == 'medecin'}">
                    <a href="${pageContext.request.contextPath}/medecin?action=dashboard" class="sidebar-link">
                        <span class="sidebar-icon">🏠</span>
                        <span class="sidebar-text">Dashboard</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/rdv?action=liste" class="sidebar-link">
                        <span class="sidebar-icon">📋</span>
                        <span class="sidebar-text">Mes rendez-vous</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/calendar" class="sidebar-link">
                        <span class="sidebar-icon">📅</span>
                        <span class="sidebar-text">Calendrier</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/patient?action=liste" class="sidebar-link">
                        <span class="sidebar-icon">👥</span>
                        <span class="sidebar-text">Liste des patients</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/medecin?action=mesPatients" class="sidebar-link">
                        <span class="sidebar-icon">📋</span>
                        <span class="sidebar-text">Mes patients</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/medecin?action=top5" class="sidebar-link">
                        <span class="sidebar-icon">🏆</span>
                        <span class="sidebar-text">Top 5 médecins</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/medecin?action=edit&id=${sessionScope.idUtilisateur}" class="sidebar-link">
                        <span class="sidebar-icon">⚙️</span>
                        <span class="sidebar-text">Mon profil</span>
                    </a>
                </c:when>
            </c:choose>

            <div class="sidebar-divider"></div>

            <a href="${pageContext.request.contextPath}/auth?action=logout" class="sidebar-link">
                <span class="sidebar-icon">🔓</span>
                <span class="sidebar-text">Déconnexion</span>
            </a>
        </div>
    </div>

    <!-- CONTENU PRINCIPAL -->
    <div class="main-content" id="mainContent">

        <!-- Header -->
        <div class="content-header">
            <div class="header-left">
                <button class="menu-toggle-btn" id="menuToggleBtn">☰</button>
                <div class="logo">
                    <h1>🏥 RDV Medical</h1>
                    <p>Plateforme de rendez-vous médicaux</p>
                </div>
            </div>
            <div class="header-actions">
                <button class="dark-mode-toggle" id="darkModeToggleBtn" title="Thème sombre/clair">🌙</button>
                <div class="header-right">
                    <div class="user-name">
                        👋
                        <c:choose>
                            <c:when test="${sessionScope.role == 'patient'}">
                                ${sessionScope.utilisateur.nomPat}
                            </c:when>
                            <c:when test="${sessionScope.role == 'medecin'}">
                                Dr. ${sessionScope.utilisateur.nommed}
                            </c:when>
                            <c:otherwise>
                                Invité
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="date-area">
                        <script>
                            const jours = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
                            const mois = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
                            const date = new Date();
                            document.write(jours[date.getDay()] + ' ' + date.getDate() + ' ' + mois[date.getMonth()] + ' ' + date.getFullYear());
                        </script>
                    </div>
                </div>
            </div>
        </div>

<script>
    // ===== FERMER LE LOADER IMMÉDIATEMENT =====
    (function() {
        const loader = document.getElementById('fullscreenLoader');
        if (loader) {
            loader.classList.add('hidden');
        }
    })();

    // ===== DARK MODE TOGGLE =====
    const darkModeToggle = document.getElementById('darkModeToggleBtn');
    const body = document.body;

    const savedTheme = localStorage.getItem('darkMode');
    if (savedTheme === 'enabled') {
        body.classList.add('dark-mode');
        if (darkModeToggle) darkModeToggle.innerHTML = '☀️';
    } else {
        if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
            body.classList.add('dark-mode');
            if (darkModeToggle) darkModeToggle.innerHTML = '☀️';
            localStorage.setItem('darkMode', 'enabled');
        }
    }

    function toggleDarkMode() {
        if (body.classList.contains('dark-mode')) {
            body.classList.remove('dark-mode');
            if (darkModeToggle) darkModeToggle.innerHTML = '🌙';
            localStorage.setItem('darkMode', 'disabled');
        } else {
            body.classList.add('dark-mode');
            if (darkModeToggle) darkModeToggle.innerHTML = '☀️';
            localStorage.setItem('darkMode', 'enabled');
        }
    }

    if (darkModeToggle) {
        darkModeToggle.addEventListener('click', toggleDarkMode);
    }

    // ===== SIDEBAR TOGGLE =====
    let sidebarVisible = false;
    const sidebar = document.getElementById('sidebar');
    const menuToggleBtn = document.getElementById('menuToggleBtn');

    function toggleSidebar() {
        sidebarVisible = !sidebarVisible;
        if (sidebarVisible) {
            sidebar.classList.add('visible');
            localStorage.setItem('sidebarVisible', 'true');
        } else {
            sidebar.classList.remove('visible');
            localStorage.setItem('sidebarVisible', 'false');
        }
    }

    const savedSidebarState = localStorage.getItem('sidebarVisible');
    if (savedSidebarState === 'true') {
        sidebarVisible = true;
        sidebar.classList.add('visible');
    } else {
        sidebarVisible = false;
        sidebar.classList.remove('visible');
    }

    if (menuToggleBtn) {
        menuToggleBtn.addEventListener('click', toggleSidebar);
    }

    document.querySelectorAll('.sidebar-link').forEach(link => {
        link.addEventListener('click', function() {
            if (window.innerWidth <= 768) {
                sidebar.classList.remove('visible');
                sidebarVisible = false;
                localStorage.setItem('sidebarVisible', 'false');
            }
        });
    });
</script>

</body>
</html>