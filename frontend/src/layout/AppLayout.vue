<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { LogOut, Menu as MenuIcon, UserCircle } from 'lucide-vue-next'
import { ElMessage } from 'element-plus'
import { menus } from '@/router/menu'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

const availableMenus = computed(() => menus.filter((item) => auth.hasPermission(item.permission)))
const activePath = computed(() => route.path)

function openProfile() {
  router.push('/profile')
}

async function handleLogout() {
  await auth.logout()
  ElMessage.success('已退出登录')
  router.replace('/login')
}
</script>

<template>
  <el-container class="app-shell">
    <el-aside class="app-aside" width="236px">
      <div class="brand">
        <div class="brand-mark">DDM</div>
        <div>
          <div class="brand-title">动态数据脱敏系统</div>
          <div class="brand-subtitle">Database Security</div>
        </div>
      </div>

      <el-menu :default-active="activePath" router class="side-menu">
        <el-menu-item v-for="item in availableMenus" :key="item.path" :index="item.path">
          <component :is="item.icon" class="menu-icon" :size="18" />
          <span>{{ item.title }}</span>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <el-container>
      <el-header class="app-header">
        <div class="header-left">
          <MenuIcon :size="20" />
          <span>{{ route.meta.title || '动态数据脱敏系统' }}</span>
        </div>
        <div class="header-user">
          <el-button text class="profile-link" @click="openProfile">
            <UserCircle :size="18" />
            <span>{{ auth.user?.realName || auth.user?.username || '未加载用户' }}</span>
          </el-button>
          <el-tag v-for="role in auth.roles" :key="role" size="small" effect="plain">{{ role }}</el-tag>
          <el-tooltip content="退出登录" placement="bottom">
            <el-button circle :icon="LogOut" @click="handleLogout" />
          </el-tooltip>
        </div>
      </el-header>

      <el-main class="app-main">
        <RouterView />
      </el-main>
    </el-container>
  </el-container>
</template>

<style scoped>
.app-shell {
  min-height: 100vh;
}

.app-aside {
  border-right: 1px solid #e4e8f0;
  background: #ffffff;
}

.brand {
  display: flex;
  align-items: center;
  gap: 12px;
  height: 72px;
  padding: 0 18px;
  border-bottom: 1px solid #e4e8f0;
}

.brand-mark {
  display: grid;
  place-items: center;
  width: 42px;
  height: 42px;
  border-radius: 8px;
  background: #1f6feb;
  color: #ffffff;
  font-size: 13px;
  font-weight: 800;
}

.brand-title {
  color: #182033;
  font-size: 15px;
  font-weight: 700;
}

.brand-subtitle {
  margin-top: 3px;
  color: #7b8494;
  font-size: 12px;
}

.side-menu {
  border-right: 0;
  padding: 10px;
}

.side-menu :deep(.el-menu-item) {
  height: 44px;
  border-radius: 8px;
  margin-bottom: 4px;
}

.menu-icon {
  margin-right: 10px;
}

.app-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 64px;
  border-bottom: 1px solid #e4e8f0;
  background: #ffffff;
}

.header-left,
.header-user,
.profile-link {
  display: flex;
  align-items: center;
  gap: 10px;
}

.header-left {
  color: #182033;
  font-weight: 700;
}

.header-user {
  color: #4b5563;
  font-size: 14px;
}

.profile-link {
  color: #374151;
}

.app-main {
  min-height: calc(100vh - 64px);
  background: #f5f7fb;
  padding: 22px;
}

@media (max-width: 780px) {
  .app-aside {
    display: none;
  }

  .app-main {
    padding: 14px;
  }
}
</style>
