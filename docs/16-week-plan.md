# 全栈 TypeScript · Vue 线（16 周执行版）

> 目标：**前后端全用 TypeScript 写**的全栈工程师，方向是"大前端"。
> 起点：有 Java Web 经验（Spring Boot / MVC / SQL 熟悉）。
> 默认投入：**每周 10–12 小时**。文末有 6h / 20h 的调整方案。
> 上一版（Vue + Spring Boot）已作废——后端不再是 Java。

---

## 0. 先把"大前端 + TS 后端"定义清楚

### 技术栈全景

```
┌─────────────────────────────────────────────┐
│  前端  Vue 3 + TypeScript + Vite + Pinia    │
├─────────────────────────────────────────────┤
│  共享  packages/shared（DTO / 类型 / 校验）  │
├─────────────────────────────────────────────┤
│  后端  NestJS + TypeScript + Prisma         │
├─────────────────────────────────────────────┤
│  数据  PostgreSQL + Redis                   │
├─────────────────────────────────────────────┤
│  工程  pnpm workspace + Docker + CI         │
└─────────────────────────────────────────────┘
```

**关键认知：这条路最大的收益不是"少学一门语言"，而是端到端类型安全。**

Java 栈里，前端调后端要靠 Swagger 文档 + 手动对字段，字段改名就线上炸。全栈 TS 里，后端 DTO 的类型 `import` 到前端直接用，改名当场编译报错。这是你真正要拿到的东西，第 13 周会专门做这件事。

### 你的 Java 经验怎么平移（这张表值两周时间）

| Spring Boot | NestJS | 说明 |
|---|---|---|
| `@RestController` | `@Controller` | 几乎一样 |
| `@Service` + `@Autowired` | `@Injectable()` + 构造函数注入 | DI 容器，概念一致 |
| `@Configuration` / `@Bean` | `@Module({ providers, exports })` | 模块化，但 Nest 更强制 |
| Spring Security Filter | `Guard`（`canActivate`） | 鉴权就写在这 |
| AOP `@Around` | `Interceptor` | 日志、耗时、统一响应 |
| Bean Validation `@Valid` | `Pipe`（`ValidationPipe`） | 参数校验 |
| `@ControllerAdvice` | `ExceptionFilter`（`@Catch`） | 全局异常 |
| JPA / Hibernate | Prisma / TypeORM | Prisma 是 schema-first，更像"写 SQL 的 ORM" |
| `application.yml` | `ConfigModule` + `.env` | 环境配置 |
| Maven / Gradle | pnpm workspace | 多模块 → monorepo |
| JUnit | Jest + supertest | e2e 测试尤其像 `@SpringBootTest` |

**结论：后端你不需要"从零学"，你需要的是"把 Spring 的心智模型换一套语法映射"。** 这也是为什么本方案选 NestJS 而不是 Express/Koa——选 Express 等于放弃你最大的存量优势。

### 16 周不做的事

- ❌ 不写 Java 后端了（不碰 Spring Boot，避免"两个都用一点"）
- ❌ 不上 SSR / Nuxt（单体 SPA + API 没跑通前不谈）
- ❌ 不碰微服务 / Kubernetes（第 16 周后再看）
- ❌ 不学 React（先把 Vue 走穿）

---

## 1. 书单：7 本核心 + 5 本配套

### 核心（按阅读顺序）

