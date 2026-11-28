package util;

import java.io.File;
import jakarta.servlet.http.Part;

public class UploadUtil {
    // ten file nguoi dung chon (khong kem thu muc); khong chon file -> ""
    public static String getFileName(Part part) {
        if (part == null || part.getSize() == 0) return "";
        String name = part.getSubmittedFileName();
        if (name == null) return "";
        return new File(name).getName();          // trinh duyet cu gui ca duong dan C:\...\ten.pdf
    }

    // file co duoi nam trong danh sach khong (khong phan biet hoa thuong)
    public static boolean hasExtension(String fileName, String... extensions) {
        String lower = fileName.toLowerCase();
        for (String ext : extensions) {
            if (lower.endsWith(ext)) return true;
        }
        return false;
    }

    // luu file vao thu muc folder (duong dan that tren o dia) voi ten moi = so mili-giay + duoi file
    // (doi ten de 2 file trung ten khong de len nhau, va ten file khong chua ky tu la)
    // tra ve ten file moi, loi -> null
    public static String save(Part part, String folder) {
        try {
            String name = getFileName(part);
            String ext = name.substring(name.lastIndexOf('.')).toLowerCase();
            String newName = System.currentTimeMillis() + ext;
            File dir = new File(folder);
            if (!dir.exists()) dir.mkdirs();
            part.write(new File(dir, newName).getAbsolutePath());
            return newName;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
