package com.ddm.module.student.dto;

public record StudentQueryRequest(
        String studentNo,
        String name,
        String college,
        String major,
        String grade,
        Integer pageNum,
        Integer pageSize
) {
}
