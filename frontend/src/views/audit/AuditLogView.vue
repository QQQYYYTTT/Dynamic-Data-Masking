<script setup lang="ts">
const rows = [
  { user: 'teacher01', action: 'QUERY', object: 'student_info', result: 'MASKED', time: '2026-06-19 21:00:00' },
  { user: 'admin', action: 'UPDATE_POLICY', object: 'masking_policy', result: 'SUCCESS', time: '2026-06-19 21:05:00' }
]
</script>

<template>
  <div class="page">
    <div class="page-header">
      <div>
        <h1 class="page-title">安全审计日志</h1>
        <p class="page-subtitle">记录查询、导出、策略变更和异常访问行为。</p>
      </div>
      <el-button>导出审计报告</el-button>
    </div>

    <section class="panel">
      <el-table :data="rows" border>
        <el-table-column prop="user" label="用户" width="130" />
        <el-table-column prop="action" label="行为" width="160" />
        <el-table-column prop="object" label="对象" width="180" />
        <el-table-column prop="result" label="结果" width="120" />
        <el-table-column prop="time" label="时间" />
      </el-table>
    </section>
  </div>
</template>
