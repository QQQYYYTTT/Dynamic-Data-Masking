package com.ddm.module.auth.service;

import com.ddm.common.exception.BusinessException;
import com.ddm.common.security.JwtTokenProvider;
import com.ddm.module.auth.dto.AuthUserResponse;
import com.ddm.module.auth.dto.LoginRequest;
import com.ddm.module.auth.dto.LoginResponse;
import com.ddm.module.user.entity.SysUser;
import com.ddm.module.user.mapper.UserMapper;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
public class AuthService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    public AuthService(UserMapper userMapper, PasswordEncoder passwordEncoder, JwtTokenProvider jwtTokenProvider) {
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    public LoginResponse login(LoginRequest request) {
        SysUser user = userMapper.findByUsername(request.username())
                .orElseThrow(() -> new BusinessException(401, "用户名或密码错误"));

        if (user.getStatus() == null || user.getStatus() != 1) {
            throw new BusinessException(403, "账号已被禁用");
        }

        if (!passwordEncoder.matches(request.password(), user.getPassword())) {
            throw new BusinessException(401, "用户名或密码错误");
        }

        List<String> roles = userMapper.findRoleCodesByUserId(user.getId());
        List<String> permissions = userMapper.findPermissionCodesByUserId(user.getId());
        String token = jwtTokenProvider.createToken(user.getId(), user.getUsername());

        return new LoginResponse(
                token,
                user.getId(),
                user.getUsername(),
                user.getRealName(),
                roles,
                permissions
        );
    }

    public AuthUserResponse currentUser(String authorizationHeader) {
        String token = resolveToken(authorizationHeader);
        Long userId = jwtTokenProvider.getUserId(token);
        SysUser user = userMapper.findById(userId)
                .orElseThrow(() -> new BusinessException(401, "登录状态无效"));

        if (user.getStatus() == null || user.getStatus() != 1) {
            throw new BusinessException(403, "账号已被禁用");
        }

        return buildUserResponse(user);
    }

    private AuthUserResponse buildUserResponse(SysUser user) {
        return new AuthUserResponse(
                user.getId(),
                user.getUsername(),
                user.getRealName(),
                userMapper.findRoleCodesByUserId(user.getId()),
                userMapper.findPermissionCodesByUserId(user.getId())
        );
    }

    private String resolveToken(String authorizationHeader) {
        if (!StringUtils.hasText(authorizationHeader) || !authorizationHeader.startsWith("Bearer ")) {
            throw new BusinessException(401, "缺少登录令牌");
        }
        return authorizationHeader.substring("Bearer ".length());
    }
}
