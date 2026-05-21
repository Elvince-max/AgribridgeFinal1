package com.agribridgef1.service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Base64;
import java.util.Date;
import org.json.JSONObject;

public class MpesaService {
   public MpesaService() {
   }

   public String generateAccessToken() throws IOException {
      String credentials = "TkkaxTUJofVFeGACp4LSGPL07RPXGcjxjww5hb2iM3XtNY1y:R9yHBU9oA36yVcp6e9A3p6LB535RRRH9Y74ZKfY8AVUqyWOdYE3BBljNWx8UABeT";
      String encodedCredentials = Base64.getEncoder().encodeToString(credentials.getBytes());
      URL url = new URL("https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials");
      HttpURLConnection conn = (HttpURLConnection)url.openConnection();
      conn.setRequestMethod("GET");
      conn.setRequestProperty("Authorization", "Basic " + encodedCredentials);
      int responseCode = conn.getResponseCode();
      String response = this.readResponse(conn, responseCode);
      if (responseCode == 200) {
         JSONObject json = new JSONObject(response);
         return json.getString("access_token");
      } else {
         throw new IOException("Failed to generate M-Pesa access token: " + response);
      }
   }

   public String stkPush(String phoneNumber, int amount, int orderId) throws IOException {
      String accessToken = this.generateAccessToken();
      String timestamp = (new SimpleDateFormat("yyyyMMddHHmmss")).format(new Date());
      String passwordString = "174379bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919" + timestamp;
      String password = Base64.getEncoder().encodeToString(passwordString.getBytes());
      URL url = new URL("https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest");
      JSONObject payload = new JSONObject();
      payload.put("BusinessShortCode", "174379");
      payload.put("Password", password);
      payload.put("Timestamp", timestamp);
      payload.put("TransactionType", "CustomerPayBillOnline");
      payload.put("Amount", amount);
      payload.put("PartyA", phoneNumber);
      payload.put("PartyB", "174379");
      payload.put("PhoneNumber", phoneNumber);
      payload.put("CallBackURL", "https://remold-unwoven-deafness.ngrok-free.dev/mpesaCallback");
      payload.put("AccountReference", "AgribridgeF1-" + orderId);
      payload.put("TransactionDesc", "AgribridgeF1 Order Payment");
      HttpURLConnection conn = (HttpURLConnection)url.openConnection();
      conn.setRequestMethod("POST");
      conn.setRequestProperty("Authorization", "Bearer " + accessToken);
      conn.setRequestProperty("Content-Type", "application/json");
      conn.setDoOutput(true);
      OutputStream os = conn.getOutputStream();

      try {
         byte[] input = payload.toString().getBytes();
         os.write(input, 0, input.length);
      } catch (Throwable var15) {
         if (os != null) {
            try {
               os.close();
            } catch (Throwable var14) {
               var15.addSuppressed(var14);
            }
         }

         throw var15;
      }

      if (os != null) {
         os.close();
      }

      int responseCode = conn.getResponseCode();
      String response = this.readResponse(conn, responseCode);
      if (responseCode == 200) {
         return response;
      } else {
         throw new IOException("STK Push failed: " + response);
      }
   }

   private String readResponse(HttpURLConnection conn, int responseCode) throws IOException {
      InputStream stream;
      if (responseCode >= 200 && responseCode < 300) {
         stream = conn.getInputStream();
      } else {
         stream = conn.getErrorStream();
      }

      if (stream == null) {
         return "";
      } else {
         BufferedReader br = new BufferedReader(new InputStreamReader(stream));

         String var7;
         try {
            StringBuilder response = new StringBuilder();

            String line;
            while((line = br.readLine()) != null) {
               response.append(line.trim());
            }

            var7 = response.toString();
         } catch (Throwable var9) {
            try {
               br.close();
            } catch (Throwable var8) {
               var9.addSuppressed(var8);
            }

            throw var9;
         }

         br.close();
         return var7;
      }
   }
}
