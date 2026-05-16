<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card" style="max-width:580px; margin:0 auto;">

        <h2 class="card-title">
            <c:choose>
                <c:when test="${not empty medecin}">Modifier le médecin</c:when>
                <c:otherwise>Nouveau médecin</c:otherwise>
            </c:choose>
        </h2>

        <c:if test="${not empty erreur}">
            <div class="alert alert-danger">${erreur}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/medecin" method="post" id="medecinForm">
            <input type="hidden" name="action" value="enregistrer">
            <input type="hidden" name="idmed" value="${medecin.idmed}">

            <div class="form-group">
                <label>Nom du médecin</label>
                <input type="text" name="nommed" id="nommed"
                       value="${medecin.nommed}"
                       placeholder="Ex: Rasoa Marie" required>
            </div>

            <div style="display:grid; grid-template-columns:1fr 1fr; gap:14px;">
                <div class="form-group">
                    <label>Spécialité</label>
                    <input type="text" name="specialite" id="specialite"
                           value="${medecin.specialite}"
                           placeholder="Ex: Cardiologie" required>
                </div>
                <div class="form-group">
                    <label>Taux horaire (Ar)</label>
                    <input type="number" name="taux_horaire" id="taux_horaire"
                           value="${medecin.tauxHoraire}"
                           placeholder="Ex: 80000" required>
                </div>
            </div>

            <div class="form-group">
                <label>Lieu / Cabinet</label>
                <input type="text" name="lieu" id="lieu"
                       value="${medecin.lieu}"
                       placeholder="Ex: Antananarivo" required>
            </div>

            <div class="form-group">
                <label>Email</label>
                <input type="email" name="email" id="email"
                       value="${medecin.email}"
                       placeholder="medecin@email.com" required>
            </div>

            <!-- 🔥 CHAMP TÉLÉPHONE AVEC VÉRIFICATION EN TEMPS RÉEL -->
            <div class="form-group">
                <label>📱 Numéro de téléphone</label>
                <input type="tel" name="telephone" id="telephone"
                       value="${medecin.telephone}"
                       placeholder="Ex: 0330000000 ou +261330000000"
                       pattern="[0-9+]{9,15}"
                       title="Format: 0330000000 ou +261330000000"
                       autocomplete="off">
                <small id="telephoneHelp" style="color: #666; font-size: 11px;">Format accepté: 0330000000 ou +261330000000</small>
                <div id="telephoneError" style="color: #dc3545; font-size: 12px; margin-top: 5px; display: none;"></div>
                <div id="telephoneSuccess" style="color: #28a745; font-size: 12px; margin-top: 5px; display: none;"></div>
            </div>

            <c:if test="${empty medecin}">
                <div class="form-group">
                    <label>Mot de passe</label>
                    <input type="password" name="password" id="password"
                           placeholder="Minimum 6 caractères" required>
                </div>
            </c:if>

            <div style="display:flex; gap:12px; margin-top:8px;">
                <button type="submit" class="btn btn-primary" style="flex:1;" id="submitBtn">
                    <c:choose>
                        <c:when test="${not empty medecin}">Enregistrer les modifications</c:when>
                        <c:otherwise>Créer le médecin</c:otherwise>
                    </c:choose>
                </button>

                <c:choose>
                    <c:when test="${sessionScope.role == 'medecin' and not empty medecin}">
                        <a href="${pageContext.request.contextPath}/medecin?action=dashboard"
                           class="btn btn-secondary" style="flex:1; text-align:center;">
                            Annuler
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/medecin?action=liste"
                           class="btn btn-secondary" style="flex:1; text-align:center;">
                            Annuler
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </form>

        <c:if test="${not empty medecin}">
            <hr style="margin: 30px 0 20px 0; border-color: #ddd;">
            <div style="background-color: #fff3f3; padding: 15px; border-radius: 8px; border-left: 4px solid #dc3545;">
                <h3 style="color: #dc3545; font-size: 16px; margin: 0 0 10px 0;">Zone dangereuse</h3>
                <a href="${pageContext.request.contextPath}/medecin?action=supprimer&id=${medecin.idmed}"
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
    
    if (telephone === '') {
        telephoneError.style.display = 'none';
        telephoneSuccess.style.display = 'none';
        telephoneHelp.style.display = 'block';
        telephoneHelp.style.color = '#666';
        submitBtn.disabled = false;
        return;
    }
    
    const phoneRegex = /^[0-9+]{9,15}$/;
    if (!phoneRegex.test(telephone) || telephone.length < 9) {
        telephoneError.innerHTML = '⚠️ Format invalide. Utilisez 0330000000 ou +261330000000';
        telephoneError.style.display = 'block';
        telephoneSuccess.style.display = 'none';
        telephoneHelp.style.display = 'none';
        submitBtn.disabled = true;
        return;
    }
    
    let normalizedPhone = telephone;
    if (!normalizedPhone.startsWith('+') && normalizedPhone.startsWith('0')) {
        normalizedPhone = '+261' + normalizedPhone.substring(1);
    }
    
    telephoneError.innerHTML = '⏳ Vérification en cours...';
    telephoneError.style.color = '#17a2b8';
    telephoneError.style.display = 'block';
    telephoneSuccess.style.display = 'none';
    
    const medecinId = document.querySelector('input[name="idmed"]')?.value || '';
    
    fetch('${pageContext.request.contextPath}/api/check-telephone', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'telephone=' + encodeURIComponent(normalizedPhone) + '&type=medecin&id=' + encodeURIComponent(medecinId)
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