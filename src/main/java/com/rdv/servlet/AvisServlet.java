package com.rdv.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import org.json.JSONObject;

import com.rdv.model.Avis;
import com.rdv.service.AvisService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/avis")
public class AvisServlet extends HttpServlet {
    
    private final AvisService avisService = new AvisService();
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("utilisateur") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"success\": false, \"message\": \"Non authentifié\"}");
            return;
        }
        
        String action = req.getParameter("action");
        String role = (String) session.getAttribute("role");
        String idUtilisateur = (String) session.getAttribute("idUtilisateur");
        
        PrintWriter out = resp.getWriter();
        JSONObject json = new JSONObject();
        
        if ("donner".equals(action)) {
            // Seul un patient peut donner un avis
            if (!"patient".equals(role)) {
                json.put("success", false);
                json.put("message", "Seuls les patients peuvent donner un avis");
                out.write(json.toString());
                return;
            }
            
            String idMedecin = req.getParameter("idMedecin");
            int note = Integer.parseInt(req.getParameter("note"));
            String commentaire = req.getParameter("commentaire");
            
            boolean success = avisService.donnerAvis(idUtilisateur, idMedecin, note, commentaire);
            
            json.put("success", success);
            json.put("message", success ? "Avis enregistré avec succès" : "Erreur lors de l'enregistrement");
            out.write(json.toString());
            
        } else if ("repondre".equals(action)) {
            // Seul un médecin peut répondre
            if (!"medecin".equals(role)) {
                json.put("success", false);
                json.put("message", "Seuls les médecins peuvent répondre");
                out.write(json.toString());
                return;
            }
            
            String idAvis = req.getParameter("idAvis");
            String reponse = req.getParameter("reponse");
            
            boolean success = avisService.repondreAvis(idAvis, reponse);
            
            json.put("success", success);
            json.put("message", success ? "Réponse enregistrée" : "Erreur");
            out.write(json.toString());
            
        } else if ("supprimer".equals(action)) {
            String idAvis = req.getParameter("idAvis");
            
            // Vérifier les droits (admin ou auteur)
            Avis avis = avisService.getAvisPourPatient(idUtilisateur).stream()
                        .filter(a -> a.getIdAvis().equals(idAvis))
                        .findFirst().orElse(null);
            
            if (!"admin".equals(role) && avis == null) {
                json.put("success", false);
                json.put("message", "Non autorisé");
                out.write(json.toString());
                return;
            }
            
            boolean success = avisService.supprimerAvis(idAvis);
            json.put("success", success);
            out.write(json.toString());
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        
        String idMedecin = req.getParameter("idMedecin");
        PrintWriter out = resp.getWriter();
        JSONObject json = new JSONObject();
        
        if (idMedecin != null) {
            List<Avis> avis = avisService.getAvisPourMedecin(idMedecin);
            double moyenne = avisService.getNoteMoyenne(idMedecin);
            int total = avisService.getNombreAvis(idMedecin);
            
            json.put("success", true);
            json.put("moyenne", moyenne);
            json.put("total", total);
            json.put("avis", avis);
            out.write(json.toString());
        } else {
            json.put("success", false);
            json.put("message", "ID médecin manquant");
            out.write(json.toString());
        }
    }
}