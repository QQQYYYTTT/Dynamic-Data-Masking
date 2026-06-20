<script setup lang="ts">
const rows = [
  { role: 'TEACHER', field: 'student_info.phone', strategy: '保留前三后四', priority: 20 },
  { role: 'ANALYST', field: 'student_score.score', strategy: '区间泛化', priority: 30 },
  { role: 'NORMAL', field: 'student_info.id_card', strategy: '全掩码', priority: 90 }
]
</script>

<template>
  <div class="page">
    <div class="page-header">
      <div>
        <h1 class="page-title">脱敏规则管理</h1>
        <p class="page-subtitle">配置角色、敏感字段和脱敏策略之间的动态绑定关系。</p>
      </div>
      <el-button type="primary">新增规则</el-button>
    </div>

    <section class="panel">
      <el-table :data="rows" border>
        <el-table-column prop="role" label="角色" width="140" />
        <el-table-column prop="field" label="字段" min-width="220" />
        <el-table-column prop="strategy" label="策略" width="160" />
        <el-table-column prop="priority" label="优先级" width="100" />
        <el-table-column label="操作" width="150">
          <el-button link type="primary">编辑</el-button>
          <el-button link type="danger">停用</el-button>
        </el-table-column>
      </el-table>
    </section>
  </div>
</template>
