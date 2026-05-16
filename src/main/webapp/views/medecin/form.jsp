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

        <form action="${pageContext.request.contextPath}/medecin" method="post">
            <input type="hidden" name="action" value="enregistrer">
            <input type="hidden" name="idmed"  value="${medecin.idmed}">

            <div class="form-group">
                <label>Nom du médecin</label>
                <input type="text" name="nommed"
                       value="${medecin.nommed}"
                       placeholder="Ex: Rasoa Marie" required>
            </div>

            <div style="display:grid; grid-template-columns:1fr 1fr; gap:14px;">
                <div class="form-group">
                    <label>Spécialité</label>
                    <input type="text" name="specialite"
                           value="${medecin.specialite}"
                           placeholder="Ex: Cardiologie" required>
                </div>
                <div class="form-group">
                    <label>Taux horaire (Ar)</label>
                    <input type="number" name="taux_horaire"
                           value="${medecin.tauxHoraire}"
                           placeholder="Ex: 80000" required>
                </div>
            </div>

            <div class="form-group">
                <label>Lieu / Cabinet</label>
                <input type="text" name="lieu"
                       value="${medecin.lieu}"
                       placeholder="Ex: Antananarivo" required>
            </div>

            <div class="form-group">
                <label>Email</label>
                <input type="email" name="email"
                       value="${medecin.email}"
                       placeholder="medecin@email.com" required>
            </div>

            <!-- NOUVEAU : Champ Téléphone -->
            <div class="form-group">
                <label>📱 Numéro de téléphone</label>
                <input type="tel" name="telephone" id="telephone"
                       value="${medecin.telephone}"
                       placeholder="Ex: 0330000000 ou +261330000000"
                       pattern="[0-9+]{9,15}"
                       title="Format: 0330000000 ou +261330000000">
                <small style="color: #666; font-size: 11px;">Format accepté: 0330000000 ou +261330000000 (recevra SMS/WhatsApp)</small>
            </div>

            <c:if test="${empty medecin}">
                <div class="form-group">
                    <label>Mot de passe</label>
                    <input type="password" name="password"
                           placeholder="Minimum 6 caractères" required>
                </div>
            </c:if>

            <div style="display:flex; gap:12px; margin-top:8px;">
                <button type="submit" class="btn btn-primary" style="flex:1;">
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

        <!-- BOUTON SUPPRIMER LE COMPTE -->
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
                    Cette opération ne peut pas être annulée.
                </p>
            </div>
        </c:if>
        
    </div>
</div>
</body>
</html>