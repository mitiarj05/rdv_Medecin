<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ include file="/views/shared/header.jsp" %>

<div class="container">
    <div class="card" style="max-width:560px; margin:0 auto;">
        <h2 class="card-title">
            <c:choose>
                <c:when test="${not empty medecin}">✏️ Modifier le médecin</c:when>
                <c:otherwise>👨‍⚕️ Nouveau médecin</c:otherwise>
            </c:choose>
        </h2>

        <c:if test="${not empty erreur}">
            <div class="alert alert-danger">${erreur}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/admin" method="post" id="medecinForm">
            <input type="hidden" name="action" value="enregistrerMedecin">
            <input type="hidden" name="idmed" id="idmed" value="${medecin.idmed}">

            <div class="form-group">
                <label>Nom complet</label>
                <input type="text" name="nommed" id="nommed" value="${medecin.nommed}" required>
            </div>

            <div class="form-group">
                <label>Spécialité</label>
                <input type="text" name="specialite" id="specialite" value="${medecin.specialite}" required>
            </div>

            <div class="form-group">
                <label>Taux horaire (Ar)</label>
                <input type="number" name="taux_horaire" id="taux_horaire" value="${medecin.tauxHoraire}" required>
            </div>

            <div class="form-group">
                <label>Lieu / Cabinet</label>
                <input type="text" name="lieu" id="lieu" value="${medecin.lieu}" required>
            </div>

            <div class="form-group">
                <label>Email</label>
                <input type="email" name="email" id="email" value="${medecin.email}" required>
            </div>

            <div class="form-group">
                <label>📱 Numéro de téléphone</label>
                <input type="tel" name="telephone" id="telephone" value="${medecin.telephone}"
                       placeholder="Ex: 0328725411 ou +261328725411" autocomplete="off"
                       style="width:100%; padding:10px; border:1px solid #ddd; border-radius:8px;">
                <small style="color:#666; font-size:11px;">Format: 0328725411 ou +261328725411</small>
                <div id="telephoneStatus" style="font-size:13px; margin-top:8px; padding:8px; border-radius:6px; display:none;"></div>
            </div>

            <c:if test="${empty medecin}">
                <div class="form-group">
                    <label>Mot de passe temporaire</label>
                    <input type="password" name="password" id="password" required>
                    <small style="color:#666;">Le médecin pourra modifier son mot de passe après connexion</small>
                </div>
            </c:if>

            <div style="display:flex; gap:10px; margin-top:20px;">
                <button type="submit" class="btn btn-primary" style="flex:1;" id="submitBtn">
                    <c:choose>
                        <c:when test="${not empty medecin}">Enregistrer les modifications</c:when>
                        <c:otherwise>Créer le médecin</c:otherwise>
                    </c:choose>
                </button>
                <a href="${pageContext.request.contextPath}/admin?action=medecins" class="btn btn-secondary" style="flex:1; text-align:center;">Annuler</a>
            </div>
        </form>
    </div>
</div>

<script>
const telephoneInput = document.getElementById('telephone');
const telephoneStatus = document.getElementById('telephoneStatus');
const submitBtn = document.getElementById('submitBtn');
let checkTimeout = null;

function verifierTelephone() {
    let telephone = telephoneInput.value.trim();
    if (telephone === '') {
        telephoneStatus.style.display = 'none';
        submitBtn.disabled = false;
        return;
    }
    telephoneStatus.style.display = 'block';
    telephoneStatus.style.backgroundColor = '#e3f2fd';
    telephoneStatus.innerHTML = '⏳ Vérification en cours...';
    submitBtn.disabled = true;
    
    const medecinId = document.getElementById('idmed')?.value || '';
    fetch('${pageContext.request.contextPath}/api/check-telephone', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'telephone=' + encodeURIComponent(telephone) + '&type=medecin&id=' + encodeURIComponent(medecinId)
    })
    .then(response => response.json())
    .then(data => {
        if (data.exists) {
            telephoneStatus.style.backgroundColor = '#f8d7da';
            telephoneStatus.style.color = '#721c24';
            telephoneStatus.innerHTML = '❌ ' + data.message;
            submitBtn.disabled = true;
        } else if (data.valid === false) {
            telephoneStatus.style.backgroundColor = '#fff3cd';
            telephoneStatus.style.color = '#856404';
            telephoneStatus.innerHTML = '⚠️ ' + data.message;
            submitBtn.disabled = true;
        } else {
            telephoneStatus.style.backgroundColor = '#d4edda';
            telephoneStatus.style.color = '#155724';
            telephoneStatus.innerHTML = '✓ ' + data.message;
            submitBtn.disabled = false;
        }
    })
    .catch(error => { telephoneStatus.style.display = 'none'; submitBtn.disabled = false; });
}

telephoneInput.addEventListener('input', function() { if (checkTimeout) clearTimeout(checkTimeout); checkTimeout = setTimeout(verifierTelephone, 500); });
telephoneInput.addEventListener('blur', function() { if (checkTimeout) clearTimeout(checkTimeout); verifierTelephone(); });
</script>
</body>
</html>