| # | 书 | 作者 | 用途 | 读哪些 | 链接 |
|---|---|---|---|---|---|
| 1 | JavaScript高级程序设计（第5版） | 马特·弗里斯比 | 语言地基 | 语言基础、作用域与内存、对象与类、函数、期约与异步 | [打开](https://weread.qq.com/web/reader/16632270813abb1d0g019ba0) |
| 2 | CSS世界 | 张鑫旭 | 布局 | 基本概念、流与元素、盒尺寸、层叠规则 | [打开](https://yd.qq.com/web/reader/00932ab0715a41e90093ab5) |
| 3 | 深入理解TypeScript | Basarat Ali Syed | 类型系统 | 类型、接口、泛型、类型收窄、声明文件 | [打开](https://weread.qq.com/web/reader/6393276071bc6e966392234) |
| 4 | 剑指Vue3——从入门到实践 | 尚硅谷教育 | 前端上手 | 第1–4章 → 第5–8章 | [打开](https://weread.qq.com/web/reader/97332900813ab8fc1g013114) |
| 5 | Vue.js设计与实现 | 霍春阳 | 前端原理 | 第1–6章（响应式）、第7–11章（渲染器/Diff） | [打开](https://weread.qq.com/web/reader/c5c32170813ab7177g0181a9) |
| 6 | 深入浅出Node.js | 朴灵 | Node 运行时 | 模块机制、异步I/O、内存控制、构建Web应用 | [打开](https://weread.qq.com/web/bookDetail/d1b32290718ff65fd1befcc) |
| 7 | **NestJS全栈开发解析** | 温健民 | **后端主线** | 全书通读一遍做地图，细节回官方文档 | [打开](https://weread.qq.com/web/reader/a8c32ef0813ab966dg010e96) |

> ⚠️ 关于第 7 本：这是微信读书上**唯一一本中文 NestJS 书**，出版较新、评分样本少。它的价值是"给你一张完整地图"，但深度不够。**真正的教材是 [docs.nestjs.com](https://docs.nestjs.com)（有中文版）**，写得比大多数书好。书用来串，文档用来查。

### 配套（按需查，不通读）

| 书 | 什么时候翻 | 链接 |
|---|---|---|
| 全栈Monorepo开发实战（Vue 3+Fastify+Deno+pnpm） | 第 13 周搭 monorepo、接 Prisma 时**重点参考**，它把 Vue + 服务端 + Prisma + pnpm 串了一遍 | [打开](https://weread.qq.com/web/reader/bf9323d0813ab8658g015ca9) |
| Vue.js 3.x + Express 全栈开发 | 想看"最小可用全栈"长什么样（Express 比 Nest 简单，适合对照理解） | [打开](https://weread.qq.com/web/reader/90632640813ab966dg015552) |
| TypeScript全栈开发（赵卓） | 补 TS 编译配置、前后端共用 TS 的工程细节 | [打开](https://weread.qq.com/web/reader/a2332920813ab7e12g01223c) |
| 前端工程化：体系设计与实践 | 第 15 周配 CI/构建/部署 | [打开](https://weread.qq.com/web/reader/65832f00716ce84e658ac89) |
| Node.js Design Patterns（英文） | 第 16 周想深入 Node 设计模式时看，质量很高 | [打开](https://weread.qq.com/web/reader/6da32480813ab8efg0174a4) |

> 《剑指大前端全栈工程师》《大前端三剑客》这类综合书，当**技术地图**翻 30 分钟就行，别当教材——它们广度够、深度不够，你已经有方向了。

---

## 2. 第 0 天：环境一次配好

```bash
# 只装两样，别的等用到再说
nvm install 20 && nvm use 20
npm i -g pnpm
```

**第 0 天检查项**

| 项 | 通过标准 |
|---|---|
| Node | `node -v` → v20.x |
| pnpm | `pnpm -v` → 9.x |
| Git | `git --version` 正常，且已配 `user.name` / `user.email` |
| 编辑器 | VS Code + Volar，**禁用 Vetur** |
| 能起项目 | `pnpm create vue@latest` 选 TS，`pnpm dev` 能打开页面 |

**第 0 天不做的事**：Docker、PostgreSQL、Redis、NestJS CLI。

这些第一次真正用到是第 10–12 周。现在装只会让你在镜像下载、端口占用、权限报错上先耗掉半天，而且完全无法理解自己在装什么。

**固定选型，16 周不换：**

| 层 | 选择 | 什么时候装 |
|---|---|---|
| 运行时 | Node 20 LTS | 第 0 天（别用奇数版本） |
| 包管理 | pnpm + workspace | 第 0 天 |
| 编辑器 | VS Code + Volar | 第 0 天 |
| 前端 | Vue 3 + Vite + TS strict | 第 5 周（组合式 API + `<script setup>`） |
| 前端状态/路由/UI | Pinia / Vue Router 4 / Element Plus | 第 7 周 |
| 后端 | **NestJS 10+**（默认 Express 适配器） | 第 10 周（`pnpm dlx @nestjs/cli new`，不用全局装） |
| ORM | **Prisma** | 第 12 周 |
| 数据库 | PostgreSQL | 第 12 周（用 Docker；别用 SQLite，会掩盖类型问题） |
| 缓存 | Redis | 第 12 周 |
| 容器 | Docker + docker-compose | **第 11 周末**（写第 12 周之前） |
| 校验 | class-validator + class-transformer | 第 10 周 |
| 测试 | 前端 Vitest / 后端 Jest + supertest | 第 14 周 |

**第 0 天验收**：`pnpm create vue@latest` 起一个空项目，`pnpm dev` 能打开页面，`pnpm exec tsc --noEmit` 零报错。

---

## 3. 贯穿项目：设备工单系统（全栈）

全程只做这一个，别每章写 demo。业务你熟（CRUD + 权限 + 状态流转），注意力全放技术上。

### 功能（就 5 条）

1. 登录 / 登出 / 刷新 token（JWT + refresh）
2. 工单列表：分页、搜索、状态筛选
3. 工单详情 + 编辑 + 状态流转（待处理 → 处理中 → 已完成）
4. 新建工单：表单校验 + 附件上传（本地/MinIO）
5. 权限：admin 可删，user 只能看自己的

### 仓库结构（一开始就这样建）

```
vue-ticket/
├─ apps/
│  ├─ web/                    # Vue3 + Vite
│  │  └─ src/{api,features,components,composables,router,stores,types}
│  └─ api/                    # NestJS
│     ├─ src/
│     │  ├─ modules/          # auth / ticket / user / upload
│     │  ├─ common/           # guards / interceptors / filters / pipes
│     │  └─ prisma/
│     └─ prisma/schema.prisma
├─ packages/
│  └─ shared/                 # ★ 前后端共享的 DTO 类型
│     └─ src/{dto,enums,constants}
├─ docker-compose.yml
├─ pnpm-workspace.yaml
└─ .github/workflows/ci.yml
```

**`packages/shared` 是这个项目的灵魂**，第 13 周你会明白为什么。

**每阶段打 tag**：`v0.1-js`、`v0.4-ts`、`v0.7-vue`、`v1.0-fullstack`。

---

## 4. 16 周计划

### 第 1 周｜环境 + JS 语言基础

**读**：高程5 · 语言基础 / 变量作用域与内存 / 集合引用类型

**做**
- 配环境，建 monorepo
- 原生 JS 写 10 个练习：数组扁平化、深拷贝、防抖、节流、柯里化、发布订阅、手写 `call/apply/bind`、数组去重、深比较、简易模板引擎

**验收**
- [ ] 讲清 `var`/`let`/`const` 与 TDZ
- [ ] 讲清 8 种数据类型、`typeof null` 为什么是 `"object"`
- [ ] 手写 `debounce`（含 `immediate`）和能处理循环引用的 `deepClone`

---

### 第 2 周｜原型链与异步（最疼的一周）

**读**：高程5 · 对象、类与面向对象编程 / 函数 / 期约与异步函数

**做**
- 手写 `Promise`（`then`/`catch`/`finally`/`all`/`race`/`allSettled`）
- 手写 `new`、`instanceof`、`Object.create`
- 用 `class` 实现 EventEmitter

**验收**
- [ ] 任意 `setTimeout` + `Promise` + `async/await` 混排代码，能口算输出顺序
- [ ] 能画出事件循环图（宏任务/微任务/`nextTick`）
- [ ] 能说清"JS 单线程 + 事件循环"和"Java 线程池"解决同一问题的不同代价

---

### 第 3 周｜CSS 布局

**读**：CSS世界 · 基本概念 / 流与元素 / 盒尺寸 / 内联元素 / 层叠规则

**做**
- 纯 CSS（不用 UI 库）复刻后台布局：侧边栏 + 顶栏 + 内容区 + 表格
- `flex` 和 `grid` 各写一遍对比；`vw` 方案做移动端适配

**验收**
- [ ] 能解释 BFC 触发条件，及它为什么能解决 margin 塌陷
- [ ] 能解释层叠上下文，说出 3 种 `z-index` 失效场景
- [ ] 375px / 1440px 下都不破版

---

### 第 4 周｜TypeScript 基础

**读**：深入理解TypeScript · 类型 / 接口 / 泛型

**做**
- 把第 1–2 周练习全部改写成 TS，`strict: true`，零 `any`
- 写泛型请求封装 `request<T>(config): Promise<T>`

**验收**
- [ ] 讲清 `interface` vs `type` 的适用场景
- [ ] 能写 `<T extends { id: number }>` 并解释约束意义
- [ ] 讲清 `unknown` vs `any`、类型收窄（`typeof`/`in`/类型谓词）
- [ ] **讲清 TS 结构化类型与 Java 名义类型的区别**（你的盲区）

---

### 第 5 周｜TS 进阶 + Vue3 起步

**读**：深入理解TypeScript · 类型进阶 / 声明文件 / 编译配置；剑指Vue3 第 1–4 章

**做**
- Vite + TS + Vue3 起项目，写带筛选排序的 todo-list
- `<script setup>` + 泛型 `defineProps`/`defineEmits`

**验收**
- [ ] 讲清 `ref` vs `reactive` 的选型
- [ ] 讲清 `computed` vs `watch`
- [ ] 说出组件 `v-model` 的本质：`modelValue` + `update:modelValue`
- [ ] 搜不到 `any`

---

### 第 6 周｜组件化

**读**：剑指Vue3 第 5–8 章

**做**
- 抽 5 个可复用组件：数据表格、表单、弹窗、分页、上传（都带 TS 类型）
- 抽 3 个 composable：分页、表单校验、请求 loading

**验收**
- [ ] 讲清 props 单向数据流，子组件要改父数据怎么办
- [ ] 能写带作用域插槽的表格
- [ ] 讲清 `Teleport` 解决什么、`KeepAlive` 的 `include`/`max`
- [ ] 组件有 README 和 props 类型

---

### 第 7 周｜路由、状态与权限

**读**：剑指Vue3 第 9 章

**做**
- Vue Router 4：懒加载、动态路由 `addRoute`、全局守卫、`meta` 权限
- Pinia：用户/权限/字典；持久化插件
- Element Plus 按需引入
- `v-permission` 按钮级权限指令

**验收**
- [ ] 走通"登录 → token → 拉用户信息 → 动态加路由 → 首页"
- [ ] 401 自动清 token 跳登录，无死循环
- [ ] 讲清 Pinia 为什么去掉 mutations

> 本周结束时，前端已经能独立跑起来（对着 mock 数据）。这是 `v0.7`。

---

### 第 8 周｜Vue 响应式原理

**读**：Vue.js设计与实现 第 1–6 章

**做**
- 手写 mini-reactive：`reactive`/`ref`/`effect`/`track`/`trigger`/`computed`/`watch`/调度器
- 20 个单测覆盖嵌套对象、数组、分支切换、effect 嵌套

**验收**
- [ ] 画出 `WeakMap<Target, Map<Key, Set<Effect>>>` 并解释设计原因
- [ ] 解释 `cleanup` 解决什么问题
- [ ] 解释 `computed` 的 `dirty` 缓存机制
- [ ] 解释调度器为什么用微任务、job 去重与排序
- [ ] 单测全绿

> 渲染器/编译器（第 7–11、14–17 章）**本轮先跳过**，放到第 16 周选做。全栈方向优先把后端拿下来。

---

### 第 9 周｜Node.js 运行时

**读**：深入浅出Node.js · 模块机制 / 异步I/O / 异步编程 / 内存控制 / 构建Web应用

**做**
- 纯 Node 写一个 HTTP 服务（不用框架）：路由、静态文件、JSON 解析
- 手写一个中间件（洋葱模型雏形）
- 写一个 Stream 管道（读文件 → 转换 → 写文件）

**验收**
- [ ] 解释事件循环 6 个阶段，`poll` 卡住会怎样
- [ ] 讲清 CJS vs ESM（同步/异步、值拷贝/活绑定）
- [ ] 讲清 Stream 背压
- [ ] 解释 `Buffer` 与内存分配、为什么会有内存泄漏

> **不要跳过这周直接上 Nest。** 框架会掩盖你对运行时的无知，第 14 周排查线上问题时全要还回来。

---

### 第 10 周｜NestJS 基础

**读**：《NestJS全栈开发解析》前几章通读做地图 + [官方文档 Fundamentals](https://docs.nestjs.com/first-steps)

**做**
- 建 `apps/api`，拆 `auth` / `ticket` / `user` 三个模块
- 写 controller + service + DTO（class-validator 校验）
- 全局管道、全局异常过滤器、统一响应格式拦截器

**验收**
- [ ] 能解释 Nest 的模块图与依赖注入解析过程
- [ ] 能说出 `@Injectable()` 的默认作用域（singleton）及 request-scope 的代价
- [ ] 校验失败返回 400 且错误信息结构化
- [ ] 能用 `@nestjs/swagger` 自动生成接口文档

---

### 第 11 周｜NestJS 进阶：鉴权与切面

**读**：官方文档 Guards / Interceptors / Custom Decorators / Authentication

**做**
- JWT 登录 + refresh token，`@Public()` 自定义装饰器放行
- `RolesGuard` + `@Roles('admin')` 做 RBAC
- 拦截器记录耗时 + traceId 日志
- 限流（`@nestjs/throttler`）、helmet、CORS

**验收**
- [ ] 能解释 Guard → Interceptor → Pipe → Handler → Interceptor → Filter 的执行顺序
- [ ] 手写一个 `@CurrentUser()` 参数装饰器
- [ ] 越权访问返回 403，未登录返回 401
- [ ] 日志能按 traceId 串起一次请求全链路

> **本周是后端的分水岭**：过了这周，你会发现 Spring Security 那套你早就懂了，只是换了语法。

---

### 第 12 周｜数据库与 ORM

**读**：Prisma 官方文档（Schema / Migrate / Client）；《全栈Monorepo开发实战》数据层部分

**做**
- `schema.prisma` 设计 User / Ticket / Attachment / Comment
- `prisma migrate dev` 管理迁移；写 seed 脚本
- `PrismaService` 接入 Nest（`onModuleInit` 连接）
- 事务：状态流转 + 写日志必须原子
- Redis 缓存字典数据、token 黑名单

**验收**
- [ ] 能解释 Prisma 的 schema-first 和 JPA 注解式的取舍
- [ ] 能手写一条带 `include` 的查询，并解释有没有 N+1
- [ ] 事务能正确回滚（故意造一个异常验证）
- [ ] 列表接口在 10 万条数据下走索引，响应 < 200ms

---

### 第 13 周｜全栈打通 + 类型共享（重点周）

**读**：《全栈Monorepo开发实战》第 1–3 章（pnpm workspace / 共享包）

**做**
- 在 `packages/shared` 定义 DTO：`CreateTicketDto`、`TicketStatus`、`ApiResponse<T>`
- 后端 controller 的入参/出参**直接引用 shared 类型**
- 前端 `api/ticket.ts` 也引用同一份类型
- 前端 axios 封装：泛型、拦截器、错误码、取消重复请求
- 联调：前端从 mock 切到真实 API

**验收**
- [ ] **故意改掉 shared 里一个字段名**，前后端同时编译报错 —— 这是本方案的核心收益，必须亲眼见到
- [ ] 端到端跑通：登录 → 分页 → 新增 → 编辑 → 删除
- [ ] `pnpm -r typecheck` 一条命令检查全仓库
- [ ] 打 tag `v1.0-fullstack`，这是能拿出去演示的版本

---

### 第 14 周｜测试

**做**
- 后端：service 单测（mock Prisma）、e2e（supertest 打真实接口 + 测试库）
- 前端：composable 单测、组件测试（@vue/test-utils）
- 覆盖率门槛：后端 service 层 > 60%

**验收**
- [ ] e2e 能覆盖登录 + 工单 CRUD 主流程
- [ ] 单测能在 CI 里跑（不依赖本地数据库，或用 docker service）
- [ ] 能说出单测/集成/e2e 各自该测什么、不该测什么

---

### 第 15 周｜工程化与部署

**读**：前端工程化 · 构建 / 本地服务 / 部署 / 工作流

**做**
- ESLint（flat config）+ Prettier + husky + lint-staged + commitlint
- GitHub Actions：`lint → typecheck → test → build`（前后端并行 job）
- 多阶段 Dockerfile：web（nginx 托管静态）+ api（node 运行）
- `docker-compose`：web + api + postgres + redis 一键起
- 环境变量分环境，密钥不入库

**验收**
- [ ] 提交不合规代码被 husky 拦下
- [ ] CI 全绿，全流程 < 6 分钟
- [ ] 服务器上 `docker compose up -d` 后能通过域名访问
- [ ] 能解释 Vite 开发为什么快（ESM + esbuild 预构建）、生产为什么用 Rollup

---

### 第 16 周｜性能、可观测性与收尾

**做**
- 前端：路由懒加载、`manualChunks` 分包、图片懒加载、虚拟列表（1 万条）
- 后端：接口压测（autocannon）、加索引、Redis 缓存热点、连接池
- 可观测：健康检查（`@nestjs/terminus`）、结构化日志、慢查询日志
- **选做**：Vue 渲染器/编译器（设计与实现 第 7–11、14–17 章）
- **选做**：uni-app 把工单列表做成小程序（Vue 语法直接复用）

**验收**
- [ ] Lighthouse Performance ≥ 90，首屏 JS（gzip）< 200KB
- [ ] 列表接口 P95 < 200ms（1 万条数据）
- [ ] 1 万行表格滚动 60fps
- [ ] 仓库 README 有架构图，陌生人 10 分钟能跑起来
- [ ] 简历有 3 条带数字的成果

---

## 5. 每周固定节奏

| 时段 | 做什么 |
|---|---|
| 周一–周二 | 读 1–2 章，只读不敲，标出 3 个不懂的点 |
| 周三–周四 | 每个疑点写最小 demo 验证（< 30 行） |
| 周五 | 合进 `vue-ticket` |
| 周六 | 补验收清单没过的项 |
| 周日 | 演示 + 打 tag + 写 5 行周记 |

**铁律**：代码不跑一遍不算读过。微信读书手机端代码块会折行，用 PC 网页版看，代码从 GitHub 拉。

---

## 6. 自测题

**JS**
1. `[] == ![]` 的结果和原因
2. 闭包在循环里为什么拿到同一个 `i`，三种解法
3. `Promise.then` 里 `return` 一个 Promise 会怎样
4. `async` 函数返回什么？`await` 接非 Promise 呢

**CSS**
5. `margin: auto` 在 flex 下为什么能垂直居中
6. `position: fixed` 什么情况下"失效"
7. 2 倍屏的 1px 边框怎么处理

**TS**
8. `interface` 能声明合并、`type` 不能，实践里有什么用
9. 结构化类型带来什么坑（提示：多传字段）
10. 用 `Omit`/`Pick`/`Partial` 组合出表单类型

**Vue**
11. `ref` 在模板里为什么不用 `.value`
12. `reactive` 解构后为什么丢响应性，`toRefs` 做了什么
13. `v-if` 和 `v-for` 为什么不该同级
14. 为什么 `key` 不能用 index（举出错场景）
15. `effect` 嵌套时 `activeEffect` 怎么管理

**Node / Nest**
16. `process.nextTick` 和 `setImmediate` 谁先
17. 为什么 Node 适合 I/O 密集不适合 CPU 密集，怎么补救
18. Nest 的 Guard / Interceptor / Pipe 执行顺序
19. 为什么 Nest 默认是单例作用域？改成 request 作用域有什么代价
20. Prisma 的 `include` 什么时候会造成 N+1

---

## 7. Java 人最常踩的 12 个坑

1. **`==` 会隐式转换**：永远用 `===`，ESLint 开 `eqeqeq`。
2. **`this` 不是"当前对象"**：看调用方式，箭头函数继承外层。
3. **`class` 是语法糖**：底层原型链，`super` 和字段初始化顺序与 Java 不同。
4. **没有阻塞调用**：`for` 里 `await` 是串行，该用 `Promise.all`。
5. **对象是引用**：`map` 返回新数组，元素还是同一批对象。
6. **`reactive` 解构丢响应性**：要 `toRefs` / `storeToRefs`。
7. **`provide/inject` 不是 Spring DI**：没有容器、没有按类型注入、没有生命周期。
8. **别把 `controller/service/dao` 搬到前端**：前端按 **feature** 分目录。
9. **Nest 的模块不是 Spring 的 `@Configuration`**：`providers` 默认模块内可见，要 `exports` 才能被别的模块注入——这个坑第一次必踩。
10. **Prisma 不是 Hibernate**：没有一级/二级缓存、没有脏检查、没有延迟加载。查什么写什么，别指望"事务里改了对象自动 flush"。
11. **lockfile 必须提交**：`pnpm-lock.yaml` 进 git，别让依赖乱飘。
12. **别过早微服务**：单体 Nest 应用没上线过，谈拆分都是空的。

---

## 8. 简历话术（第 16 周直接用）

- 独立完成设备工单系统**全栈开发**（Vue3 + NestJS + Prisma + PostgreSQL），前后端共用 TypeScript 类型包，接口字段变更在**编译期**即可发现，联调返工减少约 **50%**
- 基于 NestJS 实现 JWT + RBAC 鉴权体系（Guard / 自定义装饰器 / 拦截器），覆盖 3 类角色 12 个接口，越权请求 100% 拦截
- 前端首屏 JS 压缩至 **180KB（gzip）**，Lighthouse 性能 **92**；后端列表接口 10 万数据下 P95 **< 200ms**
- 搭建 pnpm monorepo + GitHub Actions CI + Docker Compose 部署，全流程 **6 分钟内**完成，一键起 4 个服务

---

## 9. 时间不够 / 时间充裕

| 每周投入 | 周期 | 怎么调 |
|---|---|---|
| 6 小时 | 约 24 周 | 砍掉第 8 周（Vue 原理）和第 16 周选做；阅读改通勤听 + 周末精读 |
| 10–12 小时 | 16 周 | 按本文 |
| 20 小时 | 约 10 周 | 第 3+4 周合并、第 10+11 周合并、第 14 周并入第 15 周 |

**奔着找工作**：保留全部后端周（10–13），砍第 8 周 Vue 原理和第 16 周选做——面试问后端深度的岗位，TS 全栈比"会背 Vue 源码"更值钱。

---

## 10. 微信读书使用提示

- 这几本基本都在无限卡内，**点开书页确认有没有"无限卡"标识**。
- 技术书用 **PC 网页版**读，代码块不折行。
- **NestJS 那本只读一遍做地图**，真正学习时间应该花在官方文档 + 动手写模块上，比例大概 2:8。
- 《Vue.js设计与实现》《深入浅出Node.js》必须边读边敲，光看会觉得懂了，一写就废。

---

*最后一句：你这次转的不是"前端"，是"用一门语言写完整应用"。Java 那套分层、DI、鉴权、事务的思想一条都没浪费，只是换了语法。16 周后你手上应该有一个能部署、能演示、类型端到端打通的仓库——那才是"大前端"的入场券。*
