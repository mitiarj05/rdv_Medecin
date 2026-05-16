package com.rdv.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.rdv.model.Medecin;
import com.rdv.model.Patient;
import com.rdv.service.MedecinService;
import com.rdv.service.PatientService;
import com.rdv.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/auth")
public class AuthServlet extends HttpServlet {

    private final PatientService patientService = new PatientService();
    private final MedecinService medecinService = new MedecinService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("logout".equals(action)) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp?logout=success");
            return;
        }

        if ("removeEmail".equals(action)) {
            String emailToRemove = req.getParameter("email");
            String role = req.getParameter("role");
            if (emailToRemove != null && !emailToRemove.isEmpty() && role != null) {
                removeEmailFromCookie(req, resp, emailToRemove, role);
            }
            resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if ("login".equals(action)) {
            traiterConnexion(req, resp);
        } else if ("register".equals(action)) {
            traiterInscription(req, resp);
        } else if ("forgot-password".equals(action)) {
            traiterForgotPassword(req, resp);
        } else if ("reset-password".equals(action)) {
            traiterResetPassword(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
        }
    }

    private void traiterConnexion(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String remember = req.getParameter("remember");
        String roleParam = req.getParameter("role");

        System.out.println("[AuthServlet] Tentative connexion - Email: " + email + ", Role demandé: " + roleParam);

        boolean authentifie = false;
        HttpSession session = req.getSession();

        // 1. Essayer patient
        Patient patient = patientService.connecter(email, password);
        if (patient != null) {
            authentifie = true;
            session.setAttribute("utilisateur", patient);
            session.setAttribute("role", "patient");
            session.setAttribute("idUtilisateur", patient.getIdpat());
            saveEmailToCookie(req, resp, email, "patient");
            System.out.println("[AuthServlet] Patient connecté - ID: " + patient.getIdpat());
        } else {
            // 2. Si patient non trouvé, essayer médecin
            Medecin medecin = medecinService.connecter(email, password);
            if (medecin != null) {
                authentifie = true;
                session.setAttribute("utilisateur", medecin);

                // Détecter l'admin
                if ("admin@rdv.com".equals(medecin.getEmail())) {
                    session.setAttribute("role", "admin");
                    saveEmailToCookie(req, resp, email, "admin");
                    System.out.println("[AuthServlet] ADMIN connecté - Email: " + medecin.getEmail());
                } else {
                    session.setAttribute("role", "medecin");
                    saveEmailToCookie(req, resp, email, "medecin");
                }

                session.setAttribute("idUtilisateur", medecin.getIdmed());
                System.out.println("[AuthServlet] Médecin connecté - ID: " + medecin.getIdmed());
            }
        }

        if (authentifie) {
            if ("true".equals(remember)) {
                session.setMaxInactiveInterval(60 * 60 * 24 * 7); // 7 jours
            } else {
                session.setMaxInactiveInterval(60 * 30); // 30 minutes
            }

            String role = (String) session.getAttribute("role");

            if ("admin".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/admin?action=dashboard");
            } else if ("medecin".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/medecin?action=dashboard");
            } else {
                resp.sendRedirect(req.getContextPath() + "/patient?action=dashboard");
            }
        } else {
            req.setAttribute("erreur", "Email ou mot de passe incorrect.");
            req.getRequestDispatcher("/views/shared/login.jsp").forward(req, resp);
        }
    }

    private void traiterInscription(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        String role = req.getParameter("role");
        String telephone = req.getParameter("telephone");
        
        // Champs pour profil détaillé
        String bio = req.getParameter("bio");
        String diplomes = req.getParameter("diplomes");
        String experience = req.getParameter("experience");
        
        // Photo de profil (toujours null à l'inscription via formulaire)
        String photoProfile = null;

        if ("medecin".equals(role)) {
            // CORRECTION : Ajout du paramètre photoProfile (null pour l'inscription)
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
                    photoProfile,  // ← PARAMÈTRE MANQUANT AJOUTÉ
                    req.getParameter("password")
            );
            if (erreur != null) {
                req.setAttribute("erreur", erreur);
                req.getRequestDispatcher("/views/shared/register.jsp").forward(req, resp);
            } else {
                req.setAttribute("succes", "Inscription réussie ! Connectez-vous.");
                req.getRequestDispatcher("/views/shared/login.jsp").forward(req, resp);
            }

        } else {
            String erreur = patientService.inscrire(
                    req.getParameter("nom_pat"),
                    req.getParameter("datenais"),
                    req.getParameter("email"),
                    telephone,
                    req.getParameter("password")
            );
            if (erreur != null) {
                req.setAttribute("erreur", erreur);
                req.getRequestDispatcher("/views/shared/register.jsp").forward(req, resp);
            } else {
                req.setAttribute("succes", "Inscription réussie ! Connectez-vous.");
                req.getRequestDispatcher("/views/shared/login.jsp").forward(req, resp);
            }
        }
    }

    private void traiterForgotPassword(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String role = req.getParameter("role");

        if (email == null || email.isEmpty()) {
            req.setAttribute("erreur", "Veuillez entrer votre email.");
            req.getRequestDispatcher("/views/shared/forgot-password.jsp").forward(req, resp);
            return;
        }

        String token = java.util.UUID.randomUUID().toString();

        HttpSession session = req.getSession();
        session.setAttribute("reset_token_" + email, token);
        session.setAttribute("reset_role_" + email, role);
        session.setMaxInactiveInterval(60 * 30);

        req.setAttribute("email", email);
        req.setAttribute("role", role);
        req.setAttribute("token", token);
        req.getRequestDispatcher("/views/shared/reset-password.jsp").forward(req, resp);
    }

    private void traiterResetPassword(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String role = req.getParameter("role");
        String token = req.getParameter("token");
        String newPassword = req.getParameter("new_password");
        String confirmPassword = req.getParameter("confirm_password");

        HttpSession session = req.getSession();
        String savedToken = (String) session.getAttribute("reset_token_" + email);
        String savedRole = (String) session.getAttribute("reset_role_" + email);

        if (savedToken == null || !savedToken.equals(token)) {
            req.setAttribute("erreur", "Lien invalide ou expiré. Veuillez recommencer.");
            req.getRequestDispatcher("/views/shared/forgot-password.jsp").forward(req, resp);
            return;
        }

        if (newPassword == null || newPassword.length() < 6) {
            req.setAttribute("erreur", "Le mot de passe doit contenir au moins 6 caractères.");
            req.setAttribute("email", email);
            req.setAttribute("role", role);
            req.setAttribute("token", token);
            req.getRequestDispatcher("/views/shared/reset-password.jsp").forward(req, resp);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            req.setAttribute("erreur", "Les mots de passe ne correspondent pas.");
            req.setAttribute("email", email);
            req.setAttribute("role", role);
            req.setAttribute("token", token);
            req.getRequestDispatcher("/views/shared/reset-password.jsp").forward(req, resp);
            return;
        }

        String hashedPassword = PasswordUtil.hasher(newPassword);
        boolean updated = false;

        if ("medecin".equals(role)) {
            Medecin medecin = medecinService.trouverParEmail(email);
            if (medecin != null) {
                medecin.setMotDePasse(hashedPassword);
                updated = medecinService.modifierMotDePasse(medecin);
            }
        } else {
            Patient patient = patientService.trouverParEmail(email);
            if (patient != null) {
                patient.setMotDePasse(hashedPassword);
                updated = patientService.modifierMotDePasse(patient);
            }
        }

        if (updated) {
            session.removeAttribute("reset_token_" + email);
            session.removeAttribute("reset_role_" + email);
            req.setAttribute("succes", "Mot de passe réinitialisé avec succès ! Connectez-vous.");
            req.getRequestDispatcher("/views/shared/login.jsp").forward(req, resp);
        } else {
            req.setAttribute("erreur", "Email non trouvé. Veuillez vérifier votre adresse.");
            req.getRequestDispatcher("/views/shared/forgot-password.jsp").forward(req, resp);
        }
    }

    private void saveEmailToCookie(HttpServletRequest req, HttpServletResponse resp, String newEmail, String role) {
        String cookieName = "last_emails_" + role;
        String existing = "";
        Cookie[] cookies = req.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if (cookieName.equals(c.getName())) {
                    existing = c.getValue();
                    break;
                }
            }
        }

        List<String> emails = new ArrayList<>();
        if (existing != null && !existing.isEmpty()) {
            String[] parts = existing.split("\\|");
            for (String p : parts) {
                if (p != null && !p.isEmpty()) {
                    emails.add(p);
                }
            }
        }

        // Supprimer l'email s'il existe déjà (pour le remettre en premier)
        emails.removeIf(e -> e.equals(newEmail));

        // Ajouter en premier
        emails.add(0, newEmail);

        // Garder seulement les 5 derniers
        if (emails.size() > 5) {
            emails = emails.subList(0, 5);
        }

        String newValue = String.join("|", emails);
        Cookie emailCookie = new Cookie(cookieName, newValue);
        emailCookie.setMaxAge(60 * 60 * 24 * 30); // 30 jours
        emailCookie.setPath("/");
        resp.addCookie(emailCookie);
    }

    private void removeEmailFromCookie(HttpServletRequest req, HttpServletResponse resp, String emailToRemove, String role) {
        String cookieName = "last_emails_" + role;
        String existing = "";
        Cookie[] cookies = req.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if (cookieName.equals(c.getName())) {
                    existing = c.getValue();
                    break;
                }
            }
        }

        List<String> emails = new ArrayList<>();
        if (existing != null && !existing.isEmpty()) {
            String[] parts = existing.split("\\|");
            for (String p : parts) {
                if (p != null && !p.isEmpty() && !p.equals(emailToRemove)) {
                    emails.add(p);
                }
            }
        }

        String newValue = String.join("|", emails);
        Cookie emailCookie = new Cookie(cookieName, newValue);
        emailCookie.setMaxAge(60 * 60 * 24 * 30);
        emailCookie.setPath("/");
        resp.addCookie(emailCookie);
    }
}