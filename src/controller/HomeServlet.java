package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.bo.PostBO;
import util.WebUtil;

@WebServlet("/HomeServlet")
public class HomeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String category = WebUtil.trim(request.getParameter("category"));   // "" = tat ca
        request.setAttribute("category", category);
        request.setAttribute("postList", new PostBO().getPublishedPosts(category));
        request.getRequestDispatcher("/guest/index.jsp").forward(request, response);
    }
}