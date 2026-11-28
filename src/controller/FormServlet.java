package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.bo.PostBO;

// trang bieu mau: ai cung xem / tai duoc (guest, user, admin) -> khong nam trong /user/*
@WebServlet("/FormServlet")
public class FormServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("formList", new PostBO().getPublishedForms());
        request.getRequestDispatcher("/guest/forms.jsp").forward(request, response);
    }
}
