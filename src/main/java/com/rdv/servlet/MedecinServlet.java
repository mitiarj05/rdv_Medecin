package com.rdv.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;

import com.rdv.dao.MedecinDAO;
import com.rdv.model.Medecin;
import com.rdv.model.Patient;
import com.rdv.model.Rdv;
import com.rdv.service.MedecinService;
import com.rdv.service.PatientService;
import com.rdv.service.RdvService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/medecin")
public class MedecinServlet extends HttpServlet {

    private final MedecinService medecinService = new MedecinService();
    private final RdvService rdvService = new RdvService();
    private final PatientService patientService = new PatientService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if (action == null || action.isEmpty()) {
            action = "dashboard";
        }

        System.out.println("=== MedecinServlet doGet - Action: " + action + " ===");

        switch (action) {
            case "dashboard":
                afficherDashboard(req, resp);
                break;
                
            case "liste":
                List<Patient> listePatients = patientService.listerTous();
                req.setAttribute("patients", listePatients);
                req.getRequestDispatcher("/views/medecin/list.jsp").forward(req, resp);
                break;
                
            case "mesPatients":
                afficherMesPatients(req, resp);
                break;
                
            case "retirerPatient":
                retirerPatient(req, resp);
                break;
                
            case "form":
                req.setAttribute("specialites", medecinService.listerSpecialites());
                req.getRequestDispatcher("/views/medecin/form.jsp").forward(req, resp);
                break;
                
            case "edit":
                String idEdit = req.getParameter("id");
                Medecin medecin = medecinService.trouverParId(idEdit);
                if (medecin == null) {
                    resp.sendRedirect(req.getContextPath() + "/medecin?action=dashboard");
                    return;
                }
                req.setAttribute("medecin", medecin);
                req.setAttribute("specialites", medecinService.listerSpecialites());
                req.getRequestDispatcher("/views/medecin/form.jsp").forward(req, resp);
                break;
                
            case "supprimer":
                String idSupp = req.getParameter("id");
                HttpSession sessionSupp = req.getSession(false);
                String idMedecinConnecte = null;
                String roleUtilisateur = null;
                
                if (sessionSupp != null) {
                    idMedecinConnecte = (String) sessionSupp.getAttribute("idUtilisateur");
                    roleUtilisateur = (String) sessionSupp.getAttribute("role");
                }
                
                boolean supprimeReussi = medecinService.supprimer(idSupp);
                
                if (supprimeReussi && "medecin".equals(roleUtilisateur) && idSupp != null && idSupp.equals(idMedecinConnecte)) {
                    sessionSupp.invalidate();
                    resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp?msg=account_deleted");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/medecin?action=liste");
                }
                break;
                
            case "top5":
                List<Medecin> top5 = medecinService.top5PlusConsultes();
                req.setAttribute("top5", top5);
                req.getRequestDispatcher("/views/medecin/top5.jsp").forward(req, resp);
                break;
                
            case "profile":
                afficherProfilPublic(req, resp);
                break;
                
            // ========== NOUVEAU : Carte interactive ==========
            case "map":
                afficherCarte(req, resp);
                break;
                
            // ========== API pour médecins à proximité ==========
            case "nearby":
                trouverMedecinsProches(req, resp);
                break;

