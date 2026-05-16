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

        <form action="${pageContext.request.contextPath}/patient" method="post">
            <input type="hidden" name="action" value="enregistrer">
            <input type="hidden" name="idpat" value="${patient.idpat}">

            <div class="form-group">
                <label>Nom complet</label>
                <input type="text" name="nom_pat"
                       value="${patient.nomPat}"
                       placeholder="Ex: Rakoto Jean" required>
            </div>

            <div class="form-group">
                <label>Date de naissance</label>
                <input type="date" name="datenais"
                       value="${patient.datenais}" required>
            </div>

            <div class="form-group">
                <label>Email</label>
                <input type="email" name="email"
                       value="${patient.email}"
                       placeholder="votre@email.com" required>
            </div>

            <!-- NOUVEAU : Champ Téléphone -->
            <div class="form-group">
                <label>📱 Numéro de téléphone</label>
                <input type="tel" name="telephone" id="telephone"
                       value="${patient.telephone}"
                       placeholder="Ex: 0330000000 ou +261330000000"
                       pattern="[0-9+]{9,15}"
                       title="Format: 0330000000 ou +261330000000">
                <small style="color: #666; font-size: 11px;">Format accepté: 0330000000 ou +261330000000 (recevra SMS/WhatsApp)</small>
            </div>

            <c:if test="${empty patient}">
                <div class="form-group">
                    <label>Mot de passe</label>
                    <input type="password" name="password"
                           placeholder="Minimum 6 caractères" required>
                </div>
            </c:if>

            <div style="display:flex; gap:12px; margin-top:8px;">
                <button type="submit" class="btn btn-primary" style="flex:1;">
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

        <!-- BOUTON SUPPRIMER LE COMPTE PATIENT -->
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
                    Cette opération ne peut pas être annulée.
                </p>
            </div>
        </c:if>
        
    </div>
</div>
</body>
</html>