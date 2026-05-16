package com.rdv.servlet;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

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

@WebServlet("/patient")
public class PatientServlet extends HttpServlet {

    private final PatientService patientService = new PatientService();
    private final RdvService rdvService = new RdvService();
    private final MedecinService medecinService = new MedecinService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null || action.isEmpty()) {
            action = "liste";
        }

        System.out.println("[PatientServlet] doGet - Action: " + action);

        switch (action) {
            case "liste":
                List<Patient> listePatients = patientService.listerTous();
                System.out.println("[PatientServlet] Nombre de patients trouvés: " + (listePatients != null ? listePatients.size() : 0));
                req.setAttribute("patients", listePatients);
                req.getRequestDispatcher("/views/patient/list.jsp").forward(req, resp);
                break;

            case "dashboard":
                System.out.println("[PatientServlet] Affichage dashboard");
                afficherDashboard(req, resp);
                break;
                
            // ========== NOUVEAU : Carte pour patient ==========
            case "map":
                afficherCarte(req, resp);
                break;

            case "form":
                req.getRequestDispatcher("/views/patient/form.jsp").forward(req, resp);
                break;

            case "edit":
                String idEdit = req.getParameter("id");
                if (idEdit == null || idEdit.isEmpty()) {
                    resp.sendRedirect(req.getContextPath() + "/patient?action=liste");
                    return;
                }
                Patient patient = patientService.trouverParId(idEdit);
                if (patient == null) {
                    resp.sendRedirect(req.getContextPath() + "/patient?action=liste");
                    return;
                }
                req.setAttribute("patient", patient);
                req.getRequestDispatcher("/views/patient/form.jsp").forward(req, resp);
                break;

            case "supprimer":
                String idSupp = req.getParameter("id");
                
                HttpSession sessionSupp = req.getSession(false);
                String idPatientConnecte = null;
                String roleUtilisateur = null;
                
                if (sessionSupp != null) {
                    idPatientConnecte = (String) sessionSupp.getAttribute("idUtilisateur");
                    roleUtilisateur = (String) sessionSupp.getAttribute("role");
                }
                
                boolean isSelfDelete = "patient".equals(roleUtilisateur) && idSupp != null && idSupp.equals(idPatientConnecte);
                
                boolean supprimeReussi = patientService.supprimer(idSupp);
                
                if (supprimeReussi && isSelfDelete) {
                    sessionSupp.invalidate();
                    resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp?msg=account_deleted");
                } else if (supprimeReussi) {
                    resp.sendRedirect(req.getContextPath() + "/patient?action=liste");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/patient?action=liste&error=suppression");
                }
                break;

            case "top5":
                System.out.println("[PatientServlet] Affichage Top 5 médecins");
                List<Medecin> top5 = medecinService.top5PlusConsultes();
                req.setAttribute("top5", top5);
                req.getRequestDispatcher("/views/patient/top5.jsp").forward(req, resp);
                break;

            default:
                resp.sendRedirect(req.getContextPath() + "/patient?action=liste");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        
        System.out.println("[PatientServlet] doPost - Action: " + action);

        if ("enregistrer".equals(action)) {
            String id = req.getParameter("idpat");
            String nom = req.getParameter("nom_pat");
            String datenais = req.getParameter("datenais");
            String email = req.getParameter("email");
            String telephone = req.getParameter("telephone");
            String password = req.getParameter("password");

            HttpSession session = req.getSession(false);
            String role = (session != null) ? (String) session.getAttribute("role") : null;

            if (id != null && !id.trim().isEmpty()) {
                System.out.println("[PatientServlet] Modification patient ID: " + id);
                String erreur = patientService.modifier(id, nom, datenais, email, telephone);

                if (erreur != null) {
                    req.setAttribute("erreur", erreur);
                    Patient patientExistant = patientService.trouverParId(id);
                    req.setAttribute("patient", patientExistant);
                    req.getRequestDispatcher("/views/patient/form.jsp").forward(req, resp);
                    return;
                }

                Patient patientMisAJour = patientService.trouverParId(id);
                if (patientMisAJour != null && session != null) {
                    session.setAttribute("utilisateur", patientMisAJour);
                    session.setAttribute("idUtilisateur", patientMisAJour.getIdpat());
                    session.setAttribute("messageSucces", "Profil modifié avec succès !");
                }
                
                if ("patient".equals(role)) {
                    resp.sendRedirect(req.getContextPath() + "/patient?action=dashboard");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/patient?action=liste");
                }
                return;
                
            } else {
                System.out.println("[PatientServlet] Création nouveau patient");
                String erreur = patientService.inscrire(nom, datenais, email, telephone, password);
                
                if (erreur != null) {
                    req.setAttribute("erreur", erreur);
                    req.getRequestDispatcher("/views/patient/form.jsp").forward(req, resp);
                    return;
                }

                Patient nouveauPatient = patientService.trouverParEmail(email);
                if (session != null && nouveauPatient != null) {
                    if (session.getAttribute("utilisateur") != null) {
                        session.setAttribute("messageSucces", "Patient créé avec succès !");
                        resp.sendRedirect(req.getContextPath() + "/patient?action=liste");
                    } else {
                        session.setAttribute("utilisateur", nouveauPatient);
                        session.setAttribute("idUtilisateur", nouveauPatient.getIdpat());
                        session.setAttribute("role", "patient");
                        session.setAttribute("messageSucces", "Inscription réussie ! Bienvenue !");
                        resp.sendRedirect(req.getContextPath() + "/patient?action=dashboard");
                    }
                } else {
                    resp.sendRedirect(req.getContextPath() + "/patient?action=liste");
                }
                return;
            }
        }

        resp.sendRedirect(req.getContextPath() + "/patient?action=liste");
    }

    private void afficherDashboard(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        System.out.println("[PatientServlet] Entrée dans afficherDashboard");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("utilisateur") == null) {
            System.out.println("[PatientServlet] Session null ou utilisateur null - redirection login");
            resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");
        System.out.println("[PatientServlet] Rôle: " + role);

        if (!"patient".equals(role)) {
            System.out.println("[PatientServlet] Rôle non patient - redirection login");
            resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
            return;
        }

        Patient patientSession = (Patient) session.getAttribute("utilisateur");
        Patient patientFresh = patientService.trouverParId(patientSession.getIdpat());
        if (patientFresh != null) {
            session.setAttribute("utilisateur", patientFresh);
        }

        List<Rdv> rdvs = rdvService.listerParPatient(patientSession.getIdpat());
        System.out.println("[PatientServlet] Nombre de RDV trouvés: " + (rdvs != null ? rdvs.size() : 0));

        LocalDateTime now = LocalDateTime.now();

        long rdvTotal = rdvs != null ? rdvs.size() : 0;
        long rdvAVenir = 0;
        long rdvPasses = 0;

        if (rdvs != null) {
            rdvAVenir = rdvs.stream()
                    .filter(r -> r.getDateRdv().isAfter(now) && !"ANNULE".equals(r.getStatut()))
                    .count();
            rdvPasses = rdvs.stream()
                    .filter(r -> (r.getDateRdv().isBefore(now) || "ANNULE".equals(r.getStatut())))
                    .count();
        }

        long nbMedecinsConsultes = 0;
        if (rdvs != null) {
            nbMedecinsConsultes = rdvs.stream()
                    .map(Rdv::getIdmed)
                    .distinct()
                    .count();
        }

        long rdvConfirmes = 0;
        if (rdvs != null) {
            rdvConfirmes = rdvs.stream()
                    .filter(r -> "CONFIRME".equals(r.getStatut()))
                    .count();
        }
        int tauxAssiduite = rdvTotal > 0 ? (int) ((rdvConfirmes * 100) / rdvTotal) : 0;

        Rdv prochainRdv = null;
        if (rdvs != null && !rdvs.isEmpty()) {
            prochainRdv = rdvs.stream()
                    .filter(r -> r.getDateRdv().isAfter(now) && !"ANNULE".equals(r.getStatut()))
                    .min(Comparator.comparing(Rdv::getDateRdv))
                    .orElse(null);
        }

        List<Rdv> derniersRdvs = new ArrayList<>();
        if (rdvs != null) {
            derniersRdvs = rdvs.stream()
                    .sorted(Comparator.comparing(Rdv::getDateRdv).reversed())
                    .limit(5)
                    .collect(Collectors.toList());
        }

        req.setAttribute("nbRdvTotal", rdvTotal);
        req.setAttribute("rdvAVenir", rdvAVenir);
        req.setAttribute("rdvPasses", rdvPasses);
        req.setAttribute("nbMedecinsConsultes", nbMedecinsConsultes);
        req.setAttribute("tauxAssiduite", tauxAssiduite);
        req.setAttribute("prochainRdv", prochainRdv);
        req.setAttribute("derniersRdvs", derniersRdvs);

        String messageSucces = (String) session.getAttribute("messageSucces");
        if (messageSucces != null) {
            req.setAttribute("messageSucces", messageSucces);
            session.removeAttribute("messageSucces");
        }

        System.out.println("[PatientServlet] Forward vers /views/patient/dashboard.jsp");
        req.getRequestDispatcher("/views/patient/dashboard.jsp").forward(req, resp);
    }
    
    /**
     * Affiche la carte interactive des médecins pour les patients
     */
    private void afficherCarte(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        List<Medecin> medecins = medecinService.listerAvecCoordonnees();
        List<String> specialites = medecinService.listerSpecialites();
        
        req.setAttribute("medecins", medecins);
        req.setAttribute("specialites", specialites);
        req.getRequestDispatcher("/views/medecin/map.jsp").forward(req, resp);
    }
}