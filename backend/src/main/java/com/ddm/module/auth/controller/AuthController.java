package com.ddm.module.auth.controller;

import com.ddm.common.response.ApiResponse;
import com.ddm.module.auth.dto.AuthUserResponse;
import com.ddm.module.auth.dto.LoginRequest;
import com.ddm.module.auth.dto.LoginResponse;
import com.ddm.module.auth.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ApiResponse<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.success(authService.login(request));
    }

    @GetMapping("/me")
    public ApiResponse<AuthUserResponse> currentUser(@RequestHeader("Authorization") String authorizationHeader) {
        return ApiResponse.success(authService.currentUser(authorizationHeader));
    }

    @PostMapping("/logout")
    public ApiResponse<Map<String, Boolean>> logout() {
        return ApiResponse.success(Map.of("loggedOut", true));
    }
}
