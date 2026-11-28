package model.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import model.bean.Post;

public class PostDAO {
    private static final String SELECT_POST =
        "select p.*, u.full_name as author_name from posts p join users u on u.id = p.author_id ";

    private Post mapPost(ResultSet rs) throws SQLException {
        Post p = new Post();
        p.setId(rs.getInt("id"));
        p.setTitle(rs.getString("title"));
        p.setContent(rs.getString("content"));
        p.setCategory(rs.getString("category"));
        p.setFileUrl(rs.getString("file_url"));
        p.setPublished(rs.getBoolean("is_published"));
        p.setAuthorId(rs.getInt("author_id"));
        p.setCreatedAt(DBConnect.getDateTime(rs, "created_at"));
        p.setAuthorName(rs.getString("author_name"));
        return p;
    }

    private ArrayList<Post> query(String sql, Object... params) {
        ArrayList<Post> result = new ArrayList<Post>();
        try (Connection conn = DBConnect.getConnection()) {
            PreparedStatement pst = conn.prepareStatement(sql);
            DBConnect.setParams(pst, params);
            ResultSet rs = pst.executeQuery();
            while (rs.next()) result.add(mapPost(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // guest: chi bai da xuat ban
    // category rong = tat ca tin tuc (TRU bieu mau), category = 'form' = trang bieu mau
    public ArrayList<Post> getPublishedPosts(String category) {
        return query(SELECT_POST + "where p.is_published = true"
                   + " and ((?='' and p.category<>'form') or p.category=?)"
                   + " order by p.created_at desc", category, category);
    }

    // admin: tat ca, ke ca ban nhap va bieu mau
    public ArrayList<Post> getAllPosts() {
        return query(SELECT_POST + "order by p.created_at desc");
    }

    public Post getPostById(int id) {
        ArrayList<Post> list = query(SELECT_POST + "where p.id=?", id);
        return list.isEmpty() ? null : list.get(0);
    }

    public boolean insertPost(Post p) {
        return DBConnect.executeUpdate("insert into posts (title, content, category, file_url, is_published, author_id)"
            + " values (?, ?, ?, ?, ?, ?)", p.getTitle(), p.getContent(), p.getCategory(), p.getFileUrl(),
            p.isPublished(), p.getAuthorId()) == 1;
    }

    public boolean updatePost(Post p) {
        return DBConnect.executeUpdate("update posts set title=?, content=?, category=?, file_url=?, is_published=?"
            + " where id=?", p.getTitle(), p.getContent(), p.getCategory(), p.getFileUrl(),
            p.isPublished(), p.getId()) == 1;
    }

    public boolean deletePost(int id) {
        return DBConnect.executeUpdate("delete from posts where id=?", id) == 1;
    }

    public int countByAuthor(int userId) {
        return DBConnect.count("select count(*) from posts where author_id=?", userId);
    }
}
