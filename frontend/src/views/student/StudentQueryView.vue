<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { RefreshCcw, Search } from 'lucide-vue-next'
import { queryStudentsApi, type StudentRecord } from '@/api/student'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()
const loading = ref(false)
const rows = ref<StudentRecord[]>([])
const total = ref(0)
const dataView = ref('待查询')
const expandedRowKeys = ref<number[]>([])

const queryForm = reactive({
  studentNo: '',
  name: '',
  college: '',
  major: '',
  grade: '',
  pageNum: 1,
  pageSize: 10
})

const currentRoleText = computed(() => authStore.roles.join(' / ') || '未加载')

async function loadStudents() {
  loading.value = true
  try {
    const response = await queryStudentsApi({ ...queryForm })
    rows.value = response.data.records
    total.value = response.data.total
    queryForm.pageNum = response.data.pageNum
    queryForm.pageSize = response.data.pageSize
    dataView.value = response.data.dataView
  } finally {
    loading.value = false
  }
}

function resetQuery() {
  queryForm.studentNo = ''
  queryForm.name = ''
  queryForm.college = ''
  queryForm.major = ''
  queryForm.grade = ''
  queryForm.pageNum = 1
  loadStudents()
}

function handleSearch() {
  queryForm.pageNum = 1
  loadStudents()
}

function handlePageChange(page: number) {
  queryForm.pageNum = page
  loadStudents()
}

function handleSizeChange(size: number) {
  queryForm.pageSize = size
  queryForm.pageNum = 1
  loadStudents()
}

function maskingType(row: StudentRecord, field: string) {
  return row.maskingTypes?.[`student_info.${field}`] || 'NO_MASK'
}

onMounted(() => {
  loadStudents()
})
</script>

<template>
  <div class="page">
    <div class="page-header">
      <div>
        <h1 class="page-title">学生信息查询</h1>
        <p class="page-subtitle">同一条学生数据会根据当前登录角色动态加载脱敏规则并展示不同数据视图。</p>
      </div>
    </div>

    <section class="context-bar">
      <div class="context-item">
        <span class="context-label">当前用户</span>
        <strong>{{ authStore.user?.username || '-' }}</strong>
      </div>
      <div class="context-item">
        <span class="context-label">当前角色</span>
        <strong>{{ currentRoleText }}</strong>
      </div>
      <div class="context-item">
        <span class="context-label">数据视图</span>
        <el-tag type="success" effect="light">{{ dataView }}</el-tag>
      </div>
    </section>

    <section class="panel">
      <div class="toolbar">
        <el-input v-model="queryForm.studentNo" placeholder="学号" clearable style="width: 170px" />
        <el-input v-model="queryForm.name" placeholder="姓名" clearable style="width: 150px" />
        <el-input v-model="queryForm.college" placeholder="学院" clearable style="width: 220px" />
        <el-input v-model="queryForm.major" placeholder="专业" clearable style="width: 180px" />
        <el-input v-model="queryForm.grade" placeholder="年级" clearable style="width: 120px" />
        <el-button type="primary" :loading="loading" @click="handleSearch">
          <Search :size="16" />
          查询
        </el-button>
        <el-button @click="resetQuery">
          <RefreshCcw :size="16" />
          重置
        </el-button>
      </div>
    </section>

    <section class="panel">
      <el-table
        v-loading="loading"
        :data="rows"
        row-key="id"
        border
        :expand-row-keys="expandedRowKeys"
        empty-text="暂无学生数据"
      >
        <el-table-column type="expand">
          <template #default="{ row }">
            <div class="detail-grid">
              <div><span>地址</span><strong>{{ row.address }}</strong></div>
              <div><span>出生年份/日期</span><strong>{{ row.birthDate }}</strong></div>
              <div><span>家庭收入</span><strong>{{ row.familyIncome }}</strong></div>
              <div><span>银行卡</span><strong>{{ row.bankCard }}</strong></div>
            </div>
            <el-table :data="row.scores" border size="small" class="score-table" empty-text="暂无成绩">
              <el-table-column prop="semester" label="学期" width="120" />
              <el-table-column prop="courseName" label="课程" min-width="180" />
              <el-table-column prop="score" label="成绩/区间" width="120" />
            </el-table>
          </template>
        </el-table-column>
        <el-table-column prop="studentNo" label="学号" width="120" />
        <el-table-column prop="name" label="姓名" width="110">
          <template #default="{ row }">
            <span>{{ row.name }}</span>
            <el-tag size="small" class="mask-tag">{{ maskingType(row, 'name') }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="phone" label="手机号" width="150" />
        <el-table-column prop="email" label="邮箱" min-width="190" />
        <el-table-column prop="idCard" label="身份证号" min-width="190" />
        <el-table-column prop="college" label="学院" min-width="170" />
        <el-table-column prop="major" label="专业" min-width="150" />
        <el-table-column prop="grade" label="年级" width="90" />
        <el-table-column prop="className" label="班级" min-width="130" />
      </el-table>

      <div class="pagination-row">
        <el-pagination
          background
          layout="total, sizes, prev, pager, next"
          :total="total"
          :current-page="queryForm.pageNum"
          :page-size="queryForm.pageSize"
          :page-sizes="[10, 20, 50]"
          @current-change="handlePageChange"
          @size-change="handleSizeChange"
        />
      </div>
    </section>
  </div>
</template>

<style scoped>
.context-bar {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 12px;
}

.context-item {
  display: flex;
  min-height: 72px;
  flex-direction: column;
  justify-content: center;
  gap: 8px;
  border: 1px solid #e4e8f0;
  border-radius: 8px;
  background: #ffffff;
  padding: 14px 16px;
}

.context-label {
  color: #687386;
  font-size: 13px;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 12px;
  margin-bottom: 12px;
}

.detail-grid div {
  display: flex;
  min-width: 0;
  flex-direction: column;
  gap: 6px;
  border: 1px solid #e7eaf0;
  border-radius: 8px;
  padding: 10px 12px;
}

.detail-grid span {
  color: #687386;
  font-size: 12px;
}

.detail-grid strong {
  overflow-wrap: anywhere;
  font-size: 14px;
}

.mask-tag {
  margin-left: 6px;
}

.score-table {
  width: 560px;
  max-width: 100%;
}

.pagination-row {
  display: flex;
  justify-content: flex-end;
  margin-top: 14px;
}

@media (max-width: 900px) {
  .context-bar,
  .detail-grid {
    grid-template-columns: 1fr;
  }
}
</style>
