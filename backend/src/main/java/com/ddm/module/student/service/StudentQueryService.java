package com.ddm.module.student.service;

import com.ddm.common.exception.BusinessException;
import com.ddm.module.student.dto.StudentQueryRequest;
import com.ddm.module.student.dto.StudentQueryResponse;
import com.ddm.module.student.dto.StudentQueryResult;
import com.ddm.module.student.dto.StudentScoreResponse;
import com.ddm.module.student.entity.MaskingRule;
import com.ddm.module.student.entity.StudentInfo;
import com.ddm.module.student.entity.StudentScore;
import com.ddm.module.student.mapper.StudentMapper;
import com.ddm.module.student.masking.StudentMaskingEngine;
import com.ddm.module.user.entity.SysUser;
import com.ddm.module.user.mapper.UserMapper;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
public class StudentQueryService {

    private static final List<String> STUDENT_COLUMNS = List.of(
            "student_no", "name", "gender", "phone", "email", "id_card", "address",
            "birth_date", "college", "major", "grade", "class_name", "gpa",
            "family_income", "bank_card"
    );

    private final StudentMapper studentMapper;
    private final UserMapper userMapper;
    private final StudentMaskingEngine maskingEngine;
    private final ObjectMapper objectMapper;

    public StudentQueryService(StudentMapper studentMapper,
                               UserMapper userMapper,
                               StudentMaskingEngine maskingEngine,
                               ObjectMapper objectMapper) {
        this.studentMapper = studentMapper;
        this.userMapper = userMapper;
        this.maskingEngine = maskingEngine;
        this.objectMapper = objectMapper;
    }

    public StudentQueryResult query(StudentQueryRequest request, HttpServletRequest servletRequest) {
        SysUser currentUser = currentUser();
        List<String> roles = userMapper.findRoleCodesByUserId(currentUser.getId());
        int pageNum = normalizePageNum(request.pageNum());
        int pageSize = normalizePageSize(request.pageSize());
        int offset = (pageNum - 1) * pageSize;

        List<StudentInfo> students = studentMapper.queryStudents(request, pageSize, offset);
        int total = studentMapper.countStudents(request);
        Map<Long, List<StudentScore>> scoreMap = loadScores(students);

        List<MaskingRule> rules = shouldBypassMasking(roles)
                ? List.of()
                : studentMapper.findMaskingRulesByRoles(roles);
        Map<String, MaskingRule> ruleMap = chooseRulesByRolePriority(rules, roles);

        List<StudentQueryResponse> records = students.stream()
                .map(student -> toResponse(student, scoreMap.getOrDefault(student.getId(), List.of()), ruleMap))
                .toList();

        writeAccessLog(currentUser, roles, request, ruleMap, records.size(), servletRequest);

        return new StudentQueryResult(
                records,
                total,
                pageNum,
                pageSize,
                currentUser.getUsername(),
                roles,
                dataView(roles, ruleMap)
        );
    }

