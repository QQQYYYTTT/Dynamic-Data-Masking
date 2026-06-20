package com.ddm.module.auth.dto;

import java.util.List;

public record AuthUserResponse(
        Long userId,
        String username,
        String realName,
        List<String> roles,
        List<String> permissions
) {
}
