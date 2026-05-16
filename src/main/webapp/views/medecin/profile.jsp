<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/views/shared/header.jsp" %>

<style>
    .profile-header {
        background: linear-gradient(135deg, #1a56db 0%, #0d3b8a 100%);
        border-radius: 1rem;
        padding: 2rem;
        margin-bottom: 2rem;
        color: white;
        position: relative;
        overflow: hidden;
    }
    .profile-header::before {
        content: '';
        position: absolute;
        top: -50%;
        right: -10%;
        width: 300px;
        height: 300px;
        background: rgba(255,255,255,0.05);
        border-radius: 50%;
    }
    .profile-avatar {
        width: 120px;
        height: 120px;
        background: rgba(255,255,255,0.2);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 1rem;
        overflow: hidden;
        border: 3px solid rgba(255,255,255,0.5);
    }
    .profile-avatar img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
    .profile-avatar i {
        font-size: 3rem;
    }
    .profile-section {
        background: white;
        border-radius: 1rem;
        padding: 1.5rem;
        margin-bottom: 1.5rem;
        box-shadow: 0 0.125rem 0.25rem rgba(0,0,0,0.075);
    }
    .profile-section h3 {
        color: #1a73e8;
        font-size: 1.25rem;
        margin-bottom: 1rem;
        padding-bottom: 0.5rem;
        border-bottom: 2px solid #e9ecef;
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }
    .profile-section i {
        color: #1a73e8;
    }
    .badge-specialty {
        background: rgba(255,255,255,0.2);
        padding: 0.25rem 1rem;
        border-radius: 2rem;
        font-size: 0.875rem;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
    }
    .info-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 1rem;
        margin-bottom: 1.5rem;
    }
    .info-card {
        background: #f8f9fa;
        border-radius: 0.75rem;
        padding: 1rem;
        text-align: center;
    }
    .info-card i {
        font-size: 1.5rem;
        color: #1a73e8;
        margin-bottom: 0.5rem;
    }
    .info-card .label {
        font-size: 0.75rem;
        color: #6c757d;
        text-transform: uppercase;
    }
    .info-card .value {
        font-size: 1.1rem;
        font-weight: 600;
        color: #212529;
    }
    .btn-rdv {
        background: #1a73e8;
        color: white;
        padding: 0.75rem 1.5rem;
        border-radius: 0.5rem;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        transition: all 0.2s ease;
    }
    .btn-rdv:hover {
        background: #0d47a1;
        transform: translateY(-2px);
        color: white;
    }
    .btn-message {
        background: #fbbc04;
        color: #333;
    }
    .btn-message:hover {
        background: #e6a800;
        color: #333;
    }
    .profile-content {
        max-width: 800px;
        margin: 0 auto;
    }
    .text-content {
        line-height: 1.6;
        color: #495057;
    }
    .whitespace-pre {
        white-space: pre-wrap;
    }
    
    /* Styles pour les avis */
    .star, .star-edit {
        font-size: 24px;
        cursor: pointer;
        color: #ccc;
        transition: color 0.2s;
        display: inline-block;
    }
    .star:hover, .star-edit:hover,
    .star.active, .star-edit.active {
        color: #fbbc04;
    }
    .avis-item {
        border-bottom: 1px solid #e9ecef;
        padding: 15px 0;
    }
    .avis-patient {
        font-weight: 600;
        color: #1a73e8;
    }
    .avis-note {
        margin: 5px 0;
    }
    .avis-commentaire {
        margin: 5px 0;
        line-height: 1.5;
    }
    .avis-date {
        font-size: 11px;
        color: #888;
    }
    .avis-reponse {
        background: #f8f9fa;
        padding: 10px;
        border-radius: 8px;
        margin-top: 10px;
        margin-left: 20px;
    }
    .reponse-medecin-form {
        margin-top: 10px;
        margin-left: 20px;
        display: none;
    }
    .rating-stars, .rating-stars-edit {
        display: inline-flex;
        gap: 5px;
    }
    .btn-sm {
        padding: 5px 10px;
        font-size: 12px;
        border-radius: 5px;
    }
    .btn-outline-primary {
        background: transparent;
        border: 1px solid #1a73e8;
        color: #1a73e8;
    }
    .btn-outline-primary:hover {
        background: #1a73e8;
        color: white;
    }
</style>

