package com.rdv.servlet;

import java.io.IOException;
import java.util.List;

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

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    private final MedecinService medecinService = new MedecinService();
    private final PatientService patientService = new PatientService();
    private final RdvService rdvService = new RdvService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if (action == null || action.isEmpty()) {
            action = "dashboard";
        }

        System.out.println("[AdminServlet] doGet - Action: " + action);

        switch (action) {
            case "dashboard":
                afficherDashboard(req, resp);
                break;

            // ========== GESTION MÉDECINS ==========
            case "medecins":
                listerMedecins(req, resp);
                break;

            // ========== LISTE DES MÉDECINS POUR ADMIN (sans bouton prendre RDV) ==========
            case "listeMedecins":
                listerMedecinsPourAdmin(req, resp);
                break;

            case "formMedecin":
                req.setAttribute("specialites", medecinService.listerSpecialites());
                req.getRequestDispatcher("/views/admin/medecinForm.jsp").forward(req, resp);
                break;

            case "editMedecin":
                String idMedEdit = req.getParameter("id");
                Medecin medecin = medecinService.trouverParId(idMedEdit);
                if (medecin == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin?action=medecins");
                    return;
                }
                req.setAttribute("medecin", medecin);
                req.setAttribute("specialites", medecinService.listerSpecialites());
                req.getRequestDispatcher("/views/admin/medecinForm.jsp").forward(req, resp);
                break;

            case "supprimerMedecin":
                supprimerMedecin(req, resp);
                break;

            // ========== GESTION PATIENTS ==========
            case "patients":
                listerPatients(req, resp);
                break;

            // ========== LISTE DES PATIENTS POUR ADMIN ==========
            case "listePatients":
                listerPatientsPourAdmin(req, resp);
                break;

            case "formPatient":
                req.getRequestDispatcher("/views/admin/patientForm.jsp").forward(req, resp);
                break;

            case "editPatient":
                String idPatEdit = req.getParameter("id");
                Patient patient = patientService.trouverParId(idPatEdit);
                if (patient == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin?action=patients");
                    return;
                }
                req.setAttribute("patient", patient);
                req.getRequestDispatcher("/views/admin/patientForm.jsp").forward(req, resp);
                break;

            case "supprimerPatient":
                supprimerPatient(req, resp);
                break;

            // ========== GESTION RDV ==========
            case "rdvs":
                listerRdvs(req, resp);
                break;

            // ========== TOP 5 MÉDECINS ==========
            case "top5Medecins":
                afficherTop5Medecins(req, resp);
                break;

            // ========== TOP 5 PATIENTS ==========
            case "topPatients":
                afficherTopPatients(req, resp);
                break;

            default:
                resp.sendRedirect(req.getContextPath() + "/admin?action=dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        System.out.println("[AdminServlet] doPost - Action: " + action);

        switch (action) {
            case "enregistrerMedecin":
                enregistrerMedecin(req, resp);
                break;

            case "enregistrerPatient":
                enregistrerPatient(req, resp);
                break;

            default:
                resp.sendRedirect(req.getContextPath() + "/admin?action=dashboard");
        }
    }

    // ========== MÉTHODES PRIVÉES ==========

    private void afficherDashboard(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Medecin> allMedecins = medecinService.listerTousAvecAdmin();
        List<Patient> allPatients = patientService.listerTous();
        List<Rdv> allRdvs = rdvService.listerTous();

        // Compter les médecins (sans compter l'admin)
        long totalMedecins = allMedecins.stream()
                .filter(m -> !"admin@rdv.com".equals(m.getEmail()))
                .count();

        long totalPatients = allPatients.size();
        long totalRdvs = allRdvs.size();

        // RDV du mois
        java.time.LocalDateTime now = java.time.LocalDateTime.now();
        long rdvsMois = allRdvs.stream()
                .filter(r -> r.getDateRdv() != null && r.getDateRdv().getMonth() == now.getMonth())
                .count();

        req.setAttribute("totalMedecins", totalMedecins);
        req.setAttribute("totalPatients", totalPatients);
        req.setAttribute("totalRdvs", totalRdvs);
        req.setAttribute("rdvsMois", rdvsMois);

        req.getRequestDispatcher("/views/admin/dashboard.jsp").forward(req, resp);
    }

    /**
     * Liste des médecins pour l'admin - exclut l'admin de l'affichage
     */
    private void listerMedecins(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Medecin> medecins = medecinService.listerTous(); // Exclut admin automatiquement
        req.setAttribute("medecins", medecins);
        req.getRequestDispatcher("/views/admin/medecins.jsp").forward(req, resp);
    }

    /**
     * Liste des médecins pour admin (sans bouton prendre RDV) - exclut l'admin
     */
    private void listerMedecinsPourAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Medecin> medecins = medecinService.listerTous(); // Exclut admin automatiquement
        req.setAttribute("medecins", medecins);
        req.getRequestDispatcher("/views/admin/medecinList.jsp").forward(req, resp);
    }

    // Liste des patients pour admin
    private void listerPatientsPourAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Patient> patients = patientService.listerTous();
        req.setAttribute("patients", patients);
        req.getRequestDispatcher("/views/admin/patientList.jsp").forward(req, resp);
    }

    private void listerPatients(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Patient> patients = patientService.listerTous();
        req.setAttribute("patients", patients);
        req.getRequestDispatcher("/views/admin/patients.jsp").forward(req, resp);
    }

    private void listerRdvs(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Rdv> rdvs = rdvService.listerTous();
        req.setAttribute("rdvs", rdvs);
        req.getRequestDispatcher("/views/admin/rdvs.jsp").forward(req, resp);
    }

    private void enregistrerMedecin(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String id = req.getParameter("idmed");
        String nom = req.getParameter("nommed");
        String specialite = req.getParameter("specialite");
        String tauxStr = req.getParameter("taux_horaire");
        String lieu = req.getParameter("lieu");
        String email = req.getParameter("email");
        String telephone = req.getParameter("telephone"); // NOUVEAU
        String password = req.getParameter("password");

        String erreur = null;

        if (id != null && !id.isEmpty()) {
            // MODIFICATION - avec téléphone
            erreur = medecinService.modifier(id, nom, specialite, tauxStr, lieu, email, telephone);
        } else {
            // CRÉATION - avec téléphone
            erreur = medecinService.inscrire(nom, specialite, tauxStr, lieu, email, telephone, password);
        }

        if (erreur != null) {
            req.setAttribute("erreur", erreur);
            req.setAttribute("specialites", medecinService.listerSpecialites());
            if (id != null && !id.isEmpty()) {
                req.setAttribute("medecin", medecinService.trouverParId(id));
            }
            req.getRequestDispatcher("/views/admin/medecinForm.jsp").forward(req, resp);
            return;
        }

        req.getSession().setAttribute("messageSucces", "Médecin " + (id != null ? "modifié" : "créé") + " avec succès !");
        resp.sendRedirect(req.getContextPath() + "/admin?action=medecins");
    }

    private void enregistrerPatient(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String id = req.getParameter("idpat");
        String nom = req.getParameter("nom_pat");
        String datenais = req.getParameter("datenais");
        String email = req.getParameter("email");
        String telephone = req.getParameter("telephone"); // NOUVEAU
        String password = req.getParameter("password");

        String erreur = null;

        if (id != null && !id.isEmpty()) {
            // MODIFICATION - avec téléphone
            erreur = patientService.modifier(id, nom, datenais, email, telephone);
        } else {
            // CRÉATION - avec téléphone
            erreur = patientService.inscrire(nom, datenais, email, telephone, password);
        }

        if (erreur != null) {
            req.setAttribute("erreur", erreur);
            if (id != null && !id.isEmpty()) {
                req.setAttribute("patient", patientService.trouverParId(id));
            }
            req.getRequestDispatcher("/views/admin/patientForm.jsp").forward(req, resp);
            return;
        }

        req.getSession().setAttribute("messageSucces", "Patient " + (id != null ? "modifié" : "créé") + " avec succès !");
        resp.sendRedirect(req.getContextPath() + "/admin?action=patients");
    }

    private void supprimerMedecin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String idMedecin = req.getParameter("id");

        if (idMedecin != null) {
            Medecin medecin = medecinService.trouverParId(idMedecin);

            // Empêcher la suppression de l'admin
            if (medecin != null && "admin@rdv.com".equals(medecin.getEmail())) {
                req.getSession().setAttribute("erreur", "Impossible de supprimer le compte administrateur principal !");
            } else {
                boolean supprime = medecinService.supprimer(idMedecin);
                if (supprime) {
                    req.getSession().setAttribute("messageSucces", "Médecin supprimé avec succès !");
                } else {
                    req.getSession().setAttribute("erreur", "Erreur lors de la suppression du médecin.");
                }
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin?action=medecins");
    }

    private void supprimerPatient(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String idPatient = req.getParameter("id");

        if (idPatient != null) {
            boolean supprime = patientService.supprimer(idPatient);
            if (supprime) {
                req.getSession().setAttribute("messageSucces", "Patient supprimé avec succès !");
            } else {
                req.getSession().setAttribute("erreur", "Erreur lors de la suppression du patient.");
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin?action=patients");
    }

    // ========== TOP 5 MÉDECINS ==========
    private void afficherTop5Medecins(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Medecin> top5 = medecinService.top5PlusConsultes();
        req.setAttribute("top5", top5);
        req.getRequestDispatcher("/views/admin/top5Medecins.jsp").forward(req, resp);
    }

    // ========== TOP 5 PATIENTS ==========
    private void afficherTopPatients(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Object[]> topPatients = rdvService.top5PlusActifs();
        req.setAttribute("topPatients", topPatients);
        req.getRequestDispatcher("/views/admin/topPatients.jsp").forward(req, resp);
    }
}