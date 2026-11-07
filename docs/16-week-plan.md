# 全栈 TypeScript · 数据平台控制台（16 周执行版）

> 目标：能**一个人把数据平台里的一整块控制面做完**的全栈工程师——前端 Vue、后端 NestJS、领域是调度（Airflow）与数据平台（Databricks 形态）。
> 起点：有 Java Web 经验（Spring Boot / MVC / SQL 熟悉）；公司里在做 Databricks-like 产品；家里已经跑着 k3s + Airflow。
> 默认投入：**每周 10–12 小时**。文末有 6h / 20h 的调整方案。
> 技术主线没变（JS → TS → Vue → Nest → Prisma）。**换的是练手载体**：不再写虚构的设备工单系统，改成你自己每天要打开的那个作业控制台。

---

## 0. 先把"做什么"定义清楚

### 技术栈全景

```
┌ 前端   Vue 3 + TypeScript + Vite + Pinia
├ 共享   packages/shared（DTO / 类型 / 校验）
├ 后端   NestJS + TypeScript + Prisma      ← BFF / 控制面，不是业务后端
├ 数据   PostgreSQL（只存"判断"，不存调度状态）
├ 领域   Airflow REST API · k8s API（只读）  ← 你原来没写完的那半边
└ 工程   pnpm workspace + Docker + CI
```

**这里最容易被看错的是「后端」那一行：它不存业务数据。**

Airflow 自己就有元数据库，DAG 状态、TaskInstance、日志都在里面。你的 NestJS 一个字节都不该去复制它——那是**数据面**的事。你的后端是**控制面**：把 Airflow 的 API、k8s 的 pod 状态、和你自己的标注（备注、标签、收藏、失败原因）缝在一个界面里。这个分工是 Databricks 本身的核心设计，也是这个项目里你能学到的最贵的一课。

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
- ❌ **不自己搭 k8s 集群、不学 k8s 运维**。Airflow 已经跑在你的 k3s 上，你对 k8s 的全部要求是"只读 pod 状态"，做到 v2 就够
- ❌ **不重造调度器、不写 DAG 引擎、不做 Notebook**。Airflow 干了十几年，你干不过，也不需要
- ❌ **不在这台机器上跑 Spark / Trino / Flink**。8G 单通道 + 100G 盘，跑起来只有痛苦——数据面不在这（见第 3 节的控制面 / 数据面分层）
- ❌ 不学 React（先把 Vue 走穿）

---

## 1. 书单：7 本核心 + 5 本配套 + 领域资料

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

### 领域：Airflow / 数据平台（不是"读"，是"查"）

