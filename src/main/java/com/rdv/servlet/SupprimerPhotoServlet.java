package com.rdv.servlet;

import java.io.File;
import java.io.IOException;

import com.rdv.model.Medecin;
import com.rdv.service.MedecinService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/supprimer-photo")
public class SupprimerPhotoServlet extends HttpServlet {

    private final MedecinService medecinService = new MedecinService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("utilisateur") == null) {
            resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");
        String idMedecin = req.getParameter("idmed");
        
        // CORRECTION : Admin peut supprimer pour n'importe quel médecin
        if ("admin".equals(role)) {
            if (idMedecin == null || idMedecin.isEmpty()) {
                session.setAttribute("erreurPhoto", "ID du médecin manquant.");
                resp.sendRedirect(req.getContextPath() + "/admin?action=medecins");
                return;
            }
        } else if ("medecin".equals(role)) {
            idMedecin = (String) session.getAttribute("idUtilisateur");
            if (idMedecin == null) {
                resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
                return;
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
            return;
        }

        Medecin medecin = medecinService.trouverParId(idMedecin);
        if (medecin == null) {
            session.setAttribute("erreurPhoto", "Médecin non trouvé.");
            if ("admin".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/admin?action=medecins");
            } else {
                resp.sendRedirect(req.getContextPath() + "/medecin?action=dashboard");
            }
            return;
        }
        
        // Supprimer le fichier physique
        String oldPhoto = medecin.getPhotoProfile();
        if (oldPhoto != null && !oldPhoto.isEmpty()) {
            String oldPhotoPath = getServletContext().getRealPath("/") + "uploads/medecins/" + 
                oldPhoto.substring(oldPhoto.lastIndexOf("/") + 1);
            File oldFile = new File(oldPhotoPath);
            if (oldFile.exists()) {
                oldFile.delete();
            }
        }
        
        // Mettre à jour la base de données (supprimer la référence)
        String erreur = medecinService.modifier(
            medecin.getIdmed(),
            medecin.getNommed(),
            medecin.getSpecialite(),
            String.valueOf(medecin.getTauxHoraire()),
            medecin.getLieu(),
            medecin.getEmail(),
            medecin.getTelephone(),
            medecin.getBio(),
            medecin.getDiplomes(),
            medecin.getExperience(),
            null
        );
        
        if (erreur != null) {
            session.setAttribute("erreurPhoto", "Erreur lors de la suppression: " + erreur);
        } else {
            session.setAttribute("succesPhoto", "Photo de profil supprimée avec succès !");
            
            // Mettre à jour l'objet en session si c'est le médecin lui-même
            if ("medecin".equals(role)) {
                Medecin medecinMisAJour = medecinService.trouverParId(idMedecin);
                if (medecinMisAJour != null) {
                    session.setAttribute("utilisateur", medecinMisAJour);
                }
            }
        }
        
        // Redirection selon le rôle
        if ("admin".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/admin?action=editMedecin&id=" + idMedecin);
        } else {
            resp.sendRedirect(req.getContextPath() + "/medecin?action=edit&id=" + idMedecin);
        }
    }
}