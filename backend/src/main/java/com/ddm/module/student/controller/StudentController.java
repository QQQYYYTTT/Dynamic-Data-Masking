package com.ddm.module.student.controller;

import com.ddm.common.response.ApiResponse;
import com.ddm.module.student.dto.StudentQueryRequest;
import com.ddm.module.student.dto.StudentQueryResult;
import com.ddm.module.student.service.StudentQueryService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/student")
public class StudentController {

    private final StudentQueryService studentQueryService;

    public StudentController(StudentQueryService studentQueryService) {
        this.studentQueryService = studentQueryService;
    }

    @PostMapping("/query")
    public ApiResponse<StudentQueryResult> query(@RequestBody StudentQueryRequest request,
                                                 HttpServletRequest servletRequest) {
        return ApiResponse.success(studentQueryService.query(request, servletRequest));
    }
}
