package com.rdv.servlet;

import java.io.IOException;
import java.util.List;

import com.rdv.model.Rdv;
import com.rdv.service.MedecinService;
import com.rdv.service.RdvService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/rdv")
public class RdvServlet extends HttpServlet {

    private final RdvService     rdvService     = new RdvService();
    private final MedecinService medecinService = new MedecinService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) action = "liste";

        HttpSession session  = req.getSession(false);
        String role          = (String) session.getAttribute("role");
        String idUtilisateur = (String) session.getAttribute("idUtilisateur");

        String idmed;
        String idRdv;
        Rdv rdv;
        List<Rdv> rdvs;
        List<String> heuresPrises;

        switch (action) {

            case "liste":
                if ("medecin".equals(role)) {
                    rdvs = rdvService.listerParMedecin(idUtilisateur);
                } else {
                    rdvs = rdvService.listerParPatient(idUtilisateur);
                }
                req.setAttribute("rdvs", rdvs);
                req.getRequestDispatcher("/views/rdv/list.jsp")
                   .forward(req, resp);
                break;

            case "form":
                idmed = req.getParameter("idmed");
                req.setAttribute("medecin", medecinService.trouverParId(idmed));

                // Passer date et heure seulement si présents (venant de horaires.jsp)
                String dateParam  = req.getParameter("date");
                String heureParam = req.getParameter("heure");
                if (dateParam  != null && !dateParam.isEmpty())
                    req.setAttribute("datePreselect",  dateParam);
                if (heureParam != null && !heureParam.isEmpty())
                    req.setAttribute("heurePreselect", heureParam);

                req.getRequestDispatcher("/views/rdv/form.jsp")
                   .forward(req, resp);
                break;

            case "edit":
                idRdv = req.getParameter("id");
                rdv   = rdvService.trouverParId(idRdv);
                if (rdv == null) {
                    resp.sendRedirect(req.getContextPath() + "/rdv?action=liste");
                    return;
                }
                req.setAttribute("rdv", rdv);
                req.setAttribute("medecin", medecinService.trouverParId(rdv.getIdmed()));
                req.getRequestDispatcher("/views/rdv/form.jsp")
                   .forward(req, resp);
                break;

            case "horaires":
                idmed = req.getParameter("idmed");
                req.setAttribute("medecin", medecinService.trouverParId(idmed));
                req.getRequestDispatcher("/views/rdv/horaires.jsp")
                   .forward(req, resp);
                break;

            case "annuler":
                idRdv = req.getParameter("id");
                String erreurAnnul = rdvService.annulerRdv(idRdv);
                if (erreurAnnul != null) {
                    req.getSession().setAttribute("erreur", erreurAnnul);
                }
                resp.sendRedirect(req.getContextPath() + "/rdv?action=liste");
                break;

            case "supprimer":
                idRdv = req.getParameter("id");
                rdv   = rdvService.trouverParId(idRdv);

                if (rdv == null) {
                    resp.sendRedirect(req.getContextPath() + "/rdv?action=liste");
                    return;
                }

                // Patient ne peut supprimer que SES propres RDV
                if ("patient".equals(role) &&
                    !rdv.getIdpat().equals(idUtilisateur)) {
                    resp.sendRedirect(req.getContextPath() + "/rdv?action=liste");
                    return;
                }

                // Médecin ne peut supprimer que SES propres RDV
                if ("medecin".equals(role) &&
                    !rdv.getIdmed().equals(idUtilisateur)) {
                    resp.sendRedirect(req.getContextPath() + "/rdv?action=liste");
                    return;
                }

                rdvService.supprimer(idRdv);
                resp.sendRedirect(req.getContextPath() + "/rdv?action=liste");
                break;

            case "heuresPrises":
                idmed        = req.getParameter("idmed");
                String dateH = req.getParameter("date");
                String idRdvExclu = req.getParameter("idrdv");
                heuresPrises = rdvService.listerHeuresPrisesParDate(
                                   idmed, dateH, idRdvExclu);

                resp.setContentType("application/json");
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < heuresPrises.size(); i++) {
                    json.append("\"").append(heuresPrises.get(i)).append("\"");
                    if (i < heuresPrises.size() - 1) json.append(",");
                }
                json.append("]");
                resp.getWriter().write(json.toString());
                return;

            default:
                resp.sendRedirect(req.getContextPath() + "/rdv?action=liste");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if ("prendre".equals(action)) {
            HttpSession session  = req.getSession(false);
            String idUtilisateur = (String) session.getAttribute("idUtilisateur");
            String idmed         = req.getParameter("idmed");
            String dateRdv       = req.getParameter("date_rdv");
            String idRdv         = req.getParameter("idrdv");

            String erreur;

            if (idRdv != null && !idRdv.isEmpty()) {
                erreur = rdvService.modifierRdv(idRdv, idmed, dateRdv);
            } else {
                erreur = rdvService.prendreRdv(idmed, idUtilisateur, dateRdv);
            }

            if (erreur != null) {
                req.setAttribute("erreur", erreur);
                req.setAttribute("medecin", medecinService.trouverParId(idmed));
                req.getRequestDispatcher("/views/rdv/form.jsp")
                   .forward(req, resp);
                return;
            }

            resp.sendRedirect(req.getContextPath() + "/rdv?action=liste");
        }
    }
}