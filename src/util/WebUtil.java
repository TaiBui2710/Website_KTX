package util;

import java.io.IOException;
import java.net.URLEncoder;
import java.time.LocalDate;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class WebUtil {
    // chuoi -> so, thieu hoac khong phai so thi tra ve 0 (giong UpdateServlet cua thay)
    public static int toInt(String s) {
        try { return Integer.parseInt(s.trim()); } catch (Exception e) { return 0; }
    }

    // gia tien: sai thi tra ve -1 de BO bao loi "gia khong hop le"
    public static long toLong(String s) {
        try { return Long.parseLong(s.trim()); } catch (Exception e) { return -1; }
    }

    // <input type="date"> gui len dang yyyy-MM-dd; sai/trong -> null
    public static LocalDate toDate(String s) {
        try { return LocalDate.parse(s.trim()); } catch (Exception e) { return null; }
    }

    // null -> "" va bo khoang trang 2 dau
    public static String trim(String s) {
        return s == null ? "" : s.trim();
    }

    // redirect ve 1 trang trong web, kem thong bao (loai = ok: chu xanh, loi: chu do)
    // path bat dau bang "/", vd "/admin/RoomServlet"
    public static void redirect(HttpServletRequest request, HttpServletResponse response,
                                String path, String loai, String thongbao) throws IOException {
        String url = request.getContextPath() + path;
        if (thongbao != null) {
            url += (path.contains("?") ? "&" : "?") + "loai=" + loai
                 + "&thongbao=" + URLEncoder.encode(thongbao, "UTF-8");
        }
        response.sendRedirect(url);
    }
}