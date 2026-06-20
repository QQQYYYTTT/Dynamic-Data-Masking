<script setup lang="ts">
const rows = [
  { code: 'SUPER_ADMIN', name: '超级管理员', permissionCount: 30 },
  { code: 'TEACHER', name: '教师', permissionCount: 8 },
  { code: 'AUDITOR', name: '审计员', permissionCount: 6 }
]
</script>

<template>
  <div class="page">
    <div class="page-header">
      <div>
        <h1 class="page-title">角色权限管理</h1>
        <p class="page-subtitle">维护角色、菜单权限、接口权限和数据权限。</p>
      </div>
      <el-button type="primary">分配权限</el-button>
    </div>

    <section class="panel">
      <el-table :data="rows" border>
        <el-table-column prop="code" label="角色编码" width="180" />
        <el-table-column prop="name" label="角色名称" width="180" />
        <el-table-column prop="permissionCount" label="权限数量" />
      </el-table>
    </section>
  </div>
</template>
