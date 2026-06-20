package com.ddm.module.student.dto;

import java.util.List;

public record StudentQueryResult(
        List<StudentQueryResponse> records,
        int total,
        int pageNum,
        int pageSize,
        String username,
        List<String> roles,
        String dataView
) {
}
