package com.agribridgef1.util;

import java.security.SecureRandom;
import java.security.spec.KeySpec;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class PasswordUtil {
   private static final int ITERATIONS = 65536;
   private static final int KEY_LENGTH = 256;
   private static final SecureRandom RANDOM = new SecureRandom();

   public PasswordUtil() {
   }

   public static String hashPassword(String password) {
      try {
         byte[] salt = new byte[16];
         RANDOM.nextBytes(salt);
         KeySpec spec = new PBEKeySpec(password.toCharArray(), salt, 65536, 256);
         SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
         byte[] hash = factory.generateSecret(spec).getEncoded();
         String var10000 = Base64.getEncoder().encodeToString(salt);
         return var10000 + ":" + Base64.getEncoder().encodeToString(hash);
      } catch (Exception e) {
         throw new RuntimeException("Error hashing password", e);
      }
   }

   public static boolean verifyPassword(String password, String storedPassword) {
      try {
         String[] parts = storedPassword.split(":");
         byte[] salt = Base64.getDecoder().decode(parts[0]);
         byte[] storedHash = Base64.getDecoder().decode(parts[1]);
         KeySpec spec = new PBEKeySpec(password.toCharArray(), salt, 65536, 256);
         SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
         byte[] testHash = factory.generateSecret(spec).getEncoded();
         if (testHash.length != storedHash.length) {
            return false;
         } else {
            int diff = 0;

            for(int i = 0; i < testHash.length; ++i) {
               diff |= testHash[i] ^ storedHash[i];
            }

            return diff == 0;
         }
      } catch (Exception var10) {
         return false;
      }
   }
}
