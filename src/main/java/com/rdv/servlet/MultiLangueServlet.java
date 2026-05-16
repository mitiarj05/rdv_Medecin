package com.rdv.servlet;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import com.rdv.model.Medecin;
import com.rdv.model.Patient;
import com.rdv.service.MedecinService;
import com.rdv.service.PatientService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/changer-langue")
public class MultiLangueServlet extends HttpServlet {
    
    private final PatientService patientService = new PatientService();
    private final MedecinService medecinService = new MedecinService();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        String langue = req.getParameter("langue");
        String returnUrl = req.getParameter("returnUrl");
        
        if (langue == null || langue.isEmpty()) {
            langue = "fr";
        }
        
        // Valider la langue
        if (!langue.equals("fr") && !langue.equals("en") && !langue.equals("mg")) {
            langue = "fr";
        }
        
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("utilisateur") != null) {
            String role = (String) session.getAttribute("role");
            String idUtilisateur = (String) session.getAttribute("idUtilisateur");
            
            if ("patient".equals(role)) {
                Patient patient = patientService.trouverParId(idUtilisateur);
                if (patient != null) {
                    patient.setLangue(langue);
                    updatePatientLangue(idUtilisateur, langue);
                    session.setAttribute("utilisateur", patient);
                }
            } else if ("medecin".equals(role)) {
                Medecin medecin = medecinService.trouverParId(idUtilisateur);
                if (medecin != null) {
                    medecin.setLangue(langue);
                    updateMedecinLangue(idUtilisateur, langue);
                    session.setAttribute("utilisateur", medecin);
                }
            } else if ("admin".equals(role)) {
                // L'admin est aussi un médecin dans la base
                Medecin admin = medecinService.trouverParId(idUtilisateur);
                if (admin != null) {
                    admin.setLangue(langue);
                    updateMedecinLangue(idUtilisateur, langue);
                    session.setAttribute("utilisateur", admin);
                }
            }
        }
        
        // Stocker la langue en session
        session.setAttribute("langue", langue);
        
        // Rediriger vers la page précédente
        if (returnUrl != null && !returnUrl.isEmpty()) {
            // Nettoyer l'URL pour éviter les problèmes
            String cleanUrl = returnUrl;
            // Si l'URL contient des paramètres, les conserver
            resp.sendRedirect(cleanUrl);
        } else {
            // Rediriger vers la page d'accueil selon le rôle
            String role = (String) session.getAttribute("role");
            if ("admin".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/admin?action=dashboard");
            } else if ("medecin".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/medecin?action=dashboard");
            } else if ("patient".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/patient?action=dashboard");
            } else {
                resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
            }
        }
    }
    
    private void updatePatientLangue(String idPatient, String langue) {
        String sql = "UPDATE patient SET langue = ? WHERE idpat::text = ?";
        try (java.sql.Connection conn = com.rdv.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, langue);
            ps.setString(2, idPatient);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private void updateMedecinLangue(String idMedecin, String langue) {
        String sql = "UPDATE medecin SET langue = ? WHERE idmed::text = ?";
        try (java.sql.Connection conn = com.rdv.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, langue);
            ps.setString(2, idMedecin);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}