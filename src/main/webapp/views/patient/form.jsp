<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card" style="max-width:560px; margin:0 auto;">

        <h2 class="card-title">
            <c:choose>
                <c:when test="${not empty patient}">Modifier le patient</c:when>
                <c:otherwise>Nouveau patient</c:otherwise>
            </c:choose>
        </h2>

        <c:if test="${not empty erreur}">
            <div class="alert alert-danger">${erreur}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/patient" method="post" id="patientForm">
            <input type="hidden" name="action" value="enregistrer">
            <input type="hidden" name="idpat" value="${patient.idpat}">

            <div class="form-group">
                <label>Nom complet</label>
                <input type="text" name="nom_pat" id="nom_pat"
                       value="${patient.nomPat}"
                       placeholder="Ex: Rakoto Jean" required>
            </div>

            <div class="form-group">
                <label>Date de naissance</label>
                <input type="date" name="datenais" id="datenais"
                       value="${patient.datenais}" required>
            </div>

            <div class="form-group">
                <label>Email</label>
                <input type="email" name="email" id="email"
                       value="${patient.email}"
                       placeholder="votre@email.com" required>
            </div>

            <!-- 🔥 CHAMP TÉLÉPHONE AVEC VÉRIFICATION EN TEMPS RÉEL -->
            <div class="form-group">
                <label>📱 Numéro de téléphone</label>
                <input type="tel" name="telephone" id="telephone"
                       value="${patient.telephone}"
                       placeholder="Ex: 0330000000 ou +261330000000"
                       pattern="[0-9+]{9,15}"
                       title="Format: 0330000000 ou +261330000000"
                       autocomplete="off">
                <small id="telephoneHelp" style="color: #666; font-size: 11px;">Format accepté: 0330000000 ou +261330000000</small>
                <div id="telephoneError" style="color: #dc3545; font-size: 12px; margin-top: 5px; display: none;"></div>
                <div id="telephoneSuccess" style="color: #28a745; font-size: 12px; margin-top: 5px; display: none;"></div>
            </div>

            <c:if test="${empty patient}">
                <div class="form-group">
                    <label>Mot de passe</label>
                    <input type="password" name="password" id="password"
                           placeholder="Minimum 6 caractères" required>
                </div>
            </c:if>

            <div style="display:flex; gap:12px; margin-top:8px;">
                <button type="submit" class="btn btn-primary" style="flex:1;" id="submitBtn">
                    <c:choose>
                        <c:when test="${not empty patient}">Enregistrer les modifications</c:when>
                        <c:otherwise>Créer le patient</c:otherwise>
                    </c:choose>
                </button>

                <c:choose>
                    <c:when test="${sessionScope.role == 'patient' and not empty patient}">
                        <a href="${pageContext.request.contextPath}/patient?action=dashboard"
                           class="btn btn-secondary" style="flex:1; text-align:center;">
                            Annuler
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/patient?action=liste"
                           class="btn btn-secondary" style="flex:1; text-align:center;">
                            Annuler
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </form>

        <c:if test="${not empty patient}">
            <hr style="margin: 30px 0 20px 0; border-color: #ddd;">
            <div style="background-color: #fff3f3; padding: 15px; border-radius: 8px; border-left: 4px solid #dc3545;">
                <h3 style="color: #dc3545; font-size: 16px; margin: 0 0 10px 0;">Zone dangereuse</h3>
                <a href="${pageContext.request.contextPath}/patient?action=supprimer&id=${patient.idpat}"
                   class="btn btn-danger"
                   style="display: inline-block; background-color:#dc3545; color:white; padding:10px 20px; 
                          text-decoration:none; border-radius:5px; font-weight:bold;"
                   onclick="return confirm('Êtes-vous ABSOLUMENT sûr de vouloir supprimer votre compte ?\n\n⚠️ Cette action est IRRÉVERSIBLE !\n\nToutes vos données (rendez-vous, etc.) seront supprimées définitivement.');">
                    🗑️ Supprimer mon compte définitivement
                </a>
                <p style="font-size:12px; color:#666; margin-top:10px;">
                    ⚠️ Attention : Cette action supprimera votre compte ainsi que tous vos rendez-vous associés.
                </p>
            </div>
        </c:if>
        
    </div>
</div>

<script>
// 🔥 VÉRIFICATION EN TEMPS RÉEL DU NUMÉRO DE TÉLÉPHONE
const telephoneInput = document.getElementById('telephone');
const telephoneError = document.getElementById('telephoneError');
const telephoneSuccess = document.getElementById('telephoneSuccess');
const telephoneHelp = document.getElementById('telephoneHelp');
const submitBtn = document.getElementById('submitBtn');
let checkTimeout = null;

function verifierTelephone() {
    let telephone = telephoneInput.value.trim();
    
    // Ignorer si vide
    if (telephone === '') {
        telephoneError.style.display = 'none';
        telephoneSuccess.style.display = 'none';
        telephoneHelp.style.display = 'block';
        telephoneHelp.style.color = '#666';
        submitBtn.disabled = false;
        return;
    }
    
    // Validation du format
    const phoneRegex = /^[0-9+]{9,15}$/;
    if (!phoneRegex.test(telephone) || telephone.length < 9) {
        telephoneError.innerHTML = '⚠️ Format invalide. Utilisez 0330000000 ou +261330000000';
        telephoneError.style.display = 'block';
        telephoneSuccess.style.display = 'none';
        telephoneHelp.style.display = 'none';
        submitBtn.disabled = true;
        return;
    }
    
    // Normaliser le numéro pour la vérification
    let normalizedPhone = telephone;
    if (!normalizedPhone.startsWith('+') && normalizedPhone.startsWith('0')) {
        normalizedPhone = '+261' + normalizedPhone.substring(1);
    }
    
    // Afficher chargement
    telephoneError.innerHTML = '⏳ Vérification en cours...';
    telephoneError.style.color = '#17a2b8';
    telephoneError.style.display = 'block';
    telephoneSuccess.style.display = 'none';
    
    // Récupérer l'ID du patient (pour modification)
    const patientId = document.querySelector('input[name="idpat"]')?.value || '';
    
    // Appel AJAX pour vérifier si le numéro existe déjà
    fetch('${pageContext.request.contextPath}/api/check-telephone', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'telephone=' + encodeURIComponent(normalizedPhone) + '&type=patient&id=' + encodeURIComponent(patientId)
    })
    .then(response => response.json())
    .then(data => {
        if (data.exists) {
            telephoneError.innerHTML = '❌ ' + data.message;
            telephoneError.style.color = '#dc3545';
            telephoneError.style.display = 'block';
            telephoneSuccess.style.display = 'none';
            telephoneHelp.style.display = 'none';
            submitBtn.disabled = true;
        } else {
            telephoneError.style.display = 'none';
            telephoneSuccess.innerHTML = '✓ Numéro disponible';
            telephoneSuccess.style.display = 'block';
            telephoneHelp.style.display = 'none';
            submitBtn.disabled = false;
        }
    })
    .catch(error => {
        console.error('Erreur:', error);
        telephoneError.style.display = 'none';
        telephoneSuccess.style.display = 'none';
        telephoneHelp.style.display = 'block';
        submitBtn.disabled = false;
    });
}

// Événements de saisie avec délai
telephoneInput.addEventListener('input', function() {
    if (checkTimeout) clearTimeout(checkTimeout);
    checkTimeout = setTimeout(verifierTelephone, 500);
});

telephoneInput.addEventListener('blur', function() {
    if (checkTimeout) clearTimeout(checkTimeout);
    verifierTelephone();
});
</script>

</body>
</html>