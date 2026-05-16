package com.rdv.servlet;

import java.io.IOException;
import java.io.PrintWriter;

import com.rdv.dao.MedecinDAO;
import com.rdv.dao.PatientDAO;
import com.rdv.util.PhoneUtil;

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

        if (telephone == null || telephone.trim().isEmpty()) {
            out.write("{\"exists\": false, \"message\": \"\", \"valid\": true}");
            return;
        }

        String normalizedPhone = PhoneUtil.normaliserTelephone(telephone);
        
        if (normalizedPhone == null) {
            out.write("{\"exists\": false, \"message\": \"Format invalide. Utilisez 032... ou +26132...\", \"valid\": false}");
            return;
        }

        boolean exists = false;

        try {
            if ("patient".equals(type)) {
                exists = patientDAO.telephoneExiste(normalizedPhone, id);
            } else if ("medecin".equals(type)) {
                exists = medecinDAO.telephoneExiste(normalizedPhone, id);
            } else {
                exists = patientDAO.telephoneExiste(normalizedPhone, null) ||
                         medecinDAO.telephoneExiste(normalizedPhone, null);
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.write("{\"exists\": false, \"message\": \"Erreur technique\", \"valid\": false}");
            return;
        }

        if (exists) {
            out.write("{\"exists\": true, \"message\": \"❌ Ce numéro est déjà utilisé par un autre compte. Veuillez en utiliser un autre.\", \"valid\": false}");
        } else {
            out.write("{\"exists\": false, \"message\": \"✓ Numéro disponible\", \"valid\": true}");
        }
    }
}