class AppCopy {
  static const appTitle = '企业基础信息管理平台';

  static const brandName = 'Enterprise Admin';
  static const brandSubtitle = '企业基础信息管理平台';
  static const navigationSectionTitle = '导航菜单';
  static const menuTooltip = '打开菜单';
  static const logoutTooltip = '退出登录';
  static const breadcrumbRoot = '控制台';
  static const breadcrumbHome = '首页';

  static const dashboardLabel = '仪表盘';
  static const employeesLabel = '员工管理';
  static const departmentsLabel = '部门管理';
  static const positionsLabel = '岗位管理';
  static const usersLabel = '用户管理';
  static const rolesLabel = '角色权限';

  static const loginHeroBadge = 'Enterprise Admin Suite';
  static const loginHeroTitle = '企业基础信息管理平台';
  static const loginHeroDescription =
      '围绕员工、部门、岗位与账号权限构建统一后台，先打通组织管理与权限基础，再逐步扩展导出、图表和更多业务能力。';
  static const loginFeatureWebDesktop = '支持 Web / Windows';
  static const loginFeatureAuth = 'JWT 登录与权限控制';
  static const loginFeatureCrud = '员工基础 CRUD';
  static const loginFeatureAnalytics = '支持统计图表与导出';
  static const loginMetricStageLabel = '当前阶段';
  static const loginMetricStageValue = '可运行预览';
  static const loginMetricBackendLabel = '默认后端';
  static const loginMetricBackendValue = 'FastAPI + SQLite';
  static const loginMetricAccountLabel = '默认账号';
  static const loginMetricAccountValue = 'admin';
  static const loginWelcomeTitle = '欢迎回来';
  static const loginWelcomeSubtitle = '输入账号和密码，进入企业管理后台。';
  static const loginUsernameLabel = '账号';
  static const loginPasswordLabel = '密码';
  static const loginUsernameRequired = '请输入账号';
  static const loginPasswordRequired = '请输入密码';
  static const loginPreviewTitle = '预览账号';
  static const loginPreviewContent = '用户名：admin\n密码：123456';
  static const loginSubmit = '登录系统';

  static const dashboardDefaultUserName = '系统管理员';
  static const dashboardLatestHiresTitle = '最新入职员工';
  static const dashboardLatestHiresSubtitle = '最近 5 条入职记录';
  static const dashboardOverviewTitle = '本月总览';
  static const dashboardTotalEmployeesTitle = '总员工数';
  static const dashboardTotalEmployeesNote = '当前系统内全部有效员工';
  static const dashboardMonthHiresTitle = '本月入职';
  static const dashboardMonthHiresNote = '本月新增员工数量';
  static const dashboardMonthLeavesTitle = '本月离职';
  static const dashboardMonthLeavesNote = '本月离职员工数量';
  static const dashboardAverageHeadcountTitle = '平均编制';
  static const dashboardAverageHeadcountNote = '按启用部门估算的人均规模';
  static const dashboardDepartmentChartTitle = '各部门人数分布';
  static const dashboardDepartmentChartSubtitle = '按有效员工统计部门人员规模';
  static const dashboardPositionChartTitle = '岗位占比';
  static const dashboardPositionChartSubtitle = '当前岗位结构分布';

  static String dashboardOverviewHires(int hires) => '$hires 人入职';

  static String dashboardOverviewLeaves(int leaves) => '离职 $leaves 人';

  static String dashboardGreeting(String userName) => '早上好，$userName';

  static String dashboardHeroDescription(int joinDays) =>
      '今天是你加入企业的第 $joinDays 天。组织数据已经汇总完成，你可以在这里快速查看人员规模、岗位分布和最新入职情况。';

  const AppCopy._();
}
