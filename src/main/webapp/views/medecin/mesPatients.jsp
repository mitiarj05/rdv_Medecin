<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ include file="/views/shared/header.jsp" %>

<!-- DEBUG TEMPORAIRE - À SUPPRIMER APRÈS 
<div style="background: #ffeb3b; color: #000; padding: 10px; margin: 10px; border: 2px solid red; border-radius: 5px;">
    <strong>🔍 DEBUG:</strong><br/>
    patientsDuMedecin = 
    <c:choose>
        <c:when test="${empty patientsDuMedecin}">
            <span style="color:red;">❌ VIDE ou NULL</span>
        </c:when>
        <c:otherwise>
            <span style="color:green;">✅ TROUVÉ (${fn:length(patientsDuMedecin)} élément(s))</span>
        </c:otherwise>
    </c:choose>
    <br/>
    totalPatients = ${totalPatients}
    <br/>
    <c:if test="${not empty patientsDuMedecin}">
        Premier patient: ${patientsDuMedecin[0].nomPat}
    </c:if>
</div>
FIN DEBUG -->

<div class="container">
    <div class="card">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
            <h2 class="card-title" style="margin-bottom:0; border:none;">
                <i class="fas fa-users"></i> Mes patients
            </h2>
            <div>
                <span class="badge badge-success">Total: 
                    <c:choose>
                        <c:when test="${not empty patientsDuMedecin}">
                            ${fn:length(patientsDuMedecin)}
                        </c:when>
                        <c:otherwise>0</c:otherwise>
                    </c:choose>
                    patients
                </span>
            </div>
        </div>

        <c:if test="${not empty erreur}">
            <div class="alert alert-danger">${erreur}</div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="alert alert-success">${success}</div>
        </c:if>

        <!-- Explication -->
        <div style="background: #e7f3ff; padding: 10px 15px; border-radius: 8px; margin-bottom: 20px; font-size: 13px;">
            <i class="fas fa-info-circle"></i> 
            <strong>Information :</strong> Le bouton "Retirer" supprime ce patient de VOTRE liste de patients, 
            mais ne supprime pas son compte définitivement. Le patient peut toujours consulter d'autres médecins.
        </div>

        <c:choose>
            <c:when test="${empty patientsDuMedecin or fn:length(patientsDuMedecin) == 0}">
                <div style="text-align:center; padding:50px;">
                    <i class="fas fa-user-slash" style="font-size: 48px; color: #ccc; margin-bottom: 15px;"></i>
                    <p style="color:#888; font-size:15px;">
                        Vous n'avez pas encore de patients.
                    </p>
                    <p style="color:#999; font-size:13px;">
                        Les patients prendront rendez-vous avec vous via la plateforme.
                    </p>
                </div>
            </c:when>
            <c:otherwise>
                <div style="overflow-x:auto;">
                    <table style="width:100%; border-collapse:collapse;">
                        <thead>
                            <tr>
                                <th style="text-align:left; padding:12px;">Patient</th>
                                <th style="text-align:left; padding:12px;">Email</th>
                                <th style="text-align:left; padding:12px;">Date de naissance</th>
                                <th style="text-align:center; padding:12px;">Nb RDV</th>
                                <th style="text-align:left; padding:12px;">Dernier RDV</th>
                                <th style="text-align:center; padding:12px;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="patient" items="${patientsDuMedecin}">
                                <tr style="border-bottom:1px solid var(--border-light);">
                                    <td style="padding:12px;">
                                        <div style="display:flex; align-items:center; gap:10px;">
                                            <div style="width:32px; height:32px; background:linear-gradient(135deg, #1a73e8, #0d47a1); border-radius:50%; display:flex; align-items:center; justify-content:center; color:white; font-weight:bold;">
                                                ${fn:substring(patient.nomPat, 0, 1)}
                                            </div>
                                            <strong>${patient.nomPat}</strong>
                                        </div>
                                    </td>
                                    <td style="padding:12px;">${patient.email}</td>
                                    <td style="padding:12px;">${patient.datenais}</td>
                                    <td style="text-align:center;">
                                        <span class="badge badge-success">${patient.nbRendezVous}</span>
                                    </td>
                                    <td style="padding:12px;">
                                        <c:choose>
                                            <c:when test="${not empty patient.dernierRdv}">
                                                <span class="patient-date">${patient.dernierRdv}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #999;">Aucun RDV</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="text-align:center;">
                                        <a href="${pageContext.request.contextPath}/medecin?action=retirerPatient&idPatient=${patient.idpat}"
                                           class="btn btn-danger btn-sm"
                                           style="background-color:#dc3545; color:white; padding:6px 12px; font-size:12px; border-radius:5px; text-decoration:none; display:inline-block;"
                                           onclick="return confirm('Retirer ${patient.nomPat} de votre liste de patients ?\n\n⚠️ Cela ne supprime PAS son compte, juste son association avec vous.');">
                                            <i class="fas fa-user-minus"></i> Retirer
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<style>
    .patient-date {
        font-size: 0.75rem;
        background: #e9ecef;
        padding: 0.25rem 0.75rem;
        border-radius: 1rem;
        color: #1a73e8;
    }
    body.dark-mode .patient-date {
        background: #2a2a4a;
        color: #4ade80;
    }
    .badge-success {
        background: #e6f4ea;
        color: #137333;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 12px;
    }
    body.dark-mode .badge-success {
        background: #1a3a2a;
        color: #4ade80;
    }
</style>

</body>
</html>