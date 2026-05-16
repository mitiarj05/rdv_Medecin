<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inscription - RDV Medical</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #e8f0fe 0%, #ffffff 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        /* Container principal en deux colonnes */
        .register-wrapper {
            max-width: 1100px;
            width: 100%;
            background: white;
            border-radius: 24px;
            box-shadow: 0 25px 50px -12px rgba(0,0,0,0.15);
            overflow: hidden;
            display: flex;
            flex-wrap: wrap;
            animation: slideUp 0.5s ease-out;
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* Colonne gauche - Image médicale */
        .register-image {
            flex: 1.2;
            background: linear-gradient(135deg, #1a73e8 0%, #0d47a1 100%);
            padding: 40px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            color: white;
            position: relative;
            overflow: hidden;
        }

        .register-image::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 320"><path fill="rgba(255,255,255,0.08)" d="M0,96L48,112C96,128,192,160,288,160C384,160,480,128,576,122.7C672,117,768,139,864,154.7C960,171,1056,181,1152,165.3C1248,149,1344,107,1392,85.3L1440,64L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path></svg>') repeat-x bottom;
            background-size: cover;
            opacity: 0.3;
        }

        .image-content {
            position: relative;
            z-index: 1;
        }

        .image-icon {
            font-size: 80px;
            margin-bottom: 30px;
            background: rgba(255,255,255,0.2);
            width: 120px;
            height: 120px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-left: auto;
            margin-right: auto;
            backdrop-filter: blur(10px);
        }

        .image-content h2 {
            font-size: 28px;
            margin-bottom: 15px;
            font-weight: 600;
        }

        .image-content p {
            font-size: 15px;
            line-height: 1.6;
            opacity: 0.9;
            max-width: 300px;
            margin-left: auto;
            margin-right: auto;
        }

        .features-list {
            margin-top: 30px;
            text-align: left;
            display: inline-block;
        }

        .features-list li {
            list-style: none;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 13px;
        }

        .features-list li i {
            width: 24px;
            font-size: 16px;
        }

        /* Colonne droite - Formulaire */
        .register-form {
            flex: 0.9;
            padding: 40px;
            background: white;
            max-height: 90vh;
            overflow-y: auto;
        }

        .register-form::-webkit-scrollbar {
            width: 6px;
        }

        .register-form::-webkit-scrollbar-track {
            background: #f0f0f0;
            border-radius: 3px;
        }

        .register-form::-webkit-scrollbar-thumb {
            background: #1a73e8;
            border-radius: 3px;
        }

        .form-header {
            text-align: center;
            margin-bottom: 25px;
        }

        .form-header h2 {
            font-size: 24px;
            color: #1a73e8;
            margin-bottom: 6px;
        }

        .form-header p {
            font-size: 13px;
            color: #666;
        }

        /* Steps */
        .steps-row {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0;
            margin-bottom: 28px;
        }
        .step-col {
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .step-dot {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #f0f0f0;
            color: #bbb;
            font-size: 13px;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
        }
        .step-dot.active {
            background: #1a73e8;
            color: white;
        }
        .step-dot.done {
            background: #34a853;
            color: white;
        }
        .step-label {
            font-size: 11px;
            color: #bbb;
            margin-top: 4px;
            white-space: nowrap;
        }
        .step-label.active {
            color: #1a73e8;
            font-weight: 600;
        }
        .step-line {
            width: 80px;
            height: 2px;
            background: #f0f0f0;
            margin-bottom: 16px;
            transition: background 0.3s;
        }
        .step-line.done {
            background: #34a853;
        }

        /* Alertes */
        .alert {
            padding: 10px 14px;
            border-radius: 8px;
            margin-bottom: 16px;
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

        /* Steps containers */
        .reg-step {
            display: none;
        }
        .reg-step.active {
            display: block;
        }

        /* Role cards */
        .role-cards-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
            margin-bottom: 24px;
        }
        .role-card {
            border: 2px solid #e8e8e8;
            border-radius: 16px;
            padding: 24px 16px 20px;
            cursor: pointer;
            text-align: center;
            transition: all 0.2s;
            background: #fafafa;
        }
        .role-card:hover {
            border-color: #a8c4f8;
            background: #f0f6ff;
            transform: translateY(-2px);
        }
        .role-card.selected {
            border-color: #1a73e8;
            background: #f0f6ff;
            box-shadow: 0 0 0 4px rgba(26, 115, 232, 0.12);
        }
        .role-card .role-icon {
            font-size: 38px;
            margin-bottom: 10px;
            display: block;
        }
        .role-card .role-name {
            font-size: 15px;
            font-weight: 700;
            color: #1a1a1a;
            margin-bottom: 4px;
        }
        .role-card.selected .role-name {
            color: #1a73e8;
        }
        .role-card .role-desc {
            font-size: 11px;
            color: #888;
            line-height: 1.4;
        }
        .role-card .check-badge {
            display: none;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background: #1a73e8;
            color: white;
            font-size: 11px;
            font-weight: 700;
            align-items: center;
            justify-content: center;
            margin: 8px auto 0;
        }
        .role-card.selected .check-badge {
            display: flex;
        }
        .role-helper {
            font-size: 13px;
            color: #888;
            text-align: center;
            margin-bottom: 16px;
        }

        /* Sections */
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
        .section-title:first-of-type {
            margin-top: 0;
        }
        .section-title::after {
            content: '';
            flex: 1;
            height: 1px;
            background: #e8f0fe;
        }

        /* Form groups */
        .form-group {
            margin-bottom: 14px;
        }
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
        .form-group input.input-ok {
            border-color: #34a853 !important;
            background: #f6fff8;
        }
        .row2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }
        .pw-wrap {
            position: relative;
        }
        .pw-wrap input {
            padding-right: 44px;
        }
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
        .toggle-password:hover {
            color: #1a73e8;
        }
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
        .confirm-feedback {
            font-size: 11px;
            margin-top: 4px;
            min-height: 16px;
        }
        .confirm-feedback.match {
            color: #34a853;
        }
        .confirm-feedback.nomatch {
            color: #ea4335;
        }

        /* Buttons */
        .btn-primary {
            background: #1a73e8;
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            padding: 11px 20px;
            transition: background 0.2s, transform 0.1s;
        }
        .btn-primary:hover {
            background: #1557b0;
        }
        .btn-primary:active {
            transform: scale(0.99);
        }
        .btn-primary.full {
            width: 100%;
            margin-top: 4px;
        }
        .btn-secondary {
            background: white;
            color: #666;
            border: 1.5px solid #e0e0e0;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            padding: 11px 20px;
            transition: all 0.2s;
        }
        .btn-secondary:hover {
            background: #f5f5f5;
            border-color: #bbb;
        }
        .btn-row {
            display: flex;
            gap: 10px;
            margin-top: 6px;
        }
        .btn-row .btn-secondary {
            flex: 1;
        }
        .btn-row .btn-primary {
            flex: 2;
        }

        /* Footer */
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
        .footer a:hover {
            text-decoration: underline;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .register-image {
                display: none;
            }
            .register-form {
                flex: 1;
            }
            .register-wrapper {
                max-width: 480px;
            }
        }
    </style>
</head>
<body>

<div class="register-wrapper">
    <!-- Colonne gauche - Image médicale -->
    <div class="register-image">
        <div class="image-content">
            <div class="image-icon">
                <i class="fas fa-user-plus"></i>
            </div>
            <h2>RDV Medical</h2>
            <p>Rejoignez notre plateforme médicale</p>
            <ul class="features-list">
                <li><i class="fas fa-check-circle"></i> Création gratuite et rapide</li>
                <li><i class="fas fa-calendar-alt"></i> Prenez RDV en ligne</li>
                <li><i class="fas fa-envelope"></i> Recevez des confirmations</li>
                <li><i class="fas fa-chart-line"></i> Suivez votre historique</li>
            </ul>
        </div>
    </div>

    <!-- Colonne droite - Formulaire d'inscription -->
    <div class="register-form">
        <div class="form-header">
            <h2><i class="fas fa-user-plus"></i> Créer un compte</h2>
            <p>Rejoignez RDV Medical</p>
        </div>

        <!-- Steps -->
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

        <!-- Messages -->
        <c:if test="${not empty erreur}">
            <div class="alert alert-danger"><i class="fas fa-exclamation-triangle"></i> ${erreur}</div>
        </c:if>
        <c:if test="${not empty succes}">
            <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${succes}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/auth" method="post" id="registerForm" novalidate>
            <input type="hidden" name="action" value="register">
            <input type="hidden" name="role" id="roleInput" value="patient">

            <!-- ÉTAPE 1 : Choix du rôle -->
            <div class="reg-step active" id="step1">
                <p class="role-helper">Quel type de compte souhaitez-vous créer ?</p>
                <div class="role-cards-row">
                    <div class="role-card selected" id="card-patient" onclick="selectRole('patient')">
                        <span class="role-icon"><i class="fas fa-user"></i></span>
                        <div class="role-name">Patient</div>
                        <div class="role-desc">Prenez et gérez vos rendez-vous médicaux</div>
                        <div class="check-badge">✓</div>
                    </div>
                    <div class="role-card" id="card-medecin" onclick="selectRole('medecin')">
                        <span class="role-icon"><i class="fas fa-user-md"></i></span>
                        <div class="role-name">Médecin</div>
                        <div class="role-desc">Gérez votre agenda et vos consultations</div>
                        <div class="check-badge">✓</div>
                    </div>
                </div>
                <button type="button" class="btn-primary full" onclick="goStep2()">
                    <i class="fas fa-arrow-right"></i> Continuer
                </button>
                <div class="footer">
                    Déjà un compte ? <a href="${pageContext.request.contextPath}/views/shared/login.jsp"><i class="fas fa-sign-in-alt"></i> Se connecter</a>
                </div>
            </div>

            <!-- ÉTAPE 2 : Formulaire PATIENT -->
            <div class="reg-step" id="step2-patient">
                <div class="section-title"><i class="fas fa-user-circle"></i> Informations personnelles</div>
                <div class="form-group">
                    <label for="pat-nom">Nom complet</label>
                    <input type="text" name="nom_pat" id="pat-nom" placeholder="Ex : Rakoto Jean" autocomplete="name">
                </div>
                <div class="form-group">
                    <label for="pat-datenais">Date de naissance</label>
                    <input type="date" name="datenais" id="pat-datenais">
                </div>
                <div class="section-title"><i class="fas fa-lock"></i> Informations de connexion</div>
                <div class="form-group">
                    <label for="pat-telephone">📱 Numéro de téléphone</label>
                    <div class="pw-wrap">
                        <input type="tel" name="telephone" id="pat-telephone"
                                placeholder="Ex: 0330000000 ou +261330000000"
                                pattern="[0-9+]{9,15}">
                    </div>
                <div class="pw-hint" style="margin-top: 2px;">Format:+261330000000 (optionnel)</div>
                </div>
                <div class="form-group">
                    <label for="pat-email">Adresse email</label>
                    <input type="email" name="email" id="pat-email" placeholder="votre@email.com" autocomplete="email">
                </div>
                <div class="form-group">
                    <label for="pat-pw">Mot de passe</label>
                    <div class="pw-wrap">
                        <input type="password" name="password" id="pat-pw" placeholder="Minimum 6 caractères" autocomplete="new-password"
                               oninput="checkStrength('pat'); checkConfirm('pat');">
                        <button type="button" class="toggle-password" onclick="togglePw('pat-pw')"><i class="far fa-eye"></i></button>
                    </div>
                    <div class="pw-strength"><div class="pw-strength-bar" id="pat-bar"></div></div>
                    <div class="pw-hint" id="pat-hint">Au moins 6 caractères</div>
                </div>
                <div class="form-group">
                    <label for="pat-confirm">Confirmer le mot de passe</label>
                    <div class="pw-wrap">
                        <input type="password" name="confirm_password" id="pat-confirm" placeholder="Répétez votre mot de passe" autocomplete="new-password"
                               oninput="checkConfirm('pat');">
                        <button type="button" class="toggle-password" onclick="togglePw('pat-confirm')"><i class="far fa-eye"></i></button>
                    </div>
                    <div class="confirm-feedback" id="pat-confirm-fb"></div>
                </div>
                <div class="btn-row">
                    <button type="button" class="btn-secondary" onclick="goStep1()"><i class="fas fa-arrow-left"></i> Retour</button>
                    <button type="submit" class="btn-primary" onclick="return prepareFormBeforeSubmit('patient') && validateForm('patient')">
                        <i class="fas fa-check-circle"></i> Créer mon compte
                    </button>
                </div>
                <div class="footer">
                    Déjà un compte ? <a href="${pageContext.request.contextPath}/views/shared/login.jsp"><i class="fas fa-sign-in-alt"></i> Se connecter</a>
                </div>
            </div>

            <!-- ÉTAPE 2 : Formulaire MÉDECIN -->
            <div class="reg-step" id="step2-medecin">
                <div class="section-title"><i class="fas fa-stethoscope"></i> Informations professionnelles</div>
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
                <div class="section-title"><i class="fas fa-lock"></i> Informations de connexion</div>
                <div class="form-group">
                    <label for="med-telephone">📱 Numéro de téléphone</label>
                    <div class="pw-wrap">
                            <input type="tel" name="telephone" id="med-telephone"
                                    placeholder="Ex: 0330000000 ou +261330000000"
                                    pattern="[0-9+]{9,15}">
                </div>
                <div class="pw-hint" style="margin-top: 2px;">Format: 0330000000 ou +261330000000 (optionnel)</div>
                </div>
                <div class="form-group">
                    <label for="med-email">Adresse email</label>
                    <input type="email" name="email" id="med-email" placeholder="votre@email.com" autocomplete="email">
                </div>
                <div class="form-group">
                    <label for="med-pw">Mot de passe</label>
                    <div class="pw-wrap">
                        <input type="password" name="password" id="med-pw" placeholder="Minimum 6 caractères" autocomplete="new-password"
                               oninput="checkStrength('med'); checkConfirm('med');">
                        <button type="button" class="toggle-password" onclick="togglePw('med-pw')"><i class="far fa-eye"></i></button>
                    </div>
                    <div class="pw-strength"><div class="pw-strength-bar" id="med-bar"></div></div>
                    <div class="pw-hint" id="med-hint">Au moins 6 caractères</div>
                </div>
                <div class="form-group">
                    <label for="med-confirm">Confirmer le mot de passe</label>
                    <div class="pw-wrap">
                        <input type="password" name="confirm_password" id="med-confirm" placeholder="Répétez votre mot de passe" autocomplete="new-password"
                               oninput="checkConfirm('med');">
                        <button type="button" class="toggle-password" onclick="togglePw('med-confirm')"><i class="far fa-eye"></i></button>
                    </div>
                    <div class="confirm-feedback" id="med-confirm-fb"></div>
                </div>
                <div class="btn-row">
                    <button type="button" class="btn-secondary" onclick="goStep1()"><i class="fas fa-arrow-left"></i> Retour</button>
                    <button type="submit" class="btn-primary" onclick="return prepareFormBeforeSubmit('medecin') && validateForm('medecin')">
                        <i class="fas fa-check-circle"></i> Créer mon compte
                    </button>
                </div>
                <div class="footer">
                    Déjà un compte ? <a href="${pageContext.request.contextPath}/views/shared/login.jsp"><i class="fas fa-sign-in-alt"></i> Se connecter</a>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
    var currentRole = 'patient';

    function selectRole(role) {
        currentRole = role;
        document.getElementById('roleInput').value = role;
        document.getElementById('card-patient').classList.toggle('selected', role === 'patient');
        document.getElementById('card-medecin').classList.toggle('selected', role === 'medecin');
    }

    // Désactive tous les champs du rôle inactif
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

    // Réactive tous les champs lors du changement d'étape
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
        if (input) {
            input.type = input.type === 'password' ? 'text' : 'password';
        }
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