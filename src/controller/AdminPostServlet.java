package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import model.bean.Post;
import model.bean.User;
import model.bo.PostBO;
import util.UploadUtil;
import util.WebUtil;

@WebServlet("/admin/PostServlet")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)   // file toi da 5MB
public class AdminPostServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // GET: ?action=add | ?action=edit&id=.. | khong co action = danh sach
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        PostBO postBO = new PostBO();
        String action = WebUtil.trim(request.getParameter("action"));

        if (action.equals("add") || action.equals("edit")) {
            Post post = new Post();                             // them moi: form trong
            post.setCategory(WebUtil.trim(request.getParameter("category")).equals("form") ? "form" : "news");
            if (action.equals("edit")) {
                post = postBO.getPostById(WebUtil.toInt(request.getParameter("id")));
                if (post == null) {
                    WebUtil.redirect(request, response, "/admin/PostServlet", "loi", "Không tìm thấy bài viết!");
                    return;
                }
            }
            request.setAttribute("post", post);
            request.getRequestDispatcher("/admin/post-form.jsp").forward(request, response);
            return;
        }

        request.setAttribute("postList", postBO.getAllPosts());
        request.getRequestDispatcher("/admin/posts.jsp").forward(request, response);
    }

    // POST: action=save (them/sua, form multipart co o chon file) | action=delete
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        PostBO postBO = new PostBO();
        String action = WebUtil.trim(request.getParameter("action"));

        if (action.equals("delete")) {
            String loi = postBO.deletePost(WebUtil.toInt(request.getParameter("id")));
            if (loi == null) WebUtil.redirect(request, response, "/admin/PostServlet", "ok", "Đã xóa bài viết!");
            else WebUtil.redirect(request, response, "/admin/PostServlet", "loi", loi);
            return;
        }

        // 1. doc o chon file (file qua 5MB -> Tomcat nem loi ngay tai day)
        Part part;
        try {
            part = request.getPart("file");
        } catch (Exception e) {
            WebUtil.redirect(request, response, "/admin/PostServlet", "loi", "File tải lên tối đa 5MB!");
            return;
        }

        // 2. gom du lieu form vao Post
        User user = (User) request.getAttribute("currentUser");
        Post post = new Post();
        post.setId(WebUtil.toInt(request.getParameter("id")));          // input hidden, 0 = them moi
        post.setTitle(WebUtil.trim(request.getParameter("title")));
        post.setContent(WebUtil.trim(request.getParameter("content")));
        post.setCategory(WebUtil.trim(request.getParameter("category")));
        post.setPublished("on".equals(request.getParameter("published")));   // checkbox
        post.setAuthorId(user.getId());                                // chi dung khi them moi
        String fileName = UploadUtil.getFileName(part);                  // "" = khong chon file moi

        // 3. kiem tra truoc -> dung moi luu file -> roi moi ghi CSDL
        String loi = postBO.checkPost(post, fileName);
        if (loi == null && !fileName.isEmpty()) {
            String newName = UploadUtil.save(part, getServletContext().getRealPath("/uploads/forms"));
            if (newName == null) loi = "Lưu file thất bại, vui lòng thử lại!";
            else post.setFileUrl("uploads/forms/" + newName);
        }
        if (loi == null) loi = postBO.savePost(post);

        if (loi != null) {
            // loi: quay lai form, giu nguyen du lieu da nhap (file phai chon lai)
            request.setAttribute("thongbao", loi);
            request.setAttribute("post", post);
            request.getRequestDispatcher("/admin/post-form.jsp").forward(request, response);
            return;
        }
        WebUtil.redirect(request, response, "/admin/PostServlet", "ok",
                post.getId() == 0 ? "Đã thêm bài: " + post.getTitle() : "Đã cập nhật bài: " + post.getTitle());
    }
}
