package com.tickethelper.dao;

import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public final class OracleConnectionCheck {
    private OracleConnectionCheck() {
    }

    public static void main(String[] args) {
        String url = requiredEnvironment("TICKETHELPER_DB_URL");
        Properties connectionProperties = new Properties();
        connectionProperties.setProperty("user", requiredEnvironment("TICKETHELPER_DB_USER"));
        connectionProperties.setProperty("password", requiredEnvironment("TICKETHELPER_DB_PASSWORD"));
        connectionProperties.setProperty("oracle.net.CONNECT_TIMEOUT", "5000");
        connectionProperties.setProperty("oracle.jdbc.ReadTimeout", "5000");

        try (var connection = DriverManager.getConnection(url, connectionProperties);
             var statement = connection.prepareStatement("SELECT 1 FROM DUAL");
             var rows = statement.executeQuery()) {
            if (!rows.next() || rows.getInt(1) != 1) {
                throw new IllegalStateException("Oracle 연결 확인 쿼리 결과가 예상과 다릅니다.");
            }
            System.out.println("Oracle JDBC 연결 성공 (SELECT 1 FROM DUAL)");
        } catch (SQLException e) {
            throw new IllegalStateException("Oracle JDBC 연결 확인 실패 (오류 코드 " + e.getErrorCode() + ")");
        }
    }

    private static String requiredEnvironment(String name) {
        String value = System.getenv(name);
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(name + " 환경변수를 설정하세요.");
        }
        return value;
    }
}
