<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inscription - RDV Medical</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            background: linear-gradient(135deg, #1a73e8 0%, #0d47a1 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .card {
            background: white;
            border-radius: 20px;
            padding: 40px;
            width: 100%;
            max-width: 460px;
            box-shadow: 0 24px 64px rgba(0, 0, 0, 0.22);
        }

        /* ── Logo ── */
        .logo-area {
            text-align: center;
            margin-bottom: 24px;
        }

        .logo-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 60px;
            height: 60px;
            background: #e8f0fe;
            border-radius: 16px;
            margin-bottom: 12px;
        }

        .logo-badge svg { width: 32px; height: 32px; }

        .app-title {
            color: #1a1a1a;
            font-size: 22px;
            font-weight: 700;
            margin: 0;
        }

        .app-subtitle {
            color: #888;
            font-size: 13px;
            margin: 4px 0 0;
        }

        /* ── Badge patient ── */
        .patient-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #e8f0fe;
            color: #1a73e8;
            font-size: 12px;
            font-weight: 600;
            padding: 5px 14px;
            border-radius: 20px;
            margin-bottom: 22px;
        }

        /* ── Alerts ── */
        .alert {
            padding: 10px 14px;
            border-radius: 10px;
            font-size: 13px;
            margin-bottom: 16px;
        }

        .alert-danger {
            background: #fce8e6;
            color: #c5221f;
            border-left: 4px solid #ea4335;
        }

        /* ── Section title ── */
        .section-title {
            font-size: 11px;
            font-weight: 700;
            color: #1a73e8;
            text-transform: uppercase;
            letter-spacing: 0.7px;
            margin: 20px 0 12px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .section-title::after {
            content: '';
            flex: 1;
            height: 1px;
            background: #e8f0fe;
        }

        .section-title:first-of-type { margin-top: 0; }

        /* ── Form group ── */
        .form-group { margin-bottom: 14px; }

        .form-group label {
            display: block;
            font-size: 12px;
            font-weight: 600;
            color: #555;
            margin-bottom: 5px;
        }

        .form-group input {
            width: 100%;
            padding: 10px 13px;
            border: 1.5px solid #e0e0e0;
            border-radius: 10px;
            font-size: 14px;
            color: #1a1a1a;
            background: #fafafa;
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .form-group input:focus {
            outline: none;
            border-color: #1a73e8;
            background: white;
            box-shadow: 0 0 0 3px rgba(26, 115, 232, 0.12);
        }

        .form-group input.input-error {
            border-color: #ea4335 !important;
            background: #fff8f7;
        }

        .form-group input.input-error:focus {
            box-shadow: 0 0 0 3px rgba(234, 67, 53, 0.12) !important;
        }

        .form-group input.input-ok {
            border-color: #34a853 !important;
            background: #f6fff8;
        }

        /* ── Password wrap ── */
        .pw-wrap { position: relative; }
        .pw-wrap input { padding-right: 44px; }

        .toggle-password {
            position: absolute;
            right: 11px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            font-size: 17px;
            color: #bbb;
            padding: 0;
            line-height: 1;
        }

        .toggle-password:hover { color: #1a73e8; }

        /* ── Password strength ── */
        .pw-strength {
            height: 4px;
            border-radius: 2px;
            margin-top: 6px;
            background: #f0f0f0;
            overflow: hidden;
        }

        .pw-strength-bar {
            height: 100%;
            border-radius: 2px;
            width: 0%;
            transition: width 0.3s, background 0.3s;
        }

        .pw-hint {
            font-size: 11px;
            margin-top: 4px;
            color: #aaa;
            min-height: 16px;
        }

        /* ── Confirm feedback ── */
        .confirm-feedback {
            font-size: 11px;
            margin-top: 4px;
            min-height: 16px;
        }

        .confirm-feedback.match   { color: #34a853; }
        .confirm-feedback.nomatch { color: #ea4335; }

        /* ── Submit button ── */
        .btn-primary {
            width: 100%;
            padding: 12px;
            background: #1a73e8;
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 8px;
            transition: background 0.2s, transform 0.1s;
        }

        .btn-primary:hover { background: #1557b0; }
        .btn-primary:active { transform: scale(0.99); }

        /* ── Footer ── */
        .footer {
            text-align: center;
            margin-top: 20px;
            font-size: 13px;
            color: #888;
        }

        .footer a {
            color: #1a73e8;
            text-decoration: none;
            font-weight: 600;
        }

        .footer a:hover { text-decoration: underline; }
    </style>
</head>
<body>

<div class="card">

    <!-- Logo -->
    <div class="logo-area">
        <div class="logo-badge">
            <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z" fill="#1a73e8"/>
                <path d="M10.5 7h3v2.5H16v3h-2.5V15h-3v-2.5H8v-3h2.5V7z" fill="white"/>
            </svg>
        </div>
        <h1 class="app-title">Créer un compte</h1>
        <p class="app-subtitle">Rejoignez RDV Medical</p>
    </div>

    <!-- Badge patient -->
    <div style="text-align:center;">
        <span class="patient-badge">👤 Inscription Patient</span>
    </div>

    <%-- Alertes serveur --%>
    <c:if test="${not empty erreur}">
        <div class="alert alert-danger">${erreur}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/auth" method="post"
          id="registerForm" novalidate>
        <input type="hidden" name="action" value="register">
        <input type="hidden" name="role"   value="patient">

        <%-- ── Informations personnelles ── --%>
        <div class="section-title">Informations personnelles</div>

        <div class="form-group">
            <label for="nom_pat">Nom complet</label>
            <input type="text" name="nom_pat" id="nom_pat"
                   placeholder="Ex : Rakoto Jean"
                   autocomplete="name" required>
        </div>

        <div class="form-group">
            <label for="datenais">Date de naissance</label>
            <input type="date" name="datenais" id="datenais" required>
        </div>

        <%-- ── Informations de connexion ── --%>
        <div class="section-title">Informations de connexion</div>

        <div class="form-group">
            <label for="email">Adresse email</label>
            <input type="email" name="email" id="email"
                   placeholder="votre@email.com"
                   autocomplete="email" required>
        </div>

        <div class="form-group">
            <label for="password">Mot de passe</label>
            <div class="pw-wrap">
                <input type="password" name="password" id="password"
                       placeholder="Minimum 6 caractères"
                       autocomplete="new-password"
                       oninput="checkStrength(this); checkConfirm();"
                       required>
                <button type="button" class="toggle-password"
                        onclick="togglePw('password')">👁️</button>
            </div>
            <div class="pw-strength">
                <div class="pw-strength-bar" id="strength-bar"></div>
            </div>
            <div class="pw-hint" id="strength-hint">Au moins 6 caractères</div>
        </div>

        <div class="form-group">
            <label for="confirm_password">Confirmer le mot de passe</label>
            <div class="pw-wrap">
                <input type="password" name="confirm_password" id="confirm_password"
                       placeholder="Répétez votre mot de passe"
                       autocomplete="new-password"
                       oninput="checkConfirm();"
                       required>
                <button type="button" class="toggle-password"
                        onclick="togglePw('confirm_password')">👁️</button>
            </div>
            <div class="confirm-feedback" id="confirm-feedback"></div>
        </div>

        <button type="submit" class="btn-primary"
                onclick="return validateForm()">
            Créer mon compte
        </button>
    </form>

    <div class="footer">
        Déjà un compte ?
        <a href="${pageContext.request.contextPath}/views/shared/login.jsp">Se connecter</a>
    </div>

</div>

<script>
    /* ══════════════════════════════════════════
       Toggle affichage mot de passe
    ══════════════════════════════════════════ */
    function togglePw(inputId) {
        var input = document.getElementById(inputId);
        input.type = input.type === 'password' ? 'text' : 'password';
    }

    /* ══════════════════════════════════════════
       Indicateur de force du mot de passe
    ══════════════════════════════════════════ */
    function checkStrength(input) {
        var val  = input.value;
        var bar  = document.getElementById('strength-bar');
        var hint = document.getElementById('strength-hint');

        if (val.length === 0) {
            bar.style.width      = '0%';
            hint.textContent     = 'Au moins 6 caractères';
            hint.style.color     = '#aaa';
            return;
        }

        var score = 0;
        if (val.length >= 6)           score++;
        if (val.length >= 10)          score++;
        if (/[A-Z]/.test(val))         score++;
        if (/[0-9]/.test(val))         score++;
        if (/[^A-Za-z0-9]/.test(val))  score++;

        var levels = [
            { pct: '20%',  color: '#ea4335', label: 'Trop court'  },
            { pct: '40%',  color: '#ea4335', label: 'Faible'      },
            { pct: '60%',  color: '#fbbc04', label: 'Moyen'       },
            { pct: '80%',  color: '#34a853', label: 'Bon'         },
            { pct: '100%', color: '#1a73e8', label: 'Excellent'   }
        ];

        var idx = Math.max(0, Math.min(score - 1, 4));
        var lvl = levels[idx];

        bar.style.width      = lvl.pct;
        bar.style.background = lvl.color;
        hint.textContent     = lvl.label;
        hint.style.color     = lvl.color;
    }

    /* ══════════════════════════════════════════
       Vérification confirmation mot de passe (temps réel)
    ══════════════════════════════════════════ */
    function checkConfirm() {
        var pw      = document.getElementById('password').value;
        var confirm = document.getElementById('confirm_password').value;
        var fb      = document.getElementById('confirm-feedback');
        var inp     = document.getElementById('confirm_password');

        if (confirm.length === 0) {
            fb.textContent = '';
            fb.className   = 'confirm-feedback';
            inp.classList.remove('input-ok', 'input-error');
            return;
        }

        if (pw === confirm) {
            fb.textContent = '✓ Les mots de passe correspondent';
            fb.className   = 'confirm-feedback match';
            inp.classList.remove('input-error');
            inp.classList.add('input-ok');
        } else {
            fb.textContent = '✗ Les mots de passe ne correspondent pas';
            fb.className   = 'confirm-feedback nomatch';
            inp.classList.remove('input-ok');
            inp.classList.add('input-error');
        }
    }

    /* ══════════════════════════════════════════
       Validation finale avant soumission
    ══════════════════════════════════════════ */
    function validateForm() {
        var nom      = document.getElementById('nom_pat').value.trim();
        var datenais = document.getElementById('datenais').value;
        var email    = document.getElementById('email').value.trim();
        var pw       = document.getElementById('password').value;
        var confirm  = document.getElementById('confirm_password').value;

        if (!nom) {
            highlight('nom_pat');
            alert('Veuillez saisir votre nom complet.');
            return false;
        }

        if (!datenais) {
            highlight('datenais');
            alert('Veuillez saisir votre date de naissance.');
            return false;
        }

        if (!email || email.indexOf('@') === -1) {
            highlight('email');
            alert('Veuillez saisir une adresse email valide.');
            return false;
        }

        if (pw.length < 6) {
            highlight('password');
            alert('Le mot de passe doit contenir au moins 6 caractères.');
            return false;
        }

        if (pw !== confirm) {
            highlight('confirm_password');
            alert('Les mots de passe ne correspondent pas.');
            return false;
        }

        return true;
    }

    function highlight(fieldId) {
        var field = document.getElementById(fieldId);
        field.classList.add('input-error');
        field.focus();
        field.addEventListener('input', function() {
            field.classList.remove('input-error');
        }, { once: true });
    }
</script>
</body>
</html>