    private SysUser currentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || authentication.getName() == null) {
            throw new BusinessException(401, "登录状态无效");
        }
        return userMapper.findByUsername(authentication.getName())
                .orElseThrow(() -> new BusinessException(401, "登录用户不存在"));
    }

    private Map<Long, List<StudentScore>> loadScores(List<StudentInfo> students) {
        List<Long> ids = students.stream().map(StudentInfo::getId).toList();
        if (ids.isEmpty()) {
            return Map.of();
        }
        return studentMapper.findScoresByStudentIds(ids).stream()
                .collect(Collectors.groupingBy(StudentScore::getStudentId));
    }

    private Map<String, MaskingRule> chooseRulesByRolePriority(List<MaskingRule> rules, List<String> roles) {
        Map<String, MaskingRule> result = new LinkedHashMap<>();
        for (String role : roles) {
            rules.stream()
                    .filter(rule -> Objects.equals(role, rule.getRoleCode()))
                    .sorted(Comparator.comparing(MaskingRule::getSensitiveFieldId))
                    .forEach(rule -> result.putIfAbsent(maskingEngine.key(rule.getTableName(), rule.getColumnName()), rule));
        }
        return result;
    }

    private StudentQueryResponse toResponse(StudentInfo student,
                                            List<StudentScore> scores,
                                            Map<String, MaskingRule> ruleMap) {
        Map<String, String> maskingTypes = new LinkedHashMap<>();
        List<StudentScoreResponse> scoreResponses = scores.stream()
                .map(score -> new StudentScoreResponse(
                        score.getId(),
                        score.getCourseName(),
                        mask("student_score", "score", score.getScore(), ruleMap, maskingTypes),
                        score.getSemester()
                ))
                .toList();

        return new StudentQueryResponse(
                student.getId(),
                student.getStudentNo(),
                mask("student_info", "name", student.getName(), ruleMap, maskingTypes),
                student.getGender(),
                mask("student_info", "phone", student.getPhone(), ruleMap, maskingTypes),
                mask("student_info", "email", student.getEmail(), ruleMap, maskingTypes),
                mask("student_info", "id_card", student.getIdCard(), ruleMap, maskingTypes),
                mask("student_info", "address", student.getAddress(), ruleMap, maskingTypes),
                mask("student_info", "birth_date", student.getBirthDate(), ruleMap, maskingTypes),
                student.getCollege(),
                student.getMajor(),
                student.getGrade(),
                student.getClassName(),
                student.getGpa(),
                mask("student_info", "family_income", student.getFamilyIncome(), ruleMap, maskingTypes),
                mask("student_info", "bank_card", student.getBankCard(), ruleMap, maskingTypes),
                scoreResponses,
                maskingTypes
        );
    }

    private Object mask(String tableName,
                        String columnName,
                        Object value,
                        Map<String, MaskingRule> ruleMap,
                        Map<String, String> maskingTypes) {
        String key = maskingEngine.key(tableName, columnName);
        MaskingRule rule = ruleMap.get(key);
        if (rule == null) {
            maskingTypes.put(key, "NO_MASK");
            return value;
        }
        maskingTypes.put(key, rule.getMaskingType());
        return maskingEngine.apply(value, rule);
    }

    private void writeAccessLog(SysUser user,
                                List<String> roles,
                                StudentQueryRequest request,
                                Map<String, MaskingRule> ruleMap,
                                int resultCount,
                                HttpServletRequest servletRequest) {
        try {
            studentMapper.insertAccessLog(
                    user.getId(),
                    user.getUsername(),
                    roles.isEmpty() ? null : roles.get(0),
                    toJson(request),
                    String.join(",", STUDENT_COLUMNS),
                    ruleMap.keySet().stream().sorted().collect(Collectors.joining(",")),
                    ruleMap.isEmpty() ? 0 : 1,
                    toJson(ruleMap.values().stream()
                            .map(rule -> Map.of(
                                    "field", rule.getTableName() + "." + rule.getColumnName(),
                                    "role", rule.getRoleCode(),
                                    "maskingType", rule.getMaskingType()
                            ))
                            .toList()),
                    resultCount,
                    clientIp(servletRequest)
            );
        } catch (RuntimeException ex) {
            throw ex;
        }
    }

    private String toJson(Object value) {
        try {
            return objectMapper.writeValueAsString(value);
        } catch (JsonProcessingException ex) {
            return "{}";
        }
    }

    private boolean shouldBypassMasking(List<String> roles) {
        return roles.contains("SUPER_ADMIN") || roles.contains("ADMIN");
    }

    private String dataView(List<String> roles, Map<String, MaskingRule> ruleMap) {
        if (shouldBypassMasking(roles) || ruleMap.isEmpty()) {
            return "原始数据视图";
        }
        if (roles.contains("TEACHER")) {
            return "教师轻度脱敏视图";
        }
        if (roles.contains("ANALYST")) {
            return "分析员泛化视图";
        }
        if (roles.contains("NORMAL")) {
            return "普通用户高度脱敏视图";
        }
        return "动态脱敏视图";
    }

    private int normalizePageNum(Integer pageNum) {
        return pageNum == null || pageNum < 1 ? 1 : pageNum;
    }

    private int normalizePageSize(Integer pageSize) {
        if (pageSize == null || pageSize < 1) {
            return 10;
        }
        return Math.min(pageSize, 100);
    }

    private String clientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
