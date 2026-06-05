package com.example.demo.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import java.util.HashMap;
import java.util.Map;
import java.sql.Connection;

@RestController
@RequestMapping("/api")
public class DemoController {

    @Value("${spring.application.name:k8s-demo-backend}")
    private String appName;

    @Value("${app.version:1.0.0}")
    private String version;

    @Autowired
    private DataSource dataSource;

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "ok");
        response.put("app", appName);
        response.put("version", version);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/health/db")
    public ResponseEntity<Map<String, Object>> healthDb() {
        Map<String, Object> response = new HashMap<>();
        try (Connection conn = dataSource.getConnection()) {
            response.put("status", "ok");
            response.put("message", "Database connected successfully");
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
        return ResponseEntity.ok(response);
    }

    @GetMapping("/health/redis")
    public ResponseEntity<Map<String, Object>> healthRedis() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "ok");
        response.put("message", "Redis is configured");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/test")
    public ResponseEntity<Map<String, Object>> test() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "API is working!");
        response.put("timestamp", System.currentTimeMillis());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/test/db")
    public ResponseEntity<Map<String, Object>> testDb() {
        Map<String, Object> response = new HashMap<>();
        try (Connection conn = dataSource.getConnection()) {
            response.put("success", true);
            response.put("database", conn.getCatalog());
            response.put("url", conn.getMetaData().getURL());
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", e.getMessage());
        }
        return ResponseEntity.ok(response);
    }

    @GetMapping("/test/redis")
    public ResponseEntity<Map<String, Object>> testRedis() {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Redis connection test");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/pod-info")
    public ResponseEntity<Map<String, Object>> podInfo() {
        Map<String, Object> response = new HashMap<>();

        response.put("podName", System.getenv().getOrDefault("POD_NAME", "unknown"));
        response.put("podIp", System.getenv().getOrDefault("POD_IP", "unknown"));
        response.put("namespace", System.getenv().getOrDefault("POD_NAMESPACE", "default"));
        response.put("nodeName", System.getenv().getOrDefault("NODE_NAME", "unknown"));

        return ResponseEntity.ok(response);
    }
}
