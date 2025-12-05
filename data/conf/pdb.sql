-- ----------------------------------------------------------------------
-- MySQL 语法转换说明：
-- 1. AUTO_INCREMENT 替换为 SERIAL PRIMARY KEY (PostgreSQL 自增主键)
-- 2. INT UNSIGNED, TINYINT UNSIGNED 替换为 INTEGER, SMALLINT (PostgreSQL 无原生 UNSIGNED)
-- 3. 反引号 (`) 移除或替换为双引号 (")
-- 4. ON UPDATE CURRENT_TIMESTAMP 移除 (PostgreSQL 需要通过触发器实现，此处简化为创建时间)
-- 5. ENGINE/CHARSET 语句已移除
-- 6. MySQL 的行内 COMMENT 转换为 PostgreSQL 的 COMMENT ON COLUMN/TABLE 语句
-- ----------------------------------------------------------------------

-- 注意: PostgreSQL 习惯上要求先连接到数据库 slgdb 才能执行以下语句。

-- ===================================
-- 核心表结构创建
-- ===================================

CREATE TABLE IF NOT EXISTS tb_user_info (
                                            uid SERIAL PRIMARY KEY,
                                            username VARCHAR(20) NOT NULL,
    passcode CHAR(12) NOT NULL DEFAULT '',
    passwd CHAR(64) NOT NULL DEFAULT '',
    status SMALLINT NOT NULL DEFAULT 0,
    hardware VARCHAR(64) NOT NULL DEFAULT '',
    ctime TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT '2013-03-15 14:38:09',
    -- 注意: ON UPDATE CURRENT_TIMESTAMP 逻辑在 PostgreSQL 中需要通过触发器实现。
    -- 此处仅保留 DEFAULT NOW() 作为创建或最后一次更新的时间。
    mtime TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE (username)
    );

CREATE TABLE IF NOT EXISTS tb_login_history (
                                                id SERIAL PRIMARY KEY,
                                                uid INTEGER NOT NULL DEFAULT 0,
                                                state SMALLINT NOT NULL DEFAULT 0,
    -- 注意: ON UPDATE CURRENT_TIMESTAMP 逻辑在 PostgreSQL 中需要通过触发器实现。
                                                ctime TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    ip VARCHAR(31) NOT NULL DEFAULT '',
    hardware VARCHAR(64) NOT NULL DEFAULT ''
    );

CREATE TABLE IF NOT EXISTS tb_login_last (
                                             id SERIAL PRIMARY KEY,
                                             uid INTEGER NOT NULL DEFAULT 0,
                                             login_time TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL,
                                             logout_time TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL,
                                             ip VARCHAR(31) NOT NULL DEFAULT '',
    is_logout SMALLINT NOT NULL DEFAULT 0,
    session VARCHAR(100),
    hardware VARCHAR(64) NOT NULL DEFAULT '',
    UNIQUE (uid)
    );

CREATE TABLE IF NOT EXISTS tb_role_1 (
                                         rid SERIAL PRIMARY KEY,
                                         uid INTEGER NOT NULL,
                                         "headId" INTEGER NOT NULL DEFAULT 0, -- 双引号用于保留混合大小写或非标准名称
                                         sex SMALLINT NOT NULL DEFAULT 0,
                                         nick_name VARCHAR(100),
    balance INTEGER NOT NULL DEFAULT 0,
    login_time TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL,
    logout_time TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL,
    profile VARCHAR(500),
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (uid, nick_name)
    );

CREATE TABLE IF NOT EXISTS tb_map_role_city_1 (
                                                  "cityId" SERIAL PRIMARY KEY,
                                                  rid INTEGER NOT NULL,
                                                  x INTEGER NOT NULL,
                                                  y INTEGER NOT NULL,
                                                  name VARCHAR(100) NOT NULL DEFAULT '城池',
    is_main SMALLINT NOT NULL DEFAULT 0,
    cur_durable INTEGER NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    occupy_time TIMESTAMP WITHOUT TIME ZONE DEFAULT '2013-03-15 14:38:09'
    );

CREATE TABLE IF NOT EXISTS tb_map_role_build_1 (
                                                   id SERIAL PRIMARY KEY,
                                                   rid INTEGER NOT NULL,
                                                   type INTEGER NOT NULL,
                                                   level SMALLINT NOT NULL,
                                                   op_level SMALLINT,
                                                   x INTEGER NOT NULL,
                                                   y INTEGER NOT NULL,
                                                   name VARCHAR(100) NOT NULL,
    max_durable INTEGER NOT NULL,
    cur_durable INTEGER NOT NULL,
    end_time TIMESTAMP WITHOUT TIME ZONE DEFAULT '2013-03-15 14:38:09',
    occupy_time TIMESTAMP WITHOUT TIME ZONE DEFAULT '2013-03-15 14:38:09',
    "giveUp_time" INTEGER DEFAULT 0
    );

CREATE TABLE IF NOT EXISTS tb_city_facility_1 (
                                                  id SERIAL PRIMARY KEY,
                                                  "cityId" INTEGER NOT NULL,
                                                  rid INTEGER NOT NULL,
                                                  facilities VARCHAR(4096) NOT NULL,
    UNIQUE ("cityId")
    );

CREATE TABLE IF NOT EXISTS tb_role_res_1 (
                                             id SERIAL PRIMARY KEY,
                                             rid INTEGER NOT NULL,
                                             wood INTEGER NOT NULL,
                                             iron INTEGER NOT NULL,
                                             stone INTEGER NOT NULL,
                                             grain INTEGER NOT NULL,
                                             gold INTEGER NOT NULL,
                                             decree INTEGER NOT NULL,
                                             UNIQUE (rid)
    );

CREATE TABLE IF NOT EXISTS tb_general_1 (
                                            id SERIAL PRIMARY KEY,
                                            rid INTEGER NOT NULL,
                                            "cfgId" INTEGER NOT NULL,
                                            physical_power INTEGER NOT NULL,
                                            exp INTEGER NOT NULL,
                                            "order" SMALLINT NOT NULL, -- "order" 是 SQL 关键字，用双引号引用
                                            level SMALLINT NOT NULL DEFAULT 1,
                                            "cityId" INTEGER NOT NULL DEFAULT 0,
                                            star INTEGER NOT NULL DEFAULT 0,
                                            star_lv INTEGER NOT NULL DEFAULT 0,
                                            arms INTEGER NOT NULL DEFAULT 0,
                                            has_pr_point INTEGER NOT NULL DEFAULT 0,
                                            use_pr_point INTEGER NOT NULL DEFAULT 0,
                                            attack_distance INTEGER NOT NULL DEFAULT 0,
                                            force_added INTEGER NOT NULL DEFAULT 0,
                                            strategy_added INTEGER NOT NULL DEFAULT 0,
                                            defense_added INTEGER NOT NULL DEFAULT 0,
                                            speed_added INTEGER NOT NULL DEFAULT 0,
                                            destroy_added INTEGER NOT NULL DEFAULT 0,
                                            "parentId" INTEGER NOT NULL DEFAULT 0,
                                            compose_type INTEGER NOT NULL DEFAULT 0,
                                            skills VARCHAR(64) NOT NULL DEFAULT '[0, 0, 0]',
    state SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
    );

CREATE TABLE IF NOT EXISTS tb_army_1 (
                                         id SERIAL PRIMARY KEY,
                                         rid INTEGER NOT NULL,
                                         "cityId" INTEGER NOT NULL,
                                         "order" SMALLINT NOT NULL DEFAULT 0,
                                         generals VARCHAR(256) NOT NULL DEFAULT '[0, 0, 0]',
    soldiers VARCHAR(256) NOT NULL DEFAULT '[0, 0, 0]',
    conscript_times VARCHAR(256) NOT NULL DEFAULT '[0, 0, 0]',
    conscript_cnts VARCHAR(256) NOT NULL DEFAULT '[0, 0, 0]',
    cmd SMALLINT NOT NULL DEFAULT 0,
    from_x INTEGER NOT NULL,
    from_y INTEGER NOT NULL,
    to_x INTEGER,
    to_y INTEGER,
    start TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL,
    "end" TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL, -- "end" 是 SQL 关键字，用双引号引用
    UNIQUE (rid, "cityId", "order")
    );

CREATE TABLE IF NOT EXISTS tb_war_report_1 (
                                               id SERIAL PRIMARY KEY,
                                               a_rid INTEGER NOT NULL,
                                               d_rid INTEGER NOT NULL DEFAULT 0,
                                               b_a_army VARCHAR(512) NOT NULL,
    b_d_army VARCHAR(512) NOT NULL,
    e_a_army VARCHAR(512) NOT NULL,
    e_d_army VARCHAR(512) NOT NULL,
    b_a_general VARCHAR(512) NOT NULL,
    b_d_general VARCHAR(512) NOT NULL,
    e_a_general VARCHAR(512) NOT NULL,
    e_d_general VARCHAR(512) NOT NULL,
    rounds VARCHAR(10240) NOT NULL,
    result SMALLINT NOT NULL DEFAULT 0,
    a_is_read SMALLINT NOT NULL DEFAULT 0,
    d_is_read SMALLINT NOT NULL DEFAULT 0,
    destroy INTEGER,
    occupy SMALLINT NOT NULL DEFAULT 0,
    x INTEGER,
    y INTEGER,
    -- 注意: ON UPDATE CURRENT_TIMESTAMP 逻辑在 PostgreSQL 中需要通过触发器实现。
    ctime TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
    );

CREATE TABLE IF NOT EXISTS tb_coalition_1 (
                                              id SERIAL PRIMARY KEY,
                                              name VARCHAR(20) NOT NULL,
    members VARCHAR(2048) NOT NULL,
    create_id INTEGER NOT NULL,
    chairman INTEGER NOT NULL,
    vice_chairman INTEGER NOT NULL,
    notice VARCHAR(256),
    state SMALLINT NOT NULL DEFAULT 1,
    -- 注意: ON UPDATE CURRENT_TIMESTAMP 逻辑在 PostgreSQL 中需要通过触发器实现。
    ctime TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE (name)
    );

CREATE TABLE IF NOT EXISTS tb_coalition_apply_1 (
                                                    id SERIAL PRIMARY KEY,
                                                    union_id INTEGER NOT NULL,
                                                    rid INTEGER NOT NULL,
                                                    state SMALLINT NOT NULL DEFAULT 0,
    -- 注意: ON UPDATE CURRENT_TIMESTAMP 逻辑在 PostgreSQL 中需要通过触发器实现。
                                                    ctime TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
    );

CREATE TABLE IF NOT EXISTS tb_role_attribute_1 (
                                                   id SERIAL PRIMARY KEY,
                                                   rid INTEGER NOT NULL,
                                                   parent_id SMALLINT NOT NULL DEFAULT 0,
                                                   collect_times SMALLINT NOT NULL DEFAULT 0,
                                                   last_collect_time TIMESTAMP WITHOUT TIME ZONE DEFAULT '2013-03-15 14:38:09',
                                                   pos_tags VARCHAR(512)
    );

CREATE TABLE IF NOT EXISTS tb_coalition_log_1 (
                                                  id SERIAL PRIMARY KEY,
                                                  union_id INTEGER NOT NULL,
                                                  op_rid INTEGER NOT NULL,
                                                  target_id INTEGER,
                                                  des VARCHAR(256) NOT NULL,
    state SMALLINT NOT NULL,
    -- 注意: ON UPDATE CURRENT_TIMESTAMP 逻辑在 PostgreSQL 中需要通过触发器实现。
    ctime TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
    );

CREATE TABLE IF NOT EXISTS tb_skill_1 (
                                          id SERIAL PRIMARY KEY,
                                          rid INTEGER NOT NULL,
                                          "cfgId" INTEGER NOT NULL,
                                          belong_generals VARCHAR(256) NOT NULL DEFAULT '[]',
    -- 注意: ON UPDATE CURRENT_TIMESTAMP 逻辑在 PostgreSQL 中需要通过触发器实现。
    ctime TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
    );

-- ===================================
-- 添加注释 (COMMENT ON)
-- ===================================

COMMENT ON TABLE tb_user_info IS '用户信息表';
COMMENT ON COLUMN tb_user_info.uid IS '用户ID';
COMMENT ON COLUMN tb_user_info.username IS '用户名';
COMMENT ON COLUMN tb_user_info.passcode IS '加密随机数';
COMMENT ON COLUMN tb_user_info.passwd IS 'md5密码';
COMMENT ON COLUMN tb_user_info.status IS '用户账号状态。0-默认；1-冻结；2-停号';
COMMENT ON COLUMN tb_user_info.hardware IS 'hardware';

COMMENT ON TABLE tb_login_history IS '用户登录表';
COMMENT ON COLUMN tb_login_history.uid IS '用户UID';
COMMENT ON COLUMN tb_login_history.state IS '登录状态，0登录，1登出';
COMMENT ON COLUMN tb_login_history.ctime IS '登录时间';
COMMENT ON COLUMN tb_login_history.ip IS 'ip';
COMMENT ON COLUMN tb_login_history.hardware IS 'hardware';

COMMENT ON TABLE tb_login_last IS '最后一次用户登录表';
COMMENT ON COLUMN tb_login_last.uid IS '用户UID';
COMMENT ON COLUMN tb_login_last.login_time IS '登录时间';
COMMENT ON COLUMN tb_login_last.logout_time IS '登出时间';
COMMENT ON COLUMN tb_login_last.ip IS 'ip';
COMMENT ON COLUMN tb_login_last.is_logout IS '是否logout,1:logout，0:login';
COMMENT ON COLUMN tb_login_last.session IS '会话';
COMMENT ON COLUMN tb_login_last.hardware IS 'hardware';

COMMENT ON TABLE tb_role_1 IS '玩家表';
COMMENT ON COLUMN tb_role_1.rid IS 'roleId';
COMMENT ON COLUMN tb_role_1.uid IS '用户UID';
COMMENT ON COLUMN tb_role_1."headId" IS '头像Id';
COMMENT ON COLUMN tb_role_1.sex IS '性别，0:女 1男';
COMMENT ON COLUMN tb_role_1.nick_name IS 'nick_name';
COMMENT ON COLUMN tb_role_1.balance IS '余额';
COMMENT ON COLUMN tb_role_1.login_time IS '登录时间';
COMMENT ON COLUMN tb_role_1.logout_time IS '登出时间';
COMMENT ON COLUMN tb_role_1.profile IS '个人简介';

COMMENT ON TABLE tb_map_role_city_1 IS '玩家城池';
COMMENT ON COLUMN tb_map_role_city_1."cityId" IS 'cityId';
COMMENT ON COLUMN tb_map_role_city_1.rid IS 'roleId';
COMMENT ON COLUMN tb_map_role_city_1.x IS 'x坐标';
COMMENT ON COLUMN tb_map_role_city_1.y IS 'y坐标';
COMMENT ON COLUMN tb_map_role_city_1.name IS '城池名称';
COMMENT ON COLUMN tb_map_role_city_1.is_main IS '是否是主城';
COMMENT ON COLUMN tb_map_role_city_1.cur_durable IS '当前耐久';
COMMENT ON COLUMN tb_map_role_city_1.occupy_time IS '占领时间';

COMMENT ON TABLE tb_map_role_build_1 IS '角色建筑';
COMMENT ON COLUMN tb_map_role_build_1.id IS 'id';
COMMENT ON COLUMN tb_map_role_build_1.type IS '建筑类型';
COMMENT ON COLUMN tb_map_role_build_1.level IS '建筑等级';
COMMENT ON COLUMN tb_map_role_build_1.op_level IS '建筑操作等级';
COMMENT ON COLUMN tb_map_role_build_1.x IS 'x坐标';
COMMENT ON COLUMN tb_map_role_build_1.y IS 'y坐标';
COMMENT ON COLUMN tb_map_role_build_1.name IS '名称';
COMMENT ON COLUMN tb_map_role_build_1.max_durable IS '最大耐久';
COMMENT ON COLUMN tb_map_role_build_1.cur_durable IS '当前耐久';
COMMENT ON COLUMN tb_map_role_build_1.end_time IS '建造、升级、拆除结束时间';
COMMENT ON COLUMN tb_map_role_build_1.occupy_time IS '占领时间';
COMMENT ON COLUMN tb_map_role_build_1."giveUp_time" IS '放弃时间';

COMMENT ON TABLE tb_city_facility_1 IS '城池设施';
COMMENT ON COLUMN tb_city_facility_1."cityId" IS '城市id';
COMMENT ON COLUMN tb_city_facility_1.facilities IS '设施列表，格式为json结构';

COMMENT ON TABLE tb_role_res_1 IS '角色资源表';
COMMENT ON COLUMN tb_role_res_1.id IS 'id';
COMMENT ON COLUMN tb_role_res_1.rid IS 'rid';
COMMENT ON COLUMN tb_role_res_1.wood IS '木';
COMMENT ON COLUMN tb_role_res_1.iron IS '铁';
COMMENT ON COLUMN tb_role_res_1.stone IS '石头';
COMMENT ON COLUMN tb_role_res_1.grain IS '粮食';
COMMENT ON COLUMN tb_role_res_1.gold IS '金币';
COMMENT ON COLUMN tb_role_res_1.decree IS '令牌';

COMMENT ON TABLE tb_general_1 IS '将领表';
COMMENT ON COLUMN tb_general_1.id IS 'id';
COMMENT ON COLUMN tb_general_1.rid IS 'rid';
COMMENT ON COLUMN tb_general_1."cfgId" IS '配置id';
COMMENT ON COLUMN tb_general_1.physical_power IS '体力';
COMMENT ON COLUMN tb_general_1.exp IS '经验';
COMMENT ON COLUMN tb_general_1."order" IS '第几队';
COMMENT ON COLUMN tb_general_1.level IS 'level';
COMMENT ON COLUMN tb_general_1."cityId" IS '城市id';
COMMENT ON COLUMN tb_general_1.star IS '稀有度(星级)';
COMMENT ON COLUMN tb_general_1.star_lv IS '稀有度(星级)进阶等级级';
COMMENT ON COLUMN tb_general_1.arms IS '兵种';
COMMENT ON COLUMN tb_general_1.has_pr_point IS '总属性点';
COMMENT ON COLUMN tb_general_1.use_pr_point IS '已用属性点';
COMMENT ON COLUMN tb_general_1.attack_distance IS '攻击距离';
COMMENT ON COLUMN tb_general_1.force_added IS '已加攻击属性';
COMMENT ON COLUMN tb_general_1.strategy_added IS '已加战略属性';
COMMENT ON COLUMN tb_general_1.defense_added IS '已加防御属性';
COMMENT ON COLUMN tb_general_1.speed_added IS '已加速度属性';
COMMENT ON COLUMN tb_general_1.destroy_added IS '已加破坏属性';
COMMENT ON COLUMN tb_general_1."parentId" IS '已合成到武将的id';
COMMENT ON COLUMN tb_general_1.compose_type IS '合成类型';
COMMENT ON COLUMN tb_general_1.skills IS '携带的技能';
COMMENT ON COLUMN tb_general_1.state IS '0:正常，1:转换掉了';

COMMENT ON TABLE tb_army_1 IS '军队表';
COMMENT ON COLUMN tb_army_1.id IS 'id';
COMMENT ON COLUMN tb_army_1.rid IS 'rid';
COMMENT ON COLUMN tb_army_1."cityId" IS '城市id';
COMMENT ON COLUMN tb_army_1."order" IS '第几队 1-5队';
COMMENT ON COLUMN tb_army_1.generals IS '将领';
COMMENT ON COLUMN tb_army_1.soldiers IS '士兵';
COMMENT ON COLUMN tb_army_1.conscript_times IS '征兵结束时间';
COMMENT ON COLUMN tb_army_1.conscript_cnts IS '征兵数量';
COMMENT ON COLUMN tb_army_1.cmd IS '命令  0:空闲 1:攻击 2：驻军 3:返回';
COMMENT ON COLUMN tb_army_1.from_x IS '来自x坐标';
COMMENT ON COLUMN tb_army_1.from_y IS '来自y坐标';
COMMENT ON COLUMN tb_army_1.to_x IS '去往x坐标';
COMMENT ON COLUMN tb_army_1.to_y IS '去往y坐标';
COMMENT ON COLUMN tb_army_1.start IS '出发时间';
COMMENT ON COLUMN tb_army_1."end" IS '到达时间';

COMMENT ON TABLE tb_war_report_1 IS '战报表';
COMMENT ON COLUMN tb_war_report_1.id IS 'id';
COMMENT ON COLUMN tb_war_report_1.a_rid IS '攻击方id';
COMMENT ON COLUMN tb_war_report_1.d_rid IS '防守方id,0为系统npc';
COMMENT ON COLUMN tb_war_report_1.b_a_army IS '开始攻击方军队';
COMMENT ON COLUMN tb_war_report_1.b_d_army IS '开始防守方军队';
COMMENT ON COLUMN tb_war_report_1.e_a_army IS '开始攻击方军队';
COMMENT ON COLUMN tb_war_report_1.e_d_army IS '开始防守方军队';
COMMENT ON COLUMN tb_war_report_1.b_a_general IS '开始攻击方武将';
COMMENT ON COLUMN tb_war_report_1.b_d_general IS '开始防守方武将';
COMMENT ON COLUMN tb_war_report_1.e_a_general IS '结束攻击方武将';
COMMENT ON COLUMN tb_war_report_1.e_d_general IS '结束防守方武将';
COMMENT ON COLUMN tb_war_report_1.rounds IS '回合战报数据';
COMMENT ON COLUMN tb_war_report_1.result IS '0失败，1打平，2胜利';
COMMENT ON COLUMN tb_war_report_1.a_is_read IS '攻击方战报是否已阅 0:未阅 1:已阅';
COMMENT ON COLUMN tb_war_report_1.d_is_read IS '攻击方战报是否已阅 0:未阅 1:已阅';
COMMENT ON COLUMN tb_war_report_1.destroy IS '破坏了多少耐久';
COMMENT ON COLUMN tb_war_report_1.occupy IS '是否攻占 0:否 1:是';
COMMENT ON COLUMN tb_war_report_1.x IS 'x坐标';
COMMENT ON COLUMN tb_war_report_1.y IS 'y坐标';
COMMENT ON COLUMN tb_war_report_1.ctime IS '发生时间';

COMMENT ON TABLE tb_coalition_1 IS '联盟';
COMMENT ON COLUMN tb_coalition_1.id IS 'id';
COMMENT ON COLUMN tb_coalition_1.name IS '联盟名字';
COMMENT ON COLUMN tb_coalition_1.members IS '成员';
COMMENT ON COLUMN tb_coalition_1.create_id IS '创建者id';
COMMENT ON COLUMN tb_coalition_1.chairman IS '盟主';
COMMENT ON COLUMN tb_coalition_1.vice_chairman IS '副盟主';
COMMENT ON COLUMN tb_coalition_1.notice IS '公告';
COMMENT ON COLUMN tb_coalition_1.state IS '0解散，1运行中';
COMMENT ON COLUMN tb_coalition_1.ctime IS '发生时间';

COMMENT ON TABLE tb_coalition_apply_1 IS '联盟申请表';
COMMENT ON COLUMN tb_coalition_apply_1.id IS 'id';
COMMENT ON COLUMN tb_coalition_apply_1.union_id IS '联盟id';
COMMENT ON COLUMN tb_coalition_apply_1.rid IS '申请者的rid';
COMMENT ON COLUMN tb_coalition_apply_1.state IS '申请状态，0未处理，1拒绝，2通过';
COMMENT ON COLUMN tb_coalition_apply_1.ctime IS '发生时间';

COMMENT ON TABLE tb_role_attribute_1 IS '玩家属性表';
COMMENT ON COLUMN tb_role_attribute_1.id IS 'id';
COMMENT ON COLUMN tb_role_attribute_1.rid IS 'rid';
COMMENT ON COLUMN tb_role_attribute_1.parent_id IS '上级联盟id';
COMMENT ON COLUMN tb_role_attribute_1.collect_times IS '征收次数';
COMMENT ON COLUMN tb_role_attribute_1.last_collect_time IS '最后征收时间';
COMMENT ON COLUMN tb_role_attribute_1.pos_tags IS '收藏的位置';

COMMENT ON TABLE tb_coalition_log_1 IS '联盟日志表';
COMMENT ON COLUMN tb_coalition_log_1.id IS 'id';
COMMENT ON COLUMN tb_coalition_log_1.union_id IS '联盟id';
COMMENT ON COLUMN tb_coalition_log_1.op_rid IS '操作者id';
COMMENT ON COLUMN tb_coalition_log_1.target_id IS '被操作的对象';
COMMENT ON COLUMN tb_coalition_log_1.des IS '描述';
COMMENT ON COLUMN tb_coalition_log_1.state IS '0:创建,1:解散,2:加入,3:退出,4:踢出,5:任命,6:禅让,7:修改公告';
COMMENT ON COLUMN tb_coalition_log_1.ctime IS '发生时间';

COMMENT ON TABLE tb_skill_1 IS '技能表';
COMMENT ON COLUMN tb_skill_1.id IS 'id';
COMMENT ON COLUMN tb_skill_1.rid IS 'rid';
COMMENT ON COLUMN tb_skill_1."cfgId" IS '技能id';
COMMENT ON COLUMN tb_skill_1.belong_generals IS '归属武将数组';
COMMENT ON COLUMN tb_skill_1.ctime IS '获得技能时间';