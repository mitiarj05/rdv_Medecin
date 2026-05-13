package com.rdv.filter;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.rdv.model.Medecin;

@WebFilter("/*")
public class AuthFilter implements Filter {

    private static final String[] PAGES_PUBLIQUES = {
            "/views/shared/login.jsp",
            "/views/shared/register.jsp",
            "/views/shared/forgot-password.jsp",
            "/views/shared/reset-password.jsp",
            "/auth",
            "/index.jsp",
            "/css/",
            "/js/",
            ".css",
            ".js",
            ".png",
            ".jpg",
            ".jpeg",
            ".gif"
    };

    // Pages réservées aux médecins SEULEMENT
    private static final String[] PAGES_RESERVEES_MEDECIN = {
            "/medecin?action=liste",
            "/medecin?action=form",
            "/medecin?action=edit",
            "/medecin?action=supprimer",
            "/views/medecin/list.jsp",
            "/views/medecin/form.jsp",
            "/views/patient/list.jsp"
    };

    // Pages accessibles aux patients (dans /medecin)
    private static final String[] PAGES_ACCESSIBLES_PATIENT = {
            "/medecin?action=top5",
            "/views/medecin/top5.jsp"
    };

    // Pages accessibles à tous les utilisateurs connectés (peu importe le rôle)
    private static final String[] PAGES_ACCESSIBLES_TOUS = {
            "/calendar",
            "/views/shared/calendar.jsp"
    };

    // Pages réservées à l'ADMIN
    private static final String[] PAGES_ADMIN = {
            "/admin",
            "/views/admin/"
    };

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String chemin = req.getRequestURI().substring(req.getContextPath().length());
        String queryString = req.getQueryString();
        String cheminComplet = chemin + (queryString != null ? "?" + queryString : "");
        String method = req.getMethod();

        System.out.println("[AuthFilter] Chemin demandé: " + cheminComplet);

        // Vérifier si la page est publique
        for (String page : PAGES_PUBLIQUES) {
            if (chemin.startsWith(page) || chemin.endsWith(page)) {
                System.out.println("[AuthFilter] Page publique: " + chemin);
                chain.doFilter(request, response);
                return;
            }
        }

        HttpSession session = req.getSession(false);
        boolean connecte = (session != null && session.getAttribute("utilisateur") != null);

