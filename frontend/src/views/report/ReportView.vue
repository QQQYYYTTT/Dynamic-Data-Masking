<template>
  <div class="page">
    <div class="page-header">
      <div>
        <h1 class="page-title">数据分析报表</h1>
        <p class="page-subtitle">仅基于脱敏后数据生成统计结果，避免报表泄露原始敏感字段。</p>
      </div>
      <el-button type="primary">生成报表</el-button>
    </div>

    <section class="stat-grid">
      <div class="stat-item">
        <div class="stat-label">学院统计</div>
        <div class="stat-value">--</div>
      </div>
      <div class="stat-item">
        <div class="stat-label">成绩区间</div>
        <div class="stat-value">--</div>
      </div>
      <div class="stat-item">
        <div class="stat-label">脱敏覆盖</div>
        <div class="stat-value">--</div>
      </div>
      <div class="stat-item">
        <div class="stat-label">导出次数</div>
        <div class="stat-value">--</div>
      </div>
    </section>
  </div>
</template>
