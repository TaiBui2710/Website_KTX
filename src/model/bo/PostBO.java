package model.bo;

import java.util.ArrayList;
import model.bean.Post;
import model.dao.PostDAO;

public class PostBO {
    PostDAO postDAO = new PostDAO();

    public ArrayList<Post> getPublishedPosts(String category) { return postDAO.getPublishedPosts(category); }
    public ArrayList<Post> getAllPosts() { return postDAO.getAllPosts(); }
    public Post getPostById(int id) { return postDAO.getPostById(id); }

    // guest xem chi tiet: bai nhap coi nhu khong ton tai
    public Post getPublishedPost(int id) {
        Post p = postDAO.getPostById(id);
        return (p != null && p.isPublished()) ? p : null;
    }

    public String savePost(Post p) {
        if (p.getTitle().isEmpty() || p.getTitle().length() > 200) return "Tiêu đề 1–200 ký tự!";
        if (p.getContent().isEmpty()) return "Vui lòng nhập nội dung!";
        if (!p.getCategory().equals("news") && !p.getCategory().equals("notice") && !p.getCategory().equals("rule"))
            return "Chuyên mục không hợp lệ!";
        if (p.getId() == 0) return postDAO.insertPost(p) ? null : "Thêm bài thất bại!";
        if (postDAO.getPostById(p.getId()) == null) return "Không tìm thấy bài viết!";
        return postDAO.updatePost(p) ? null : "Cập nhật bài thất bại!";
    }

    public String deletePost(int id) {
        if (postDAO.getPostById(id) == null) return "Không tìm thấy bài viết!";
        return postDAO.deletePost(id) ? null : "Xóa bài thất bại!";
    }
}