        if (!connecte) {
            System.out.println("[AuthFilter] Non connecté - redirection login");
            resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");
        String idUtilisateur = (String) session.getAttribute("idUtilisateur");

        // 🔥 NOUVEAU : Détecter et convertir le rôle ADMIN
        // Vérifier si l'utilisateur est un médecin avec l'email admin@rdv.com
        if ("medecin".equals(role) && session.getAttribute("utilisateur") != null) {
            Object utilisateur = session.getAttribute("utilisateur");
            if (utilisateur instanceof Medecin) {
                Medecin medecin = (Medecin) utilisateur;
                if ("admin@rdv.com".equals(medecin.getEmail())) {
                    role = "admin";
                    session.setAttribute("role", "admin");
                    System.out.println("[AuthFilter] ✅ Utilisateur détecté comme ADMIN - Email: " + medecin.getEmail());
                }
            }
        }

        System.out.println("[AuthFilter] Connecté - Rôle: " + role + ", Chemin: " + cheminComplet);

        // ✅ Vérification PRIORITAIRE pour les pages admin
        for (String page : PAGES_ADMIN) {
            if (cheminComplet.startsWith(page) || chemin.startsWith(page)) {
                if (!"admin".equals(role)) {
                    System.out.println("[AuthFilter] Page admin - Accès refusé pour " + role);
                    if ("patient".equals(role)) {
                        resp.sendRedirect(req.getContextPath() + "/patient?action=dashboard");
                    } else if ("medecin".equals(role)) {
                        resp.sendRedirect(req.getContextPath() + "/medecin?action=dashboard");
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
                    }
                    return;
                }
                System.out.println("[AuthFilter] ✅ Accès admin autorisé - Suite de la chaîne");
                chain.doFilter(request, response);
                return;
            }
        }

        // ✅ Vérification PRIORITAIRE pour les pages accessibles à tous les utilisateurs connectés
        for (String page : PAGES_ACCESSIBLES_TOUS) {
            if (chemin.startsWith(page) || chemin.equals(page)) {
                System.out.println("[AuthFilter] Page accessible à tous: " + page);
                chain.doFilter(request, response);
                return;
            }
        }

        // ✅ Vérification PRIORITAIRE pour les pages accessibles aux patients
        for (String page : PAGES_ACCESSIBLES_PATIENT) {
            if (cheminComplet.startsWith(page) || chemin.equals(page) ||
                    (chemin.startsWith("/views/medecin/top5.jsp"))) {
                System.out.println("[AuthFilter] Page accessible aux patients: " + page);
                chain.doFilter(request, response);
                return;
            }
        }

        // ✅ Rediriger les accès directs aux JSP vers les servlets
        if (chemin.endsWith(".jsp") && !chemin.startsWith("/views/shared/")) {
            System.out.println("[AuthFilter] Accès direct JSP détecté: " + chemin + " - Redirection vers servlet");
            if ("patient".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/patient?action=dashboard");
                return;
            } else if ("medecin".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/medecin?action=dashboard");
                return;
            } else if ("admin".equals(role)) {
                resp.sendRedirect(req.getContextPath() + "/admin?action=dashboard");
                return;
            }
        }

        // ✅ Vérifier les pages réservées aux médecins
        for (String page : PAGES_RESERVEES_MEDECIN) {
            if (cheminComplet.startsWith(page) ||
                    (chemin.startsWith(page) && !page.contains("?"))) {
                if (!"medecin".equals(role) && !"admin".equals(role)) {
                    System.out.println("[AuthFilter] Page réservée médecin - Accès refusé pour " + role);
                    if ("patient".equals(role)) {
                        resp.sendRedirect(req.getContextPath() + "/patient?action=dashboard");
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
                    }
                    return;
                }
            }
        }

        // ✅ Vérification spécifique pour /medecin
        if (chemin.startsWith("/medecin")) {
            // L'admin est autorisé à accéder à /medecin aussi
            if (!"medecin".equals(role) && !"admin".equals(role)) {
                System.out.println("[AuthFilter] Accès à /medecin refusé pour " + role);
                if ("patient".equals(role)) {
                    resp.sendRedirect(req.getContextPath() + "/patient?action=dashboard");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
                }
                return;
            }
        }

        // ✅ Pour /patient, tout le monde peut y accéder
        if (chemin.startsWith("/patient") && !"patient".equals(role) && !"medecin".equals(role) && !"admin".equals(role)) {
            System.out.println("[AuthFilter] Accès à /patient refusé - rôle invalide: " + role);
            resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
            return;
        }

        // ✅ Exception spéciale: médecin ou admin qui veut voir la liste des patients
        if (chemin.startsWith("/patient") && queryString != null && queryString.contains("action=liste")
                && ("medecin".equals(role) || "admin".equals(role))) {
            System.out.println("[AuthFilter] Médecin/Admin accède à la liste des patients - autorisé");
            chain.doFilter(request, response);
            return;
        }

        // ✅ Exception: patient modifie son propre profil
        if (chemin.startsWith("/patient") && queryString != null && queryString.contains("action=edit")
                && idUtilisateur != null && idUtilisateur.equals(req.getParameter("id"))) {
            System.out.println("[AuthFilter] Exception: patient modifie son propre profil");
            chain.doFilter(request, response);
            return;
        }

        // ✅ Exception: POST pour enregistrer les modifications
        if (chemin.startsWith("/patient") && "POST".equalsIgnoreCase(method)
                && "enregistrer".equals(req.getParameter("action"))) {
            System.out.println("[AuthFilter] Exception: POST enregistrement patient");
            chain.doFilter(request, response);
            return;
        }

        System.out.println("[AuthFilter] Accès autorisé - suite de la chaîne");
        chain.doFilter(request, response);
    }
}