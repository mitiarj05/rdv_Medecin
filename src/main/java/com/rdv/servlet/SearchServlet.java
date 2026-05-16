package com.rdv.servlet;

import java.io.IOException;
import java.util.List;

import com.rdv.model.Medecin;
import com.rdv.service.MedecinService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Gère la recherche de médecins et l'affichage du profil public.
 * URL : /search
 *
 * GET  q=..            → recherche par nom (LIKE %q%)
 * GET  specialite=..   → filtrer par spécialité
 * GET  profile         → afficher profil public d'un médecin
 * GET  (rien)          → afficher tous les médecins (sauf admin)
 */
@WebServlet("/search")
public class SearchServlet extends HttpServlet {

    private final MedecinService medecinService = new MedecinService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        
        // ========== NOUVEAU : Affichage du profil public d'un médecin ==========
        if ("profile".equals(action)) {
            afficherProfilPublic(req, resp);
            return;
        }

        String motCle     = req.getParameter("q");
        String specialite = req.getParameter("specialite");

        List<Medecin> resultats;

        if (specialite != null && !specialite.trim().isEmpty()) {
            // Filtrer par spécialité
            resultats = medecinService.listerParSpecialite(specialite.trim());
            req.setAttribute("filtreSpecialite", specialite);

        } else if (motCle != null && !motCle.trim().isEmpty()) {
            // Recherche par nom LIKE %motCle%
            resultats = medecinService.rechercherParNom(motCle.trim());
            req.setAttribute("motCle", motCle);

        } else {
            // Afficher tous les médecins (sauf admin car listerTous() exclut admin@rdv.com)
            resultats = medecinService.listerTous();
        }

        // Passer les résultats et les spécialités à la JSP
        req.setAttribute("resultats",   resultats);
        req.setAttribute("specialites", medecinService.listerSpecialites());

        req.getRequestDispatcher("/views/medecin/search.jsp")
                .forward(req, resp);
    }
    
    /**
     * Affiche le profil public détaillé d'un médecin
     * Accessible par les patients (et tout le monde sans authentification)
     */
    private void afficherProfilPublic(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        String idMedecin = req.getParameter("id");
        
        if (idMedecin == null || idMedecin.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/search");
            return;
        }
        
        Medecin medecin = medecinService.trouverParId(idMedecin);
        
        if (medecin == null) {
            resp.sendRedirect(req.getContextPath() + "/search?error=notfound");
            return;
        }
        
        req.setAttribute("medecin", medecin);
        req.getRequestDispatcher("/views/medecin/profile.jsp").forward(req, resp);
    }
}