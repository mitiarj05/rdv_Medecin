package com.rdv.servlet;

import java.io.IOException;
import java.time.LocalDate;
import java.util.Map;

import com.rdv.service.CalendarService;
import com.rdv.service.CalendarService.CalendarRdv;
import com.rdv.service.CalendarService.MonthStats;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/calendar")
public class CalendarServlet extends HttpServlet {

    private final CalendarService calendarService = new CalendarService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("utilisateur") == null) {
            resp.sendRedirect(req.getContextPath() + "/views/shared/login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");
        String idUtilisateur = (String) session.getAttribute("idUtilisateur");

        // Récupérer l'année et le mois, ou utiliser la date actuelle
        int year, month;
        try {
            year = Integer.parseInt(req.getParameter("year"));
            month = Integer.parseInt(req.getParameter("month"));
        } catch (NumberFormatException e) {
            LocalDate now = LocalDate.now();
            year = now.getYear();
            month = now.getMonthValue();
        }

        // Valider les valeurs
        if (month < 1) { month = 12; year--; }
        if (month > 12) { month = 1; year++; }

        // Récupérer les rendez-vous du mois
        Map<Integer, java.util.List<CalendarRdv>> rdvsByDay = calendarService.getRdvsByMonth(idUtilisateur, role, year, month);
        MonthStats stats = calendarService.getMonthStats(idUtilisateur, role, year, month);

        // Calculer le premier jour du mois et le nombre de jours
        LocalDate firstDay = LocalDate.of(year, month, 1);
        int daysInMonth = firstDay.lengthOfMonth();
        int startOffset = firstDay.getDayOfWeek().getValue() - 1; // Lundi = 1

        // Passer les attributs à la JSP
        req.setAttribute("year", year);
        req.setAttribute("month", month);
        req.setAttribute("daysInMonth", daysInMonth);
        req.setAttribute("startOffset", startOffset);
        req.setAttribute("rdvsByDay", rdvsByDay);
        req.setAttribute("stats", stats);
        req.setAttribute("monthName", getMonthName(month));
        req.setAttribute("role", role);

        req.getRequestDispatcher("/views/shared/calendar.jsp").forward(req, resp);
    }

    private String getMonthName(int month) {
        String[] months = {"Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
                "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"};
        return months[month - 1];
    }
}