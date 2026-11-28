package model.bo;

import java.util.ArrayList;
import model.bean.Post;
import model.dao.PostDAO;
import util.UploadUtil;

public class PostBO {
    // loai file bieu mau duoc phep tai len
    public static final String[] FORM_EXTENSIONS = {".pdf", ".doc", ".docx"};

    PostDAO postDAO = new PostDAO();

    public ArrayList<Post> getPublishedPosts(String category) { return postDAO.getPublishedPosts(category); }
    public ArrayList<Post> getPublishedForms() { return postDAO.getPublishedPosts("form"); }
    public ArrayList<Post> getAllPosts() { return postDAO.getAllPosts(); }
    public Post getPostById(int id) { return postDAO.getPostById(id); }

    // guest xem chi tiet: bai nhap coi nhu khong ton tai
    public Post getPublishedPost(int id) {
        Post p = postDAO.getPostById(id);
        return (p != null && p.isPublished()) ? p : null;
    }

    private boolean isCategory(String c) {
        return c.equals("news") || c.equals("notice") || c.equals("rule") || c.equals("form");
    }

    // kiem tra du lieu form TRUOC khi Servlet luu file len o dia (sai thi khong luu file thua)
    // newFileName = ten file admin vua chon, "" = khong chon file moi
    public String checkPost(Post p, String newFileName) {
        if (p.getTitle().isEmpty() || p.getTitle().length() > 200) return "Tiêu đề 1–200 ký tự!";
        if (p.getContent().isEmpty()) return "Vui lòng nhập nội dung!";
        if (!isCategory(p.getCategory())) return "Chuyên mục không hợp lệ!";
        if (!newFileName.isEmpty() && !UploadUtil.hasExtension(newFileName, FORM_EXTENSIONS))
            return "Chỉ nhận file .pdf, .doc, .docx!";
        if (p.getId() > 0) {
            Post old = postDAO.getPostById(p.getId());
            if (old == null) return "Không tìm thấy bài viết!";
            if (p.getFileUrl() == null) p.setFileUrl(old.getFileUrl());   // khong chon file moi -> giu file cu
        }
        boolean hasFile = !newFileName.isEmpty() || (p.getFileUrl() != null && !p.getFileUrl().isEmpty());
        if (p.getCategory().equals("form") && !hasFile) return "Biểu mẫu phải có file đính kèm!";
        return null;
    }

    // luu vao CSDL; file (neu co) da duoc Servlet luu va gan vao p.fileUrl
    public String savePost(Post p) {
        String loi = checkPost(p, "");
        if (loi != null) return loi;
        if (p.getId() == 0) return postDAO.insertPost(p) ? null : "Thêm bài thất bại!";
        return postDAO.updatePost(p) ? null : "Cập nhật bài thất bại!";
    }

    public String deletePost(int id) {
        if (postDAO.getPostById(id) == null) return "Không tìm thấy bài viết!";
        return postDAO.deletePost(id) ? null : "Xóa bài thất bại!";
    }
}
