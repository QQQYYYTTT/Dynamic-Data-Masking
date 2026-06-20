package com.ddm;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@MapperScan("com.ddm.module")
@SpringBootApplication
public class DynamicDataMaskingApplication {

    public static void main(String[] args) {
        SpringApplication.run(DynamicDataMaskingApplication.class, args);
    }
}
