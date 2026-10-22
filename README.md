# 前端路线图 · 全栈 TypeScript

从 Java Web 转向「大前端」的学习路线 —— **前后端全部用 TypeScript 写**。

> 详细执行版（16 周逐周任务、验收清单、自测题、避坑指南）见 **[docs/16-week-plan.md](docs/16-week-plan.md)**

---

## 为什么是这条路

Java 的存量经验可以平移，不需要从零开始：

| Spring Boot | NestJS |
|---|---|
| `@RestController` | `@Controller` |
| `@Service` + `@Autowired` | `@Injectable()` + 构造函数注入 |
| Spring Security Filter | `Guard` |
| AOP `@Around` | `Interceptor` |
| `@Valid` | `Pipe` |
| `@ControllerAdvice` | `ExceptionFilter` |
| JPA / Hibernate | Prisma |
| Maven 多模块 | pnpm workspace |

**真正的收益不是"少学一门语言"，而是端到端类型安全**——后端 DTO 的类型可以直接 `import` 到前端，字段改名当场编译报错，而不是上线后才发现。

---

## 技术栈

```
前端    Vue 3 + TypeScript + Vite + Pinia + Element Plus
共享    packages/shared（DTO / 枚举 / 校验）
后端    NestJS + TypeScript + Prisma
数据    PostgreSQL + Redis
工程    pnpm workspace + Docker + GitHub Actions
```

---

## 16 周概览

| 周次 | 阶段 | 产出 |
|:---:|---|---|
| 1–2 | JS 语言地基 | 手写 Promise / 防抖节流 / 深拷贝 |
| 3 | CSS 布局 | 纯 CSS 复刻后台页 |
| 4–5 | TypeScript + Vue 起步 | 全 TS 改造 + todo-list |
| 6–7 | 组件化 / 路由 / 状态 / 权限 | 5 个通用组件 + 登录鉴权 |
| 8 | Vue 响应式原理 | 手写 mini-reactive + 20 个单测 |
| 9 | Node.js 运行时 | 原生 HTTP 服务 + Stream 管道 |
| 10–11 | NestJS 基础与鉴权 | 模块 / 守卫 / 拦截器 / JWT + RBAC |
| 12 | 数据库与 ORM | Prisma schema + 迁移 + 事务 + 缓存 |
| 13 | **全栈打通 + 类型共享** | 端到端可跑，改字段前后端同时报错 |
| 14 | 测试 | service 单测 + e2e |
| 15 | 工程化与部署 | CI 全绿 + Docker Compose 一键起 |
| 16 | 性能与收尾 | Lighthouse ≥ 90，P95 < 200ms |

---

## 书单（微信读书可读）

| # | 书 | 用途 |
|:---:|---|---|
| 1 | [JavaScript高级程序设计（第5版）](https://weread.qq.com/web/reader/16632270813abb1d0g019ba0) | 语言地基 |
| 2 | [CSS世界](https://yd.qq.com/web/reader/00932ab0715a41e90093ab5) | 布局与盒模型 |
| 3 | [深入理解TypeScript](https://weread.qq.com/web/reader/6393276071bc6e966392234) | 类型系统 |
| 4 | [剑指Vue3——从入门到实践](https://weread.qq.com/web/reader/97332900813ab8fc1g013114) | 前端上手 |
| 5 | [Vue.js设计与实现](https://weread.qq.com/web/reader/c5c32170813ab7177g0181a9) | 前端原理 |
| 6 | [深入浅出Node.js](https://weread.qq.com/web/bookDetail/d1b32290718ff65fd1befcc) | Node 运行时 |
| 7 | [NestJS全栈开发解析](https://weread.qq.com/web/reader/a8c32ef0813ab966dg010e96) | 后端地图（深度靠[官方文档](https://docs.nestjs.com)补） |

> 配套与选读书目见 [docs/16-week-plan.md](docs/16-week-plan.md) 第 1 节。

---

## 进度

- [ ] 第 1 周 · 环境 + JS 基础
- [ ] 第 2 周 · 原型链与异步
- [ ] 第 3 周 · CSS 布局
- [ ] 第 4 周 · TypeScript 基础
- [ ] 第 5 周 · TS 进阶 + Vue3 起步
- [ ] 第 6 周 · 组件化
- [ ] 第 7 周 · 路由、状态与权限
- [ ] 第 8 周 · Vue 响应式原理
- [ ] 第 9 周 · Node.js 运行时
- [ ] 第 10 周 · NestJS 基础
- [ ] 第 11 周 · NestJS 鉴权与切面
- [ ] 第 12 周 · 数据库与 ORM
- [ ] 第 13 周 · 全栈打通 + 类型共享
- [ ] 第 14 周 · 测试
- [ ] 第 15 周 · 工程化与部署
- [ ] 第 16 周 · 性能与收尾

---

## 怎么用

1. 先读 [docs/16-week-plan.md](docs/16-week-plan.md) 的第 0 节，搞清楚边界
2. 每周只看当周那一节，别提前翻
3. 周末对照验收清单逐条打勾，过了才进下一周
4. 每周在 README 勾掉一行进度，打一个 git tag

**贯穿项目**：全栈 TS 的「设备工单系统」（Vue3 + NestJS + Prisma），单独立仓，不放在这里。
