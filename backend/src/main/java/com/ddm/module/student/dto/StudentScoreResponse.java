package com.ddm.module.student.dto;

public record StudentScoreResponse(
        Long id,
        String courseName,
        Object score,
        String semester
) {
}
