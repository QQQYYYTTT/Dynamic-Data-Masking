<script setup lang="ts">
const rows = [
  { tableName: 'student_info', fieldName: 'phone', level: '高', type: '手机号', defaultMasking: 'KEEP_PREFIX_SUFFIX' },
  { tableName: 'student_info', fieldName: 'id_card', level: '高', type: '身份证号', defaultMasking: 'FULL_MASK' },
  { tableName: 'student_score', fieldName: 'score', level: '中', type: '成绩', defaultMasking: 'GENERALIZATION' }
]
</script>

<template>
  <div class="page">
    <div class="page-header">
      <div>
        <h1 class="page-title">敏感字段管理</h1>
        <p class="page-subtitle">维护表字段敏感等级、字段类型和默认脱敏方式。</p>
      </div>
      <el-button type="primary">扫描敏感字段</el-button>
    </div>

    <section class="panel">
      <el-table :data="rows" border>
        <el-table-column prop="tableName" label="表名" width="150" />
        <el-table-column prop="fieldName" label="字段名" width="140" />
        <el-table-column prop="type" label="字段类型" width="120" />
        <el-table-column prop="level" label="敏感等级" width="100" />
        <el-table-column prop="defaultMasking" label="默认脱敏方式" />
      </el-table>
    </section>
  </div>
</template>
