package com.ddm.module.student.masking;

import com.ddm.module.student.entity.MaskingRule;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.BiFunction;

@Component
public class StudentMaskingEngine {

    private final ObjectMapper objectMapper;
    private final Map<String, MaskingStrategy> strategies;

    public StudentMaskingEngine(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        this.strategies = buildStrategies();
    }

    public Object apply(Object value, MaskingRule rule) {
        if (rule == null || value == null) {
            return value;
        }
        MaskingStrategy strategy = strategies.getOrDefault(rule.getMaskingType(), strategies.get("FULL_MASK"));
        return strategy.apply(value, parseParams(rule.getParams()));
    }

    public Map<String, MaskingRule> toRuleMap(List<MaskingRule> rules) {
        Map<String, MaskingRule> ruleMap = new HashMap<>();
        for (MaskingRule rule : rules) {
            ruleMap.putIfAbsent(key(rule.getTableName(), rule.getColumnName()), rule);
        }
        return ruleMap;
    }

    public String key(String tableName, String columnName) {
        return tableName + "." + columnName;
    }

    private Map<String, Object> parseParams(String json) {
        if (json == null || json.isBlank()) {
            return Map.of();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<>() {});
        } catch (Exception ignored) {
            return Map.of();
        }
    }

    private Map<String, MaskingStrategy> buildStrategies() {
        Map<String, MaskingStrategy> map = new HashMap<>();
        register(map, "NO_MASK", (value, params) -> value);
        register(map, "FULL_MASK", (value, params) -> "*".repeat(Math.max(1, Objects.toString(value, "").length())));
        register(map, "KEEP_PREFIX", (value, params) -> keepPrefix(value, intParam(params, "prefix", 1)));
        register(map, "KEEP_SUFFIX", (value, params) -> keepSuffix(value, intParam(params, "suffix", 4)));
        register(map, "KEEP_PREFIX_SUFFIX", (value, params) -> keepPrefixSuffix(
                value,
                intParam(params, "prefix", 3),
                intParam(params, "suffix", 4)
        ));
        register(map, "EMAIL_MASK", this::emailMask);
        register(map, "ADDRESS_LEVEL", this::addressLevel);
        register(map, "GENERALIZATION", this::generalize);
        register(map, "KEEP_YEAR", this::keepYear);
        return map;
    }

    private void register(Map<String, MaskingStrategy> map, String type, BiFunction<Object, Map<String, Object>, Object> fn) {
        map.put(type, new MaskingStrategy() {
            @Override
            public String type() {
                return type;
            }

            @Override
            public Object apply(Object value, Map<String, Object> params) {
                return fn.apply(value, params);
            }
        });
    }

    private static Object keepPrefix(Object value, int prefix) {
        String text = Objects.toString(value, "");
        int keep = Math.min(Math.max(prefix, 0), text.length());
        return text.substring(0, keep) + "*".repeat(Math.max(1, text.length() - keep));
    }

    private static Object keepSuffix(Object value, int suffix) {
        String text = Objects.toString(value, "");
        int keep = Math.min(Math.max(suffix, 0), text.length());
        return "*".repeat(Math.max(1, text.length() - keep)) + text.substring(text.length() - keep);
    }

    private static Object keepPrefixSuffix(Object value, int prefix, int suffix) {
        String text = Objects.toString(value, "");
        int left = Math.min(Math.max(prefix, 0), text.length());
        int right = Math.min(Math.max(suffix, 0), text.length() - left);
        int hidden = Math.max(1, text.length() - left - right);
        return text.substring(0, left) + "*".repeat(hidden) + text.substring(text.length() - right);
    }

    private Object emailMask(Object value, Map<String, Object> params) {
        String text = Objects.toString(value, "");
        int at = text.indexOf('@');
        if (at <= 0) {
            return keepPrefix(value, 1);
        }
        String local = text.substring(0, at);
        String domain = text.substring(at);
        return local.charAt(0) + "*".repeat(Math.max(1, local.length() - 1)) + domain;
    }

    private Object addressLevel(Object value, Map<String, Object> params) {
        String text = Objects.toString(value, "");
        String level = Objects.toString(params.getOrDefault("level", "city"));
        if ("province".equalsIgnoreCase(level)) {
            return keepUntilAny(text, List.of("省", "自治区", "市"));
        }
        return keepUntilAny(text, List.of("市", "自治州", "地区", "盟"));
    }

    private static String keepUntilAny(String text, List<String> markers) {
        for (String marker : markers) {
            int index = text.indexOf(marker);
            if (index >= 0) {
                return text.substring(0, index + marker.length()) + "***";
            }
        }
        int keep = Math.min(6, text.length());
        return text.substring(0, keep) + "***";
    }

    private Object generalize(Object value, Map<String, Object> params) {
        Number number;
        if (value instanceof Number numericValue) {
            number = numericValue;
        } else {
            try {
                number = new BigDecimal(Objects.toString(value, "0"));
            } catch (NumberFormatException ex) {
                return "区间化";
            }
        }
        int step = Math.max(1, intParam(params, "step", 10));
        BigDecimal decimal = new BigDecimal(number.toString());
        BigDecimal stepValue = BigDecimal.valueOf(step);
        BigDecimal lower = decimal.divideToIntegralValue(stepValue).multiply(stepValue);
        BigDecimal upper = lower.add(stepValue);
        return strip(lower) + "-" + strip(upper);
    }

    private Object keepYear(Object value, Map<String, Object> params) {
        if (value instanceof LocalDate date) {
            return String.valueOf(date.getYear());
        }
        String text = Objects.toString(value, "");
        return text.length() >= 4 ? text.substring(0, 4) : text;
    }

    private static int intParam(Map<String, Object> params, String key, int defaultValue) {
        Object value = params.get(key);
        if (value instanceof Number number) {
            return number.intValue();
        }
        if (value != null) {
            try {
                return Integer.parseInt(value.toString());
            } catch (NumberFormatException ignored) {
                return defaultValue;
            }
        }
        return defaultValue;
    }

    private static String strip(BigDecimal value) {
        return value.stripTrailingZeros().toPlainString();
    }
}
