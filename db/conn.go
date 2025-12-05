package db

import (
	"database/sql"
	"fmt"
	"os"

	_ "github.com/lib/pq"
	"github.com/llr104/slgserver/config"
	"xorm.io/xorm"
	"xorm.io/xorm/log"
)

var MasterDB *xorm.Engine

var dns string

// TestDB 测试数据库
func TestDB() error {
	mysqlConfig, err := config.File.GetSection("postgres")
	if err != nil {
		fmt.Println("get mysql config error:", err)
		panic(err)
	}

	//tmpDns := fmt.Sprintf("%s:%s@tcp(%s:%s)/?charset=%s&parseTime=True&loc=Local",
	//	mysqlConfig["user"],
	//	mysqlConfig["password"],
	//	mysqlConfig["host"],
	//	mysqlConfig["port"],
	//	mysqlConfig["charset"])
	dsn := fmt.Sprintf("user=%s password=%s host=%s port=%s dbname=%s sslmode=%s",
		mysqlConfig["user"], mysqlConfig["password"], mysqlConfig["host"], mysqlConfig["port"], "slgdb", "disable")
	egnine, err := xorm.NewEngine("postgres", dsn)
	if err != nil {
		fmt.Println("new engine error:", err)
		panic(err)
	}
	defer egnine.Close()

	// 测试数据库连接是否 OK
	if err = egnine.Ping(); err != nil {
		fmt.Println("ping db error:", err)
		panic(err)
	}

	//_, err = egnine.Exec("\c " + mysqlConfig["dbname"])
	//if err != nil {
	//	fmt.Println("use db error:", err)
	//	_, err = egnine.Exec("CREATE DATABASE " + mysqlConfig["dbname"] + " DEFAULT CHARACTER SET " + mysqlConfig["charset"])
	//	if err != nil {
	//		fmt.Println("create database error:", err)
	//		panic(err)
	//	}
	//
	//	fmt.Println("create database successfully!")
	//}

	// 初始化 MasterDB
	return Init()
}

func Init() error {
	mysqlConfig, err := config.File.GetSection("postgres")
	if err != nil {
		fmt.Println("get mysql config error:", err)
		return err
	}

	// 启动时就打开数据库连接
	if err = initEngine(mysqlConfig); err != nil {
		fmt.Println("mysql is not open:", err)
		return err
	}

	return nil
}

func fillDns(mysqlConfig map[string]string) string {
	dsn := fmt.Sprintf("user=%s password=%s host=%s port=%s dbname=%s sslmode=%s",
		mysqlConfig["user"], mysqlConfig["password"], mysqlConfig["host"], mysqlConfig["port"], "slgdb", "disable")
	//return fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=%s&parseTime=True&loc=Local",
	//	mysqlConfig["user"],
	//	mysqlConfig["password"],
	//	mysqlConfig["host"],
	//	mysqlConfig["port"],
	//	mysqlConfig["dbname"],
	//	mysqlConfig["charset"])
	return dsn
}

func initEngine(mysqlConfig map[string]string) error {

	var err error
	dns := fillDns(mysqlConfig)

	MasterDB, err = xorm.NewEngine("postgres", dns)
	if err != nil {
		return err
	}

	maxIdle := config.File.MustInt("postgres", "max_idle", 2)
	maxConn := config.File.MustInt("postgres", "max_conn", 10)

	MasterDB.SetMaxIdleConns(maxIdle)
	MasterDB.SetMaxOpenConns(maxConn)

	showSQL := config.File.MustBool("xorm", "show_sql", false)
	logLevel := config.File.MustInt("xorm", "log_level", 1)
	logFile := config.File.MustValue("xorm", "log_file", "")

	if logFile != "" {
		f, _ := os.Create(logFile)
		MasterDB.SetLogger(log.NewSimpleLogger(f))
	}

	MasterDB.SetLogLevel(log.LogLevel(logLevel))
	MasterDB.ShowSQL(showSQL)

	return nil
}

func StdMasterDB() *sql.DB {
	return MasterDB.DB().DB
}
