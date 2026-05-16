package com.rdv.servlet;

import java.io.IOException;
import java.io.PrintWriter;

import com.rdv.service.GeocodeService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/api/geocode")
public class ApiGeocodeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        
        String adresse = req.getParameter("adresse");
        PrintWriter out = resp.getWriter();
        
        if (adresse == null || adresse.trim().isEmpty()) {
            out.write("{\"error\": \"Adresse manquante\"}");
            return;
        }
        
        double[] coords = GeocodeService.adresseVersCoordonnees(adresse);
        
        if (coords != null) {
            out.write("{\"latitude\": " + coords[0] + ", \"longitude\": " + coords[1] + "}");
        } else {
            out.write("{\"error\": \"Adresse non trouvée\"}");
        }
    }
}