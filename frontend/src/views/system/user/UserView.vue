<script setup lang="ts">
const rows = [
  { username: 'admin', realName: '系统超级管理员', roles: 'SUPER_ADMIN', status: '启用' },
  { username: 'teacher01', realName: '张老师', roles: 'TEACHER', status: '启用' }
]
</script>

<template>
  <div class="page">
    <div class="page-header">
      <div>
        <h1 class="page-title">用户管理</h1>
        <p class="page-subtitle">维护系统用户、状态和角色绑定关系。</p>
      </div>
      <el-button type="primary">新增用户</el-button>
    </div>

    <section class="panel">
      <el-table :data="rows" border>
        <el-table-column prop="username" label="用户名" width="160" />
        <el-table-column prop="realName" label="姓名" width="180" />
        <el-table-column prop="roles" label="角色" />
        <el-table-column prop="status" label="状态" width="100" />
      </el-table>
    </section>
  </div>
</template>
