package run

import (
	"github.com/fan785396456/slgserver/config"
	"github.com/fan785396456/slgserver/db"
	"github.com/fan785396456/slgserver/net"
	"github.com/fan785396456/slgserver/server/slgserver/controller"
	"github.com/fan785396456/slgserver/server/slgserver/logic"
	"github.com/fan785396456/slgserver/server/slgserver/logic/mgr"
	"github.com/fan785396456/slgserver/server/slgserver/model"
	"github.com/fan785396456/slgserver/server/slgserver/static_conf"
	"github.com/fan785396456/slgserver/server/slgserver/static_conf/facility"
	"github.com/fan785396456/slgserver/server/slgserver/static_conf/general"
	"github.com/fan785396456/slgserver/server/slgserver/static_conf/npc"
	"github.com/fan785396456/slgserver/server/slgserver/static_conf/skill"
)

var MyRouter = &net.Router{}

func Init() {
	db.TestDB()

	static_conf.Basic.Load()
	static_conf.MapBuildConf.Load()
	static_conf.MapBCConf.Load()

	facility.FConf.Load()
	general.GenBasic.Load()
	skill.Skill.Load()
	general.General.Load()
	npc.Cfg.Load()

	serverId := config.File.MustInt("logic", "server_id", 1)
	model.ServerId = serverId

	logic.BeforeInit()

	mgr.NMMgr.Load()
	//需要先加载联盟相关的信息
	mgr.UnionMgr.Load()
	mgr.RAttrMgr.Load()
	mgr.RCMgr.Load()
	mgr.RBMgr.Load()
	mgr.RFMgr.Load()
	mgr.RResMgr.Load()
	mgr.SkillMgr.Load()
	mgr.GMgr.Load()
	mgr.AMgr.Load()
	logic.Init()
	logic.AfterInit()

	//全部初始化完才注册路由，防止服务器还没启动就绪收到请求
	initRouter()
}

func initRouter() {

	controller.DefaultRole.InitRouter(MyRouter)
	controller.DefaultMap.InitRouter(MyRouter)
	controller.DefaultCity.InitRouter(MyRouter)
	controller.DefaultGeneral.InitRouter(MyRouter)
	controller.DefaultArmy.InitRouter(MyRouter)
	controller.DefaultWar.InitRouter(MyRouter)
	controller.DefaultCoalition.InitRouter(MyRouter)
	controller.DefaultInterior.InitRouter(MyRouter)
	controller.DefaultSkill.InitRouter(MyRouter)
}
