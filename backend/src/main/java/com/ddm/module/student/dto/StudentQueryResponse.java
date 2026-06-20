package com.ddm.module.student.dto;

import java.util.List;
import java.util.Map;

public record StudentQueryResponse(
        Long id,
        String studentNo,
        Object name,
        String gender,
        Object phone,
        Object email,
        Object idCard,
        Object address,
        Object birthDate,
        String college,
        String major,
        String grade,
        String className,
        Object gpa,
        Object familyIncome,
        Object bankCard,
        List<StudentScoreResponse> scores,
        Map<String, String> maskingTypes
) {
}
