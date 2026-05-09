<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inscription - RDV Medical</title>
    <style>
        /* --- Votre CSS existant (inchangé) --- */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Arial, sans-serif; background: linear-gradient(135deg, #1a73e8 0%, #0d47a1 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px; }
        .card { background: white; border-radius: 20px; padding: 40px; width: 100%; max-width: 480px; box-shadow: 0 24px 64px rgba(0, 0, 0, 0.22); }
        .logo-area { text-align: center; margin-bottom: 24px; }
        .logo-badge { display: inline-flex; align-items: center; justify-content: center; width: 60px; height: 60px; background: #e8f0fe; border-radius: 16px; margin-bottom: 12px; }
        .logo-badge svg { width: 32px; height: 32px; }
        .app-title { color: #1a1a1a; font-size: 22px; font-weight: 700; margin: 0; }
        .app-subtitle { color: #888; font-size: 13px; margin: 4px 0 0; }
        .steps-row { display: flex; align-items: center; justify-content: center; gap: 0; margin-bottom: 28px; }
        .step-col { display: flex; flex-direction: column; align-items: center; }
        .step-dot { width: 32px; height: 32px; border-radius: 50%; background: #f0f0f0; color: #bbb; font-size: 13px; font-weight: 700; display: flex; align-items: center; justify-content: center; transition: all 0.3s; }
        .step-dot.active { background: #1a73e8; color: white; }
        .step-dot.done   { background: #34a853; color: white; }
        .step-label { font-size: 11px; color: #bbb; margin-top: 4px; white-space: nowrap; }
        .step-label.active { color: #1a73e8; font-weight: 600; }
        .step-line { width: 80px; height: 2px; background: #f0f0f0; margin-bottom: 16px; transition: background 0.3s; }
        .step-line.done { background: #34a853; }
        .alert { padding: 10px 14px; border-radius: 10px; font-size: 13px; margin-bottom: 16px; }
        .alert-danger { background: #fce8e6; color: #c5221f; border-left: 4px solid #ea4335; }
        .reg-step { display: none; }
        .reg-step.active { display: block; }
        .role-cards-row { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 24px; }
        .role-card { border: 2px solid #e8e8e8; border-radius: 16px; padding: 24px 16px 20px; cursor: pointer; text-align: center; transition: all 0.2s; background: #fafafa; }
        .role-card:hover { border-color: #a8c4f8; background: #f0f6ff; transform: translateY(-2px); }
        .role-card.selected { border-color: #1a73e8; background: #f0f6ff; box-shadow: 0 0 0 4px rgba(26, 115, 232, 0.12); }
        .role-card .role-icon { font-size: 38px; margin-bottom: 10px; display: block; }
        .role-card .role-name { font-size: 15px; font-weight: 700; color: #1a1a1a; margin-bottom: 4px; }
        .role-card.selected .role-name { color: #1a73e8; }
        .role-card .role-desc { font-size: 11px; color: #888; line-height: 1.4; }
        .role-card .check-badge { display: none; width: 20px; height: 20px; border-radius: 50%; background: #1a73e8; color: white; font-size: 11px; font-weight: 700; align-items: center; justify-content: center; margin: 8px auto 0; }
        .role-card.selected .check-badge { display: flex; }
        .section-title { font-size: 11px; font-weight: 700; color: #1a73e8; text-transform: uppercase; letter-spacing: 0.7px; margin: 20px 0 12px; display: flex; align-items: center; gap: 8px; }
        .section-title::after { content: ''; flex: 1; height: 1px; background: #e8f0fe; }
        .section-title:first-of-type { margin-top: 0; }
        .form-group { margin-bottom: 14px; }
        .form-group label { display: block; font-size: 12px; font-weight: 600; color: #555; margin-bottom: 5px; }
        .form-group input { width: 100%; padding: 10px 13px; border: 1.5px solid #e0e0e0; border-radius: 10px; font-size: 14px; color: #1a1a1a; background: #fafafa; transition: border-color 0.2s, box-shadow 0.2s; }
        .form-group input:focus { outline: none; border-color: #1a73e8; background: white; box-shadow: 0 0 0 3px rgba(26, 115, 232, 0.12); }
        .form-group input.input-error { border-color: #ea4335 !important; background: #fff8f7; }
        .form-group input.input-ok { border-color: #34a853 !important; background: #f6fff8; }
        .row2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        .pw-wrap { position: relative; }
        .pw-wrap input { padding-right: 44px; }
        .toggle-password { position: absolute; right: 11px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; font-size: 17px; color: #bbb; padding: 0; line-height: 1; }
        .toggle-password:hover { color: #1a73e8; }
        .pw-strength { height: 4px; border-radius: 2px; margin-top: 6px; background: #f0f0f0; overflow: hidden; }
        .pw-strength-bar { height: 100%; border-radius: 2px; width: 0%; transition: width 0.3s, background 0.3s; }
        .pw-hint { font-size: 11px; margin-top: 4px; color: #aaa; min-height: 16px; }
        .confirm-feedback { font-size: 11px; margin-top: 4px; min-height: 16px; }
        .confirm-feedback.match   { color: #34a853; }
        .confirm-feedback.nomatch { color: #ea4335; }
        .btn-primary { background: #1a73e8; color: white; border: none; border-radius: 10px; font-size: 14px; font-weight: 600; cursor: pointer; padding: 11px 20px; transition: background 0.2s, transform 0.1s; }
        .btn-primary:hover { background: #1557b0; }
        .btn-primary:active { transform: scale(0.99); }
        .btn-primary.full { width: 100%; margin-top: 4px; }
        .btn-secondary { background: white; color: #666; border: 1.5px solid #e0e0e0; border-radius: 10px; font-size: 14px; font-weight: 500; cursor: pointer; padding: 11px 20px; transition: all 0.2s; }
        .btn-secondary:hover { background: #f5f5f5; border-color: #bbb; }
        .btn-row { display: flex; gap: 10px; margin-top: 6px; }
        .btn-row .btn-secondary { flex: 1; }
        .btn-row .btn-primary   { flex: 2; }
        .footer { text-align: center; margin-top: 20px; font-size: 13px; color: #888; }
        .footer a { color: #1a73e8; text-decoration: none; font-weight: 600; }
        .footer a:hover { text-decoration: underline; }
        .role-helper { font-size: 13px; color: #888; text-align: center; margin-bottom: 16px; }
    </style>
</head>
<body>

<div class="card">
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

    <div class="steps-row">
        <div class="step-col">
            <div class="step-dot active" id="dot1">1</div>
            <div class="step-label active" id="lbl1">Type de compte</div>
        </div>
        <div class="step-line" id="line1"></div>
        <div class="step-col">
            <div class="step-dot" id="dot2">2</div>
            <div class="step-label" id="lbl2">Informations</div>
        </div>
    </div>

    <c:if test="${not empty erreur}">
        <div class="alert alert-danger">${erreur}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/auth" method="post" id="registerForm" novalidate>
        <input type="hidden" name="action" value="register">
        <input type="hidden" name="role"   id="roleInput" value="patient">

        <!-- ÉTAPE 1 : Choix du rôle -->
        <div class="reg-step active" id="step1">
            <p class="role-helper">Quel type de compte souhaitez-vous créer ?</p>
            <div class="role-cards-row">
                <div class="role-card selected" id="card-patient" onclick="selectRole('patient')">
                    <span class="role-icon">👤</span>
                    <div class="role-name">Patient</div>
                    <div class="role-desc">Prenez et gérez vos rendez-vous médicaux</div>
                    <div class="check-badge">✓</div>
                </div>
                <div class="role-card" id="card-medecin" onclick="selectRole('medecin')">
                    <span class="role-icon">🩺</span>
                    <div class="role-name">Médecin</div>
                    <div class="role-desc">Gérez votre agenda et vos consultations</div>
                    <div class="check-badge">✓</div>
                </div>
            </div>
            <button type="button" class="btn-primary full" onclick="goStep2()">Continuer</button>
            <div class="footer">Déjà un compte ? <a href="${pageContext.request.contextPath}/views/shared/login.jsp">Se connecter</a></div>
        </div>

        <!-- ÉTAPE 2 : Formulaire PATIENT -->
        <div class="reg-step" id="step2-patient">
            <div class="section-title">Informations personnelles</div>
            <div class="form-group">
                <label for="pat-nom">Nom complet</label>
                <input type="text" name="nom_pat" id="pat-nom" placeholder="Ex : Rakoto Jean" autocomplete="name">
            </div>
            <div class="form-group">
                <label for="pat-datenais">Date de naissance</label>
                <input type="date" name="datenais" id="pat-datenais">
            </div>
            <div class="section-title">Informations de connexion</div>
            <div class="form-group">
                <label for="pat-email">Adresse email</label>
                <input type="email" name="email" id="pat-email" placeholder="votre@email.com" autocomplete="email">
            </div>
            <div class="form-group">
                <label for="pat-pw">Mot de passe</label>
                <div class="pw-wrap">
                    <input type="password" name="password" id="pat-pw" placeholder="Minimum 6 caractères" autocomplete="new-password"
                           oninput="checkStrength('pat'); checkConfirm('pat');">
                    <button type="button" class="toggle-password" onclick="togglePw('pat-pw')">👁️</button>
                </div>
                <div class="pw-strength"><div class="pw-strength-bar" id="pat-bar"></div></div>
                <div class="pw-hint" id="pat-hint">Au moins 6 caractères</div>
            </div>
            <div class="form-group">
                <label for="pat-confirm">Confirmer le mot de passe</label>
                <div class="pw-wrap">
                    <input type="password" name="confirm_password" id="pat-confirm" placeholder="Répétez votre mot de passe" autocomplete="new-password"
                           oninput="checkConfirm('pat');">
                    <button type="button" class="toggle-password" onclick="togglePw('pat-confirm')">👁️</button>
                </div>
                <div class="confirm-feedback" id="pat-confirm-fb"></div>
            </div>
            <div class="btn-row">
                <button type="button" class="btn-secondary" onclick="goStep1()">← Retour</button>
                <button type="submit" class="btn-primary" onclick="return prepareFormBeforeSubmit('patient') && validateForm('patient')">Créer mon compte</button>
            </div>
            <div class="footer">Déjà un compte ? <a href="${pageContext.request.contextPath}/views/shared/login.jsp">Se connecter</a></div>
        </div>

        <!-- ÉTAPE 2 : Formulaire MÉDECIN -->
        <div class="reg-step" id="step2-medecin">
            <div class="section-title">Informations professionnelles</div>
            <div class="form-group">
                <label for="med-nom">Nom du médecin</label>
                <input type="text" name="nommed" id="med-nom" placeholder="Ex : Dr. Rasoa Marie" autocomplete="name">
            </div>
            <div class="row2">
                <div class="form-group">
                    <label for="med-spec">Spécialité</label>
                    <input type="text" name="specialite" id="med-spec" placeholder="Ex : Cardiologie">
                </div>
                <div class="form-group">
                    <label for="med-taux">Taux horaire (Ar)</label>
                    <input type="number" name="taux_horaire" id="med-taux" placeholder="80000" min="0">
                </div>
            </div>
            <div class="form-group">
                <label for="med-lieu">Cabinet / Lieu</label>
                <input type="text" name="lieu" id="med-lieu" placeholder="Ex : Antananarivo">
            </div>
            <div class="section-title">Informations de connexion</div>
            <div class="form-group">
                <label for="med-email">Adresse email</label>
                <input type="email" name="email" id="med-email" placeholder="votre@email.com" autocomplete="email">
            </div>
            <div class="form-group">
                <label for="med-pw">Mot de passe</label>
                <div class="pw-wrap">
                    <input type="password" name="password" id="med-pw" placeholder="Minimum 6 caractères" autocomplete="new-password"
                           oninput="checkStrength('med'); checkConfirm('med');">
                    <button type="button" class="toggle-password" onclick="togglePw('med-pw')">👁️</button>
                </div>
                <div class="pw-strength"><div class="pw-strength-bar" id="med-bar"></div></div>
                <div class="pw-hint" id="med-hint">Au moins 6 caractères</div>
            </div>
            <div class="form-group">
                <label for="med-confirm">Confirmer le mot de passe</label>
                <div class="pw-wrap">
                    <input type="password" name="confirm_password" id="med-confirm" placeholder="Répétez votre mot de passe" autocomplete="new-password"
                           oninput="checkConfirm('med');">
                    <button type="button" class="toggle-password" onclick="togglePw('med-confirm')">👁️</button>
                </div>
                <div class="confirm-feedback" id="med-confirm-fb"></div>
            </div>
            <div class="btn-row">
                <button type="button" class="btn-secondary" onclick="goStep1()">← Retour</button>
                <button type="submit" class="btn-primary" onclick="return prepareFormBeforeSubmit('medecin') && validateForm('medecin')">Créer mon compte</button>
            </div>
            <div class="footer">Déjà un compte ? <a href="${pageContext.request.contextPath}/views/shared/login.jsp">Se connecter</a></div>
        </div>
    </form>
</div>

<script>
    var currentRole = 'patient';

    function selectRole(role) {
        currentRole = role;
        document.getElementById('roleInput').value = role;
        document.getElementById('card-patient').classList.toggle('selected', role === 'patient');
        document.getElementById('card-medecin').classList.toggle('selected', role === 'medecin');
    }

    // Désactive tous les champs du rôle inactif (email, password, confirm)
    function prepareFormBeforeSubmit(role) {
        var patEmail = document.getElementById('pat-email');
        var medEmail = document.getElementById('med-email');
        var patPw = document.getElementById('pat-pw');
        var medPw = document.getElementById('med-pw');
        var patConfirm = document.getElementById('pat-confirm');
        var medConfirm = document.getElementById('med-confirm');

        if (role === 'medecin') {
            if (patEmail) patEmail.disabled = true;
            if (medEmail) medEmail.disabled = false;
            if (patPw) patPw.disabled = true;
            if (medPw) medPw.disabled = false;
            if (patConfirm) patConfirm.disabled = true;
            if (medConfirm) medConfirm.disabled = false;
        } else {
            if (patEmail) patEmail.disabled = false;
            if (medEmail) medEmail.disabled = true;
            if (patPw) patPw.disabled = false;
            if (medPw) medPw.disabled = true;
            if (patConfirm) patConfirm.disabled = false;
            if (medConfirm) medConfirm.disabled = true;
        }
        return true;
    }

    // Réactive tous les champs (email, password, confirm) lors du changement d'étape
    function enableAllFields() {
        var fields = ['pat-email', 'med-email', 'pat-pw', 'med-pw', 'pat-confirm', 'med-confirm'];
        fields.forEach(function(id) {
            var el = document.getElementById(id);
            if (el) el.disabled = false;
        });
    }

    function goStep2() {
        enableAllFields();
        hideAll();
        var formId = currentRole === 'medecin' ? 'step2-medecin' : 'step2-patient';
        document.getElementById(formId).classList.add('active');
        setDot(1, 'done');
        setDot(2, 'active');
        setLine('done');
    }

    function goStep1() {
        enableAllFields();
        hideAll();
        document.getElementById('step1').classList.add('active');
        setDot(1, 'active');
        setDot(2, '');
        setLine('');
    }

    function hideAll() {
        document.querySelectorAll('.reg-step').forEach(function(el) {
            el.classList.remove('active');
        });
    }

    function setDot(n, state) {
        var dot = document.getElementById('dot' + n);
        var lbl = document.getElementById('lbl' + n);
        dot.classList.remove('active', 'done');
        lbl.classList.remove('active');
        if (state) {
            dot.classList.add(state);
            if (state === 'active') lbl.classList.add('active');
        }
    }

    function setLine(state) {
        var line = document.getElementById('line1');
        line.classList.remove('done');
        if (state) line.classList.add(state);
    }

    function togglePw(id) {
        var input = document.getElementById(id);
        if (input) input.type = input.type === 'password' ? 'text' : 'password';
    }

    function checkStrength(prefix) {
        var valField = document.getElementById(prefix + '-pw');
        if (!valField) return;
        var val = valField.value;
        var bar = document.getElementById(prefix + '-bar');
        var hint = document.getElementById(prefix + '-hint');
        if (!bar || !hint) return;

        if (val.length === 0) {
            bar.style.width = '0%';
            hint.textContent = 'Au moins 6 caractères';
            hint.style.color = '#aaa';
            return;
        }

        var score = 0;
        if (val.length >= 6) score++;
        if (val.length >= 10) score++;
        if (/[A-Z]/.test(val)) score++;
        if (/[0-9]/.test(val)) score++;
        if (/[^A-Za-z0-9]/.test(val)) score++;

        var levels = [
            { pct: '20%', color: '#ea4335', label: 'Trop court' },
            { pct: '40%', color: '#ea4335', label: 'Faible' },
            { pct: '60%', color: '#fbbc04', label: 'Moyen' },
            { pct: '80%', color: '#34a853', label: 'Bon' },
            { pct: '100%', color: '#1a73e8', label: 'Excellent' }
        ];
        var lvl = levels[Math.min(Math.max(0, score - 1), 4)];
        bar.style.width = lvl.pct;
        bar.style.background = lvl.color;
        hint.textContent = lvl.label;
        hint.style.color = lvl.color;
    }

    function checkConfirm(prefix) {
        var pwField = document.getElementById(prefix + '-pw');
        var confirmField = document.getElementById(prefix + '-confirm');
        var fb = document.getElementById(prefix + '-confirm-fb');
        if (!pwField || !confirmField || !fb) return;

        var pw = pwField.value;
        var confirm = confirmField.value;
        if (confirm.length === 0) {
            fb.textContent = '';
            fb.className = 'confirm-feedback';
            confirmField.classList.remove('input-ok', 'input-error');
            return;
        }
        if (pw === confirm) {
            fb.textContent = '✓ Les mots de passe correspondent';
            fb.className = 'confirm-feedback match';
            confirmField.classList.remove('input-error');
            confirmField.classList.add('input-ok');
        } else {
            fb.textContent = '✗ Les mots de passe ne correspondent pas';
            fb.className = 'confirm-feedback nomatch';
            confirmField.classList.remove('input-ok');
            confirmField.classList.add('input-error');
        }
    }

    function validateForm(role) {
        var prefix = (role === 'medecin') ? 'med' : 'pat';
        var emailField = document.getElementById(prefix + '-email');
        var pwField = document.getElementById(prefix + '-pw');
        var confirmField = document.getElementById(prefix + '-confirm');

        // DEBUG : afficher les valeurs dans la console (F12)
        console.log("Rôle:", role, "Préfixe:", prefix);
        console.log("Champ password trouvé?", pwField);
        if (pwField) console.log("Valeur du mot de passe:", pwField.value);

        if (!emailField || !pwField || !confirmField) {
            alert("Erreur technique : champs manquants.");
            return false;
        }

        var email = emailField.value.trim();
        var pw = pwField.value;
        var confirm = confirmField.value;

        // Validation spécifique au rôle
        if (role === 'patient') {
            var nomPat = document.getElementById('pat-nom');
            if (!nomPat || !nomPat.value.trim()) {
                alert('Veuillez saisir votre nom complet.');
                highlight('pat-nom');
                return false;
            }
            var dn = document.getElementById('pat-datenais');
            if (!dn || !dn.value) {
                alert('Veuillez saisir votre date de naissance.');
                highlight('pat-datenais');
                return false;
            }
        } else {
            var nomMed = document.getElementById('med-nom');
            if (!nomMed || !nomMed.value.trim()) {
                alert('Veuillez saisir le nom du médecin.');
                highlight('med-nom');
                return false;
            }
            var spec = document.getElementById('med-spec');
            if (!spec || !spec.value.trim()) {
                alert('Veuillez saisir la spécialité.');
                highlight('med-spec');
                return false;
            }
            var taux = document.getElementById('med-taux');
            if (!taux || !taux.value.trim() || parseFloat(taux.value) < 0) {
                alert('Veuillez saisir un taux horaire valide (≥ 0).');
                highlight('med-taux');
                return false;
            }
            var lieu = document.getElementById('med-lieu');
            if (!lieu || !lieu.value.trim()) {
                alert('Veuillez saisir le cabinet / lieu.');
                highlight('med-lieu');
                return false;
            }
        }

        if (!email) {
            alert('Veuillez saisir une adresse email.');
            highlight(prefix + '-email');
            return false;
        }
        var emailRegex = /^[^\s@]+@([^\s@]+\.)+[^\s@]+$/;
        if (!emailRegex.test(email)) {
            alert('Veuillez saisir une adresse email valide (ex: nom@domaine.com).');
            highlight(prefix + '-email');
            return false;
        }

        console.log("Longueur du mot de passe:", pw.length);
        if (pw.length < 6) {
            alert('Le mot de passe doit contenir au moins 6 caractères. Vous avez saisi ' + pw.length + ' caractère(s).');
            highlight(prefix + '-pw');
            return false;
        }

        if (pw !== confirm) {
            alert('Les mots de passe ne correspondent pas.');
            highlight(prefix + '-confirm');
            return false;
        }

        return true;
    }

    function highlight(id) {
        var field = document.getElementById(id);
        if (field) {
            field.classList.add('input-error');
            field.focus();
            var removeError = function() {
                field.classList.remove('input-error');
                field.removeEventListener('input', removeError);
            };
            field.addEventListener('input', removeError);
        }
    }
</script>
</body>
</html>