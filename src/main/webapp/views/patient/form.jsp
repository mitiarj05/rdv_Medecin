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
            <input type="hidden" name="idpat" id="idpat" value="${patient.idpat}">

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

            <!-- CHAMP TÉLÉPHONE AVEC VÉRIFICATION EN TEMPS RÉEL -->
            <div class="form-group">
                <label>📱 Numéro de téléphone</label>
                <input type="tel" name="telephone" id="telephone"
                       value="${patient.telephone}"
                       placeholder="Ex: 0328725411 ou +261328725411"
                       autocomplete="off"
                       style="width:100%; padding:10px; border:1px solid #ddd; border-radius:8px;">
                <small id="telephoneHelp" style="color: #666; font-size: 11px;">Format: 0328725411 ou +261328725411</small>
                <div id="telephoneStatus" style="font-size: 13px; margin-top: 8px; padding: 8px; border-radius: 6px; display: none;"></div>
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
                   onclick="return confirm('Êtes-vous ABSOLUMENT sûr de vouloir supprimer votre compte ?\n\n⚠️ Cette action est IRRÉVERSIBLE !');">
                    🗑️ Supprimer mon compte définitivement
                </a>
            </div>
        </c:if>
        
    </div>
</div>

<script>
// VÉRIFICATION EN TEMPS RÉEL DU NUMÉRO DE TÉLÉPHONE
const telephoneInput = document.getElementById('telephone');
const telephoneStatus = document.getElementById('telephoneStatus');
const submitBtn = document.getElementById('submitBtn');
let checkTimeout = null;

function verifierTelephone() {
    let telephone = telephoneInput.value.trim();
    
    // Si le champ est vide
    if (telephone === '') {
        telephoneStatus.style.display = 'none';
        submitBtn.disabled = false;
        return;
    }
    
    // Afficher "vérification en cours"
    telephoneStatus.style.display = 'block';
    telephoneStatus.style.backgroundColor = '#e3f2fd';
    telephoneStatus.style.color = '#0c5460';
    telephoneStatus.style.border = '1px solid #bee5eb';
    telephoneStatus.innerHTML = '⏳ Vérification en cours...';
    submitBtn.disabled = true;
    
    const patientId = document.getElementById('idpat')?.value || '';
    
    fetch('${pageContext.request.contextPath}/api/check-telephone', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'telephone=' + encodeURIComponent(telephone) + '&type=patient&id=' + encodeURIComponent(patientId)
    })
    .then(response => response.json())
    .then(data => {
        if (data.exists) {
            // Numéro déjà utilisé - ERREUR ROUGE
            telephoneStatus.style.backgroundColor = '#f8d7da';
            telephoneStatus.style.color = '#721c24';
            telephoneStatus.style.border = '1px solid #f5c6cb';
            telephoneStatus.innerHTML = data.message;
            submitBtn.disabled = true;
        } else if (data.valid === false && !data.exists) {
            // Format invalide
            telephoneStatus.style.backgroundColor = '#fff3cd';
            telephoneStatus.style.color = '#856404';
            telephoneStatus.style.border = '1px solid #ffeeba';
            telephoneStatus.innerHTML = data.message;
            submitBtn.disabled = true;
        } else {
            // Numéro disponible - VERT
            telephoneStatus.style.backgroundColor = '#d4edda';
            telephoneStatus.style.color = '#155724';
            telephoneStatus.style.border = '1px solid #c3e6cb';
            telephoneStatus.innerHTML = data.message;
            submitBtn.disabled = false;
        }
    })
    .catch(error => {
        console.error('Erreur:', error);
        telephoneStatus.style.display = 'none';
        submitBtn.disabled = false;
    });
}

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