| 资料 | 什么时候查 |
|---|---|
| [Airflow 官方文档](https://airflow.apache.org/docs/) | 第 3.5 节全部概念 + 第 10 周对接 API 时的**唯一权威**。UI 上每个状态的定义都在里面 |
| [Airflow REST API 参考](https://airflow.apache.org/docs/apache-airflow/stable/stable-rest-api-ref.html) | 第 10–13 周：`/dags`、`/dags/{id}/dagRuns`、`/taskInstances`、`/logs/{dag_id}/...` 的字段、分页、过滤参数 |
| 《大数据之路：阿里巴巴大数据实践》 | 第 12 周设计"我到底该存什么"时翻。讲的是数据平台怎么组织，不是某个工具怎么用 |
| 《数据密集型应用系统设计》(DDIA) | 长期。第 12 周只看第 1–3 章（可靠性 / 数据模型 / 存储与检索），**别通读**，现在读会白读 |
| 《Spark快速大数据分析》 | **选做**，第 16 周之后。你现在没有负载可练，读了也用不上 |

> 领域知识在这 16 周里**不需要读成体系**。你每天在公司就在它里面，缺的不是输入，是**把天天见到的东西整理成能说出口的概念**——第 3.5 节就是为了这个，它比这整个书单都重要。

---

## 2. 第 0 天：环境一次配好

```bash
# 只装两样，别的等用到再说
# Node 24 LTS：用 Homebrew 装，不走 nvm（机器上已有 24 就跳过这两行）
brew install node@24
echo 'export PATH="/opt/homebrew/opt/node@24/bin:$PATH"' >> ~/.zshrc
exec zsh                    # 或直接重开终端
node -v                     # 应输出 v24.x

npm i -g pnpm

# 不装新东西，只确认家里那套还在（第 9–10 周才真正用上）
# 你这台集群实测：Airflow 3.2.2，API 前缀是 /api/v2
# 端口 8080 按你 values 里的 service（NodePort 或 kubectl port-forward 都行）
curl -s localhost:8080/api/v2/monitor/health   # metadatabase / scheduler / dag_processor 都 healthy 就行
kubectl get pods -n airflow                    # api-server / scheduler / dag-processor 全 Running

# 3.x 的 API 要先换 JWT，否则一律 401（账号密码见 helm values）
# 没装 jq：brew install jq，或者把后面换成 | python3 -c 'import sys,json;print(json.load(sys.stdin)["access_token"])'
TOKEN=$(curl -s -X POST localhost:8080/auth/token \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin"}' | jq -r .access_token)
curl -s localhost:8080/api/v2/dags \
  -H "Authorization: Bearer $TOKEN" | head -c 200
```

**第 0 天检查项**

| 项 | 通过标准 |
|---|---|
| Node | `node -v` → v24.x |
| pnpm | `pnpm -v` → 9.x 或 10.x |
| Git | `git --version` 正常，且已配 `user.name` / `user.email` |
| 编辑器 | WebStorm（内置 Vue.js 插件），包管理器设为 pnpm |
| **Airflow 还在** | `/api/v2/monitor/health` 返回 `healthy`；`kubectl get pods -n airflow` 全 Running |
| **能换到 token** | `POST /auth/token` 拿到 `access_token`，带上它请求 `/api/v2/dags` 得 200 而不是 401 |
| 能起项目 | `pnpm create vue@latest` 选 TS，`pnpm dev` 能打开页面 |

**第 0 天不做的事**：Docker、PostgreSQL、Redis、NestJS CLI、Spark/Trino、k8s 集群。

这些第一次真正用到是第 10–12 周。现在装只会让你在镜像下载、端口占用、权限报错上先耗掉半天，而且完全无法理解自己在装什么。**Spark/Trino 这台机器这辈子都不用装**——见第 3 节。

**固定选型，16 周不换：**

| 层 | 选择 | 什么时候装 |
|---|---|---|
| 运行时 | Node 24 LTS | 第 0 天（别用奇数版本） |
| 包管理 | pnpm + workspace | 第 0 天 |
| 编辑器 | WebStorm（Vue.js 插件 + pnpm 包管理器） | 第 0 天 |
| **调度引擎** | **Airflow（已经跑在 k3s 上：不重装、不改它、不碰它的元数据库）** | 已有，第 10 周开始对接 |
| **领域接口** | Airflow REST API v1 / k8s API（**只读**） | 第 10 周 |
| 前端 | Vue 3 + Vite + TS strict | 第 5 周（组合式 API + `<script setup>`） |
| 前端状态/路由/UI | Pinia / Vue Router 4 / Element Plus | 第 7 周 |
| 后端 | **NestJS 10+**（默认 Express 适配器） | 第 10 周（`pnpm dlx @nestjs/cli new`，不用全局装） |
| ORM | **Prisma** | 第 12 周 |
| 数据库 | PostgreSQL | 第 12 周（**复用 Airflow 那个实例，建独立 database**，别再起第二个实例） |
| 缓存 | 默认不装，用进程内 Map | 第 16 周想练 Redis 再上——8G 机器上每个依赖都要先问一句"我真的需要你吗" |
| 容器 | Docker + docker-compose | **第 11 周末**（写第 12 周之前；控制台**不要**塞进 k3s） |
| 校验 | class-validator + class-transformer | 第 10 周 |
| 测试 | 前端 Vitest / 后端 Jest + supertest | 第 14 周 |

**第 0 天验收**：`pnpm create vue@latest` 起一个空项目，`pnpm dev` 能打开页面，`pnpm exec tsc --noEmit` 零报错；并且**能用一句话说清"控制台管什么、Airflow 管什么"**——说不清就往下读第 3 节。

### WebStorm 配置要点

不需要装 Volar / Vetur —— 那是 VS Code 生态的东西，WebStorm 自带 Vue 支持。

| 设置项 | 位置 | 怎么设 |
|---|---|---|
| 包管理器 | Settings → Node.js | 选 **pnpm**，否则新项目会生成 `package-lock.json` |
| TypeScript | Settings → TypeScript | 选项目里的 `node_modules/typescript`，别用内置版本 |
| Vue 支持 | Settings → Plugins | 确认内置 `Vue.js` 插件已启用 |
| ESLint | Settings → JavaScript → Code Quality Tools → ESLint | 选 Automatic；不生效就手动指向 `eslint.config.js` |
| Prettier | Settings → JavaScript → Prettier | 自动检测 + 勾「保存时运行」 |

> `.idea/` 已经在 `.gitignore` 里，不会误提交。
> ESLint 用的是 flat config（`eslint.config.js`），如果 IDE 完全不认，多半是 WebStorm 版本偏旧，升级后再试。

---

## 3. 贯穿项目：作业台（Airflow 控制台）

全程只做这一个，别每章写 demo。

### 为什么不再写设备工单系统

练习项目能证明"我会写"，不能证明"我在交付一个东西"。而这两件事在面试和实际工作里是两个物种。

更重要的是：**你手上已经有一个真实需求了。** 你家里那台 j4125 上跑着 Airflow，你每天（或者每周）都要进去看"昨晚那个任务跑完没有""为什么又红了"。Airflow 原生 UI 对"一个人的杂活"很难用：一次运行的来龙去脉看不全、失败要挨个点开、改个参数得重跑整个 DAG。

**那些让你烦的地方，就是这个项目的需求清单。** 从痒长出来的东西才活得下来——工单系统练到第 11 周你会烦，因为你不关心它；作业台你不会烦，因为你要用它。

### 定位一句话

> **给我家里那套 Airflow 做一个我自己愿意每天打开的作业台。它负责"谁在什么时候跑什么、跑得怎么样、失败了怎么办"——活不在这里干。**

### 控制面 / 数据面（这条是硬约束，不是设计偏好）

| | 控制面（你写的） | 数据面（不归你管） |
|---|---|---|
| 住哪 | j4125 / 8G，7×24 常开，10W | Mac 本地、云上按需机、以后的 E5 |
| 干什么 | 列表、状态、日志、重跑、标注 | 真正执行 DAG、跑 Spark |
| 存什么 | **你的判断**：备注、标签、收藏、失败原因 | DAG 状态、TaskInstance、日志本体 |
| 挂了怎么办 | 你修，因为你天天用它 | 换一台重跑，没人关心 |

**硬约束：执行器必须可替换。** 从第一天就假设"活不在本机干"，架构才不会歪。这也是 Databricks 本身的设计——控制台在它那儿，算力在你的云账号里。你只有一台弱机，天然只能这么干；**这不是妥协，是逼你学到正确的东西**：那些有一柜子服务器的团队反而常把所有东西塞进一个集群，最后学到的本事是"堆机器"。

### 架构

```
浏览器
  └─ Vue 控制台（apps/web）
       └─ NestJS BFF（apps/api）
            ├─ Airflow REST API ──────→ api-server / scheduler / DAG
            ├─ k8s API（只读，v2 才有）→ pod 状态、重启次数
            └─ Postgres（复用 Airflow 那个实例，建独立 database）
                 └─ 只存：标注 / 收藏 / 运行快照 / 失败原因
```

### 为什么要 BFF，不前端直连 Airflow

这条面试会问，自己写之前先想清楚：

- **token 不进浏览器**。Airflow 的 token 塞进 SPA，等于交给任何一个打开 devtools 的人
- **跨域**。Airflow 的 CORS 配置不值得你为它折腾
- **聚合**。一个运行详情页要打 `/dagRuns`、`/taskInstances`、`/logs` 三四个接口，BFF 一次给前端一个对象
- **N+1 只能在这解决**。想让"运行列表"显示所有 DAG 的最近运行，Airflow 只提供"按 dag_id 查"的接口，于是你得对 N 个 DAG 发 N 次请求——**这个并发 + 缓存只能在后端做**，前端做就是 N 个跨域请求排队
- **裁剪**。Airflow 的 API 字段很胖，直接吐给前端，第 16 周你会为了 200KB 首屏哭
- **收敛**。限流、超时、重试、缓存都只有这一个地方能加

### 功能（就 5 条）

1. **运行列表**：所有 DAG 的最近运行，带状态、耗时、触发方式（第 5–7 周，对着 mock 先做）
2. **一次运行的完整视图**：时间线、哪个 task 慢、日志直接看（第 10–13 周）
3. **重跑**：改参数重跑，不用碰 YAML。重跑前提示"这个任务幂等吗 / 会花钱吗"（第 13 周）
4. **我的标注**：收藏、备注、给失败打原因标签（第 12 周）——这是 Airflow 永远不做的、只属于你的数据
5. **登录 + 两层角色**：admin / viewer（第 11 周）。用户只有你一个，但**RBAC 骨架要留**——它是你 Spring Security 存量的直接平移，也是面试点

### v0 → v3 里程碑

| 阶段 | 做什么 | 验收（这一列才是真的验收） |
|---|---|---|
| **v0** | 只读：运行列表 + 运行详情 + 日志 | **用它跑一次真实的杂活，全程不打开 Airflow 原生 UI** |
| **v1** | 可写：改参数重跑、手动触发、备注/收藏 | 不改 YAML 就能重跑一个任务，参数从表单来 |
| **v2** | 观测：k8s pod 状态、运行时间线、慢在哪一步 | 能回答"上周那个任务为什么慢"，且不用登服务器 |
| **v3** | 执行器抽象：本地 / 远程 / 云 | 同一条 DAG 在 Mac 上跑成功，代码不改 |

对应到周：v0 落在第 6–7 周（前端对着 mock）+ 第 13 周（接真 API）；v1 = 第 13 周；v2 = 第 16 周；v3 = 16 周之后。

### 永不做的列表（比要做的更重要）

一个人的项目死于范围蔓延，不死于技术难度。现在就写死：

- ❌ **不自己实现 DAG 调度器**。Airflow 干了十几年，你干不过，也不需要
- ❌ **不做 Notebook / SQL 编辑器**。Jupyter 免费，别重造
- ❌ **不做多租户 / 组织权限**。用户就你一个
- ❌ **不上微服务**。一个进程，一个仓库
- ❌ **不为"像 Databricks"加功能**。Databricks 每个功能都在解决"一千个客户"的问题，你只有一个客户
- ❌ **不把控制台塞进 k3s**。多一层调度器，多一分内存和故障面，白送
- ❌ **不在这台机器跑 Spark / Trino / Flink**。不是慢，是会把 100G 盘撑爆

### 仓库结构

```
ops-console/
├─ apps/
│  ├─ web/                    # Vue3 + Vite
│  │  └─ src/{api,features,components,composables,router,stores,types}
│  └─ api/                    # NestJS（BFF）
│     ├─ src/
│     │  ├─ modules/          # airflow(客户端) / dag / run / log / note / auth
│     │  ├─ common/           # guards / interceptors / filters / pipes
│     │  └─ prisma/
│     └─ prisma/schema.prisma
├─ packages/
│  └─ shared/                 # ★ 前后端共享的 DTO（DagRun / TaskInstance / ApiResponse<T>）
│     └─ src/{dto,enums,constants}
├─ docker-compose.yml
├─ pnpm-workspace.yaml
└─ .github/workflows/ci.yml
```

**`packages/shared` 是这个项目的灵魂**，第 13 周你会明白为什么。

**`modules/airflow` 是唯一允许调 Airflow HTTP 的地方。** 单一出口（防腐层）。这样哪天你想把 Airflow 换掉、或者读一个自研调度器，只改一个目录——这个习惯比你会用 Airflow 值钱。

**每阶段打 tag**：`v0.1-js`、`v0.4-ts`、`v0.7-vue-mock`、`v1.0-live`、`v1.1-rerun`、`v1.2-observability`。

---

## 3.5 领域最小知识：调度与数据平台

这一节不是书，是**你必须能说出口的东西**。你每天在公司就在这些概念里，但"见过"和"讲得清"差了整整一个面试。

### 六个对象，先分清

| 概念 | 是什么 | 容易混的地方 |
|---|---|---|
| **DAG** | 一张任务流程图，代码定义 | 它只是**定义**，跑起来的不是它 |
| **DagRun** | DAG 的一次执行，属于某个 logical date | 重跑会产生**新** DagRun，不是覆盖旧的 |
| **TaskInstance** | DAG 里一个节点在某次运行里的实例，有独立状态 | 一个 DagRun 卡住，通常是一个 TI 在重试 |
| **logical date** | 这次运行"代表"的时间点 | **不等于**开始跑的时间。补数（backfill）跑的是过去的日子 |
| **state** | `scheduled/queued/running/success/failed/upstream_failed/skipped/up_for_retry/deferred/removed` | `upstream_failed` 不是失败，是**没轮到跑**；重试中叫 `up_for_retry`，不叫 `retry` |
| **元数据库** | Airflow 自己的库，存上面全部 | **别当业务库读**。它是 Airflow 的内部实现，升级会变 |

### 五个组件，先分清（3.x 的拆分和 2.x 不一样）

- **scheduler** 决定什么时候跑什么（它自己是个循环，不是 cron）
- **api-server** 负责 UI 和 `/api/v2`——**你的后端对接的就是它**（2.x 里这个角色叫 webserver，3.x 已经换掉了）
- **dag-processor** 单独解析 DAG 文件（3.x 从 scheduler 里拆了出来）
- **triggerer** 跑 deferrable 的 task（比如长时间等外部事件）
- **executor** 决定在哪跑（Local / Celery / Kubernetes）

这条分清楚，你就知道"控制台挂了"和"任务挂了"互不影响：你的 BFF 挂了，DAG 照跑；反过来 api-server 挂了，你的控制台才真的瞎了——**这是你唯一需要告警的上游**。

### REST API 你会反复打的几个（3.2.2 实测）

| 端点 | 用来 |
|---|---|
| `GET /api/v2/monitor/health` | 健康检查：`metadatabase` / `scheduler` / `dag_processor` 各自状态（第 0 天就用它） |
| `POST /auth/token` | 换 JWT，**3.x 每个请求都得带** |
| `GET /api/v2/version` | 版本号 |
| `GET /api/v2/dags` | 列出 DAG，带 `is_paused`、调度配置 |
| `GET /api/v2/dags/{dag_id}/dagRuns` | 运行列表，分页 + `state` 过滤 |
| `GET /api/v2/dags/{dag_id}/dagRuns/{dag_run_id}/taskInstances` | 这次运行里每个 task 的状态、`try_number`、起止时间 |
| `GET /api/v2/dags/{dag_id}/dagRuns/{dag_run_id}/taskInstances/{task_id}/logs/{try_number}` | 日志（**纯文本流**，注意别整个读进内存） |
| `POST /api/v2/dags/{dag_id}/dagRuns` | 触发一次运行（可带 conf） |
| `PATCH /api/v2/dags/{dag_id}` | 暂停 / 恢复（body 里 `is_paused`） |

**鉴权是 3.x 最容易卡住的一步**：不再接受 `-u admin:admin`，必须先换 JWT。

```bash
TOKEN=$(curl -s -X POST localhost:8080/auth/token \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin"}' | jq -r .access_token)

curl -s localhost:8080/api/v2/dags -H "Authorization: Bearer $TOKEN" | jq '.dags[0].dag_id'
```

用错会很惨的地方：**分页**（默认上限 100，`maximum_page_limit` 可调，别以为只有几条）、**时间格式**（ISO8601 带时区，`Date` 解析时区搞错一天的事故很常见）、**`try_number` 语义**（同一个端点，try 不同日志不同）、**token 过期**（JWT 有有效期，401 时要重取而不是报错给前端）。

> **按版本写，别无脑抄教程**：网上绝大多数 Airflow API 文章还是 2.x 的（`/api/v1` + basic auth + `webserver`），照抄会连错三处、白花半天。你这台是 **3.2.2**，以它为唯一标准；换机器或升级后先跑一遍 `curl /api/v2/version`。

### 六个"能讲清就超过多数人"的问题

1. 为什么 scheduler 不是 cron？cron 表达不了依赖、重试、补数
2. `catchup=True` 的老 DAG 重启后会怎样？一阵补数风暴
3. 为什么 retry 对**不幂等**的任务是负债？——见下面 LLM 一节
4. 为什么不能直接读 Airflow 元数据库做报表？升级即崩，且它没有稳定契约
5. 一次 DagRun 卡在 `running` 三天，你会先看哪三样？（TI 状态 / executor 队列 / pod 是否被驱逐）
6. 为什么"重跑"必须能区分"重算"和"重复副作用"？

> 这六条不是背的。第 10–13 周你每对接一个端点，就回来对一遍，答案会自己长出来。

### LLM 任务为什么在这个领域是全新的负载

你公司的用户已经在写"调 LLM 的 DAG"。这类任务和你熟悉的数据任务**不是一类东西**，而绝大多数调度系统还没认真处理：

| 问题 | 为什么旧方案不管用 |
|---|---|
| **不幂等** | 重跑就重复计费，还可能重复发通知。Airflow 的 `retries` 在这里是负债 |
| **不确定** | 同输入不同输出，下游没法复现，排障只能靠猜 |
| **有价钱** | 每个 task 有成本。没人做成本归因，月底才心疼 |
| **限流** | 会被 429 打，需要**全局**限流，不是单 task 限流 |
| **长尾** | 一个 task 3 分钟到 30 分钟，调度的超时模型全错 |
| **缓存** | 相同 prompt 该命中，但没人做语义级缓存 |

**这是你做作业台时能想到、而多数同行想不到的那一层。** 所以第 13 周的重跑功能里加一条小提示就够：每个任务标一个 `idempotent` 和 `costly` 属性，重跑前弹一句"这个任务不幂等，重跑会重复产生副作用"。功能很小，但它证明你知道自己在管什么。

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
- 纯 CSS（不用 UI 库）复刻**作业台的运行列表页**：左侧 DAG 列表 + 顶部筛选 + 中间运行历史表格 + 右侧日志面板
- `flex` 和 `grid` 各写一遍对比；`vw` 方案做移动端适配

**验收**
- [ ] 能解释 BFC 触发条件，及它为什么能解决 margin 塌陷
- [ ] 能解释层叠上下文，说出 3 种 `z-index` 失效场景
- [ ] 375px / 1440px 下都不破版
- [ ] 日志面板滚动时，两侧栏不跟着动（这是三栏布局的第一道坎）

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
- Vite + TS + Vue3 起项目，把第 3 周的静态页变成**运行列表**：mock 数据 + 状态筛选 + 按时间排序
- `<script setup>` + 泛型 `defineProps`/`defineEmits`

**验收**
- [ ] 讲清 `ref` vs `reactive` 的选型
- [ ] 讲清 `computed` vs `watch`
- [ ] 说出组件 `v-model` 的本质：`modelValue` + `update:modelValue`
- [ ] 搜不到 `any`
- [ ] 列表能按 `state`（success / failed / running）过滤，且这是纯客户端行为

---

### 第 6 周｜组件化

**读**：剑指Vue3 第 5–8 章

**做**
- 抽 5 个可复用组件：运行历史表格、状态徽章、日志查看器、参数表单、分页（都带 TS 类型）
- 抽 4 个 composable：分页、表单校验、请求 loading、**轮询刷新**（运行中的任务要自己更新）

**验收**
- [ ] 讲清 props 单向数据流，子组件要改父数据怎么办
- [ ] 能写带作用域插槽的表格
- [ ] 讲清 `Teleport` 解决什么、`KeepAlive` 的 `include`/`max`
- [ ] 组件有 README 和 props 类型
- [ ] **状态徽章把 7 个 Airflow 状态各自有颜色，且 `upstream_failed` 不显示成"失败"**（见第 3.5 节）

---

### 第 7 周｜路由、状态与权限

**读**：剑指Vue3 第 9 章

**做**
- Vue Router 4：懒加载、动态路由 `addRoute`、全局守卫、`meta` 权限；`/runs/:dagId/:runId` 这条详情路由
- Pinia：用户/权限/筛选条件（筛选条件要在刷新后还在）
- Element Plus 按需引入
- `v-permission` 按钮级权限指令（`admin` 才能重跑）

**验收**
- [ ] 走通"登录 → token → 拉用户信息 → 动态加路由 → 首页"
- [ ] 401 自动清 token 跳登录，无死循环
- [ ] 讲清 Pinia 为什么去掉 mutations
- [ ] 从列表点进详情、返回后筛选条件不丢

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
- 不用框架，纯 Node 写一个 **Airflow 代理**：`/api/runs` 转发到 Airflow 的 `/dagRuns`，处理 token 注入、超时、错误映射
- 手写中间件（洋葱模型）：traceId、超时、统一错误格式
- 用 Stream 做**日志流式转发**：Airflow 日志 → `Readable` → 直接推给响应，谁都不许 `readFileSync`

**验收**
- [ ] 解释事件循环 6 个阶段，`poll` 卡住会怎样
- [ ] 讲清 CJS vs ESM（同步/异步、值拷贝/活绑定）
- [ ] 讲清 Stream 背压
- [ ] 解释 `Buffer` 与内存分配、为什么会有内存泄漏
- [ ] **能说清为什么日志转发必须流式**：一个 50MB 的日志读进内存，8G 的机器会怎样

> 为什么换成这个：你写的是自己真的要用的东西，而且**流式转发日志**是这份计划里唯一一个"不用框架就写不出来、用了框架也得懂"的地方。理论题在这儿会自己变成刚需。

> **不要跳过这周直接上 Nest。** 框架会掩盖你对运行时的无知，第 14 周排查线上问题时全要还回来。

---

### 第 10 周｜NestJS 基础

**读**：《NestJS全栈开发解析》前几章通读做地图 + [官方文档 Fundamentals](https://docs.nestjs.com/first-steps)

**做**
- 建 `apps/api`，拆 `airflow`（客户端）/ `dag` / `run` / `auth` 四个模块
- 写 controller + service + DTO（class-validator 校验）
- **`AirflowClient` 管理 JWT 生命周期**：`POST /auth/token` 拿 token、缓存到过期、401 时重取并重试一次——**别每个请求都去换 token**
- **DTO 映射层**：Airflow 返回是 `snake_case`，进你的 DTO 时映射成 `camelCase`——映射**只做一次**，前端永远见不到 snake_case
- 全局管道、全局异常过滤器、统一响应格式拦截器

**验收**
- [ ] 能解释 Nest 的模块图与依赖注入解析过程
- [ ] 能说出 `@Injectable()` 的默认作用域（singleton）及 request-scope 的代价
- [ ] 校验失败返回 400 且错误信息结构化
- [ ] 能用 `@nestjs/swagger` 自动生成接口文档
- [ ] Airflow 的字段名改了，只在你这一层炸，前端不用动
- [ ] 打 10 个请求，`/auth/token` 只被调 1 次（看日志）

---

### 第 11 周｜NestJS 进阶：鉴权与切面

**读**：官方文档 Guards / Interceptors / Custom Decorators / Authentication

**做**
- JWT 登录 + refresh token，`@Public()` 自定义装饰器放行
- `RolesGuard` + `@Roles('admin')` 做 RBAC（触发、重跑这类动作要 admin）
- **Airflow 的 token 只在服务端**：由 `AirflowClient` 统一注入，前端拿不到
- 拦截器记录耗时 + traceId 日志；traceId 一路带到发给 Airflow 的请求头
- 出站超时 + 错误映射：Airflow 3 秒不回来就别等；`401/403/404` 不能原样吐给前端
- 限流（`@nestjs/throttler`）、helmet、CORS

**验收**
- [ ] 能解释 Guard → Interceptor → Pipe → Handler → Interceptor → Filter 的执行顺序
- [ ] 手写一个 `@CurrentUser()` 参数装饰器
- [ ] 越权访问返回 403，未登录返回 401
- [ ] 日志能按 traceId 串起一次请求全链路
- [ ] **浏览器 devtools 里搜不到 Airflow 的 token**
- [ ] Airflow 挂了，控制台返回的是"上游不可用"，不是一坨 500 堆栈

> **本周是后端的分水岭**：过了这周，你会发现 Spring Security 那套你早就懂了，只是换了语法。而"token 不上前端"这件事，是前后端分离后最容易做错的一条。

---

### 第 12 周｜数据库与 ORM

**读**：Prisma 官方文档（Schema / Migrate / Client）；《全栈Monorepo开发实战》数据层部分

**做**
- `schema.prisma` 设计 **User / Favorite / DagNote / RunSnapshot / FailureTag**——注意这里**没有"任务表"**，任务在 Airflow 里
- `prisma migrate dev` 管理迁移；写 seed 脚本
- `PrismaService` 接入 Nest（`onModuleInit` 连接）；**复用 Airflow 那个 Postgres 实例，建独立 database**
- 事务：写标注 + 落一条审计（谁什么时候重跑了什么）必须原子
- 运行快照：把每次运行的耗时/状态落一份，回答"最近变慢了吗"——Airflow 的历史会被保留期滚掉

**验收**
- [ ] 能解释 Prisma 的 schema-first 和 JPA 注解式的取舍
- [ ] 能手写一条带 `include` 的查询，并解释有没有 N+1
- [ ] 事务能正确回滚（故意造一个异常验证）
- [ ] 运行历史 5 万条时，按 `dag_id + 时间` 查询走索引，响应 < 200ms
- [ ] **能说清为什么不去读 Airflow 的元数据库做报表**（见第 3.5 节）

> 这一周最值钱的判断不是 Prisma 怎么用，是**"哪些数据该我存"**。Airflow 存的是调度事实，你存的是判断和留痕；两样混在一起，升级 Airflow 那天就是灾难。

---

### 第 13 周｜全栈打通 + 类型共享（重点周）

**读**：《全栈Monorepo开发实战》第 1–3 章（pnpm workspace / 共享包）

**做**
- 在 `packages/shared` 定义 DTO：`DagRunDto`、`TaskInstanceDto`、`RunState`（枚举）、`ApiResponse<T>`
- 后端 controller 的入参/出参**直接引用 shared 类型**
- 前端 `api/runs.ts` 也引用同一份类型
- 前端 axios 封装：泛型、拦截器、错误码、取消重复请求
- 联调：前端从 mock 切到**你 BFF 后面的真 Airflow**
- 重跑功能：参数表单 → `POST /dagRuns`（带 conf）；重跑前弹一句"这个任务幂等吗 / 会花钱吗"

**验收**
- [ ] **故意改掉 shared 里 `RunState` 的一个枚举值**，前后端同时编译报错 —— 这是本方案的核心收益，必须亲眼见到
- [ ] 端到端跑通：登录 → 运行列表 → 详情 → 看日志 → 改参数重跑
- [ ] `pnpm -r typecheck` 一条命令检查全仓库
- [ ] 打 tag `v1.0-live`，且**演示全程不打开 Airflow 原生 UI**（这就是 v0 的验收）

---

### 第 14 周｜测试

**做**
- 后端：service 单测（mock `AirflowClient`，不 mock Prisma）、e2e（supertest 打真实接口 + 测试库）
- 前端：composable 单测、组件测试（@vue/test-utils）
- 覆盖率门槛：后端 service 层 > 60%

**验收**
- [ ] e2e 能覆盖登录 → 运行列表 → 日志 → 重跑 主流程
- [ ] 单测能在 CI 里跑（不依赖本地 Airflow，用 mock；也别依赖本地数据库）
- [ ] 能说出单测/集成/e2e 各自该测什么、不该测什么
- [ ] **Airflow 返回 500 / 超时 / 字段缺失**，这三条都有测试，而不是只测 happy path

---

### 第 15 周｜工程化与部署

**读**：前端工程化 · 构建 / 本地服务 / 部署 / 工作流

**做**
- ESLint（flat config）+ Prettier + husky + lint-staged + commitlint
- GitHub Actions：`lint → typecheck → test → build`（前后端并行 job）
- 多阶段 Dockerfile：**Vue 打成静态文件，由 NestJS 直接 serve**（不上 nginx，省一个容器）
- `docker-compose`：api + postgres（复用 Airflow 那个实例，或起一个只给你用的）；**不装 Redis**
- 环境变量分环境，密钥不入库；Airflow token 走 secret，不进镜像

**内存预算（8G 机器，这张表才决定你做得成做不成）**

| 组件 | 方案 | 预算 |
|---|---|---|
| Airflow 那套 | 已经跑着，**别动它** | 已占 3–4G |
| 前端 | 静态文件，Nest `ServeStaticModule` | ~0 |
| 后端 | Nest 单进程 | ~200M |
| 数据库 | 复用 Airflow 的 Postgres，独立 database | ~0 额外 |
| 缓存 | 进程内 Map | 0 |
| 部署 | docker compose / systemd，**不进 k3s** | 0 |

**验收**
- [ ] 提交不合规代码被 husky 拦下
- [ ] CI 全绿，全流程 < 6 分钟
- [ ] `docker compose up -d` 后能访问，**且 `docker stats` 里你这套总共 < 400M**
- [ ] 能解释 Vite 开发为什么快（ESM + esbuild 预构建）、生产为什么用 Rollup
- [ ] 重启机器后容器自动起来（`restart: unless-stopped`），你不用登服务器

---

### 第 16 周｜性能、可观测性与收尾

**做**
- 前端：路由懒加载、`manualChunks` 分包、虚拟列表（1 万行运行历史 + 大日志）
- 后端：接口压测（autocannon）、加索引、连接池；对 Airflow 的调用做**短缓存**（同一个运行详情 5 秒内不重复打）
- 可观测：健康检查（`@nestjs/terminus`，**必含"Airflow 可达"一项**）、结构化日志、慢查询日志
- **v2 观测**：k8s pod 状态（只读）、运行时间线、慢在哪一步
- **选做**：Vue 渲染器/编译器（设计与实现 第 7–11、14–17 章）
- **选做**：做成 PWA，手机上看运行状态（比小程序少一层，且够用）

**验收**
- [ ] Lighthouse Performance ≥ 90，首屏 JS（gzip）< 200KB
- [ ] 运行列表接口 P95 < 200ms
- [ ] 1 万行表格滚动 60fps
- [ ] **能回答"上周那个任务为什么慢"，且全程没登服务器**
- [ ] 仓库 README 有架构图，陌生人 10 分钟能跑起来
- [ ] 简历有 3 条成果，**数字都是你自己测过的**（面试官一定会问"你怎么测的"）

---

## 5. 每周固定节奏

| 时段 | 做什么 |
|---|---|
| 周一–周二 | 读 1–2 章，只读不敲，标出 3 个不懂的点 |
| 周三–周四 | 每个疑点写最小 demo 验证（< 30 行） |
| 周五 | 合进 `ops-console` |
| 周六 | 补验收清单没过的项 |
| 周日 | **用它跑一次真活** + 打 tag + 写 5 行周记 |

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

**调度 / 数据平台（这组决定你是"会写界面"还是"懂平台"）**
21. 为什么 scheduler 不是 cron？cron 表达不了什么
22. `catchup=True` 的历史 DAG 重启后会怎样，怎么关
23. 为什么 retry 对**不幂等**的任务（比如调 LLM）是负债而不是保险
24. `upstream_failed` 和 `failed` 的区别，排查顺序有何不同
25. 为什么不该直接读 Airflow 元数据库做报表
26. logical date 和"实际开始跑的时间"不是一回事，这会坑在哪
27. 你的控制台挂了，DAG 还会跑吗？为什么——这一问能立刻区分出懂不懂分层

---

## 7. Java 人最常踩的 16 个坑

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
13. **把 Airflow 元数据库当业务库读**：它是内部实现，升级就变，没有稳定契约。你要的数据自己存一份。
14. **让前端直连 Airflow**：token 泄露、跨域、无法聚合、没法限流。BFF 不是过度设计，是这四件事的唯一解法。
15. **把重跑当免费操作**：不幂等的任务重跑一次就是一次副作用——可能重复发通知，可能重复花钱。重跑按钮旁边必须有一句提示。
16. **按 2.x 的记忆写 3.x 的 API**：`/api/v1` → `/api/v2`、`-u admin:admin` → `/auth/token` 换 JWT、`webserver` → `api-server`、`schedule_interval` → `schedule`。这四处一起错，症状还都是 401/404，最费时间。

---

## 8. 简历话术（第 16 周直接用）

**先说一条纪律**：下面每一句都必须是**你真跑过、能讲出细节**的。编出来的数字，面试官一句"你怎么测的"就穿了——那比不写更糟。

- 独立开发 **Airflow 作业控制台**（Vue 3 + NestJS + Prisma + PostgreSQL），把运行列表、运行详情、日志查看、参数化重跑收在一个界面里，日常排障不再打开 Airflow 原生 UI
- 按**控制面 / 数据面分离**设计：后端只持有"判断类"数据（标注、收藏、运行快照、失败原因），调度事实留在 Airflow，**不复制元数据库**；Airflow 经单一 `AirflowClient` 防腐层接入，可整体替换调度器
- 前后端共用 TypeScript 类型包（`packages/shared`），调度字段变更在**编译期**暴露；曾主动改错一次 `RunState` 枚举，验证前后端同时编译失败
- 在 8GB 内存的机器上与 Airflow 共存部署：复用其 Postgres、不引入 Redis 与 nginx，compose 编排后总内存 < 400MB
- 用 pnpm monorepo + GitHub Actions 把 lint / typecheck / test / build 串成一条流水线

**面试怎么讲它（比简历更重要）**

别说"我做了个监控面板"。说这三句：

1. **它解决什么痒**——Airflow 原生 UI 回答不了"上周那个任务为什么慢"，我得点五次、还得登服务器
2. **边界在哪**——我明确不做调度器、不做 Notebook、不做多租户，所以 16 周做出来的是个能用的东西，不是一堆半成品
3. **我改过什么主意**——"我本来想前端直连 Airflow API，后来改成 BFF，因为 token 不能进浏览器"

这三句里没有一处需要背八股，但它们证明的判断力，比"熟悉 Vue3 响应式原理"重得多。

---

## 9. 时间不够 / 时间充裕

| 每周投入 | 周期 | 怎么调 |
|---|---|---|
| 6 小时 | 约 24 周 | 砍掉第 8 周（Vue 原理）和第 16 周选做；阅读改通勤听 + 周末精读 |
| 10–12 小时 | 16 周 | 按本文 |
| 20 小时 | 约 10 周 | 第 3+4 周合并、第 10+11 周合并、第 14 周并入第 15 周 |

**奔着找工作**：保留全部后端周（10–13），砍第 8 周 Vue 原理和第 16 周选做——面试问后端深度的岗位，TS 全栈比"会背 Vue 源码"更值钱。

**奔着数据平台 / 调度平台岗**（你更可能是这个）：反过来，**第 3.5 节和第 16 周的 v2 观测优先**，第 8 周照砍。这类岗位面试问的不是"你会不会 Vue"，是"你怎么看待一次运行卡住三天""为什么不能读元数据库"——那两处正好是答案。

---

## 10. 微信读书使用提示

- 这几本基本都在无限卡内，**点开书页确认有没有"无限卡"标识**。
- 技术书用 **PC 网页版**读，代码块不折行。
- **NestJS 那本只读一遍做地图**，真正学习时间应该花在官方文档 + 动手写模块上，比例大概 2:8。
- 《Vue.js设计与实现》《深入浅出Node.js》必须边读边敲，光看会觉得懂了，一写就废。

---

*最后一句：你这次转的不是"前端"，是"用一门语言把数据平台里的一整块控制面做完"。Java 那套分层、DI、鉴权、事务一条都没浪费，只是换了语法。16 周后你手上该有一个**你每天真的会打开**的控制台——它比一个漂亮的练手项目重得多，因为它是你家的，公司裁不掉。*
