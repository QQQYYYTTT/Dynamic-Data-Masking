<script setup lang="ts">
const rows = [
  { code: 'MENU:DASHBOARD', type: 'MENU', name: '首页仪表盘' },
  { code: 'API:STUDENT_QUERY', type: 'API', name: '查询学生信息' },
  { code: 'DATA:VIEW_MASKED', type: 'DATA', name: '查看脱敏数据' }
]
</script>

<template>
  <div class="page">
    <div class="page-header">
      <div>
        <h1 class="page-title">权限编码说明</h1>
        <p class="page-subtitle">集中展示菜单、接口和数据权限编码，方便验收和报告引用。</p>
      </div>
    </div>

    <section class="panel">
      <el-table :data="rows" border>
        <el-table-column prop="code" label="权限编码" width="220" />
        <el-table-column prop="type" label="类型" width="120" />
        <el-table-column prop="name" label="说明" />
      </el-table>
    </section>
  </div>
</template>
