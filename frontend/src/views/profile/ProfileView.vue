<script setup lang="ts">
import { computed } from 'vue'
import { KeyRound, ShieldCheck, UserCircle } from 'lucide-vue-next'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()

const menuPermissions = computed(() => auth.permissions.filter((item) => item.startsWith('MENU:')))
const apiPermissions = computed(() => auth.permissions.filter((item) => item.startsWith('API:')))
const dataPermissions = computed(() => auth.permissions.filter((item) => item.startsWith('DATA:')))

const permissionGroups = computed(() => [
  { title: '菜单权限', type: 'success', records: menuPermissions.value },
  { title: '接口权限', type: 'warning', records: apiPermissions.value },
  { title: '数据权限', type: 'danger', records: dataPermissions.value }
])
</script>

<template>
  <div class="page">
    <div class="page-header">
      <div>
        <h1 class="page-title">个人中心</h1>
        <p class="page-subtitle">查看当前登录账号、角色身份和已加载的权限范围。</p>
      </div>
    </div>

    <section class="profile-summary">
      <div class="profile-card">
        <div class="avatar">
          <UserCircle :size="46" />
        </div>
        <div>
          <h2>{{ auth.user?.realName || '未加载用户' }}</h2>
          <p>{{ auth.user?.username }}</p>
          <div class="role-list">
            <el-tag v-for="role in auth.roles" :key="role" effect="plain">{{ role }}</el-tag>
          </div>
        </div>
      </div>

      <div class="stat-grid profile-stats">
        <div class="stat-item">
          <div class="stat-label">菜单权限</div>
          <div class="stat-value">{{ menuPermissions.length }}</div>
        </div>
        <div class="stat-item">
          <div class="stat-label">接口权限</div>
          <div class="stat-value">{{ apiPermissions.length }}</div>
        </div>
        <div class="stat-item">
          <div class="stat-label">数据权限</div>
          <div class="stat-value">{{ dataPermissions.length }}</div>
        </div>
      </div>
    </section>

    <section class="panel">
      <div class="section-title">
        <ShieldCheck :size="18" />
        <span>账号信息</span>
      </div>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="用户ID">{{ auth.user?.userId }}</el-descriptions-item>
        <el-descriptions-item label="用户名">{{ auth.user?.username }}</el-descriptions-item>
        <el-descriptions-item label="真实姓名">{{ auth.user?.realName }}</el-descriptions-item>
        <el-descriptions-item label="角色">{{ auth.roles.join('，') }}</el-descriptions-item>
      </el-descriptions>
    </section>

    <section class="panel">
      <div class="section-title">
        <KeyRound :size="18" />
        <span>权限明细</span>
      </div>
      <el-tabs>
        <el-tab-pane
          v-for="group in permissionGroups"
          :key="group.title"
          :label="`${group.title}（${group.records.length}）`"
        >
          <div class="permission-list">
            <el-tag v-for="permission in group.records" :key="permission" :type="group.type" effect="plain">
              {{ permission }}
            </el-tag>
            <el-empty v-if="group.records.length === 0" description="暂无权限" />
          </div>
        </el-tab-pane>
      </el-tabs>
    </section>

    <section class="panel">
      <div class="section-title">
        <KeyRound :size="18" />
        <span>密码安全</span>
      </div>
      <el-alert
        title="修改密码功能将在用户管理模块接口完成后接入。当前演示账号统一使用 123456。"
        type="info"
        show-icon
        :closable="false"
      />
    </section>
  </div>
</template>

<style scoped>
.profile-summary {
  display: grid;
  grid-template-columns: minmax(280px, 0.9fr) minmax(360px, 1.1fr);
  gap: 14px;
}

.profile-card {
  display: flex;
  align-items: center;
  gap: 16px;
  border: 1px solid #e4e8f0;
  border-radius: 8px;
  background: #ffffff;
  padding: 18px;
}

.avatar {
  display: grid;
  place-items: center;
  width: 72px;
  height: 72px;
  border-radius: 8px;
  background: #edf4ff;
  color: #1f6feb;
}

.profile-card h2 {
  margin: 0;
  color: #182033;
  font-size: 22px;
}

.profile-card p {
  margin: 6px 0 12px;
  color: #6b7280;
}

.role-list,
.permission-list,
.section-title {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
}

.profile-stats {
  grid-template-columns: repeat(3, minmax(0, 1fr));
}

.section-title {
  margin-bottom: 14px;
  color: #182033;
  font-size: 15px;
  font-weight: 700;
}

.permission-list {
  min-height: 72px;
  align-items: flex-start;
}

@media (max-width: 900px) {
  .profile-summary {
    grid-template-columns: 1fr;
  }

  .profile-stats {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 620px) {
  .profile-stats {
    grid-template-columns: 1fr;
  }
}
</style>
