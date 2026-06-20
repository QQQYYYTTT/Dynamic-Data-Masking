package com.ddm.module.student.masking;

import java.util.Map;

public interface MaskingStrategy {

    String type();

    Object apply(Object value, Map<String, Object> params);
}