            default:
                resp.sendRedirect(req.getContextPath() + "/medecin?action=dashboard");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if ("enregistrer".equals(action)) {
            String id = req.getParameter("idmed");
            String telephone = req.getParameter("telephone");
            
            String bio = req.getParameter("bio");
            String diplomes = req.getParameter("diplomes");
            String experience = req.getParameter("experience");
            
            // Récupération des coordonnées géographiques
            String adresse = req.getParameter("adresse");
            String latitudeStr = req.getParameter("latitude");
            String longitudeStr = req.getParameter("longitude");
            
            Double latitude = null;
            Double longitude = null;
            
            if (latitudeStr != null && !latitudeStr.trim().isEmpty()) {
                try {
                    latitude = Double.parseDouble(latitudeStr);
                } catch (NumberFormatException e) {}
            }
            
            if (longitudeStr != null && !longitudeStr.trim().isEmpty()) {
                try {
                    longitude = Double.parseDouble(longitudeStr);
                } catch (NumberFormatException e) {}
            }
            
            String photoProfile = null;

            if (id != null && !id.isEmpty()) {
                // Garder la photo existante si elle n'est pas modifiée
                Medecin existing = medecinService.trouverParId(id);
                if (existing != null) {
                    photoProfile = existing.getPhotoProfile();
                }
                
                String erreur = medecinService.modifier(
                        id,
                        req.getParameter("nommed"),
                        req.getParameter("specialite"),
                        req.getParameter("taux_horaire"),
                        req.getParameter("lieu"),
                        req.getParameter("email"),
                        telephone,
                        bio,
                        diplomes,
                        experience,
                        photoProfile,
                        adresse,
                        latitude,
                        longitude
                );
                if (erreur != null) {
                    req.setAttribute("erreur", erreur);
                    req.setAttribute("medecin", medecinService.trouverParId(id));
                    req.setAttribute("specialites", medecinService.listerSpecialites());
                    req.getRequestDispatcher("/views/medecin/form.jsp").forward(req, resp);
                    return;
                }

                HttpSession session = req.getSession(false);
                if (session != null) {
                    Medecin medecinMisAJour = medecinService.trouverParId(id);
                    if (medecinMisAJour != null) {
                        session.setAttribute("utilisateur", medecinMisAJour);
                        session.setAttribute("idUtilisateur", medecinMisAJour.getIdmed());
                    }
                }
            } else {
                String erreur = medecinService.inscrire(
                        req.getParameter("nommed"),
                        req.getParameter("specialite"),
                        req.getParameter("taux_horaire"),
                        req.getParameter("lieu"),
                        req.getParameter("email"),
                        telephone,
                        bio,
                        diplomes,
                        experience,
                        null,
                        adresse,
                        latitude,
                        longitude,
                        req.getParameter("password")
                );
                if (erreur != null) {
                    req.setAttribute("erreur", erreur);
                    req.setAttribute("specialites", medecinService.listerSpecialites());
                    req.getRequestDispatcher("/views/medecin/form.jsp").forward(req, resp);
                    return;
                }
            }
        }

        HttpSession session = req.getSession(false);
        String role = (String) session.getAttribute("role");