<div class="container">
    <c:choose>
        <c:when test="${empty medecin}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle"></i> Médecin non trouvé.
            </div>
            <a href="${pageContext.request.contextPath}/search" class="btn btn-primary">
                <i class="fas fa-arrow-left"></i> Retour à la recherche
            </a>
        </c:when>
        <c:otherwise>
            <!-- En-tête du profil -->
            <div class="profile-header">
                <div class="profile-content" style="max-width:800px; margin:0 auto; text-align: center;">
                    <!-- Photo de profil -->
                    <div class="profile-avatar" style="margin: 0 auto 1rem auto;">
                        <c:choose>
                            <c:when test="${not empty medecin.photoProfile}">
                                <img src="${medecin.photoProfile}" alt="Photo du Dr. ${medecin.nommed}">
                            </c:when>
                            <c:otherwise>
                                <i class="fas fa-user-md"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <h1 style="font-size: 2rem; margin-bottom: 0.5rem;">
                        Dr. ${medecin.nommed}
                    </h1>
                    <div style="display: flex; gap: 0.75rem; flex-wrap: wrap; justify-content: center; margin-bottom: 1rem;">
                        <span class="badge-specialty">
                            <i class="fas fa-stethoscope"></i> ${medecin.specialite}
                        </span>
                        <span class="badge-specialty">
                            <i class="fas fa-map-marker-alt"></i> ${medecin.lieu}
                        </span>
                        <span class="badge-specialty">
                            <i class="fas fa-envelope"></i> ${medecin.email}
                        </span>
                    </div>
                    <div style="display: flex; gap: 1rem; margin-top: 1rem; flex-wrap: wrap; justify-content: center;">
                        <a href="${pageContext.request.contextPath}/rdv?action=form&idmed=${medecin.idmed}" class="btn-rdv">
                            <i class="fas fa-calendar-plus"></i> Prendre rendez-vous
                        </a>
                        <a href="${pageContext.request.contextPath}/rdv?action=horaires&idmed=${medecin.idmed}" class="btn-rdv" style="background: #34a853;">
                            <i class="fas fa-clock"></i> Voir les horaires
                        </a>
                        <!-- NOUVEAU BOUTON : Envoyer un message (uniquement pour les patients) -->
                        <c:if test="${sessionScope.role == 'patient'}">
                            <button onclick="openMessageModal('${medecin.idmed}', 'medecin', 'Dr. ${medecin.nommed}')" class="btn-rdv btn-message">
                                <i class="fas fa-comment-dots"></i> Envoyer un message
                            </button>
                        </c:if>
                    </div>
                </div>
            </div>

            <div class="profile-content">
                <!-- Informations pratiques -->
                <div class="info-grid">
                    <div class="info-card">
                        <i class="fas fa-money-bill-wave"></i>
                        <div class="label">Taux horaire</div>
                        <div class="value">${medecin.tauxHoraire} Ar/h</div>
                    </div>
                    <div class="info-card">
                        <i class="fas fa-phone-alt"></i>
                        <div class="label">Téléphone</div>
                        <div class="value">${not empty medecin.telephone ? medecin.telephone : 'Non renseigné'}</div>
                    </div>
                    <div class="info-card">
                        <i class="fas fa-building"></i>
                        <div class="label">Cabinet</div>
                        <div class="value">${medecin.lieu}</div>
                    </div>
                </div>

                <!-- Biographie -->
                <div class="profile-section">
                    <h3><i class="fas fa-user-circle"></i> À propos</h3>
                    <div class="text-content whitespace-pre">
                        <c:choose>
                            <c:when test="${not empty medecin.bio}">
                                ${fn:escapeXml(medecin.bio)}
                            </c:when>
                            <c:otherwise>
                                <p style="color: #6c757d; font-style: italic;">Aucune biographie renseignée pour le moment.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Diplômes -->
                <div class="profile-section">
                    <h3><i class="fas fa-graduation-cap"></i> Diplômes et formations</h3>
                    <div class="text-content whitespace-pre">
                        <c:choose>
                            <c:when test="${not empty medecin.diplomes}">
                                ${fn:escapeXml(medecin.diplomes)}
                            </c:when>
                            <c:otherwise>
                                <p style="color: #6c757d; font-style: italic;">Aucun diplôme renseigné.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Expérience -->
                <div class="profile-section">
                    <h3><i class="fas fa-briefcase"></i> Expérience professionnelle</h3>
                    <div class="text-content whitespace-pre">
                        <c:choose>
                            <c:when test="${not empty medecin.experience}">
                                ${fn:escapeXml(medecin.experience)}
                            </c:when>
                            <c:otherwise>
                                <p style="color: #6c757d; font-style: italic;">Aucune expérience renseignée.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Section Avis et notes -->
                <div class="profile-section">
                    <h3><i class="fas fa-star"></i> Avis et notes</h3>
                    
                    <div id="avisSection">
                        <div style="text-align: center; padding: 20px;">
                            <i class="fas fa-spinner fa-spin"></i> Chargement des avis...
                        </div>
                    </div>
                    
                    <!-- Formulaire pour donner un avis (si patient connecté) -->
                    <c:if test="${sessionScope.role == 'patient'}">
                        <div id="avisFormContainer" style="margin-top: 20px; display: none;">
                            <h4>Donner mon avis</h4>
                            <div class="rating-stars" style="margin-bottom: 10px;">
                                <span class="star" data-value="1">☆</span>
                                <span class="star" data-value="2">☆</span>
                                <span class="star" data-value="3">☆</span>
                                <span class="star" data-value="4">☆</span>
                                <span class="star" data-value="5">☆</span>
                            </div>
                            <input type="hidden" id="avisNote" value="0">
                            <textarea id="avisCommentaire" rows="3" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px;" placeholder="Partagez votre expérience avec ce médecin..."></textarea>
                            <button id="submitAvisBtn" class="btn btn-primary" style="margin-top: 10px;">
                                <i class="fas fa-paper-plane"></i> Publier mon avis
                            </button>
                        </div>
                        
                        <div id="avisModifierContainer" style="margin-top: 20px; display: none;">
                            <h4>Modifier mon avis</h4>
                            <div class="rating-stars-edit" style="margin-bottom: 10px;">
                                <span class="star-edit" data-value="1">☆</span>
                                <span class="star-edit" data-value="2">☆</span>
                                <span class="star-edit" data-value="3">☆</span>
                                <span class="star-edit" data-value="4">☆</span>
                                <span class="star-edit" data-value="5">☆</span>
                            </div>
                            <input type="hidden" id="editAvisNote" value="0">
                            <textarea id="editAvisCommentaire" rows="3" style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px;" placeholder="Modifiez votre commentaire..."></textarea>
                            <input type="hidden" id="editAvisId" value="">
                            <button id="updateAvisBtn" class="btn btn-primary" style="margin-top: 10px;">
                                <i class="fas fa-save"></i> Modifier
                            </button>
                            <button id="deleteAvisBtn" class="btn btn-danger" style="margin-top: 10px; margin-left: 10px;">
                                <i class="fas fa-trash"></i> Supprimer
                            </button>
                        </div>
                    </c:if>
                </div>

                <!-- Bouton retour -->
                <div style="text-align: center; margin-top: 1rem;">
                    <a href="${pageContext.request.contextPath}/search" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i> Retour à la recherche
                    </a>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- MODAL POUR ENVOYER UN MESSAGE -->
