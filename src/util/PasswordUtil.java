package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

public class PasswordUtil {
    // bam SHA-256, tra ve chuoi hex 64 ky tu (giong ham SHA2(..., 256) cua MySQL)
    public static String hash(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    // so mat khau nguoi dung go voi chuoi da bam trong CSDL
    public static boolean check(String password, String hashed) {
        if (password == null || hashed == null) return false;
        return hashed.equals(hash(password));
    }
}