package com.ddm.module.student.mapper;

import com.ddm.module.student.dto.StudentQueryRequest;
import com.ddm.module.student.entity.MaskingRule;
import com.ddm.module.student.entity.StudentInfo;
import com.ddm.module.student.entity.StudentScore;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface StudentMapper {

    @Select("""
            <script>
            SELECT id, student_no, name, gender, phone, email, id_card, address, birth_date,
                   college, major, grade, class_name, gpa, family_income, bank_card
            FROM student_info
            WHERE status = 1
            <if test="request.studentNo != null and request.studentNo != ''">
              AND student_no LIKE CONCAT('%', #{request.studentNo}, '%')
            </if>
            <if test="request.name != null and request.name != ''">
              AND name LIKE CONCAT('%', #{request.name}, '%')
            </if>
            <if test="request.college != null and request.college != ''">
              AND college LIKE CONCAT('%', #{request.college}, '%')
            </if>
            <if test="request.major != null and request.major != ''">
              AND major LIKE CONCAT('%', #{request.major}, '%')
            </if>
            <if test="request.grade != null and request.grade != ''">
              AND grade = #{request.grade}
            </if>
            ORDER BY student_no
            LIMIT #{limit} OFFSET #{offset}
            </script>
            """)
    List<StudentInfo> queryStudents(@Param("request") StudentQueryRequest request,
                                    @Param("limit") int limit,
                                    @Param("offset") int offset);

    @Select("""
            <script>
            SELECT COUNT(1)
            FROM student_info
            WHERE status = 1
            <if test="request.studentNo != null and request.studentNo != ''">
              AND student_no LIKE CONCAT('%', #{request.studentNo}, '%')
            </if>
            <if test="request.name != null and request.name != ''">
              AND name LIKE CONCAT('%', #{request.name}, '%')
            </if>
            <if test="request.college != null and request.college != ''">
              AND college LIKE CONCAT('%', #{request.college}, '%')
            </if>
            <if test="request.major != null and request.major != ''">
              AND major LIKE CONCAT('%', #{request.major}, '%')
            </if>
            <if test="request.grade != null and request.grade != ''">
              AND grade = #{request.grade}
            </if>
            </script>
            """)
    int countStudents(@Param("request") StudentQueryRequest request);

    @Select("""
            <script>
            SELECT id, student_id, course_name, score, semester
            FROM student_score
            WHERE student_id IN
            <foreach collection="studentIds" item="id" open="(" separator="," close=")">
              #{id}
            </foreach>
            ORDER BY student_id, semester, course_name
            </script>
            """)
    List<StudentScore> findScoresByStudentIds(@Param("studentIds") List<Long> studentIds);

    @Select("""
            <script>
            SELECT sf.id AS sensitive_field_id, sf.table_name, sf.column_name,
                   mp.masking_type, CAST(mp.params AS CHAR) AS params, mra.role_code
            FROM masking_rule_assignment mra
            JOIN masking_policy mp ON mp.id = mra.policy_id AND mp.status = 1
            JOIN sensitive_field sf ON sf.id = mra.sensitive_field_id AND sf.enabled = 1
            WHERE mra.enabled = 1
              AND sf.table_name IN ('student_info', 'student_score')
              AND mra.role_code IN
            <foreach collection="roles" item="role" open="(" separator="," close=")">
              #{role}
            </foreach>
            ORDER BY sf.id
            </script>
            """)
    List<MaskingRule> findMaskingRulesByRoles(@Param("roles") List<String> roles);

    @Insert("""
            INSERT INTO access_log (
                user_id, username, role_code, operation_type, sql_text, table_name,
                accessed_columns, sensitive_columns, masking_applied, masking_snapshot,
                result_count, client_ip
            ) VALUES (
                #{userId}, #{username}, #{roleCode}, 'QUERY', #{sqlText}, 'student_info',
                #{accessedColumns}, #{sensitiveColumns}, #{maskingApplied}, #{maskingSnapshot},
                #{resultCount}, #{clientIp}
            )
            """)
    void insertAccessLog(@Param("userId") Long userId,
                         @Param("username") String username,
                         @Param("roleCode") String roleCode,
                         @Param("sqlText") String sqlText,
                         @Param("accessedColumns") String accessedColumns,
                         @Param("sensitiveColumns") String sensitiveColumns,
                         @Param("maskingApplied") int maskingApplied,
                         @Param("maskingSnapshot") String maskingSnapshot,
                         @Param("resultCount") int resultCount,
                         @Param("clientIp") String clientIp);
}
