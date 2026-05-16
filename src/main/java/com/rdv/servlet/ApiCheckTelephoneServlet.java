package com.rdv.servlet;

import java.io.IOException;
import java.io.PrintWriter;

import com.rdv.dao.MedecinDAO;
import com.rdv.dao.PatientDAO;
import com.rdv.model.Patient;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/api/check-telephone")
public class ApiCheckTelephoneServlet extends HttpServlet {

    private final PatientDAO patientDAO = new PatientDAO();
    private final MedecinDAO medecinDAO = new MedecinDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String telephone = req.getParameter("telephone");
        String type = req.getParameter("type");
        String id = req.getParameter("id");

        PrintWriter out = resp.getWriter();

        if (telephone == null || telephone.isEmpty()) {
            out.write("{\"exists\": false, \"message\": \"\"}");
            return;
        }

        // Normaliser le numéro
        String normalizedPhone = telephone;
        if (!normalizedPhone.startsWith("+") && normalizedPhone.startsWith("0")) {
            normalizedPhone = "+261" + normalizedPhone.substring(1);
        }

        boolean exists = false;
        String message = "";

        try {
            if ("patient".equals(type)) {
                exists = patientDAO.telephoneExiste(normalizedPhone, id);
                if (exists) {
                    message = "Ce numéro de téléphone est déjà utilisé par un autre patient ou médecin.";
                }
            } else if ("medecin".equals(type)) {
                exists = medecinDAO.telephoneExiste(normalizedPhone, id);
                if (exists) {
                    message = "Ce numéro de téléphone est déjà utilisé par un autre médecin ou patient.";
                }
            } else {
                // Vérification générale sans type spécifique
                exists = patientDAO.telephoneExiste(normalizedPhone, null) ||
                         medecinDAO.telephoneExiste(normalizedPhone, null);
                if (exists) {
                    message = "Ce numéro de téléphone est déjà utilisé par un autre compte.";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"exists\": false, \"message\": \"Erreur technique\"}");
            return;
        }

        out.write("{\"exists\": " + exists + ", \"message\": \"" + message + "\"}");
    }
}