<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { LockKeyhole, LogIn, UserRound } from 'lucide-vue-next'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const formRef = ref<FormInstance>()
const loading = ref(false)

const form = reactive({
  username: 'admin',
  password: '123456'
})

const rules: FormRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

async function handleLogin() {
  await formRef.value?.validate()
  loading.value = true
  try {
    await auth.login(form)
    ElMessage.success('登录成功')
    router.replace((route.query.redirect as string) || '/dashboard')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <main class="login-page">
    <section class="login-visual">
      <div class="visual-content">
        <p class="eyebrow">Database System & Security</p>
        <h1>动态数据脱敏系统</h1>
        <p class="lead">基于角色权限、敏感字段配置和审计日志的课程设计演示平台。</p>
        <div class="visual-metrics">
          <span>RBAC</span>
          <span>JWT</span>
          <span>MySQL</span>
          <span>Masking</span>
        </div>
      </div>
    </section>

    <section class="login-panel">
      <div class="login-box">
        <h2>用户登录</h2>
        <p>默认演示账号：admin / 123456</p>

        <el-form ref="formRef" :model="form" :rules="rules" label-position="top" @keyup.enter="handleLogin">
          <el-form-item label="用户名" prop="username">
            <el-input v-model="form.username" size="large" placeholder="请输入用户名">
              <template #prefix><UserRound :size="18" /></template>
            </el-input>
          </el-form-item>
          <el-form-item label="密码" prop="password">
            <el-input v-model="form.password" size="large" type="password" show-password placeholder="请输入密码">
              <template #prefix><LockKeyhole :size="18" /></template>
            </el-input>
          </el-form-item>
          <el-button class="login-button" size="large" type="primary" :loading="loading" @click="handleLogin">
            <LogIn :size="18" />
            登录系统
          </el-button>
        </el-form>
      </div>
    </section>
  </main>
</template>

<style scoped>
.login-page {
  display: grid;
  grid-template-columns: minmax(0, 1.1fr) minmax(360px, 0.9fr);
  min-height: 100vh;
  background: #f5f7fb;
}

.login-visual {
  display: flex;
  align-items: center;
  min-height: 100vh;
  padding: 56px;
  background:
    linear-gradient(rgba(12, 23, 42, 0.72), rgba(12, 23, 42, 0.72)),
    url("https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=1600&q=80") center/cover;
  color: #ffffff;
}

.visual-content {
  max-width: 640px;
}

.eyebrow {
  margin: 0 0 14px;
  color: #93c5fd;
  font-size: 13px;
  font-weight: 700;
  text-transform: uppercase;
}

h1 {
  margin: 0;
  font-size: 44px;
  line-height: 1.18;
}

.lead {
  max-width: 520px;
  margin: 18px 0 0;
  color: #d8e2f0;
  font-size: 17px;
  line-height: 1.8;
}

.visual-metrics {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 28px;
}

.visual-metrics span {
  border: 1px solid rgba(255, 255, 255, 0.26);
  border-radius: 8px;
  padding: 8px 12px;
  background: rgba(255, 255, 255, 0.08);
  font-size: 13px;
}

.login-panel {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 36px;
}

.login-box {
  width: min(100%, 420px);
}

.login-box h2 {
  margin: 0;
  color: #182033;
  font-size: 28px;
}

.login-box p {
  margin: 10px 0 28px;
  color: #687386;
}

.login-button {
  width: 100%;
  margin-top: 4px;
  gap: 8px;
}

@media (max-width: 820px) {
  .login-page {
    grid-template-columns: 1fr;
  }

  .login-visual {
    min-height: 320px;
    padding: 36px 24px;
  }

  h1 {
    font-size: 34px;
  }
}
</style>
