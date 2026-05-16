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
        String idUtilisateur = (String) session.getAttribute("idUtilisateur");
        
        // Seul un médecin peut supprimer sa photo
        if (!"medecin".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/medecin?action=dashboard");
            return;
        }

        Medecin medecin = medecinService.trouverParId(idUtilisateur);
        if (medecin == null) {
            session.setAttribute("erreurPhoto", "Médecin non trouvé.");
            resp.sendRedirect(req.getContextPath() + "/medecin?action=dashboard");
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
            
            // Mettre à jour l'objet en session
            Medecin medecinMisAJour = medecinService.trouverParId(idUtilisateur);
            if (medecinMisAJour != null) {
                session.setAttribute("utilisateur", medecinMisAJour);
            }
        }
        
        resp.sendRedirect(req.getContextPath() + "/medecin?action=edit&id=" + idUtilisateur);
    }
}