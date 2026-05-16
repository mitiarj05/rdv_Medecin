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
        
        <c:if test="${not empty sessionScope.succesPhoto}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> ${sessionScope.succesPhoto}
            </div>
            <% session.removeAttribute("succesPhoto"); %>
        </c:if>
        
        <c:if test="${not empty sessionScope.erreurPhoto}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle"></i> ${sessionScope.erreurPhoto}
            </div>
            <% session.removeAttribute("erreurPhoto"); %>
        </c:if>

        <!-- SECTION PHOTO DE PROFIL (uniquement pour modification) -->
        <c:if test="${not empty medecin}">
            <div style="text-align: center; margin-bottom: 20px; padding: 15px; background: #f8f9fa; border-radius: 12px;">
                <div style="margin-bottom: 10px;">
                    <c:choose>
                        <c:when test="${not empty medecin.photoProfile}">
                            <img src="${medecin.photoProfile}" 
                                 alt="Photo de profil" 
                                 style="width: 120px; height: 120px; object-fit: cover; border-radius: 50%; border: 3px solid #1a73e8; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                        </c:when>
                        <c:otherwise>
                            <div style="width: 120px; height: 120px; background: #e9ecef; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; margin: 0 auto;">
                                <i class="fas fa-user-md" style="font-size: 50px; color: #adb5bd;"></i>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div style="display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;">
                    <form action="${pageContext.request.contextPath}/upload-photo" method="post" enctype="multipart/form-data" style="display: inline;">
                        <input type="file" name="photo" accept="image/jpeg,image/png,image/gif" style="display: none;" id="photoInput" onchange="this.form.submit()">
                        <button type="button" class="btn btn-primary" onclick="document.getElementById('photoInput').click();" style="background: #1a73e8;">
                            <i class="fas fa-upload"></i> Changer la photo
                        </button>
                    </form>
                    <c:if test="${not empty medecin.photoProfile}">
                        <a href="${pageContext.request.contextPath}/supprimer-photo" class="btn btn-danger" onclick="return confirm('Supprimer votre photo de profil ?')">
                            <i class="fas fa-trash-alt"></i> Supprimer
                        </a>
                    </c:if>
                </div>
                <small style="color: #666; display: block; margin-top: 8px;">Format JPG, PNG ou GIF. Max 5 Mo.</small>
            </div>
            <hr style="margin: 15px 0;">
        </c:if>

        <form action="${pageContext.request.contextPath}/medecin" method="post" id="medecinForm">
            <input type="hidden" name="action" value="enregistrer">
            <input type="hidden" name="idmed" id="idmed" value="${medecin.idmed}">

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

            <!-- CHAMP TÉLÉPHONE AVEC VÉRIFICATION EN TEMPS RÉEL -->
            <div class="form-group">
                <label>📱 Numéro de téléphone</label>
                <input type="tel" name="telephone" id="telephone"
                       value="${medecin.telephone}"
                       placeholder="Ex: 0328725411 ou +261328725411"
                       autocomplete="off"
                       style="width:100%; padding:10px; border:1px solid #ddd; border-radius:8px;">
                <small id="telephoneHelp" style="color: #666; font-size: 11px;">Format: 0328725411 ou +261328725411</small>
                <div id="telephoneStatus" style="font-size: 13px; margin-top: 8px; padding: 8px; border-radius: 6px; display: none;"></div>
            </div>

            <!-- Champs profil détaillé -->
            <div class="form-group">
                <label>👨‍⚕️ Biographie / Présentation</label>
                <textarea name="bio" id="bio" rows="4" 
                          style="width:100%; padding:10px; border:1px solid #ddd; border-radius:8px; font-family:inherit;"
                          placeholder="Parlez de vous, votre parcours, votre philosophie médicale...">${medecin.bio}</textarea>
                <small style="color:#666; font-size:11px;">Une courte présentation qui apparaîtra sur votre profil public.</small>
            </div>

            <div class="form-group">
                <label>🎓 Diplômes et formations</label>
                <textarea name="diplomes" id="diplomes" rows="3" 
                          style="width:100%; padding:10px; border:1px solid #ddd; border-radius:8px; font-family:inherit;"
                          placeholder="Ex: Doctorat en Médecine - Université d'Antananarivo&#10;Spécialisation en Cardiologie - CHU Paris">${medecin.diplomes}</textarea>
                <small style="color:#666; font-size:11px;">Listez vos diplômes, un par ligne.</small>
            </div>

            <div class="form-group">
                <label>💼 Expérience professionnelle</label>
                <textarea name="experience" id="experience" rows="3" 
                          style="width:100%; padding:10px; border:1px solid #ddd; border-radius:8px; font-family:inherit;"
                          placeholder="Ex: 10 ans d'expérience en cardiologie&#10;Chef de service à l'hôpital HJRA (2015-2020)">${medecin.experience}</textarea>
                <small style="color:#666; font-size:11px;">Décrivez votre parcours et vos expériences.</small>
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
    
    if (telephone === '') {
        telephoneStatus.style.display = 'none';
        submitBtn.disabled = false;
        return;
    }
    
    telephoneStatus.style.display = 'block';
    telephoneStatus.style.backgroundColor = '#e3f2fd';
    telephoneStatus.style.color = '#0c5460';
    telephoneStatus.style.border = '1px solid #bee5eb';
    telephoneStatus.innerHTML = '⏳ Vérification en cours...';
    submitBtn.disabled = true;
    
    const medecinId = document.getElementById('idmed')?.value || '';
    
    fetch('${pageContext.request.contextPath}/api/check-telephone', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'telephone=' + encodeURIComponent(telephone) + '&type=medecin&id=' + encodeURIComponent(medecinId)
    })
    .then(response => response.json())
    .then(data => {
        if (data.exists) {
            telephoneStatus.style.backgroundColor = '#f8d7da';
            telephoneStatus.style.color = '#721c24';
            telephoneStatus.style.border = '1px solid #f5c6cb';
            telephoneStatus.innerHTML = data.message;
            submitBtn.disabled = true;
        } else if (data.valid === false && !data.exists) {
            telephoneStatus.style.backgroundColor = '#fff3cd';
            telephoneStatus.style.color = '#856404';
            telephoneStatus.style.border = '1px solid #ffeeba';
            telephoneStatus.innerHTML = data.message;
            submitBtn.disabled = true;
        } else {
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