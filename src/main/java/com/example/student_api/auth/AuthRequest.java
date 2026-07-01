package com.example.student_api.auth;

// register aur login dono is body ko lete hain: { "username": "...", "password": "..." }
public record AuthRequest(String username, String password) {
}