<div id="messageModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.6); z-index:2000; align-items:center; justify-content:center;">
    <div style="background:var(--bg-card); border-radius:16px; padding:25px; width:90%; max-width:450px; animation:fadeInUp 0.3s ease;">
        <h3 style="color:#1a73e8; margin-bottom:15px;">
            <i class="fas fa-comment-dots"></i> Nouveau message
        </h3>
        <div id="messageModalDestinataire" style="margin-bottom:15px; padding:8px 12px; background:var(--hover-bg); border-radius:8px;">
            <strong><i class="fas fa-user"></i> Destinataire :</strong> <span id="destinataireName"></span>
        </div>
        <textarea id="modalMessageContent" rows="4" style="width:100%; padding:12px; border:1px solid var(--border-color); border-radius:8px; resize:vertical; background:var(--bg-card); color:var(--text-primary);" placeholder="Écrivez votre message..."></textarea>
        <div style="display:flex; gap:10px; justify-content:flex-end; margin-top:20px;">
            <button onclick="closeMessageModal()" class="btn btn-secondary">Annuler</button>
            <button onclick="sendMessageFromModal()" class="btn btn-primary">
                <i class="fas fa-paper-plane"></i> Envoyer
            </button>
        </div>
    </div>
</div>

<script>
    let medecinId = '${medecin.idmed}';
    let userRole = '${sessionScope.role}';
    let userId = '${sessionScope.idUtilisateur}';
    let currentDestinataireId = null;
    let currentDestinataireType = null;
    
    // Fonction pour ouvrir le modal de message
    function openMessageModal(id, type, name) {
        currentDestinataireId = id;
        currentDestinataireType = type;
        document.getElementById('destinataireName').innerHTML = name;
        document.getElementById('messageModal').style.display = 'flex';
        document.getElementById('modalMessageContent').value = '';
        document.getElementById('modalMessageContent').focus();
    }
    
    function closeMessageModal() {
        document.getElementById('messageModal').style.display = 'none';
        currentDestinataireId = null;
        currentDestinataireType = null;
    }
    
    function sendMessageFromModal() {
        const message = document.getElementById('modalMessageContent').value.trim();
        if (!message) {
            alert('Veuillez écrire un message.');
            return;
        }
        if (!currentDestinataireId) {
            alert('Destinataire non spécifié.');
            return;
        }
        
        fetch('${pageContext.request.contextPath}/message', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'action=envoyer&idDestinataire=' + encodeURIComponent(currentDestinataireId) + 
                  '&typeDestinataire=' + encodeURIComponent(currentDestinataireType) + 
                  '&contenu=' + encodeURIComponent(message)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('Message envoyé avec succès !');
                closeMessageModal();
            } else {
                alert('Erreur: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Erreur:', error);
            alert('Erreur lors de l\'envoi du message.');
        });
    }
    
    // Charger les avis
    function loadAvis() {
        fetch('${pageContext.request.contextPath}/avis?idMedecin=' + medecinId)
            .then(response => response.json())
            .then(data => {
                const container = document.getElementById('avisSection');
                let html = '';
                
                html += '<div style="margin-bottom: 20px; text-align: center;">';
                html += '<div style="font-size: 36px; font-weight: bold; color: #1a73e8;">' + (data.moyenne ? data.moyenne.toFixed(1) : '0') + '/5</div>';
                html += '<div>' + generateStarsHtml(data.moyenne || 0) + '</div>';
                html += '<div>' + (data.total || 0) + ' avis</div>';
                html += '</div>';
                
                if (data.avis && data.avis.length > 0) {
                    data.avis.forEach(avis => {
                        html += '<div class="avis-item" id="avis-' + avis.idAvis + '">';
                        html += '<div class="avis-patient"><i class="fas fa-user"></i> ' + (avis.patient ? avis.patient.nomPat : 'Patient') + '</div>';
                        html += '<div class="avis-note">' + generateStarsHtml(avis.note) + '</div>';
                        html += '<div class="avis-commentaire">' + escapeHtml(avis.commentaire) + '</div>';
                        html += '<div class="avis-date">' + (avis.dateAvisFormatee || '') + '</div>';
                        
                        if (avis.reponseMedecin) {
                            html += '<div class="avis-reponse">';
                            html += '<strong><i class="fas fa-reply"></i> Réponse du médecin :</strong><br>';
                            html += escapeHtml(avis.reponseMedecin);
                            html += '<div class="avis-date">' + (avis.dateReponseFormatee || '') + '</div>';
                            html += '</div>';
                        }
                        
                        if (userRole === 'medecin' && !avis.reponseMedecin) {
                            html += '<div class="reponse-medecin-form" id="reponse-form-' + avis.idAvis + '">';
                            html += '<textarea id="reponse-' + avis.idAvis + '" rows="2" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 8px;" placeholder="Votre réponse..."></textarea>';
                            html += '<button onclick="repondreAvis(\'' + avis.idAvis + '\')" class="btn btn-sm btn-primary" style="margin-top: 5px;"><i class="fas fa-reply"></i> Répondre</button>';
                            html += '</div>';
                            html += '<button onclick="showReponseForm(\'' + avis.idAvis + '\')" class="btn btn-sm btn-outline-primary" style="margin-top: 5px;"><i class="fas fa-reply"></i> Répondre à cet avis</button>';
                        }
                        
                        html += '</div>';
                    });
                } else {
                    html += '<div style="text-align: center; padding: 20px;">Aucun avis pour le moment.</div>';
                }
                
                container.innerHTML = html;
                
                if (userRole === 'patient') {
                    checkExistingAvis();
                }
            })
            .catch(error => console.error('Erreur chargement avis:', error));
    }
    
    function generateStarsHtml(note) {
        let html = '';
        for (let i = 1; i <= 5; i++) {
            if (i <= note) {
                html += '<i class="fas fa-star" style="color: #fbbc04;"></i>';
            } else if (i - 0.5 <= note) {
                html += '<i class="fas fa-star-half-alt" style="color: #fbbc04;"></i>';
            } else {
                html += '<i class="far fa-star" style="color: #ccc;"></i>';
            }
        }
        return html;
    }
    
    function escapeHtml(text) {
        if (!text) return '';
        return text.replace(/[&<>]/g, function(m) {
            if (m === '&') return '&amp;';
            if (m === '<') return '&lt;';
            if (m === '>') return '&gt;';
            return m;
        }).replace(/\n/g, '<br>');
    }
    
    function checkExistingAvis() {
        fetch('${pageContext.request.contextPath}/avis?action=check&idMedecin=' + medecinId)
            .then(response => response.json())
            .then(data => {
                if (data.aDejaNote && data.avis) {
                    document.getElementById('avisFormContainer').style.display = 'none';
                    document.getElementById('avisModifierContainer').style.display = 'block';
                    document.getElementById('editAvisNote').value = data.avis.note;
                    document.getElementById('editAvisCommentaire').value = data.avis.commentaire || '';
                    document.getElementById('editAvisId').value = data.avis.idAvis;
                    updateStarsEdit(data.avis.note);
                } else {
                    document.getElementById('avisFormContainer').style.display = 'block';
                    document.getElementById('avisModifierContainer').style.display = 'none';
                }
            })
            .catch(() => {
                document.getElementById('avisFormContainer').style.display = 'block';
                document.getElementById('avisModifierContainer').style.display = 'none';
            });
    }
    
    function initStars() {
        document.querySelectorAll('.star').forEach(star => {
            star.addEventListener('click', function() {
                const value = parseInt(this.dataset.value);
                document.getElementById('avisNote').value = value;
                document.querySelectorAll('.star').forEach((s, i) => {
                    if (i < value) {
                        s.classList.add('active');
                        s.textContent = '★';
                    } else {
                        s.classList.remove('active');
                        s.textContent = '☆';
                    }
                });
            });
        });
    }
    
    function updateStarsEdit(note) {
        document.querySelectorAll('.star-edit').forEach((s, i) => {
            if (i < note) {
                s.classList.add('active');
                s.textContent = '★';
            } else {
                s.classList.remove('active');
                s.textContent = '☆';
            }
        });
    }
    
    function initStarsEdit() {
        document.querySelectorAll('.star-edit').forEach(star => {
            star.addEventListener('click', function() {
                const value = parseInt(this.dataset.value);
                document.getElementById('editAvisNote').value = value;
                updateStarsEdit(value);
            });
        });
    }
    
    document.getElementById('submitAvisBtn')?.addEventListener('click', function() {
        const note = parseInt(document.getElementById('avisNote').value);
        const commentaire = document.getElementById('avisCommentaire').value;
        
        if (note === 0) {
            alert('Veuillez sélectionner une note');
            return;
        }
        if (!commentaire.trim()) {
            alert('Veuillez écrire un commentaire');
            return;
        }
        
        fetch('${pageContext.request.contextPath}/avis', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'action=donner&idMedecin=' + medecinId + '&note=' + note + '&commentaire=' + encodeURIComponent(commentaire)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert(data.message);
                location.reload();
            } else {
                alert('Erreur: ' + data.message);
            }
        });
    });
    
    document.getElementById('updateAvisBtn')?.addEventListener('click', function() {
        const note = parseInt(document.getElementById('editAvisNote').value);
        const commentaire = document.getElementById('editAvisCommentaire').value;
        const idAvis = document.getElementById('editAvisId').value;
        
        if (note === 0) {
            alert('Veuillez sélectionner une note');
            return;
        }
        
        fetch('${pageContext.request.contextPath}/avis', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'action=modifier&idAvis=' + idAvis + '&note=' + note + '&commentaire=' + encodeURIComponent(commentaire)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('Avis modifié');
                location.reload();
            } else {
                alert('Erreur: ' + data.message);
            }
        });
    });
    
    document.getElementById('deleteAvisBtn')?.addEventListener('click', function() {
        if (confirm('Êtes-vous sûr de vouloir supprimer votre avis ?')) {
            const idAvis = document.getElementById('editAvisId').value;
            fetch('${pageContext.request.contextPath}/avis', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=supprimer&idAvis=' + idAvis
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Avis supprimé');
                    location.reload();
                } else {
                    alert('Erreur');
                }
            });
        }
    });
    
    function showReponseForm(idAvis) {
        const form = document.getElementById('reponse-form-' + idAvis);
        if (form) {
            form.style.display = form.style.display === 'none' ? 'block' : 'none';
        }
    }
    
    function repondreAvis(idAvis) {
        const reponse = document.getElementById('reponse-' + idAvis).value;
        if (!reponse.trim()) {
            alert('Veuillez écrire une réponse');
            return;
        }
        
        fetch('${pageContext.request.contextPath}/avis', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'action=repondre&idAvis=' + idAvis + '&reponse=' + encodeURIComponent(reponse)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('Réponse publiée');
                location.reload();
            } else {
                alert('Erreur: ' + data.message);
            }
        });
    }
    
    // Fermer le modal au clic en dehors
    window.onclick = function(event) {
        const modal = document.getElementById('messageModal');
        if (event.target === modal) {
            closeMessageModal();
        }
    }
    
    document.addEventListener('DOMContentLoaded', function() {
        loadAvis();
        initStars();
        initStarsEdit();
    });
</script>

</body>
</html>