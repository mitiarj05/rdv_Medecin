package com.rdv.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;

import com.rdv.model.Medecin;
import com.rdv.service.MedecinService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/api/doctors-list")
public class ApiDoctorsListServlet extends HttpServlet {
    
    private final MedecinService medecinService = new MedecinService();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("application/json;charset=UTF-8");
        
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("utilisateur") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"error\": \"Non authentifié\"}");
            return;
        }
        
        List<Medecin> medecins = medecinService.listerTous();
        
        JSONArray doctorsArray = new JSONArray();
        for (Medecin m : medecins) {
            JSONObject obj = new JSONObject();
            obj.put("id", m.getIdmed());
            obj.put("nom", m.getNommed());
            obj.put("specialite", m.getSpecialite());
            obj.put("lieu", m.getLieu());
            doctorsArray.put(obj);
        }
        
        JSONObject response = new JSONObject();
        response.put("doctors", doctorsArray);
        
        PrintWriter out = resp.getWriter();
        out.write(response.toString());
    }
}