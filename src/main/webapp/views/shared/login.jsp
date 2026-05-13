<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Connexion - RDV Medical</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1a73e8 0%, #0d47a1 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .login-container {
            max-width: 450px;
            width: 100%;
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            overflow: hidden;
            animation: slideUp 0.4s ease-out;
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .login-header {
            background: linear-gradient(135deg, #1a73e8 0%, #0d47a1 100%);
            color: white;
            padding: 35px 30px;
            text-align: center;
        }

        .login-header h1 {
            font-size: 28px;
            margin-bottom: 8px;
            font-weight: 600;
        }

        .login-header p {
            opacity: 0.9;
            font-size: 14px;
        }

        .login-body {
            padding: 30px;
        }

        /* ── Section comptes récents ── */
        .recent-accounts {
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 1px solid #e0e0e0;
        }

        .recent-title {
            font-size: 13px;
            color: #888;
            margin-bottom: 12px;
            font-weight: 500;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .accounts-counter {
            font-size: 11px;
            color: #aaa;
        }

        .accounts-carousel {
            position: relative;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .carousel-btn {
            flex-shrink: 0;
            width: 28px;
            height: 28px;
            border: 1px solid #ddd;
            border-radius: 50%;
            background: white;
            color: #555;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            transition: all 0.2s;
            box-shadow: 0 1px 4px rgba(0,0,0,0.08);
        }

        .carousel-btn:hover:not(:disabled) {
            background: #1a73e8;
            color: white;
            border-color: #1a73e8;
        }

        .carousel-btn:disabled {
            opacity: 0.3;
            cursor: not-allowed;
        }

        .accounts-viewport {
            flex: 1;
            overflow: hidden;
        }

        .accounts-list {
            display: flex;
            gap: 10px;
            transition: transform 0.3s ease;
            will-change: transform;
        }

        .accounts-dots {
            display: flex;
            justify-content: center;
            gap: 5px;
            margin-top: 8px;
        }

        .dot {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: #ddd;
            cursor: pointer;
            transition: background 0.2s;
        }

        .dot.active {
            background: #1a73e8;
        }

        .account-card {
            flex-shrink: 0;
            width: 80px;
            text-align: center;
            cursor: pointer;
            transition: all 0.2s ease;
            border-radius: 10px;
            padding: 8px 5px;
            background: #f5f5f5;
            position: relative;
        }

        .account-card:hover {
            background: #e8f0fd;
            transform: translateY(-2px);
        }

        .account-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            margin: 0 auto 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            color: white;
        }

        .account-avatar.patient {
            background: linear-gradient(135deg, #1a73e8, #0d47a1);
        }

        .account-avatar.medecin {
            background: linear-gradient(135deg, #34a853, #1e7e4a);
        }

        .account-name {
            font-size: 11px;
            font-weight: 500;
            color: #333;
            margin-bottom: 2px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .account-role {
            font-size: 9px;
            color: #888;
        }

        .remove-account-btn {
            background: none;
            border: none;
            color: #bbb;
            font-size: 9px;
            cursor: pointer;
            margin-top: 4px;
            display: inline-flex;
            align-items: center;
            gap: 3px;
            transition: color 0.2s;
        }

        .remove-account-btn:hover {
            color: #ea4335;
        }

        .add-account-card {
            border: 1px dashed #ccc;
        }

        .add-account-card:hover {
            background: #f5f5f5 !important;
            border-color: #1a73e8;
        }

        /* ── Formulaire ── */
        .form-group {
            margin-bottom: 18px;
        }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 500;
            color: #555;
            margin-bottom: 6px;
        }

        .form-group input {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.2s;
        }

        .form-group input:focus {
            outline: none;
            border-color: #1a73e8;
            box-shadow: 0 0 0 3px rgba(26,115,232,0.1);
        }

        .checkbox-group {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
            font-size: 13px;
        }

        .checkbox-left {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .checkbox-left input { width: auto; }

        .forgot-link {
            color: #1a73e8;
            text-decoration: none;
        }

        .forgot-link:hover { text-decoration: underline; }

        .btn-login {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #1a73e8, #0d47a1);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-login:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(26,115,232,0.4);
        }

        .register-link {
            text-align: center;
            margin-top: 20px;
            padding-top: 15px;
            border-top: 1px solid #e0e0e0;
            font-size: 13px;
        }

        .register-link a {
            color: #1a73e8;
            text-decoration: none;
            font-weight: 500;
        }

        .register-link a:hover { text-decoration: underline; }

        .alert {
            padding: 10px 14px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 13px;
        }

        .alert-danger {
            background: #fce8e6;
            color: #c5221f;
            border-left: 3px solid #ea4335;
        }

        .alert-success {
            background: #e6f4ea;
            color: #137333;
            border-left: 3px solid #34a853;
        }

        .temp-message {
            animation: fadeOut 0.5s ease-out 2.5s forwards;
        }

        @keyframes fadeOut {
            to { opacity: 0; visibility: hidden; }
        }
    </style>
</head>
<body>

<%
    String lastEmailsPatient = "";
    String lastEmailsMedecin = "";

    java.util.List<String> patientEmailsList = new java.util.ArrayList<>();
    java.util.List<String> medecinEmailsList  = new java.util.ArrayList<>();

    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("last_emails_patient".equals(cookie.getName())) lastEmailsPatient = cookie.getValue();
            if ("last_emails_medecin".equals(cookie.getName())) lastEmailsMedecin = cookie.getValue();
        }
    }

    if (lastEmailsPatient != null && !lastEmailsPatient.isEmpty()) {
        for (String email : lastEmailsPatient.split("\\|")) {
            if (email != null && !email.isEmpty()) patientEmailsList.add(email);
        }
    }

    if (lastEmailsMedecin != null && !lastEmailsMedecin.isEmpty()) {
        for (String email : lastEmailsMedecin.split("\\|")) {
            if (email != null && !email.isEmpty() && !"admin@rdv.com".equals(email)) medecinEmailsList.add(email);
        }
    }
%>

<div class="login-container">
    <div class="login-header">
        <h1><i class="fas fa-hospital-user"></i> RDV Medical</h1>
        <p>Connectez-vous à votre espace</p>
    </div>

    <div class="login-body">

        <c:if test="${not empty erreur}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-triangle"></i> ${erreur}
            </div>
        </c:if>
        <c:if test="${not empty succes}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> ${succes}
            </div>
        </c:if>

        <!-- SECTION COMPTES RÉCENTS -->
        <div class="recent-accounts" id="recentAccountsSection">
            <div class="recent-title">
                <span><i class="fas fa-history"></i> Connexions récentes</span>
                <span class="accounts-counter" id="accountsCounter"></span>
            </div>

            <div class="accounts-carousel">
                <button class="carousel-btn" id="prevBtn" onclick="carouselPrev()" disabled title="Précédent">
                    <i class="fas fa-chevron-left"></i>
                </button>

                <div class="accounts-viewport" id="accountsViewport">
                    <div class="accounts-list" id="accountsList"></div>
                </div>

                <button class="carousel-btn" id="nextBtn" onclick="carouselNext()" title="Suivant">
                    <i class="fas fa-chevron-right"></i>
                </button>
            </div>

            <div class="accounts-dots" id="accountsDots"></div>
        </div>

        <!-- FORMULAIRE DE CONNEXION -->
        <form id="loginForm" action="${pageContext.request.contextPath}/auth" method="post">
            <input type="hidden" name="action" value="login">

            <div class="form-group">
                <label>Adresse email</label>
                <input type="email" name="email" id="emailInput" placeholder="votre@email.com" required>
            </div>

            <div class="form-group">
                <label>Mot de passe</label>
                <input type="password" name="password" id="passwordInput" placeholder="*********" required>
            </div>

            <div class="checkbox-group">
                <div class="checkbox-left">
                    <input type="checkbox" name="remember" id="remember" value="true">
                    <label for="remember" style="margin:0;">Se souvenir de moi</label>
                </div>
                <a href="${pageContext.request.contextPath}/views/shared/forgot-password.jsp" class="forgot-link">
                    Mot de passe oublié ?
                </a>
            </div>

            <button type="submit" class="btn-login">
                <i class="fas fa-sign-in-alt"></i> Se connecter
            </button>
        </form>

        <div class="register-link">
            Pas encore de compte ?
            <a href="${pageContext.request.contextPath}/views/shared/register.jsp">S'inscrire</a>
        </div>
    </div>
</div>

<script>
    var patientEmailsData = [
        <% for (int i = 0; i < patientEmailsList.size(); i++) { %>
            { email: "<%= patientEmailsList.get(i) %>", role: "patient" }<%= (i < patientEmailsList.size()-1) ? "," : "" %>
        <% } %>
    ];

    var medecinEmailsData = [
        <% for (int i = 0; i < medecinEmailsList.size(); i++) { %>
            { email: "<%= medecinEmailsList.get(i) %>", role: "medecin" }<%= (i < medecinEmailsList.size()-1) ? "," : "" %>
        <% } %>
    ];

    var contextPath = '${pageContext.request.contextPath}';

    var CARD_WIDTH    = 90;  // largeur carte + gap (80px + 10px)
    var VISIBLE_CARDS = 4;   // cartes visibles à la fois
    var currentIndex  = 0;
    var totalAccounts = 0;

    function getDisplayName(email) {
        var namePart = email.split('@')[0].replace(/[._]/g, ' ');
        return namePart.split(' ').map(function(w) {
            return w.length ? w.charAt(0).toUpperCase() + w.slice(1).toLowerCase() : '';
        }).join(' ');
    }

    function getAvatarIcon(role)  { return role === 'medecin' ? '<i class="fas fa-user-md"></i>' : '<i class="fas fa-user"></i>'; }
    function getAvatarClass(role) { return role === 'medecin' ? 'medecin' : 'patient'; }
    function getRoleText(role)    { return role === 'medecin' ? 'Médecin' : 'Patient'; }
    function getRoleIcon(role)    { return role === 'medecin' ? 'fa-stethoscope' : 'fa-user'; }

    function buildAccountCard(account) {
        var div = document.createElement('div');
        div.className = 'account-card';
        div.onclick = (function(e, r) { return function() { selectAccount(e, r); }; })(account.email, account.role);
        div.innerHTML =
            '<div class="account-avatar ' + getAvatarClass(account.role) + '">' + getAvatarIcon(account.role) + '</div>' +
            '<div class="account-name" title="' + account.email + '">' + getDisplayName(account.email) + '</div>' +
            '<div class="account-role"><i class="fas ' + getRoleIcon(account.role) + '"></i> ' + getRoleText(account.role) + '</div>' +
            '<button class="remove-account-btn" onclick="removeAccount(event,\'' + account.email + '\',\'' + account.role + '\')">' +
                '<i class="fas fa-times-circle"></i> Supprimer</button>';
        return div;
    }

    function buildAddCard() {
        var div = document.createElement('div');
        div.className = 'account-card add-account-card';
        div.onclick = clearForm;
        div.innerHTML =
            '<div class="account-avatar" style="background:#e0e0e0;color:#999;"><i class="fas fa-plus"></i></div>' +
            '<div class="account-name">Ajouter</div>' +
            '<div class="account-role">Nouveau compte</div>';
        return div;
    }

    function buildDots(total) {
        var dotsEl = document.getElementById('accountsDots');
        dotsEl.innerHTML = '';
        var pages = Math.ceil(total / VISIBLE_CARDS);
        if (pages <= 1) return;
        for (var p = 0; p < pages; p++) {
            var dot = document.createElement('span');
            dot.className = 'dot' + (p === 0 ? ' active' : '');
            dot.setAttribute('data-page', p);
            dot.onclick = (function(page) { return function() { goToPage(page); }; })(p);
            dotsEl.appendChild(dot);
        }
    }

    function updateCarousel() {
        var list = document.getElementById('accountsList');
        list.style.transform = 'translateX(-' + (currentIndex * CARD_WIDTH) + 'px)';

        document.getElementById('prevBtn').disabled = currentIndex === 0;
        document.getElementById('nextBtn').disabled = currentIndex >= totalAccounts - VISIBLE_CARDS;

        var page = Math.floor(currentIndex / VISIBLE_CARDS);
        document.querySelectorAll('.dot').forEach(function(d) {
            d.classList.toggle('active', parseInt(d.getAttribute('data-page')) === page);
        });

        var end = Math.min(currentIndex + VISIBLE_CARDS, totalAccounts);
        document.getElementById('accountsCounter').textContent =
            totalAccounts > VISIBLE_CARDS ? (currentIndex + 1) + '–' + end + ' / ' + totalAccounts : '';
    }

    function carouselNext() {
        if (currentIndex < totalAccounts - VISIBLE_CARDS) { currentIndex++; updateCarousel(); }
    }

    function carouselPrev() {
        if (currentIndex > 0) { currentIndex--; updateCarousel(); }
    }

    function goToPage(page) {
        currentIndex = page * VISIBLE_CARDS;
        if (currentIndex > totalAccounts - VISIBLE_CARDS) currentIndex = Math.max(0, totalAccounts - VISIBLE_CARDS);
        updateCarousel();
    }

    function displayRecentAccounts() {
        var section = document.getElementById('recentAccountsSection');
        var listEl  = document.getElementById('accountsList');
        var allAccounts = patientEmailsData.concat(medecinEmailsData);
        totalAccounts = allAccounts.length + 1; // +1 pour la carte "Ajouter"

        if (allAccounts.length === 0) { section.style.display = 'none'; return; }

        section.style.display = 'block';
        listEl.innerHTML = '';
        allAccounts.forEach(function(account) { listEl.appendChild(buildAccountCard(account)); });
        listEl.appendChild(buildAddCard());

        buildDots(totalAccounts);
        currentIndex = 0;
        updateCarousel();
    }

    function selectAccount(email, role) {
        document.getElementById('emailInput').value = email;
        document.getElementById('passwordInput').value = '';
        document.getElementById('passwordInput').focus();
    }

    function removeAccount(event, email, role) {
        event.stopPropagation();
        if (confirm('Supprimer "' + email + '" de la liste des connexions récentes ?')) {
            window.location.href = contextPath + '/auth?action=removeEmail&email=' + encodeURIComponent(email) + '&role=' + role;
        }
    }

    function clearForm() {
        document.getElementById('emailInput').value = '';
        document.getElementById('passwordInput').value = '';
        document.getElementById('emailInput').focus();
    }

    function showTempMsg(html) {
        var msgDiv = document.createElement('div');
        msgDiv.className = 'alert alert-success temp-message';
        msgDiv.innerHTML = html;
        var loginBody = document.querySelector('.login-body');
        loginBody.insertBefore(msgDiv, document.getElementById('recentAccountsSection').nextSibling);
        setTimeout(function() { msgDiv.remove(); }, 3000);
    }

    document.addEventListener('DOMContentLoaded', function() {
        displayRecentAccounts();
        var urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('logout') === 'success')
            showTempMsg('<i class="fas fa-check-circle"></i> Vous avez été déconnecté avec succès.');
        if (urlParams.get('msg') === 'account_deleted')
            showTempMsg('<i class="fas fa-check-circle"></i> Votre compte a été supprimé.');
    });
</script>

</body>
</html>