        if ("medecin".equals(role)) {
            resp.sendRedirect(req.getContextPath() + "/medecin?action=dashboard");
        } else {
            resp.sendRedirect(req.getContextPath() + "/medecin?action=liste");
        }
    }

    private void afficherMesPatients(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        System.out.println("=== AFFICHER MES PATIENTS ===");
        
        HttpSession session = req.getSession(false);
        if (session == null) {
            System.err.println("Session est null!");
            resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
            return;
        }
        
        System.out.println("Session ID: " + session.getId());
        
        java.util.Enumeration<String> attrs = session.getAttributeNames();
        System.out.println("Attributs de session:");
        while (attrs.hasMoreElements()) {
            String attr = attrs.nextElement();
            System.out.println("  " + attr + " = " + session.getAttribute(attr));
        }
        
        String idMedecin = (String) session.getAttribute("idUtilisateur");
        System.out.println("ID Médecin = '" + idMedecin + "'");
        
        if (idMedecin == null) {
            System.err.println("ERREUR: idUtilisateur est NULL dans la session!");
            resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
            return;
        }
        
        try {
            List<MedecinDAO.PatientAvecStat> mesPatients = medecinService.listerPatientsAvecStats(idMedecin);
            System.out.println("Résultat: " + (mesPatients != null ? mesPatients.size() : 0) + " patients");
            
            req.setAttribute("patientsDuMedecin", mesPatients);
            req.setAttribute("totalPatients", mesPatients != null ? mesPatients.size() : 0);
            
            req.getRequestDispatcher("/views/medecin/mesPatients.jsp").forward(req, resp);
        } catch (Exception e) {
            System.err.println("ERREUR dans afficherMesPatients: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }
    
    private void retirerPatient(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
            return;
        }
        
        String idMedecin = (String) session.getAttribute("idUtilisateur");
        String idPatient = req.getParameter("idPatient");
        
        if (idMedecin == null || idPatient == null) {
            req.setAttribute("erreur", "Paramètres invalides.");
            afficherMesPatients(req, resp);
            return;
        }
        
        boolean retirerReussi = medecinService.retirerPatientDeMaListe(idMedecin, idPatient);
        
        if (retirerReussi) {
            req.setAttribute("success", "Patient retiré de votre liste avec succès.");
        } else {
            req.setAttribute("erreur", "Erreur lors du retrait du patient.");
        }
        
        List<MedecinDAO.PatientAvecStat> patientsMisAJour = medecinService.listerPatientsAvecStats(idMedecin);
        req.setAttribute("patientsDuMedecin", patientsMisAJour);
        req.setAttribute("totalPatients", patientsMisAJour != null ? patientsMisAJour.size() : 0);
        
        req.getRequestDispatcher("/views/medecin/mesPatients.jsp").forward(req, resp);
    }

    private void afficherDashboard(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        System.out.println("\n=== AFFICHAGE DASHBOARD MÉDECIN ===");

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
            return;
        }

        String idMedecin = (String) session.getAttribute("idUtilisateur");
        if (idMedecin == null) {
            resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
            return;
        }

        Medecin medecin = medecinService.trouverParId(idMedecin);
        int tauxHoraire = medecin != null ? medecin.getTauxHoraire() : 0;
        req.setAttribute("tauxHoraire", tauxHoraire);
        req.setAttribute("lieu", medecin != null ? medecin.getLieu() : "");

        List<Rdv> rdvs = rdvService.listerParMedecin(idMedecin);
        LocalDateTime now = LocalDateTime.now();

        Rdv prochainRdv = null;
        if (rdvs != null && !rdvs.isEmpty()) {
            prochainRdv = rdvs.stream()
                    .filter(r -> r.getDateRdv().isAfter(now) && !"ANNULE".equals(r.getStatut()))
                    .min(Comparator.comparing(Rdv::getDateRdv))
                    .orElse(null);
        }
        req.setAttribute("prochainRdv", prochainRdv);

        long rdvPasses = 0, rdvAVenir = 0, rdvAujourdhui = 0, rdvCetteSemaine = 0, totalPatients = 0, revenusMois = 0;

        if (rdvs != null) {
            rdvPasses = rdvs.stream().filter(r -> r.getDateRdv().isBefore(now) || "ANNULE".equals(r.getStatut())).count();
            rdvAVenir = rdvs.stream().filter(r -> r.getDateRdv().isAfter(now) && !"ANNULE".equals(r.getStatut())).count();
            rdvAujourdhui = rdvs.stream().filter(r -> r.getDateRdv().toLocalDate().equals(now.toLocalDate()) && !"ANNULE".equals(r.getStatut())).count();

            LocalDateTime debutSemaine = now.withHour(0).withMinute(0).withSecond(0).minusDays(now.getDayOfWeek().getValue() - 1);
            rdvCetteSemaine = rdvs.stream().filter(r -> r.getDateRdv().isAfter(debutSemaine) && !"ANNULE".equals(r.getStatut())).count();

            totalPatients = rdvs.stream().map(Rdv::getIdpat).filter(id -> id != null).distinct().count();

            if (tauxHoraire > 0) {
                LocalDateTime debutMois = now.withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);
                long nbRdvMois = rdvs.stream().filter(r -> r.getDateRdv().isAfter(debutMois) && !"ANNULE".equals(r.getStatut())).count();
                revenusMois = nbRdvMois * tauxHoraire;
            }
        }

        req.setAttribute("nbRdvPasses", rdvPasses);
        req.setAttribute("nbRdvAVenir", rdvAVenir);
        req.setAttribute("rdvAujourdhui", rdvAujourdhui);
        req.setAttribute("rdvCetteSemaine", rdvCetteSemaine);
        req.setAttribute("totalPatients", totalPatients);
        req.setAttribute("revenusMois", revenusMois);

        List<PatientInfo> derniersPatients = new ArrayList<>();
        if (rdvs != null) {
            rdvs.stream()
                    .filter(r -> r.getPatient() != null && r.getDateRdv().isBefore(now))
                    .sorted(Comparator.comparing(Rdv::getDateRdv).reversed())
                    .limit(5)
                    .forEach(r -> {
                        PatientInfo info = new PatientInfo();
                        info.setNomPat(r.getPatient().getNomPat());
                        info.setEmail(r.getPatient().getEmail());
                        info.setDateDernierRdv(r.getDateRdv().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
                        derniersPatients.add(info);
                    });
        }
        req.setAttribute("derniersPatients", derniersPatients);

        req.getRequestDispatcher("/views/medecin/dashboard.jsp").forward(req, resp);
    }

    /**
     * Affiche le profil public détaillé d'un médecin
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

    /**
     * Affiche la carte interactive des médecins
     */
    private void afficherCarte(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        List<Medecin> medecins = medecinService.listerAvecCoordonnees();
        List<String> specialites = medecinService.listerSpecialites();
        
        req.setAttribute("medecins", medecins);
        req.setAttribute("specialites", specialites);
        req.getRequestDispatcher("/views/medecin/map.jsp").forward(req, resp);
    }

    /**
     * API pour obtenir les médecins à proximité (AJAX)
     */
    private void trouverMedecinsProches(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        String latStr = req.getParameter("lat");
        String lonStr = req.getParameter("lon");
        String limitStr = req.getParameter("limit");
        
        double lat = -18.8792; // Antananarivo par défaut
        double lon = 47.5079;
        int limit = 20;
        
        if (latStr != null && !latStr.isEmpty()) {
            try {
                lat = Double.parseDouble(latStr);
            } catch (NumberFormatException e) {}
        }
        
        if (lonStr != null && !lonStr.isEmpty()) {
            try {
                lon = Double.parseDouble(lonStr);
            } catch (NumberFormatException e) {}
        }
        
        if (limitStr != null && !limitStr.isEmpty()) {
            try {
                limit = Integer.parseInt(limitStr);
            } catch (NumberFormatException e) {}
        }
        
        List<Medecin> medecins = medecinService.trouverPlusProches(lat, lon, limit);
        
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        
        JSONArray jsonArray = new JSONArray();
        for (Medecin m : medecins) {
            JSONObject obj = new JSONObject();
            obj.put("id", m.getIdmed());
            obj.put("nom", m.getNommed());
            obj.put("specialite", m.getSpecialite());
            obj.put("lieu", m.getLieu());
            obj.put("tauxHoraire", m.getTauxHoraire());
            obj.put("latitude", m.getLatitude());
            obj.put("longitude", m.getLongitude());
            obj.put("adresse", m.getAdresse() != null ? m.getAdresse() : "");
            obj.put("photo", m.getPhotoProfile() != null ? m.getPhotoProfile() : "");
            obj.put("telephone", m.getTelephone() != null ? m.getTelephone() : "");
            obj.put("distance", String.format("%.2f", m.distanceTo(lat, lon)));
            jsonArray.put(obj);
        }
        
        out.write(jsonArray.toString());
    }

    public static class PatientInfo {
        private String nomPat;
        private String email;
        private String dateDernierRdv;
        public String getNomPat() { return nomPat; }
        public void setNomPat(String nomPat) { this.nomPat = nomPat; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getDateDernierRdv() { return dateDernierRdv; }
        public void setDateDernierRdv(String dateDernierRdv) { this.dateDernierRdv = dateDernierRdv; }
    }
}