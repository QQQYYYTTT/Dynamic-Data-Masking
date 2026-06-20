<template>
  <div class="page">
    <div class="page-header">
      <div>
        <h1 class="page-title">首页仪表盘</h1>
        <p class="page-subtitle">展示脱敏系统运行状态、策略覆盖和审计概览。</p>
      </div>
    </div>

    <section class="stat-grid">
      <div class="stat-item">
        <div class="stat-label">敏感字段</div>
        <div class="stat-value">12</div>
      </div>
      <div class="stat-item">
        <div class="stat-label">脱敏策略</div>
        <div class="stat-value">10</div>
      </div>
      <div class="stat-item">
        <div class="stat-label">角色类型</div>
        <div class="stat-value">8</div>
      </div>
      <div class="stat-item">
        <div class="stat-label">今日访问</div>
        <div class="stat-value">--</div>
      </div>
    </section>

    <section class="panel">
      <el-table :data="rows" border>
        <el-table-column prop="module" label="模块" width="180" />
        <el-table-column prop="point" label="数据库知识点" />
        <el-table-column prop="status" label="当前状态" width="160" />
      </el-table>
    </section>
  </div>
</template>

<script setup lang="ts">
const rows = [
  { module: '认证与权限', point: '用户表、角色表、权限表、多对多关系、JWT 会话', status: '已接入后端' },
  { module: '动态脱敏', point: '敏感字段表、策略表、角色策略分配、存储过程', status: '待联调' },
  { module: '安全审计', point: '访问日志、策略变更日志、触发器、异常访问检测', status: '待实现接口' }
]
</script>
